//! Fixed x+x fixture, through the public Inputs/Outputs API and native tasks.
use super::{
    Error, FUNCTION_METADATA, MODEL_METADATA, Metadata, NDARRAY_METADATA, Runtime, SCALAR_METADATA,
    arm64,
};
use super::{
    buffer::BufferProbe,
    errors::ErrorSupport,
    model::Text,
    value::{Value, take_optional},
};
use std::ffi::{CString, c_void};
use std::mem;
use std::path::Path;
use std::ptr::{self, NonNull};

struct IntArray {
    word: usize,
    release: unsafe extern "C" fn(*mut c_void),
}
impl Drop for IntArray {
    fn drop(&mut self) {
        if self.word != 0 {
            // SAFETY: Owns one Swift Array<Int> bridge reference.
            unsafe { (self.release)(self.word as *mut c_void) };
        }
    }
}

struct Integers {
    element: usize,
    array_metadata: usize,
    repeating: *mut c_void,
    modify: *mut c_void,
    count: *mut c_void,
    at: *mut c_void,
    release: unsafe extern "C" fn(*mut c_void),
}
impl Integers {
    unsafe fn load(runtime: &Runtime) -> Result<Self, Error> {
        let symbol = |name| runtime.library.symbol(name).map(NonNull::as_ptr);
        let element = symbol(c"$sSiN")? as usize;
        let accessor = symbol(c"$sSaMa")?;
        // SAFETY: Generic Array metadata accessor takes request0/element metadata.
        let (metadata, state) =
            unsafe { arm64::call_sync_pair(accessor, [0, element, 0], ptr::null_mut(), 0) };
        if metadata == 0 || state != 0 {
            return Err(Error("incomplete Array<Int> metadata".into()));
        }
        // SAFETY: Bridge release is the C runtime function emitted for Array<Int>.
        let release = unsafe {
            mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void)>(symbol(
                c"swift_bridgeObjectRelease",
            )?)
        };
        Ok(Self {
            element,
            array_metadata: metadata,
            repeating: symbol(c"$sSa9repeating5countSayxGx_SitcfC")?,
            modify: symbol(c"$sSayxSiciM")?,
            count: symbol(c"$sSa5countSivg")?,
            at: symbol(c"$sSayxSicig")?,
            release,
        })
    }

    unsafe fn shape23(&self) -> IntArray {
        let two = 2isize;
        // SAFETY: Known generic Array(repeating:2,count:2) constructor.
        let word = unsafe {
            arm64::call_sync(
                self.repeating,
                [ptr::from_ref(&two) as usize, 2, self.element],
                ptr::null_mut(),
                0,
            )
        };
        let mut array = IntArray {
            word,
            release: self.release,
        };
        let mut scratch = [0usize; 4];
        // SAFETY: Public modify accessor has 32-byte, align8 coroutine scratch,
        // index1, Array<Int> metadata, inout word in x20. Compiler oracle uses
        // exactly this exclusive access and resumes with unwind=false.
        let (resume, element) = unsafe {
            arm64::call_sync_pair(
                self.modify,
                [scratch.as_mut_ptr() as usize, 1, self.array_metadata],
                ptr::null_mut(),
                ptr::from_mut(&mut array.word) as usize,
            )
        };
        // SAFETY: Native accessor yields initialized mutable Int at checked index.
        unsafe {
            (element as *mut isize).write(3);
            arm64::call_sync(
                resume as _,
                [scratch.as_mut_ptr() as usize, 0, 0],
                ptr::null_mut(),
                0,
            );
        }
        array
    }

    unsafe fn read(&self, word: usize) -> Result<Vec<isize>, Error> {
        let array = IntArray {
            word,
            release: self.release,
        };
        // SAFETY: Borrowed Array<Int> count and public checked subscript.
        let count = unsafe {
            arm64::call_sync(
                self.count,
                [array.word, self.element, 0],
                ptr::null_mut(),
                0,
            )
        };
        if count > 64 {
            return Err(Error("unexpected tensor rank".into()));
        }
        let mut values = vec![0isize; count];
        for (index, value) in values.iter_mut().enumerate() {
            // SAFETY: Index is within the native count; indirect Int result.
            unsafe {
                arm64::call_sync(
                    self.at,
                    [index, array.word, self.element],
                    ptr::from_mut(value).cast(),
                    0,
                )
            };
        }
        Ok(values)
    }
}

