//! Owned packed images for functions with image inputs or outputs.
use crate::api_error::Error;
use crate::native::{NativeImage, NativeImageDescriptor};
use std::collections::BTreeMap;

/// A packed CoreVideo pixel format verified end to end with Core AI.
///
/// Bytes are in CoreVideo memory order; Corsairs never converts or swizzles.
/// Planar and other formats appear only as a raw
/// [`ImageDescriptor::pixel_format_type`]; running such a function fails with
/// [`Error::Unsupported`] before any buffer is created.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[non_exhaustive]
pub enum PixelFormat {
    /// `kCVPixelFormatType_24RGB` (OSType 24): R, G, B.
    Rgb24,
    /// `kCVPixelFormatType_32ARGB` (OSType 32): A, R, G, B.
    Argb32,
    /// `kCVPixelFormatType_32BGRA` (`'BGRA'`): B, G, R, A.
    Bgra32,
}
impl PixelFormat {
    /// The CoreVideo OSType.
    pub const fn os_type(self) -> u32 {
        match self {
            Self::Rgb24 => crate::native::image::RGB24,
            Self::Argb32 => crate::native::image::ARGB32,
            Self::Bgra32 => crate::native::image::BGRA32,
        }
    }
    /// The verified format with this OSType, if any.
    pub const fn from_os_type(value: u32) -> Option<Self> {
        match value {
            crate::native::image::RGB24 => Some(Self::Rgb24),
            crate::native::image::ARGB32 => Some(Self::Argb32),
            crate::native::image::BGRA32 => Some(Self::Bgra32),
            _ => None,
        }
    }
    /// Bytes per pixel: 3 for RGB24, 4 otherwise.
    pub const fn bytes_per_pixel(self) -> usize {
        match self {
            Self::Rgb24 => 3,
            Self::Argb32 | Self::Bgra32 => 4,
        }
    }
    /// The CoreVideo name, such as `"32BGRA"`.
    pub const fn name(self) -> &'static str {
        match self {
            Self::Rgb24 => "24RGB",
            Self::Argb32 => "32ARGB",
            Self::Bgra32 => "32BGRA",
        }
    }
}
impl std::fmt::Display for PixelFormat {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(self.name())
    }
}

/// An owned packed image: `height` rows of `width` pixels, each row starting
/// every [`Image::bytes_per_row`] bytes. Input rows may be padded; images
/// returned by Corsairs are always tight.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Image {
    format: PixelFormat,
    width: usize,
    height: usize,
    bytes_per_row: usize,
    bytes: Vec<u8>,
}
impl Image {
    /// An image with tight rows: `bytes.len()` must be `width * height *
    /// format.bytes_per_pixel()`.
    pub fn new(
        format: PixelFormat,
        width: usize,
        height: usize,
        bytes: Vec<u8>,
    ) -> Result<Self, Error> {
        let row = width
            .checked_mul(format.bytes_per_pixel())
            .ok_or_else(|| Error::InvalidImage("image row size overflows".into()))?;
        Self::with_bytes_per_row(format, width, height, row, bytes)
    }
    /// An image whose rows start every `bytes_per_row` bytes. Padding bytes are
    /// never read by Core AI; `bytes.len()` must be `bytes_per_row * height`.
    pub fn with_bytes_per_row(
        format: PixelFormat,
        width: usize,
        height: usize,
        bytes_per_row: usize,
        bytes: Vec<u8>,
    ) -> Result<Self, Error> {
        let (_, total) =
            crate::native::image::image_extent(format.os_type(), width, height, bytes_per_row)
                .map_err(Error::InvalidImage)?;
        if bytes.len() != total {
            return Err(Error::InvalidImage(format!(
                "{width}x{height} {format} with {bytes_per_row} bytes per row requires {total} bytes, got {}",
                bytes.len()
            )));
        }
        Ok(Self {
            format,
            width,
            height,
            bytes_per_row,
            bytes,
        })
    }
    /// An image of zero bytes.
    pub fn zeros(format: PixelFormat, width: usize, height: usize) -> Result<Self, Error> {
        let (_, total) = crate::native::image::tight_extent(format.os_type(), width, height)
            .map_err(Error::InvalidImage)?;
        Self::new(format, width, height, vec![0; total])
    }
    /// Pixel format.
    pub fn format(&self) -> PixelFormat {
        self.format
    }
    /// Width in pixels.
    pub fn width(&self) -> usize {
        self.width
    }
    /// Height in pixels.
    pub fn height(&self) -> usize {
        self.height
    }
    /// Distance in bytes between the starts of consecutive rows.
    pub fn bytes_per_row(&self) -> usize {
        self.bytes_per_row
    }
    /// The `width * bytes_per_pixel` pixel bytes of row `y`, without padding.
    ///
    /// # Panics
    /// Panics if `y >= self.height()`.
    pub fn row(&self, y: usize) -> &[u8] {
        assert!(
            y < self.height,
            "row {y} out of range for height {}",
            self.height
        );
        let start = y * self.bytes_per_row;
        &self.bytes[start..start + self.width * self.format.bytes_per_pixel()]
    }
    /// The stored bytes, including any row padding.
    pub fn as_bytes(&self) -> &[u8] {
        &self.bytes
    }
    /// The pixel bytes with row padding removed.
    pub fn to_tight_bytes(&self) -> Vec<u8> {
        (0..self.height)
            .flat_map(|y| self.row(y))
            .copied()
            .collect()
    }
    /// Take the stored bytes, including any row padding.
    pub fn into_bytes(self) -> Vec<u8> {
        self.bytes
    }
    pub(crate) fn into_native(self) -> NativeImage {
        NativeImage {
            pixel_format: self.format.os_type(),
            width: self.width,
            height: self.height,
            bytes_per_row: self.bytes_per_row,
            bytes: self.bytes,
        }
    }
    pub(crate) fn from_native(image: NativeImage) -> Result<Self, Error> {
        let format = PixelFormat::from_os_type(image.pixel_format).ok_or_else(|| {
            Error::Binding(format!(
                "native image has unsupported format {}",
                crate::native::image::four_cc(image.pixel_format)
            ))
        })?;
        Self::with_bytes_per_row(
            format,
            image.width,
            image.height,
            image.bytes_per_row,
            image.bytes,
        )
    }
}

