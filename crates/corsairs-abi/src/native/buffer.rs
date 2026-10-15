use super::{Error, Metadata, Runtime, arm64, value::Value};
use std::ffi::c_void;
use std::ptr::{self, NonNull};

const PATTERNS: [[u32; 4]; 3] = [
    [0x3f80_0000, 0xc020_0000, 0, 0x8000_0000],
    [0x7f80_0000, 0xff80_0000, 0x7fc1_2345, 1],
    [0x7f7f_ffff, 0x0080_0000, 0x3eaa_aaab, 0xffc1_2345],
];

pub(crate) struct BufferProbe<'runtime> {
    mutable_metadata: Metadata<'runtime>,
    raw_metadata: Metadata<'runtime>,
    mutable_view: *mut c_void,
    mutable_start: *mut c_void,
    mutable_count: *mut c_void,
    raw_view: *mut c_void,
    raw_bytes: *mut c_void,
}

impl<'runtime> BufferProbe<'runtime> {
    pub(crate) unsafe fn load(runtime: &'runtime Runtime) -> Result<Self, Error> {
        let symbol = |name| runtime.library.symbol(name).map(NonNull::as_ptr);
        Ok(Self {
            // SAFETY: Verified non-generic native view metadata accessors.
            mutable_metadata: unsafe {
                runtime.metadata(c"$s13CoreAIRuntime7NDArrayV14MutableRawViewVMa")?
            },
            // SAFETY: Same metadata signature for the immutable RawView type.
            raw_metadata: unsafe { runtime.metadata(c"$s13CoreAIRuntime7NDArrayV7RawViewVMa")? },
            mutable_view: symbol(c"$s13CoreAIRuntime7NDArrayV14mutableRawViewAC07MutableeF0VyF")?,
            // ABI-public helpers implement the public inlinable mutableBytes
            // API. Its exact body is supplied by the inspected SDK interface.
            mutable_start: symbol(c"$s13CoreAIRuntime7NDArrayV14MutableRawViewV6_startSvyF")?,
            mutable_count: symbol(
                c"$s13CoreAIRuntime7NDArrayV14MutableRawViewV16storageByteCountSiyF",
            )?,
            raw_view: symbol(c"$s13CoreAIRuntime7NDArrayV7rawViewAC03RawE0VyF")?,
            raw_bytes: symbol(c"$s13CoreAIRuntime7NDArrayV7RawViewV5bytess0D4SpanVvg")?,
        })
    }

    pub(crate) unsafe fn write_bits(
        &self,
        tensor: &mut Value<'_, '_>,
        bits: &[u32],
    ) -> Result<(), Error> {
        let mut view = Value::allocate(&self.mutable_metadata)?;
        // SAFETY: Caller cedes unique tensor access; no other views/work exist.
        unsafe {
            arm64::call_sync(
                self.mutable_view,
                [0; 3],
                view.storage.as_ptr(),
                tensor.storage.as_ptr() as usize,
            );
        }
        view.initialized = true;
        // SAFETY: Verified public mutableBytes helper calls, view remains live.
        let (start, count) = unsafe {
            (
                arm64::call_sync(
                    self.mutable_start,
                    [0; 3],
                    ptr::null_mut(),
                    view.storage.as_ptr() as usize,
                ),
                arm64::call_sync(
                    self.mutable_count,
                    [0; 3],
                    ptr::null_mut(),
                    view.storage.as_ptr() as usize,
                ),
            )
        };
        validate_buffer(start, count, bits.len())?;
        // SAFETY: Exclusive native storage has exactly the checked byte length.
        unsafe { ptr::copy_nonoverlapping(bits.as_ptr().cast::<u8>(), start as *mut u8, count) };
        Ok(())
    }

    pub(crate) unsafe fn read_bits(
        &self,
        tensor: &Value<'_, '_>,
        elements: usize,
    ) -> Result<Vec<u32>, Error> {
        let mut view = Value::allocate(&self.raw_metadata)?;
        // SAFETY: Caller keeps tensor initialized and immutable; no work in flight.
        unsafe {
            arm64::call_sync(
                self.raw_view,
                [0; 3],
                view.storage.as_ptr(),
                tensor.storage.as_ptr() as usize,
            );
        }
        view.initialized = true;
        // SAFETY: Public bytes getter returns a borrowed RawSpan pointer/count.
        let (start, count) = unsafe {
            arm64::call_sync_pair(
                self.raw_bytes,
                [0; 3],
                ptr::null_mut(),
                view.storage.as_ptr() as usize,
            )
        };
        validate_buffer(start, count, elements)?;
        let mut result = vec![0u32; elements];
        // SAFETY: Native completion initialized all checked bytes; copy while
        // tensor/view remain live, without Rust element binding on native memory.
        unsafe {
            ptr::copy_nonoverlapping(start as *const u8, result.as_mut_ptr().cast::<u8>(), count);
        }
        Ok(result)
    }

    pub(crate) unsafe fn round_trip(
        &self,
        tensor: &mut Value<'_, '_>,
    ) -> Result<Vec<Vec<u32>>, Error> {
        let mut result = Vec::with_capacity(PATTERNS.len());
        for pattern in PATTERNS {
            // SAFETY: Unique initialized float32 tensor, no work in flight. Each
            // helper destroys its view before the next view is constructed.
            unsafe { self.write_bits(tensor, &pattern)? };
            // SAFETY: Every byte was just written and the mutable view destroyed.
            let actual = unsafe { self.read_bits(tensor, pattern.len())? };
            if actual != pattern {
                return Err(Error(format!(
                    "tensor bits differ: {actual:08x?} != {pattern:08x?}"
                )));
            }
            result.push(actual);
        }
        Ok(result)
    }
}

fn validate_buffer(start: usize, count: usize, elements: usize) -> Result<(), Error> {
    if start == 0 || Some(count) != elements.checked_mul(4) || !start.is_multiple_of(4) {
        return Err(Error(format!(
            "unexpected float32 buffer: pointer={start:#x}, bytes={count}"
        )));
    }
    Ok(())
}
