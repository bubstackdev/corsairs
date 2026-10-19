//! Owned packed-image values backed by Corsairs-created CVPixelBuffers.
//!
//! Every Swift lowering here is taken from experiments/swift/ImageReference.swift's
//! emitted IR (docs/image-io.md). CoreVideo's C API is plain C: its prototypes
//! are the SDK headers', and every symbol is checked by name in CoreVideo.tbd.
use super::{Metadata, NativeFailure, NativeMetadata, NativeSession, NativeValue, Result, arm64};
use crate::native::loader::Library;
use std::collections::HashSet;
use std::ffi::{CStr, c_void};
use std::mem;
use std::ptr::{self, NonNull};
use std::rc::Rc;

/// CoreVideo OSTypes of the packed formats verified end to end.
pub const RGB24: u32 = 0x0000_0018;
pub const ARGB32: u32 = 0x0000_0020;
pub const BGRA32: u32 = u32::from_be_bytes(*b"BGRA");

/// Bytes per pixel of a verified packed format; None for every other OSType,
/// including 4:2:0 planar, which traps Core AI rather than throwing.
pub const fn bytes_per_pixel(pixel_format: u32) -> Option<usize> {
    match pixel_format {
        RGB24 => Some(3),
        ARGB32 | BGRA32 => Some(4),
        _ => None,
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NativeImageDescriptor {
    pub name: String,
    pub width: usize,
    pub height: usize,
    /// The descriptor's raw CoreVideo OSType, which may be unsupported.
    pub pixel_format: u32,
}
/// A packed image in CoreVideo memory order. Rows start every `bytes_per_row`
/// bytes; `bytes` holds exactly `bytes_per_row * height` bytes.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NativeImage {
    pub pixel_format: u32,
    pub width: usize,
    pub height: usize,
    pub bytes_per_row: usize,
    pub bytes: Vec<u8>,
}

/// Checked tight row length and padded storage size of a packed image.
pub fn image_extent(
    pixel_format: u32,
    width: usize,
    height: usize,
    bytes_per_row: usize,
) -> std::result::Result<(usize, usize), String> {
    let bpp = bytes_per_pixel(pixel_format)
        .ok_or_else(|| format!("unsupported pixel format {}", four_cc(pixel_format)))?;
    if width == 0 || height == 0 {
        return Err("image width and height must be nonzero".into());
    }
    let row = width
        .checked_mul(bpp)
        .ok_or_else(|| "image row size overflows".to_owned())?;
    if bytes_per_row < row {
        return Err(format!(
            "bytes per row {bytes_per_row} is less than the {row}-byte pixel row"
        ));
    }
    let total = bytes_per_row
        .checked_mul(height)
        .filter(|total| *total <= crate::dtype::MAX_TENSOR_BYTES)
        .ok_or_else(|| "image storage exceeds the 4 GiB limit".to_owned())?;
    // CoreVideo and Core AI take Int dimensions.
    if isize::try_from(width).is_err() || isize::try_from(height).is_err() {
        return Err("image dimensions exceed Int".into());
    }
    Ok((row, total))
}

/// The extent of an unpadded image: (row bytes, total bytes).
pub fn tight_extent(
    pixel_format: u32,
    width: usize,
    height: usize,
) -> std::result::Result<(usize, usize), String> {
    let row = bytes_per_pixel(pixel_format)
        .and_then(|bpp| width.checked_mul(bpp))
        .unwrap_or(usize::MAX);
    image_extent(pixel_format, width, height, row)
}

/// Printable FourCC, or hex when any byte is not printable ASCII.
pub fn four_cc(value: u32) -> String {
    let bytes = value.to_be_bytes();
    if bytes.iter().all(|b| (0x20..0x7f).contains(b)) {
        format!("'{}'", String::from_utf8_lossy(&bytes))
    } else {
        format!("{value:#010x}")
    }
}

fn validate_image(image: &NativeImage) -> Result<()> {
    let (_, total) = image_extent(
        image.pixel_format,
        image.width,
        image.height,
        image.bytes_per_row,
    )
    .map_err(NativeFailure::InvalidData)?;
    if image.bytes.len() != total {
        return Err(NativeFailure::InvalidData(format!(
            "image storage is {} bytes; bytes per row x height is {total}",
            image.bytes.len()
        )));
    }
    Ok(())
}

pub(super) fn validate_images(
    images: &[(String, NativeImage)],
    descriptors: &[NativeImageDescriptor],
) -> Result<()> {
    let mut names = HashSet::new();
    for (name, image) in images {
        if name.contains('\0') || !names.insert(name) {
            return Err(NativeFailure::InvalidData(
                "duplicate or invalid image name".into(),
            ));
        }
        let descriptor = descriptors
            .iter()
            .find(|d| d.name == *name)
            .ok_or_else(|| NativeFailure::InvalidData(format!("unknown image name {name}")))?;
        validate_image(image)?;
        if (image.pixel_format, image.width, image.height)
            != (descriptor.pixel_format, descriptor.width, descriptor.height)
        {
            return Err(NativeFailure::InvalidData(format!(
                "image does not match descriptor {name}"
            )));
        }
    }
    if images.len() != descriptors.len() {
        return Err(NativeFailure::InvalidData("missing named images".into()));
    }
    Ok(())
}

/// Reject every image signature whose format is not a verified packed format,
/// before any CVPixelBuffer exists. This is the only defense against the
/// planar trap (`CoreAIRuntime/ImageUtils.swift:91`).
pub(super) fn supported_images<'a>(
    descriptors: impl IntoIterator<Item = &'a NativeImageDescriptor>,
) -> Result<()> {
    for d in descriptors {
        tight_extent(d.pixel_format, d.width, d.height)
            .map_err(|reason| NativeFailure::Unsupported(format!("image {}: {reason}", d.name)))?;
    }
    Ok(())
}

