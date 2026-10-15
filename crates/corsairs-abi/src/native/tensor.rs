use super::buffer::BufferProbe;
use super::value::Value;
use super::{Error, NDARRAY_METADATA, Runtime, SCALAR_METADATA, arm64};
use std::ffi::c_void;
use std::mem;
use std::ptr::{self, NonNull};

#[derive(Debug)]
pub struct TensorReport {
    pub cycles: usize,
    pub shape: Vec<isize>,
    pub scalar_tag: u32,
    pub initialized: usize,
    pub destroyed: usize,
    pub content_bits: Vec<Vec<u32>>,
}

struct ArrayWord {
    word: usize,
    release: unsafe extern "C" fn(*mut c_void),
}

impl Drop for ArrayWord {
    fn drop(&mut self) {
        if self.word != 0 {
            // SAFETY: Owns exactly one initialized Swift array bridge word.
            unsafe { (self.release)(self.word as *mut c_void) };
        }
    }
}

impl Runtime {
    /// Construct float32 tensors of shape [2, 2], inspect through public
    /// accessors, and destroy through the native value witness table.
    ///
    /// # Safety
    /// Requires the documented macOS 27 ARM64 ABI and symbol contracts. This is
    /// a bounded synchronous experiment; no asynchronous or GPU work is submitted.
    pub unsafe fn tensor_probe(&self, cycles: usize) -> Result<TensorReport, Error> {
        // SAFETY: Caller accepts the ABI contracts; no buffer views requested.
        unsafe { self.tensor_probe_impl(cycles, false) }
    }

    /// Write/read float32 bit patterns using scoped native buffer views.
    ///
    /// # Safety
    /// Requires the same macOS 27 ARM64 contracts as tensor_probe, together with
    /// the recorded nonescaping view contracts. No view or pointer is returned.
    pub unsafe fn buffer_probe(&self, cycles: usize) -> Result<TensorReport, Error> {
        // SAFETY: Caller accepts the tensor and buffer ABI contracts.
        unsafe { self.tensor_probe_impl(cycles, true) }
    }