/// An owned collection of images indexed by native operand name.
/// Inserting an existing name replaces its value, like a Rust map.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct ImageMap(BTreeMap<String, Image>);
impl ImageMap {
    /// Construct an empty collection.
    pub fn new() -> Self {
        Self::default()
    }
    /// Insert an image, returning any replaced value.
    pub fn insert(&mut self, name: impl Into<String>, image: Image) -> Option<Image> {
        self.0.insert(name.into(), image)
    }
    /// Borrow a named image.
    pub fn get(&self, name: &str) -> Option<&Image> {
        self.0.get(name)
    }
    /// Take a named image out of this collection.
    pub fn remove(&mut self, name: &str) -> Option<Image> {
        self.0.remove(name)
    }
    /// Number of named images.
    pub fn len(&self) -> usize {
        self.0.len()
    }
    /// Whether the collection is empty.
    pub fn is_empty(&self) -> bool {
        self.0.is_empty()
    }
    /// Iterate in lexicographic name order.
    pub fn iter(&self) -> impl Iterator<Item = (&str, &Image)> {
        self.0.iter().map(|(name, image)| (name.as_str(), image))
    }
    pub(crate) fn into_native(self) -> Vec<(String, NativeImage)> {
        self.0
            .into_iter()
            .map(|(name, image)| (name, image.into_native()))
            .collect()
    }
    pub(crate) fn from_native(images: Vec<(String, NativeImage)>) -> Result<Self, Error> {
        let mut result = Self::new();
        for (name, image) in images {
            if result
                .insert(name.clone(), Image::from_native(image)?)
                .is_some()
            {
                return Err(Error::DuplicateName(name));
            }
        }
        Ok(result)
    }
}
impl<K: Into<String>> FromIterator<(K, Image)> for ImageMap {
    fn from_iter<T: IntoIterator<Item = (K, Image)>>(iter: T) -> Self {
        Self(iter.into_iter().map(|(k, v)| (k.into(), v)).collect())
    }
}
impl<const N: usize, K: Into<String>> From<[(K, Image); N]> for ImageMap {
    fn from(value: [(K, Image); N]) -> Self {
        value.into_iter().collect()
    }
}

/// A named image value's declared size and CoreVideo pixel format.
#[derive(Debug, Clone, PartialEq, Eq)]
#[non_exhaustive]
pub struct ImageDescriptor {
    /// Native operand name.
    pub name: String,
    /// Width in pixels.
    pub width: usize,
    /// Height in pixels.
    pub height: usize,
    /// The raw CoreVideo OSType, kept even when Corsairs does not support it.
    pub pixel_format_type: u32,
}
impl ImageDescriptor {
    /// The verified pixel format, or None for planar, unknown or raw formats.
    pub fn format(&self) -> Option<PixelFormat> {
        PixelFormat::from_os_type(self.pixel_format_type)
    }
    pub(crate) fn from_native(value: NativeImageDescriptor) -> Self {
        Self {
            name: value.name,
            width: value.width,
            height: value.height,
            pixel_format_type: value.pixel_format,
        }
    }
}