type Create =
    unsafe extern "C" fn(*const c_void, usize, usize, u32, *const c_void, *mut *mut c_void) -> i32;
type Lock = unsafe extern "C" fn(*mut c_void, u64) -> i32;
type Pointer = unsafe extern "C" fn(*mut c_void) -> *mut c_void;
type Word = unsafe extern "C" fn(*mut c_void) -> usize;
type Format = unsafe extern "C" fn(*mut c_void) -> u32;
type Flag = unsafe extern "C" fn(*mut c_void) -> u8;
type Release = unsafe extern "C" fn(*mut c_void);

const LOCK_READ_ONLY: u64 = 1;

/// CoreVideo entry points, resolved from CoreVideo.framework at its fixed path
/// rather than through CoreAI's dependency graph.
pub(super) struct CoreVideo {
    create: Create,
    lock: Lock,
    unlock: Lock,
    base_address: Pointer,
    bytes_per_row: Word,
    width: Word,
    height: Word,
    pixel_format: Format,
    is_planar: Flag,
    data_size: Word,
    retain: Pointer,
    release: Release,
    /// `CVMutablePixelBuffer` metadata and `init(unsafeBuffer:)`.
    mutable: NativeMetadata,
    mutable_init: *mut c_void,
    _library: Library,
}
impl CoreVideo {
    unsafe fn load() -> Result<Self> {
        // SAFETY: Fixed system framework; each transmute matches the SDK C
        // prototype (CVPixelBuffer.h) recorded in image-abi-calibration.json.
        unsafe {
            let library = Library::open(
                c"/System/Library/Frameworks/CoreVideo.framework/Versions/A/CoreVideo",
            )?;
            let symbol = |name: &CStr| library.symbol(name).map(|s| s.as_ptr());
            let accessor = symbol(c"$s9CoreVideo20CVMutablePixelBufferVMa")?;
            let (pointer, state) = arm64::metadata_accessor(accessor, 0);
            let mutable = NativeMetadata::copy(&Metadata::from_response(pointer, state)?);
            Ok(Self {
                create: mem::transmute::<*mut c_void, Create>(symbol(c"CVPixelBufferCreate")?),
                lock: mem::transmute::<*mut c_void, Lock>(symbol(c"CVPixelBufferLockBaseAddress")?),
                unlock: mem::transmute::<*mut c_void, Lock>(symbol(
                    c"CVPixelBufferUnlockBaseAddress",
                )?),
                base_address: mem::transmute::<*mut c_void, Pointer>(symbol(
                    c"CVPixelBufferGetBaseAddress",
                )?),
                bytes_per_row: mem::transmute::<*mut c_void, Word>(symbol(
                    c"CVPixelBufferGetBytesPerRow",
                )?),
                width: mem::transmute::<*mut c_void, Word>(symbol(c"CVPixelBufferGetWidth")?),
                height: mem::transmute::<*mut c_void, Word>(symbol(c"CVPixelBufferGetHeight")?),
                pixel_format: mem::transmute::<*mut c_void, Format>(symbol(
                    c"CVPixelBufferGetPixelFormatType",
                )?),
                is_planar: mem::transmute::<*mut c_void, Flag>(symbol(c"CVPixelBufferIsPlanar")?),
                data_size: mem::transmute::<*mut c_void, Word>(symbol(
                    c"CVPixelBufferGetDataSize",
                )?),
                retain: mem::transmute::<*mut c_void, Pointer>(symbol(c"CVPixelBufferRetain")?),
                release: mem::transmute::<*mut c_void, Release>(symbol(c"CVPixelBufferRelease")?),
                mutable,
                mutable_init: symbol(
                    c"$s9CoreVideo20CVMutablePixelBufferV06unsafeE0ACSo11CVBufferRefan_tcfC",
                )?,
                _library: library,
            })
        }
    }
}