    unsafe fn tensor_probe_impl(
        &self,
        cycles: usize,
        buffers: bool,
    ) -> Result<TensorReport, Error> {
        let trace = |stage: &str| {
            if std::env::var_os("CORSAIRS_TRACE").is_some() {
                eprintln!("tensor: {stage}");
            }
        };
        if !(1..=1_000_000).contains(&cycles) {
            return Err(Error("tensor cycles must be between 1 and 1000000".into()));
        }
        let buffer = if buffers {
            // SAFETY: Fixed view metadata/accessors from BufferReference.swift.
            Some(unsafe { BufferProbe::load(self)? })
        } else {
            None
        };
        let symbol = |name| self.library.symbol(name).map(NonNull::as_ptr);
        let int_metadata = symbol(c"$sSiN")?;
        let repeating = symbol(c"$sSa9repeating5countSayxGx_SitcfC")?;
        let constructor =
            symbol(c"$s13CoreAIRuntime7NDArrayV5shape10scalarTypeACSaySiG_AC06ScalarF0OtcfC")?;
        let get_shape = symbol(c"$s13CoreAIRuntime7NDArrayV5shapeSaySiGvg")?;
        let get_scalar = symbol(c"$s13CoreAIRuntime7NDArrayV10scalarTypeAC06ScalarE0Ovg")?;
        let array_count = symbol(c"$sSa5countSivg")?;
        let array_element = symbol(c"$sSayxSicig")?;
        let float32 = symbol(c"$s13CoreAIRuntime7NDArrayV10ScalarTypeO7float32yA2EmFWC")?;
        let release_pointer = symbol(c"swift_bridgeObjectRelease")?;
        // SAFETY: Swift's exported bridge release has this C ABI, confirmed in IR.
        let release = unsafe {
            mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void)>(release_pointer)
        };
        // SAFETY: These symbols have the verified non-generic metadata signature.
        let tensor_metadata = unsafe { self.metadata(NDARRAY_METADATA)? };
        // SAFETY: Same contract for ScalarType's metadata accessor.
        let scalar_metadata = unsafe { self.metadata(SCALAR_METADATA)? };
        if scalar_metadata.layout.flags & 0x0020_0000 == 0 {
            return Err(Error("ScalarType metadata lacks enum witnesses".into()));
        }
        // SAFETY: This exported symbol is an aligned i32 enum-case tag constant,
        // not a function or an already-initialized ScalarType value.
        let tag = unsafe { float32.cast::<u32>().read() };
        // SAFETY: Enum VWT slot 13 is C-ABI destructiveInjectEnumTag; slot 11 is
        // getEnumTag. The enum-witness flag was checked above.
        let (inject, get_tag) = unsafe {
            (
                mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void, u32, *mut c_void)>(
                    scalar_metadata.witness(13),
                ),
                mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void, *mut c_void) -> u32>(
                    scalar_metadata.witness(11),
                ),
            )
        };
        let mut report = TensorReport {
            cycles,
            shape: vec![],
            scalar_tag: tag,
            initialized: 0,
            destroyed: 0,
            content_bits: vec![],
        };
        trace(&format!(
            "symbols ready, scalar tag={tag}, flags={:#x}",
            scalar_metadata.layout.flags
        ));
        for _ in 0..cycles {
            let mut scalar = Value::allocate(&scalar_metadata)?;
            let mut tensor = Value::allocate(&tensor_metadata)?;
            let mut observed_scalar = Value::allocate(&scalar_metadata)?;
            trace("inject scalar");
            // SAFETY: Injecting a verified payload-free case initializes the raw
            // scalar storage. All allocations use the runtime's own layouts.
            unsafe {
                inject(
                    scalar.storage.as_ptr(),
                    tag,
                    scalar_metadata.pointer.as_ptr(),
                )
            };
            scalar.initialized = true;
            let dimension: isize = 2;
            trace("construct shape array");
            // SAFETY: Public generic Array(repeating:count:), specialized at
            // runtime by passing Int metadata, consumes a trivial Int input.
            let word = unsafe {
                arm64::call_sync(
                    repeating,
                    [
                        &dimension as *const isize as usize,
                        2,
                        int_metadata as usize,
                    ],
                    ptr::null_mut(),
                    0,
                )
            };
            if word == 0 {
                return Err(Error("Array constructor returned null".into()));
            }
            let mut shape = ArrayWord { word, release };
            trace("construct NDArray");
            // SAFETY: Verified initializer: x8=uninitialized NDArray result,
            // x0=owned Array<Int>, x1=owned indirect ScalarType. It cannot throw.
            unsafe {
                arm64::call_sync(
                    constructor,
                    [shape.word, scalar.storage.as_ptr() as usize, 0],
                    tensor.storage.as_ptr(),
                    0,
                );
            }
            shape.word = 0; // Both arguments were consumed by the initializer.
            scalar.initialized = false;
            tensor.initialized = true;
            report.initialized += 1;
            if let Some(buffer) = &buffer {
                trace("write/read content patterns");
                // SAFETY: Tensor is fully initialized float32, shape [2, 2],
                // uniquely owned here. Views cannot outlive this call.
                report.content_bits = unsafe { buffer.round_trip(&mut tensor)? };
            }
            trace("read shape");
            // SAFETY: Public borrowing shape getter, native self in x20.
            let word = unsafe {
                arm64::call_sync(
                    get_shape,
                    [0; 3],
                    ptr::null_mut(),
                    tensor.storage.as_ptr() as usize,
                )
            };
            if word == 0 {
                return Err(Error("shape getter returned null".into()));
            }
            let observed_shape = ArrayWord { word, release };
            trace("read array count");
            // SAFETY: Generic Array.count takes its single-word value self as
            // an ordinary argument in x0, followed by element metadata in x1.
            // Array's fixed-size self is not a swiftself context in x20.
            let count = unsafe {
                arm64::call_sync(
                    array_count,
                    [observed_shape.word, int_metadata as usize, 0],
                    ptr::null_mut(),
                    0,
                )
            };
            if count != 2 {
                return Err(Error(format!("expected rank 2, got {count}")));
            }
            let mut dimensions = vec![];
            trace("read array elements");
            for index in 0..count {
                let mut value: isize = 0;
                // SAFETY: Index is in bounds. Generic Array subscript returns
                // Int indirectly, using its metadata, without exposing storage.
                unsafe {
                    arm64::call_sync(
                        array_element,
                        [index, observed_shape.word, int_metadata as usize],
                        (&mut value as *mut isize).cast(),
                        0,
                    );
                }
                dimensions.push(value);
            }
            if dimensions != [2, 2] {
                return Err(Error(format!("wrong tensor shape: {dimensions:?}")));
            }
            trace("read scalar");
            // SAFETY: Public borrowing scalar getter initializes an indirect
            // result in runtime-sized ScalarType storage.
            unsafe {
                arm64::call_sync(
                    get_scalar,
                    [0; 3],
                    observed_scalar.storage.as_ptr(),
                    tensor.storage.as_ptr() as usize,
                )
            };
            observed_scalar.initialized = true;
            // SAFETY: Initialized scalar value and its exact metadata match.
            let observed_tag = unsafe {
                get_tag(
                    observed_scalar.storage.as_ptr(),
                    scalar_metadata.pointer.as_ptr(),
                )
            };
            if observed_tag != tag {
                return Err(Error(format!(
                    "wrong scalar tag: {observed_tag}, expected {tag}"
                )));
            }
            report.shape = dimensions;
            trace("destroy tensor");
            drop(tensor);
            report.destroyed += 1;
        }
        Ok(report)
    }
}