/// Check images against descriptors before submission. Also rejects functions
/// whose image formats are unsupported, even when no image is supplied.
pub(crate) fn validate_images(
    inputs: &[ImageDescriptor],
    outputs: &[ImageDescriptor],
    images: &ImageMap,
) -> Result<(), Error> {
    for descriptor in inputs.iter().chain(outputs) {
        if descriptor.format().is_none() {
            return Err(Error::Unsupported(format!(
                "image {} has pixel format {}; only 24RGB, 32ARGB and 32BGRA are supported",
                descriptor.name,
                crate::native::image::four_cc(descriptor.pixel_format_type)
            )));
        }
    }
    for (name, _) in images.iter() {
        if !inputs.iter().any(|d| d.name == name) {
            return Err(Error::UnexpectedTensor {
                kind: "image input",
                name: name.into(),
            });
        }
    }
    for descriptor in inputs {
        let image = images
            .get(&descriptor.name)
            .ok_or_else(|| Error::MissingTensor {
                kind: "image input",
                name: descriptor.name.clone(),
            })?;
        if Some(image.format()) != descriptor.format() {
            return Err(Error::DescriptorMismatch {
                name: descriptor.name.clone(),
                reason: format!(
                    "requires pixel format {}, got {}",
                    crate::native::image::four_cc(descriptor.pixel_format_type),
                    image.format()
                ),
            });
        }
        if (image.width(), image.height()) != (descriptor.width, descriptor.height) {
            return Err(Error::DescriptorMismatch {
                name: descriptor.name.clone(),
                reason: format!(
                    "requires {}x{} pixels, got {}x{}",
                    descriptor.width,
                    descriptor.height,
                    image.width(),
                    image.height()
                ),
            });
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn formats_round_trip_their_os_types() {
        for format in [PixelFormat::Rgb24, PixelFormat::Argb32, PixelFormat::Bgra32] {
            assert_eq!(PixelFormat::from_os_type(format.os_type()), Some(format));
        }
        assert_eq!(PixelFormat::Bgra32.os_type(), 1_111_970_369);
        assert_eq!(
            PixelFormat::from_os_type(u32::from_be_bytes(*b"y420")),
            None
        );
        assert_eq!(PixelFormat::from_os_type(0), None);
    }

    #[test]
    fn images_check_rows_and_storage() {
        let tight = Image::new(PixelFormat::Rgb24, 2, 2, (0..12).collect()).unwrap();
        assert_eq!(tight.bytes_per_row(), 6);
        assert_eq!(tight.row(1), &[6, 7, 8, 9, 10, 11]);
        let padded =
            Image::with_bytes_per_row(PixelFormat::Rgb24, 2, 2, 8, (0..16).collect()).unwrap();
        assert_eq!(padded.row(1), &[8, 9, 10, 11, 12, 13]);
        assert_eq!(
            padded.to_tight_bytes(),
            vec![0, 1, 2, 3, 4, 5, 8, 9, 10, 11, 12, 13]
        );
        for result in [
            Image::new(PixelFormat::Bgra32, 2, 2, vec![0; 15]),
            Image::new(PixelFormat::Bgra32, 0, 2, vec![]),
            Image::with_bytes_per_row(PixelFormat::Bgra32, 2, 2, 7, vec![0; 14]),
            Image::with_bytes_per_row(PixelFormat::Bgra32, 2, 2, 8, vec![0; 15]),
            Image::new(PixelFormat::Bgra32, usize::MAX, 1, vec![]),
        ] {
            assert!(matches!(result, Err(Error::InvalidImage(_))), "{result:?}");
        }
    }

    fn fixtures() -> std::path::PathBuf {
        std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../../fixtures/parity-v05/images")
    }

    #[test]
    #[ignore = "requires native Core AI"]
    fn native_images_round_trip_on_every_backend() {
        use crate::{Compute, DType, Runtime, Tensor, TensorMap};
        let runtime = Runtime::new().unwrap();
        let tight = std::fs::read(fixtures().join("RGB24_identity_3x5/x.bin")).unwrap();
        for compute in [
            Compute::CpuOnly,
            Compute::GpuPreferred,
            Compute::NeuralEnginePreferred,
        ] {
            let model = runtime
                .load_model(fixtures().join("RGB24_identity_3x5/model.aimodel"), compute)
                .wait()
                .unwrap();
            let function = model.load_function("main").wait().unwrap();
            let d = function.descriptor();
            assert!(d.inputs.is_empty() && d.outputs.is_empty());
            assert_eq!(
                (
                    d.image_inputs[0].format(),
                    d.image_inputs[0].width,
                    d.image_inputs[0].height
                ),
                (Some(PixelFormat::Rgb24), 5, 3)
            );
            // Padded rows (0xEE) must be skipped; the output is always tight.
            let mut padded = Vec::new();
            for row in tight.chunks(15) {
                padded.extend_from_slice(row);
                padded.extend_from_slice(&[0xEE; 5]);
            }
            let image = Image::with_bytes_per_row(PixelFormat::Rgb24, 5, 3, 20, padded).unwrap();
            let result = function
                .run_with_images(
                    TensorMap::new(),
                    ImageMap::from([("x", image)]),
                    TensorMap::new(),
                )
                .wait()
                .unwrap();
            let y = result.images.get("y").unwrap();
            assert_eq!((y.bytes_per_row(), y.as_bytes()), (15, &tight[..]));
            assert!(matches!(
                function.run(TensorMap::new(), TensorMap::new()).wait(),
                Err(Error::MissingTensor { .. })
            ));

            // Tensor input, image output: plain `run` returns the image.
            let model = runtime
                .load_model(fixtures().join("BGRA32_from_tensor/model.aimodel"), compute)
                .wait()
                .unwrap();
            let function = model.load_function("main").wait().unwrap();
            let bytes = std::fs::read(fixtures().join("BGRA32_from_tensor/x.bin")).unwrap();
            let x = Tensor::from_bytes(DType::UInt8, [2, 4, 4], bytes.clone()).unwrap();
            let result = function
                .run(TensorMap::from([("x", x)]), TensorMap::new())
                .wait()
                .unwrap();
            assert_eq!(result.images.get("y").unwrap().as_bytes(), &bytes[..]);

            // Planar 4:2:0 loads and is described, but never reaches Core AI,
            // which would trap the process (docs/image-io.md).
            let model = runtime
                .load_model(
                    fixtures().join("YpCbCr8420Planar_to_tensor/model.aimodel"),
                    compute,
                )
                .wait()
                .unwrap();
            let function = model.load_function("main").wait().unwrap();
            let x = &function.descriptor().image_inputs[0];
            assert_eq!(
                (x.pixel_format_type, x.format()),
                (u32::from_be_bytes(*b"y420"), None)
            );
            let image = Image::zeros(PixelFormat::Bgra32, 4, 2).unwrap();
            for images in [ImageMap::new(), ImageMap::from([("x", image)])] {
                assert!(matches!(
                    function
                        .run_with_images(TensorMap::new(), images, TensorMap::new())
                        .wait(),
                    Err(Error::Unsupported(_))
                ));
            }
        }
    }

    #[test]
    fn signatures_reject_names_formats_and_sizes_before_execution() {
        let input = ImageDescriptor {
            name: "x".into(),
            width: 4,
            height: 2,
            pixel_format_type: PixelFormat::Bgra32.os_type(),
        };
        let inputs = std::slice::from_ref(&input);
        let good = Image::zeros(PixelFormat::Bgra32, 4, 2).unwrap();
        assert!(validate_images(inputs, &[], &ImageMap::from([("x", good.clone())])).is_ok());
        assert!(matches!(
            validate_images(inputs, &[], &ImageMap::new()),
            Err(Error::MissingTensor { .. })
        ));
        assert!(matches!(
            validate_images(
                inputs,
                &[],
                &ImageMap::from([("x", good.clone()), ("y", good)])
            ),
            Err(Error::UnexpectedTensor { .. })
        ));
        for image in [
            Image::zeros(PixelFormat::Argb32, 4, 2).unwrap(),
            Image::zeros(PixelFormat::Bgra32, 2, 4).unwrap(),
        ] {
            assert!(matches!(
                validate_images(inputs, &[], &ImageMap::from([("x", image)])),
                Err(Error::DescriptorMismatch { .. })
            ));
        }
        let planar = ImageDescriptor {
            pixel_format_type: u32::from_be_bytes(*b"y420"),
            ..input
        };
        assert_eq!(planar.format(), None);
        assert!(matches!(
            validate_images(&[], std::slice::from_ref(&planar), &ImageMap::new()),
            Err(Error::Unsupported(_))
        ));
    }
}