/// Corsairs' own +1 reference to a CVPixelBuffer, released on drop.
pub(super) struct PixelBuffer {
    buffer: NonNull<c_void>,
    video: Rc<CoreVideo>,
}
impl Drop for PixelBuffer {
    fn drop(&mut self) {
        // SAFETY: Balances the +1 from CVPixelBufferCreate.
        unsafe { (self.video.release)(self.buffer.as_ptr()) };
    }
}
/// Holds a base-address lock and unlocks with the same flags on every path.
struct Locked<'a> {
    buffer: &'a PixelBuffer,
    flags: u64,
    base: NonNull<u8>,
}
impl Drop for Locked<'_> {
    fn drop(&mut self) {
        // SAFETY: Balances the successful lock taken by PixelBuffer::lock.
        unsafe { (self.buffer.video.unlock)(self.buffer.buffer.as_ptr(), self.flags) };
    }
}
impl PixelBuffer {
    unsafe fn create(
        video: &Rc<CoreVideo>,
        pixel_format: u32,
        width: usize,
        height: usize,
    ) -> Result<Self> {
        let (row, _) =
            tight_extent(pixel_format, width, height).map_err(NativeFailure::InvalidData)?;
        let mut out = ptr::null_mut();
        // SAFETY: NULL allocator and attributes request a default memory-backed
        // buffer; on success `out` holds one +1 reference that this owner keeps.
        let status = unsafe {
            (video.create)(
                ptr::null(),
                width,
                height,
                pixel_format,
                ptr::null(),
                &mut out,
            )
        };
        let buffer = NonNull::new(out);
        if status != 0 || buffer.is_none() {
            if let Some(buffer) = buffer {
                // SAFETY: Release a buffer returned alongside a failure status.
                unsafe { (video.release)(buffer.as_ptr()) };
            }
            return Err(NativeFailure::Binding(format!(
                "CVPixelBufferCreate failed with status {status}"
            )));
        }
        let buffer = Self {
            buffer: buffer.unwrap(),
            video: Rc::clone(video),
        };
        // SAFETY: Plain C accessors on the live buffer owned above.
        unsafe {
            let raw = buffer.buffer.as_ptr();
            let bytes_per_row = (video.bytes_per_row)(raw);
            if (video.is_planar)(raw) != 0
                || (video.pixel_format)(raw) != pixel_format
                || (video.width)(raw) != width
                || (video.height)(raw) != height
                || bytes_per_row < row
                || bytes_per_row
                    .checked_mul(height)
                    .is_none_or(|total| total > (video.data_size)(raw))
            {
                return Err(NativeFailure::Binding(
                    "CVPixelBufferCreate returned an unexpected buffer layout".into(),
                ));
            }
        }
        Ok(buffer)
    }
    fn lock(&self, flags: u64) -> Result<Locked<'_>> {
        // SAFETY: The buffer is live; a successful lock is always balanced,
        // by the guard or, without a base address, immediately.
        unsafe {
            let raw = self.buffer.as_ptr();
            let status = (self.video.lock)(raw, flags);
            if status != 0 {
                return Err(NativeFailure::Binding(format!(
                    "CVPixelBufferLockBaseAddress failed with status {status}"
                )));
            }
            match NonNull::new((self.video.base_address)(raw).cast::<u8>()) {
                Some(base) => Ok(Locked {
                    buffer: self,
                    flags,
                    base,
                }),
                None => {
                    (self.video.unlock)(raw, flags);
                    Err(NativeFailure::Binding(
                        "CVPixelBuffer has no base address".into(),
                    ))
                }
            }
        }
    }
    /// Copy a validated image's rows into this buffer's (possibly padded) rows.
    fn fill(&self, image: &NativeImage) -> Result<()> {
        let (row, _) = image_extent(
            image.pixel_format,
            image.width,
            image.height,
            image.bytes_per_row,
        )
        .map_err(NativeFailure::InvalidData)?;
        let locked = self.lock(0)?;
        // SAFETY: create() verified bytesPerRow >= row and bytesPerRow*height
        // within the buffer's data size; source rows were validated likewise.
        unsafe {
            let stride = (self.video.bytes_per_row)(self.buffer.as_ptr());
            for y in 0..image.height {
                ptr::copy_nonoverlapping(
                    image.bytes.as_ptr().add(y * image.bytes_per_row),
                    locked.base.as_ptr().add(y * stride),
                    row,
                );
            }
        }
        Ok(())
    }
    /// Read the buffer as a tight image, skipping CoreVideo's row padding.
    fn read(&self) -> Result<NativeImage> {
        // SAFETY: Plain C accessors on a live buffer; native work has completed.
        unsafe {
            let raw = self.buffer.as_ptr();
            let pixel_format = (self.video.pixel_format)(raw);
            let (width, height) = ((self.video.width)(raw), (self.video.height)(raw));
            let (row, total) =
                tight_extent(pixel_format, width, height).map_err(NativeFailure::Binding)?;
            let locked = self.lock(LOCK_READ_ONLY)?;
            let stride = (self.video.bytes_per_row)(raw);
            if (self.video.is_planar)(raw) != 0
                || stride < row
                || stride
                    .checked_mul(height)
                    .is_none_or(|bytes| bytes > (self.video.data_size)(raw))
            {
                return Err(NativeFailure::Binding(
                    "output CVPixelBuffer has an unexpected layout".into(),
                ));
            }
            let mut bytes = Vec::with_capacity(total);
            for y in 0..height {
                bytes.extend_from_slice(std::slice::from_raw_parts(
                    locked.base.as_ptr().add(y * stride),
                    row,
                ));
            }
            Ok(NativeImage {
                pixel_format,
                width,
                height,
                bytes_per_row: row,
                bytes,
            })
        }
    }
}