unsafe fn optional_metadata<'r>(
    runtime: &'r Runtime,
    payload: &Metadata<'r>,
) -> Result<Metadata<'r>, Error> {
    let accessor = runtime.library.symbol(c"$sSqMa")?;
    // SAFETY: Verified Optional metadata accessor signature.
    let (metadata, state) = unsafe {
        arm64::call_sync_pair(
            accessor.as_ptr(),
            [0, payload.address(), 0],
            ptr::null_mut(),
            0,
        )
    };
    // SAFETY: This is the complete generic Optional<Payload> metadata response.
    unsafe { Metadata::from_response(metadata as _, state) }
}

#[derive(Debug)]
pub struct InferenceReport {
    pub cycles: usize,
    pub completed: usize,
    pub shape: Vec<isize>,
    pub strides: Vec<isize>,
    pub is_float32: bool,
    pub output_bits: Vec<u32>,
    pub exact_bytes_match: bool,
    pub output_count: usize,
    pub remaining_outputs: usize,
}

impl Runtime {
    /// Run the fixed float32[2,3] x+x fixture using CPU specialization.
    ///
    /// # Safety
    /// Requires the recorded macOS27 arm64 ABI and the supplied double fixture.
    /// Blocking research driver, without cancellation or user callbacks.
    pub unsafe fn inference_probe(
        &self,
        path: &Path,
        cycles: usize,
    ) -> Result<InferenceReport, Error> {
        if !(1..=1_000_000).contains(&cycles) {
            return Err(Error(
                "inference cycles must be between 1 and 1000000".into(),
            ));
        }
        let path = CString::new(
            path.to_str()
                .ok_or_else(|| Error("asset path must be UTF8".into()))?,
        )
        .map_err(|e| Error(e.to_string()))?;
        let symbol = |name| self.library.symbol(name).map(NonNull::as_ptr);
        let load_function =
            symbol(c"$s13CoreAIRuntime7AIModelV12loadFunction5namedAA09InferenceE0VSgSS_tKF")?;
        let tensor_init =
            symbol(c"$s13CoreAIRuntime7NDArrayV5shape10scalarTypeACSaySiG_AC06ScalarF0OtcfC")?;
        let raw_view = symbol(c"$s13CoreAIRuntime7NDArrayV7rawViewAC03RawE0VyF")?;
        let inputs_init = symbol(c"$s13CoreAIRuntime17InferenceFunctionV6InputsVAEycfC")?;
        let insert = symbol(
            c"$s13CoreAIRuntime17InferenceFunctionV6InputsV6insert_3foryAA7NDArrayV7RawViewVn_SStF",
        )?;
        let views_init = symbol(c"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC")?;
        let remove =
            symbol(c"$s13CoreAIRuntime17InferenceFunctionV7OutputsV6removeyAA0C5ValueVSgSSF")?;
        let output_count = symbol(c"$s13CoreAIRuntime17InferenceFunctionV7OutputsV5countSivg")?;
        let nd_array = symbol(c"$s13CoreAIRuntime14InferenceValueV7ndArrayAA7NDArrayVSgvg")?;
        let get_shape = symbol(c"$s13CoreAIRuntime7NDArrayV5shapeSaySiGvg")?;
        let get_strides = symbol(c"$s13CoreAIRuntime7NDArrayV7stridesSaySiGvg")?;
        let get_scalar = symbol(c"$s13CoreAIRuntime7NDArrayV10scalarTypeAC06ScalarE0Ovg")?;
        let float32 = symbol(c"$s13CoreAIRuntime7NDArrayV10ScalarTypeO7float32yA2EmFWC")?;
        let text = Text::load(self)?;
        let errors = ErrorSupport::load(self)?;
        // SAFETY: Fixed verified metadata/accessor and buffer contracts.
        let integers = unsafe { Integers::load(self)? };
        // SAFETY: Fixed non-generic native view contracts.
        let buffer = unsafe { BufferProbe::load(self)? };
        // SAFETY: All named symbols are nominal complete metadata accessors.
        let model_md = unsafe { self.metadata(MODEL_METADATA)? };
        // SAFETY: Same verified non-generic accessor convention.
        let function_md = unsafe { self.metadata(FUNCTION_METADATA)? };
        // SAFETY: Same verified non-generic accessor convention.
        let tensor_md = unsafe { self.metadata(NDARRAY_METADATA)? };
        // SAFETY: Same verified non-generic accessor convention.
        let scalar_md = unsafe { self.metadata(SCALAR_METADATA)? };
        // SAFETY: Same verified non-generic accessor convention.
        let raw_md = unsafe { self.metadata(c"$s13CoreAIRuntime7NDArrayV7RawViewVMa")? };
        // SAFETY: Same verified non-generic accessor convention.
        let inputs_md =
            unsafe { self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV6InputsVMa")? };
        // SAFETY: Same verified non-generic accessor convention.
        let views_md =
            unsafe { self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVMa")? };
        // SAFETY: Same verified non-generic accessor convention.
        let outputs_md =
            unsafe { self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV7OutputsVMa")? };
        // SAFETY: Same verified non-generic accessor convention.
        let value_md = unsafe { self.metadata(c"$s13CoreAIRuntime14InferenceValueVMa")? };
        // SAFETY: Each Optional accessor is specialized by the exact payload md.
        let optional_function_md = unsafe { optional_metadata(self, &function_md)? };
        // SAFETY: Same Optional contract for InferenceValue.
        let optional_value_md = unsafe { optional_metadata(self, &value_md)? };
        // SAFETY: Same Optional contract for NDArray.
        let optional_tensor_md = unsafe { optional_metadata(self, &tensor_md)? };
        if scalar_md.layout.flags & 0x0020_0000 == 0 {
            return Err(Error("scalar metadata lacks enum witnesses".into()));
        }
        // SAFETY: Exported u32 case tag, not an initialized enum value.
        let float_tag = unsafe { float32.cast::<u32>().read() };
        // SAFETY: Payload-free enum VWT inject/get C signatures.
        let (inject, get_tag) = unsafe {
            (
                mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void, u32, *mut c_void)>(
                    scalar_md.witness(13),
                ),
                mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void, *mut c_void) -> u32>(
                    scalar_md.witness(11),
                ),
            )
        };
        let mut model = Value::allocate(&model_md)?;
        // SAFETY: Empty model allocation, known async initializer, CPU-only.
        if let Some(error_type) = unsafe { self.initialize_model(&path, &mut model)? } {
            return Err(Error(format!("model load failed: {error_type}")));
        }
        // SAFETY: Copy fixed, terminated UTF8 names into owned Strings.
        let main = unsafe { text.string(c"main") };
        // SAFETY: Same copying String contract.
        let x = unsafe { text.string(c"x") };
        // SAFETY: Same copying String contract.
        let y = unsafe { text.string(c"y") };
        let mut optional_function = Value::allocate(&optional_function_md)?;
        // SAFETY: loadFunction borrows model and name; x21 returns owned error.
        let error = unsafe {
            arm64::call_throwing(
                load_function,
                [main.words[0], main.words[1], 0],
                optional_function.storage.as_ptr(),
                model.storage.as_ptr() as usize,
            )
        };
        if !error.is_null() {
            // SAFETY: Synchronous throwing call supplied one owned error.
            let error = unsafe { errors.take(error) };
            return Err(Error(format!(
                "function load failed: {}",
                errors.name(&error)?
            )));
        }
        optional_function.initialized = true;
        // SAFETY: Matching Optional and payload metadata, move Some via witnesses.
        let function = unsafe { take_optional(&mut optional_function, &function_md)? }
            .ok_or_else(|| Error("model lacks main".into()))?;
        let mut tensor = Value::allocate(&tensor_md)?;
        let mut scalar = Value::allocate(&scalar_md)?;
        // SAFETY: Inject verified payload-free float32 case into fresh storage.
        unsafe {
            inject(
                scalar.storage.as_ptr(),
                float_tag,
                scalar_md.pointer.as_ptr(),
            )
        };
        scalar.initialized = true;
        // SAFETY: Public Array constructors/modify accessor build [2,3].
        let mut shape = unsafe { integers.shape23() };
        // SAFETY: NDArray initializer consumes shape word and scalar value.
        unsafe {
            arm64::call_sync(
                tensor_init,
                [shape.word, scalar.storage.as_ptr() as usize, 0],
                tensor.storage.as_ptr(),
                0,
            )
        };
        shape.word = 0;
        scalar.initialized = false;
        tensor.initialized = true;
        let input = [1.0f32, -2.0, 0.0, 0.5, 100.0, -0.25].map(f32::to_bits);
        let expected = [2.0f32, -4.0, 0.0, 1.0, 200.0, -0.5].map(f32::to_bits);
        // SAFETY: Unique float32[2,3] tensor, checked 24-byte mutable view.
        unsafe { buffer.write_bits(&mut tensor, &input)? };
        let mut inputs = Value::allocate(&inputs_md)?;
        let mut view = Value::allocate(&raw_md)?;
        // SAFETY: Inputs() initializes result; rawView borrows initialized tensor.
        unsafe {
            arm64::call_sync(inputs_init, [0; 3], inputs.storage.as_ptr(), 0);
            inputs.initialized = true;
            arm64::call_sync(
                raw_view,
                [0; 3],
                view.storage.as_ptr(),
                tensor.storage.as_ptr() as usize,
            );
            view.initialized = true;
            arm64::call_sync(
                insert,
                [view.storage.as_ptr() as usize, x.words[0], x.words[1]],
                ptr::null_mut(),
                inputs.storage.as_ptr() as usize,
            );
        }
        view.initialized = false;
        // Inputs (declared after tensor) is destroyed before its borrowed tensor.
        let mut report = InferenceReport {
            cycles,
            completed: 0,
            shape: vec![],
            strides: vec![],
            is_float32: false,
            output_bits: vec![],
            exact_bytes_match: true,
            output_count: 0,
            remaining_outputs: 0,
        };
        for _ in 0..cycles {
            let mut states = Value::allocate(&views_md)?;
            let mut output_views = Value::allocate(&views_md)?;
            let mut outputs = Value::allocate(&outputs_md)?;
            // SAFETY: Both empty MutableViews initialize independent results.
            unsafe {
                arm64::call_sync(views_init, [0; 3], states.storage.as_ptr(), 0);
                states.initialized = true;
                arm64::call_sync(views_init, [0; 3], output_views.storage.as_ptr(), 0);
                output_views.initialized = true;
            }
            // SAFETY: Verified run borrows Inputs/self, consumes both mutable
            // views, returns Outputs or owned x20 error. All storage stays live.
            let result = unsafe {
                self.await_native(c"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVAC6InputsV_AC07MutableI0VnAMntYaKFTu",
                    [outputs.storage.as_ptr() as usize, inputs.storage.as_ptr() as usize, states.storage.as_ptr() as usize, output_views.storage.as_ptr() as usize],
                    function.storage.as_ptr() as usize, true)?
            };
            states.initialized = false;
            output_views.initialized = false;
            if result.error != 0 {
                // SAFETY: Own the async error before any fallible validation.
                let error = unsafe { errors.take(result.error as _) };
                return Err(Error(format!("inference failed: {}", errors.name(&error)?)));
            }
            outputs.initialized = true;
            if !result.tls_clear || result.identities != 2 || result.resumes != 1 {
                return Err(Error(format!(
                    "inference async lifecycle mismatch: {result:?}"
                )));
            }
            // SAFETY: Outputs count borrows initialized native self.
            report.output_count = unsafe {
                arm64::call_sync(
                    output_count,
                    [0; 3],
                    ptr::null_mut(),
                    outputs.storage.as_ptr() as usize,
                )
            };
            let mut optional_value = Value::allocate(&optional_value_md)?;
            // SAFETY: remove borrows String and mutates Outputs, initializes optional.
            unsafe {
                arm64::call_sync(
                    remove,
                    [y.words[0], y.words[1], 0],
                    optional_value.storage.as_ptr(),
                    outputs.storage.as_ptr() as usize,
                )
            };
            optional_value.initialized = true;
            // SAFETY: Matching Optional<InferenceValue>, move payload into own storage.
            let mut value = unsafe { take_optional(&mut optional_value, &value_md)? }
                .ok_or_else(|| Error("output lacks y".into()))?;
            let mut optional_array = Value::allocate(&optional_tensor_md)?;
            // SAFETY: Getter consumes InferenceValue, initializes Optional<NDArray>.
            unsafe {
                arm64::call_sync(
                    nd_array,
                    [0; 3],
                    optional_array.storage.as_ptr(),
                    value.storage.as_ptr() as usize,
                )
            };
            value.initialized = false;
            optional_array.initialized = true;
            // SAFETY: Matching Optional<NDArray>, move payload into own storage.
            let array = unsafe { take_optional(&mut optional_array, &tensor_md)? }
                .ok_or_else(|| Error("output y is not NDArray".into()))?;
            // SAFETY: Getters borrow output tensor, return owned Array<Int> words.
            report.shape = unsafe {
                integers.read(arm64::call_sync(
                    get_shape,
                    [0; 3],
                    ptr::null_mut(),
                    array.storage.as_ptr() as usize,
                ))?
            };
            // SAFETY: Same verified getter/owned Array<Int> contracts for strides.
            report.strides = unsafe {
                integers.read(arm64::call_sync(
                    get_strides,
                    [0; 3],
                    ptr::null_mut(),
                    array.storage.as_ptr() as usize,
                ))?
            };
            let mut observed = Value::allocate(&scalar_md)?;
            // SAFETY: Scalar getter initializes indirect result, inspected by VWT.
            unsafe {
                arm64::call_sync(
                    get_scalar,
                    [0; 3],
                    observed.storage.as_ptr(),
                    array.storage.as_ptr() as usize,
                )
            };
            observed.initialized = true;
            // SAFETY: Initialized enum value and matching metadata.
            report.is_float32 =
                unsafe { get_tag(observed.storage.as_ptr(), scalar_md.pointer.as_ptr()) }
                    == float_tag;
            if report.shape != [2, 3] || report.strides != [3, 1] || !report.is_float32 {
                return Err(Error("inference output metadata mismatch".into()));
            }
            // SAFETY: Run completed; checked shape/dtype/strides, initialized24bytes.
            report.output_bits = unsafe { buffer.read_bits(&array, 6)? };
            report.exact_bytes_match &= report.output_bits == expected;
            // SAFETY: Outputs remains initialized after removal.
            report.remaining_outputs = unsafe {
                arm64::call_sync(
                    output_count,
                    [0; 3],
                    ptr::null_mut(),
                    outputs.storage.as_ptr() as usize,
                )
            };
            if !report.exact_bytes_match
                || report.output_count != 1
                || report.remaining_outputs != 0
            {
                return Err(Error("inference output bytes/count mismatch".into()));
            }
            report.completed += 1;
        }
        Ok(report)
    }
}