/// A Corsairs-created buffer and the `CVMutablePixelBuffer` wrapping it.
/// Fields drop in order: the Swift wrapper first, then Corsairs' reference.
pub(super) struct OwnedImage {
    value: NativeValue,
    buffer: PixelBuffer,
}
impl OwnedImage {
    pub(super) fn read(&self) -> Result<NativeImage> {
        self.buffer.read()
    }
}

impl NativeSession {
    pub(super) fn video(&self) -> Result<Rc<CoreVideo>> {
        if let Some(video) = self.video.get() {
            return Ok(Rc::clone(video));
        }
        // SAFETY: Fixed framework path and SDK-declared C prototypes.
        let video = Rc::new(unsafe { CoreVideo::load()? });
        Ok(Rc::clone(self.video.get_or_init(|| video)))
    }

    /// Create a memory-backed buffer, optionally fill it, and wrap it.
    ///
    /// # Safety
    /// The format and size must already be validated as a supported image.
    pub(super) unsafe fn image(
        &self,
        pixel_format: u32,
        width: usize,
        height: usize,
        contents: Option<&NativeImage>,
    ) -> Result<OwnedImage> {
        let video = self.video()?;
        // SAFETY: Validated packed format and size; the result is owned here.
        let buffer = unsafe { PixelBuffer::create(&video, pixel_format, width, height)? };
        if let Some(image) = contents {
            buffer.fill(image)?;
        }
        let mut value = NativeValue::allocate(video.mutable)?;
        // SAFETY: ImageReference.swift `mutableBuffer`: swiftcc void (sret x8,
        // ptr x0) with x0 consumed (`sending`). Retain first, so the wrapper
        // owns one reference and `buffer` keeps Corsairs' own.
        unsafe {
            (video.retain)(buffer.buffer.as_ptr());
            arm64::call_sync(
                video.mutable_init,
                [buffer.buffer.as_ptr() as usize, 0, 0],
                value.ptr(),
                0,
            );
        }
        value.initialized = true;
        Ok(OwnedImage { value, buffer })
    }

    /// # Safety
    /// `inputs` is an initialized `Inputs`. It borrows `image` (`@_lifetime(self:
    /// borrow value)`), so `image` must outlive it and must not move.
    pub(super) unsafe fn insert_image_input(
        &self,
        inputs: &mut NativeValue,
        image: &OwnedImage,
        name: &str,
    ) -> Result<()> {
        // SAFETY: ImageReference.swift `insertMutableInput`: x0 borrowed T, x1/x2
        // String, x3 T metadata, x4 ViewRepresentable witness table, x20 inout Inputs.
        unsafe {
            let key = self.string(name)?;
            let insert = self.symbol(c"$s13CoreAIRuntime17InferenceFunctionV6InputsV6insert_3foryx_SStAA0C5ValueV17ViewRepresentableRzRi_zlF")?;
            let witness = self.symbol(c"$s9CoreVideo20CVMutablePixelBufferV0A9AIRuntime14InferenceValueV17ViewRepresentableADWP")?;
            arm64::call_sync5(
                insert,
                [
                    image.value.address(),
                    key.words[0],
                    key.words[1],
                    image.value.metadata.pointer,
                    witness as usize,
                ],
                inputs.address(),
            );
            Ok(())
        }
    }

    /// # Safety
    /// `views` is an initialized `MutableViews` that depends on `image`
    /// (`@_lifetime(self: &value)`); `image` must outlive it and must not move.
    pub(super) unsafe fn insert_image_view(
        &self,
        views: &mut NativeValue,
        image: &mut OwnedImage,
        name: &str,
    ) -> Result<()> {
        // SAFETY: ImageReference.swift `insertMutableImage`: x0 inout T, x1/x2
        // String, x3 T metadata, x4 MutableViewRepresentable witness table,
        // x20 inout MutableViews.
        unsafe {
            let key = self.string(name)?;
            let insert = self.symbol(c"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsV6insert_3foryxz_SStAA0C5ValueV0E17ViewRepresentableRzRi_zlF")?;
            let witness = self.symbol(c"$s9CoreVideo20CVMutablePixelBufferV0A9AIRuntime14InferenceValueV24MutableViewRepresentableADWP")?;
            arm64::call_sync5(
                insert,
                [
                    image.value.address(),
                    key.words[0],
                    key.words[1],
                    image.value.metadata.pointer,
                    witness as usize,
                ],
                views.address(),
            );
            Ok(())
        }
    }

    /// Read an `ImageDescriptor` payload already taken out of its enum.
    ///
    /// # Safety
    /// `payload` is an initialized `ImageDescriptor`.
    pub(super) unsafe fn image_descriptor(
        &self,
        payload: &NativeValue,
        name: String,
    ) -> Result<NativeImageDescriptor> {
        // SAFETY: ImageReference.swift: width/height are swiftcc i64 (ptr
        // swiftself); pixelFormatType is swiftcc i32 in w0, so only the low 32
        // bits of x0 are defined.
        unsafe {
            let receiver = payload.address();
            let width = self.call(
                c"$s13CoreAIRuntime15ImageDescriptorV5widthSivg",
                [0; 3],
                ptr::null_mut(),
                receiver,
            )? as isize;
            let height = self.call(
                c"$s13CoreAIRuntime15ImageDescriptorV6heightSivg",
                [0; 3],
                ptr::null_mut(),
                receiver,
            )? as isize;
            let pixel_format = self.call(
                c"$s13CoreAIRuntime15ImageDescriptorV15pixelFormatTypes6UInt32Vvg",
                [0; 3],
                ptr::null_mut(),
                receiver,
            )? as u32;
            if width <= 0 || height <= 0 {
                return Err(NativeFailure::Unsupported(format!(
                    "image {name} has dimensions {width}x{height}"
                )));
            }
            Ok(NativeImageDescriptor {
                name,
                width: width as usize,
                height: height as usize,
                pixel_format,
            })
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn os_types_match_corevideo_constants() {
        // kCVPixelFormatType_24RGB, _32ARGB, _32BGRA ('BGRA' = 1111970369).
        assert_eq!((RGB24, ARGB32, BGRA32), (24, 32, 1_111_970_369));
        assert_eq!(bytes_per_pixel(u32::from_be_bytes(*b"y420")), None);
        assert_eq!(bytes_per_pixel(0), None);
        assert_eq!(four_cc(BGRA32), "'BGRA'");
        assert_eq!(four_cc(RGB24), "0x00000018");
    }

    #[test]
    fn extents_are_checked_before_allocation() {
        assert_eq!(image_extent(RGB24, 4, 2, 12), Ok((12, 24)));
        assert_eq!(image_extent(BGRA32, 4, 2, 64), Ok((16, 128)));
        assert!(image_extent(BGRA32, 4, 2, 15).is_err());
        assert!(image_extent(BGRA32, 0, 2, 0).is_err());
        assert!(image_extent(BGRA32, usize::MAX, 1, usize::MAX).is_err());
        assert!(image_extent(BGRA32, 1 << 20, 1 << 11, 1 << 22).is_err());
        assert!(image_extent(u32::from_be_bytes(*b"y420"), 4, 2, 4).is_err());
    }

    #[test]
    fn images_must_match_descriptors_and_storage() {
        let descriptor = NativeImageDescriptor {
            name: "x".into(),
            width: 4,
            height: 2,
            pixel_format: BGRA32,
        };
        let image = NativeImage {
            pixel_format: BGRA32,
            width: 4,
            height: 2,
            bytes_per_row: 20,
            bytes: vec![0; 40],
        };
        let d = std::slice::from_ref(&descriptor);
        assert!(validate_images(&[("x".into(), image.clone())], d).is_ok());
        assert!(validate_images(&[], d).is_err());
        assert!(validate_images(&[("y".into(), image.clone())], d).is_err());
        for bad in [
            NativeImage {
                bytes: vec![0; 39],
                ..image.clone()
            },
            NativeImage {
                pixel_format: ARGB32,
                ..image.clone()
            },
            NativeImage {
                width: 5,
                ..image.clone()
            },
        ] {
            assert!(validate_images(&[("x".into(), bad)], d).is_err());
        }
        let planar = NativeImageDescriptor {
            pixel_format: u32::from_be_bytes(*b"y420"),
            ..descriptor
        };
        assert!(matches!(
            supported_images([&planar]),
            Err(NativeFailure::Unsupported(_))
        ));
    }
}
