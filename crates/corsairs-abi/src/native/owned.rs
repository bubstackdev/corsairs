//! Owned native values confined to one session and its creating worker thread.
//!
//! Swift code is supplied by the OS. Every call uses the explicit arm64 lowering
//! established by the compiler references, rather than Rust aggregate lowering.
use super::{
    Error, Metadata, Runtime, TypeLayout, arm64,
    errors::ErrorSupport,
    text::{NativeString, Text},
};
use std::alloc::{Layout, alloc_zeroed, dealloc};
use std::collections::{HashMap, HashSet};
use std::ffi::{CStr, CString, c_void};
use std::fmt;
use std::marker::PhantomData;
use std::mem;
use std::path::Path;
use std::ptr::{self, NonNull};
use std::rc::Rc;

mod function_batch;
pub use function_batch::NativeFunctionBatchOutcome;
mod batch;
#[cfg(any(feature = "abi-research", test))]
pub use batch::NativeBatchMetrics;
pub use batch::NativeBatchOutcome;
mod handles;
pub use handles::NativeTensorHandle;
mod metal;
pub use metal::{NativeMetalInput, NativeMetalObject, NativeMetalTensor};
mod run_stream;

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum NativeDType {
    F16,
    Bf16,
    F32,
    I32,
    I64,
    Bool,
}
impl NativeDType {
    pub const fn byte_width(self) -> usize {
        match self {
            Self::F16 | Self::Bf16 => 2,
            Self::F32 | Self::I32 => 4,
            Self::I64 => 8,
            Self::Bool => 1,
        }
    }
    fn case(self) -> &'static CStr {
        match self {
            Self::F16 => c"$s13CoreAIRuntime7NDArrayV10ScalarTypeO7float16yA2EmFWC",
            Self::Bf16 => c"$s13CoreAIRuntime7NDArrayV10ScalarTypeO8bfloat16yA2EmFWC",
            Self::F32 => c"$s13CoreAIRuntime7NDArrayV10ScalarTypeO7float32yA2EmFWC",
            Self::I32 => c"$s13CoreAIRuntime7NDArrayV10ScalarTypeO5int32yA2EmFWC",
            Self::I64 => c"$s13CoreAIRuntime7NDArrayV10ScalarTypeO5int64yA2EmFWC",
            Self::Bool => c"$s13CoreAIRuntime7NDArrayV10ScalarTypeO4boolyA2EmFWC",
        }
    }
}
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum NativeCompute {
    CpuOnly,
    GpuPreferred,
}
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct NativeLoadOptions {
    pub compute: NativeCompute,
    /// None leaves the SDK's constructor-selected value unchanged.
    pub expect_frequent_reshapes: Option<bool>,
}
impl From<NativeCompute> for NativeLoadOptions {
    fn from(compute: NativeCompute) -> Self {
        Self {
            compute,
            expect_frequent_reshapes: None,
        }
    }
}
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NativeTensor {
    pub dtype: NativeDType,
    pub shape: Vec<usize>,
    pub bytes: Vec<u8>,
}
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NativeTensorDescriptor {
    pub name: String,
    pub shape: Vec<isize>,
    pub dtype: NativeDType,
}
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NativeFunctionDescriptor {
    pub name: String,
    pub inputs: Vec<NativeTensorDescriptor>,
    pub outputs: Vec<NativeTensorDescriptor>,
    pub states: Vec<NativeTensorDescriptor>,
}
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NativeModel {
    pub id: u64,
    pub function_names: Vec<String>,
}
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NativeFunction {
    pub id: u64,
    pub descriptor: NativeFunctionDescriptor,
}
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct NativeRunResult {
    pub outputs: Vec<(String, NativeTensor)>,
    pub states: Vec<(String, NativeTensor)>,
}
#[derive(Clone, Debug, PartialEq, Eq)]
pub enum NativeFailure {
    Binding(String),
    InvalidData(String),
    FunctionNotFound(String),
    InvalidHandle {
        kind: &'static str,
        id: u64,
    },
    Unsupported(String),
    Native {
        operation: &'static str,
        type_name: String,
    },
}
impl fmt::Display for NativeFailure {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Binding(s) => write!(f, "native binding: {s}"),
            Self::InvalidData(s) => f.write_str(s),
            Self::FunctionNotFound(name) => write!(f, "model has no function {name:?}"),
            Self::InvalidHandle { kind, id } => write!(f, "unknown {kind} handle {id}"),
            Self::Unsupported(s) => write!(f, "unsupported: {s}"),
            Self::Native {
                operation,
                type_name,
            } => write!(f, "{operation} failed: {type_name}"),
        }
    }
}
impl std::error::Error for NativeFailure {}
impl From<Error> for NativeFailure {
    fn from(value: Error) -> Self {
        Self::Binding(value.to_string())
    }
}
type Result<T> = std::result::Result<T, NativeFailure>;

// Metadata and VWT storage belong to the OS image. Copying their addresses avoids
// self references; NativeSession clears every value before closing that image.
#[derive(Clone, Copy)]
struct NativeMetadata {
    pointer: usize,
    witnesses: usize,
    layout: TypeLayout,
}
impl NativeMetadata {
    fn copy(metadata: &Metadata<'_>) -> Self {
        Self {
            pointer: metadata.address(),
            witnesses: metadata.witnesses_address(),
            layout: metadata.layout,
        }
    }
    unsafe fn witness(self, index: usize) -> *mut c_void {
        // SAFETY: Only ABI-ledger function slots are used, with the session live.
        unsafe { (self.witnesses as *const *mut c_void).add(index).read() }
    }
}
struct NativeValue {
    pointer: NonNull<c_void>,
    allocation: Layout,
    metadata: NativeMetadata,
    initialized: bool,
    _thread: PhantomData<Rc<()>>,
}
impl NativeValue {
    fn allocate(metadata: NativeMetadata) -> Result<Self> {
        let allocation =
            Layout::from_size_align(metadata.layout.stride.max(1), metadata.layout.alignment)
                .map_err(|e| NativeFailure::Binding(e.to_string()))?;
        // SAFETY: A checked, nonzero allocation; native initialization is tracked.
        let pointer = NonNull::new(unsafe { alloc_zeroed(allocation) }.cast())
            .ok_or_else(|| NativeFailure::Binding("native value allocation failed".into()))?;
        Ok(Self {
            pointer,
            allocation,
            metadata,
            initialized: false,
            _thread: PhantomData,
        })
    }
    fn ptr(&self) -> *mut c_void {
        self.pointer.as_ptr()
    }
    fn address(&self) -> usize {
        self.ptr() as usize
    }
    unsafe fn copy_owned(&self) -> Result<Self> {
        // SAFETY: The source is initialized and its session/framework remain
        // live. Swift's initializeWithCopy creates an independent value owner;
        // it does not borrow this allocation or copy the tensor's payload bytes.
        unsafe {
            debug_assert!(self.initialized);
            let mut value = Self::allocate(self.metadata)?;
            let copy: unsafe extern "C" fn(*mut c_void, *mut c_void, *mut c_void) -> *mut c_void =
                mem::transmute(self.metadata.witness(2));
            copy(value.ptr(), self.ptr(), self.metadata.pointer as _);
            value.initialized = true;
            Ok(value)
        }
    }
    unsafe fn take_optional(&mut self, payload: NativeMetadata) -> Result<Option<Self>> {
        // SAFETY: The caller supplies the exact initialized Optional<Payload>.
        unsafe {
            let tag: unsafe extern "C" fn(*mut c_void, u32, *mut c_void) -> u32 =
                mem::transmute(payload.witness(6));
            match tag(self.ptr(), 1, payload.pointer as _) {
                1 => Ok(None),
                0 => {
                    let mut value = Self::allocate(payload)?;
                    let take: unsafe extern "C" fn(
                        *mut c_void,
                        *mut c_void,
                        *mut c_void,
                    ) -> *mut c_void = mem::transmute(payload.witness(4));
                    take(value.ptr(), self.ptr(), payload.pointer as _);
                    self.initialized = false;
                    value.initialized = true;
                    Ok(Some(value))
                }
                _ => Err(NativeFailure::Binding("invalid Optional tag".into())),
            }
        }
    }
}
impl Drop for NativeValue {
    fn drop(&mut self) {
        // SAFETY: The session outlives its values; initialized values have one +1.
        unsafe {
            if self.initialized {
                let destroy: unsafe extern "C" fn(*mut c_void, *mut c_void) =
                    mem::transmute(self.metadata.witness(1));
                destroy(self.ptr(), self.metadata.pointer as _);
            }
            dealloc(self.ptr().cast(), self.allocation);
        }
    }
}
struct OwnedWord {
    word: usize,
    release: unsafe extern "C" fn(*mut c_void),
}
impl Drop for OwnedWord {
    fn drop(&mut self) {
        // SAFETY: Owns precisely one compiler-established native reference.
        unsafe {
            if self.word != 0 {
                (self.release)(self.word as _);
            }
        };
    }
}
struct FunctionRecord {
    value: NativeValue,
    descriptor: NativeFunctionDescriptor,
    model: u64,
}
struct ModelRecord {
    value: NativeValue,
    names: Vec<String>,
    compute: NativeCompute,
}

/// Thread-confined native object store. Its DTOs contain no native addresses.
/// Create this session inside the dedicated worker that will own it.
pub struct NativeSession {
    metal: metal::Store,
    tensors: HashMap<u64, handles::TensorRecord>,
    functions: HashMap<u64, FunctionRecord>,
    models: HashMap<u64, ModelRecord>,
    next: u64,
    text: Text,
    runtime: Runtime,
    _thread: PhantomData<Rc<()>>,
}
impl Drop for NativeSession {
    fn drop(&mut self) {
        self.metal.clear();
        self.tensors.clear();
        self.functions.clear();
        self.models.clear();
    }
}
impl NativeSession {
    #[cfg(test)]
    pub(crate) fn live_counts(&self) -> (usize, usize) {
        (self.models.len(), self.functions.len())
    }
    /// # Safety
    /// Requires the documented macOS 27 arm64 SDK/runtime pairing. All calls and
    /// final destruction must stay on this session's creating worker thread.
    pub unsafe fn open() -> Result<Self> {
        // SAFETY: Caller accepts the platform contract; ownership stays local.
        let runtime = unsafe { Runtime::open()? };
        let text = Text::load(&runtime)?;
        // Resolve error ownership/reflection support before any throwing call.
        let _ = ErrorSupport::load(&runtime)?;
        Ok(Self {
            metal: metal::Store::default(),
            tensors: HashMap::new(),
            functions: HashMap::new(),
            models: HashMap::new(),
            next: 1,
            text,
            runtime,
            _thread: PhantomData,
        })
    }
    fn symbol(&self, name: &CStr) -> Result<*mut c_void> {
        Ok(self.runtime.library.symbol(name)?.as_ptr())
    }
    unsafe fn metadata(&self, name: &CStr) -> Result<NativeMetadata> {
        // SAFETY: All callers supply known complete nominal metadata accessors.
        Ok(NativeMetadata::copy(&unsafe {
            self.runtime.metadata(name)?
        }))
    }
    unsafe fn optional(&self, payload: NativeMetadata) -> Result<NativeMetadata> {
        // SAFETY: Verified Optional metadata accessor takes request and payload.
        unsafe {
            let (pointer, state) = arm64::call_sync_pair(
                self.symbol(c"$sSqMa")?,
                [0, payload.pointer, 0],
                ptr::null_mut(),
                0,
            );
            Ok(NativeMetadata::copy(&Metadata::from_response(
                pointer as _,
                state,
            )?))
        }
    }
    unsafe fn call(
        &self,
        name: &CStr,
        args: [usize; 3],
        out: *mut c_void,
        receiver: usize,
    ) -> Result<usize> {
        // SAFETY: Call sites establish each named symbol's lowered ABI.
        Ok(unsafe { arm64::call_sync(self.symbol(name)?, args, out, receiver) })
    }
    unsafe fn pair(
        &self,
        name: &CStr,
        args: [usize; 3],
        out: *mut c_void,
        receiver: usize,
    ) -> Result<(usize, usize)> {
        // SAFETY: Call sites establish the exact two-word result contract.
        Ok(unsafe { arm64::call_sync_pair(self.symbol(name)?, args, out, receiver) })
    }
    fn release(&self, name: &CStr) -> Result<unsafe extern "C" fn(*mut c_void)> {
        // SAFETY: Only the verified C release entry points are supplied.
        Ok(unsafe {
            mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void)>(self.symbol(name)?)
        })
    }
    fn string(&self, value: &str) -> Result<NativeString> {
        let value = CString::new(value).map_err(|_| {
            NativeFailure::InvalidData("names and paths must not contain NUL".into())
        })?;
        // SAFETY: Native initializer copies the terminated string before return.
        Ok(unsafe { self.text.string(&value) })
    }
    fn id(&mut self) -> Result<u64> {
        let id = self.next;
        self.next = self
            .next
            .checked_add(1)
            .ok_or_else(|| NativeFailure::Binding("handle space exhausted".into()))?;
        Ok(id)
    }
    unsafe fn failure(&self, pointer: usize, operation: &'static str) -> NativeFailure {
        // SAFETY: Called only with an owned error from a throwing continuation.
        unsafe {
            match ErrorSupport::load(&self.runtime) {
                Ok(support) => {
                    let error = support.take(pointer as _);
                    match support.name(&error) {
                        Ok(type_name) => NativeFailure::Native {
                            operation,
                            type_name,
                        },
                        Err(e) => NativeFailure::Binding(format!("{operation}: {e}")),
                    }
                }
                Err(e) => {
                    // Resolve release independently so even reflection failure
                    // balances the original +1 when the runtime is available.
                    if let Ok(release) = self.release(c"swift_errorRelease") {
                        release(pointer as _);
                    }
                    NativeFailure::Binding(format!("{operation}: {e}"))
                }
            }
        }
    }
    fn lifecycle(result: &super::async_task::AsyncResult) -> Result<()> {
        if result.identities != 2 || result.resumes != 1 || !result.tls_clear {
            Err(NativeFailure::Binding(format!(
                "native task lifecycle mismatch: {result:?}"
            )))
        } else {
            Ok(())
        }
    }

    /// # Safety
    /// Uses the platform-specific metadata, enum, URL and async contracts.
    pub unsafe fn load_model(
        &mut self,
        path: &Path,
        compute: NativeCompute,
    ) -> Result<NativeModel> {
        // SAFETY: Preserve the original compute-only loader's SDK defaults.
        unsafe { self.load_model_with_options(path, compute.into()) }
    }
    /// # Safety
    /// Uses compiler-verified options accessors and the existing async load ABI.
    pub unsafe fn load_model_with_options(
        &mut self,
        path: &Path,
        load_options: NativeLoadOptions,
    ) -> Result<NativeModel> {
        // SAFETY: Only compiler-verified constructors/accessors are called here.
        unsafe {
            let path = path
                .to_str()
                .ok_or_else(|| NativeFailure::InvalidData("asset path must be UTF8".into()))?;
            let path = self.string(path)?;
            let mut url = NativeValue::allocate(self.metadata(c"$s10Foundation3URLVMa")?)?;
            let mut options = NativeValue::allocate(
                self.metadata(c"$s15CoreAIDelegates21SpecializationOptionsVMa")?,
            )?;
            let mut model = NativeValue::allocate(self.metadata(super::MODEL_METADATA)?)?;
            // Resolve all fallible symbols before consuming any values.
            let url_init = self.symbol(c"$s10Foundation3URLV15fileURLWithPathACSSh_tcfC")?;
            arm64::call_sync(url_init, [path.words[0], path.words[1], 0], url.ptr(), 0);
            url.initialized = true;
            match load_options.compute {
                NativeCompute::CpuOnly => {
                    self.call(
                        c"$s15CoreAIDelegates21SpecializationOptionsV7cpuOnlyACvgZ",
                        [0; 3],
                        options.ptr(),
                        0,
                    )?;
                }
                NativeCompute::GpuPreferred => {
                    let md = self.metadata(c"$s15CoreAIDelegates15ComputeUnitKindOMa")?;
                    let mut kind = NativeValue::allocate(md)?;
                    self.inject(
                        &mut kind,
                        c"$s15CoreAIDelegates15ComputeUnitKindO3gpuyA2CmFWC",
                    )?;
                    let initialize = self.symbol(c"$s15CoreAIDelegates21SpecializationOptionsV24preferredComputeUnitKindAcA0fgH0O_tcfC")?;
                    arm64::call_sync(initialize, [kind.address(), 0, 0], options.ptr(), 0);
                    kind.initialized = false;
                }
            }
            options.initialized = true;
            if let Some(enabled) = load_options.expect_frequent_reshapes {
                // LoadOptionsReference.swift: Bool in w0; inout/borrowed self
                // in x20. Resolve both accessors before mutation. No field
                // offset or SpecializationOptions representation is assumed.
                let set = self.symbol(
                    c"$s15CoreAIDelegates21SpecializationOptionsV22expectFrequentReshapesSbvs",
                )?;
                let get = self.symbol(
                    c"$s15CoreAIDelegates21SpecializationOptionsV22expectFrequentReshapesSbvg",
                )?;
                arm64::call_sync(
                    set,
                    [usize::from(enabled), 0, 0],
                    ptr::null_mut(),
                    options.address(),
                );
                let actual = arm64::call_sync(get, [0; 3], ptr::null_mut(), options.address());
                if actual & 1 != usize::from(enabled) {
                    return Err(NativeFailure::Binding(
                        "native frequent-reshape option did not round-trip".into(),
                    ));
                }
            }
            let result = self.runtime.await_native(c"$s13CoreAIRuntime7AIModelV0A11AIDelegatesE10contentsOf7optionsAC10Foundation3URLV_AD21SpecializationOptionsVtYaKcfCTu",
                [model.address(),url.address(),options.address(),0],0,true)?;
            url.initialized = false;
            options.initialized = false;
            if result.error != 0 {
                return Err(self.failure(result.error, "load_model"));
            }
            model.initialized = true;
            Self::lifecycle(&result)?;
            let names = self.call(
                c"$s13CoreAIRuntime7AIModelV13functionNamesSaySSGvg",
                [0; 3],
                ptr::null_mut(),
                model.address(),
            )?;
            let names = self.strings(names)?;
            let id = self.id()?;
            self.models.insert(
                id,
                ModelRecord {
                    value: model,
                    names: names.clone(),
                    compute: load_options.compute,
                },
            );
            Ok(NativeModel {
                id,
                function_names: names,
            })
        }
    }
    /// # Safety
    /// The handle must belong to this session; uses native throwing call ABI.
    pub unsafe fn load_function(&mut self, model: u64, name: &str) -> Result<NativeFunction> {
        // SAFETY: A live model and owned String remain valid across the call.
        unsafe {
            let model_record = self
                .models
                .get(&model)
                .ok_or(NativeFailure::InvalidHandle {
                    kind: "model",
                    id: model,
                })?;
            if !model_record.names.iter().any(|n| n == name) {
                return Err(NativeFailure::InvalidData(format!(
                    "unknown function {name}"
                )));
            }
            let name = self.string(name)?;
            let md = self.metadata(super::FUNCTION_METADATA)?;
            let mut optional = NativeValue::allocate(self.optional(md)?)?;
            let error = arm64::call_throwing(
                self.symbol(
                    c"$s13CoreAIRuntime7AIModelV12loadFunction5namedAA09InferenceE0VSgSS_tKF",
                )?,
                [name.words[0], name.words[1], 0],
                optional.ptr(),
                model_record.value.address(),
            );
            if !error.is_null() {
                return Err(self.failure(error as _, "load_function"));
            }
            optional.initialized = true;
            let function = optional
                .take_optional(md)?
                .ok_or_else(|| NativeFailure::InvalidData("function was not found".into()))?;
            let descriptor = self.inspect_function(&function)?;
            let id = self.id()?;
            self.functions.insert(
                id,
                FunctionRecord {
                    value: function,
                    descriptor: descriptor.clone(),
                    model,
                },
            );
            Ok(NativeFunction { id, descriptor })
        }
    }
    /// # Safety
    /// The handle must belong to this worker-confined native session.
    #[cfg(feature = "abi-research")]
    pub unsafe fn descriptor(&self, function: u64) -> Result<NativeFunctionDescriptor> {
        self.functions
            .get(&function)
            .map(|f| f.descriptor.clone())
            .ok_or(NativeFailure::InvalidHandle {
                kind: "function",
                id: function,
            })
    }
    /// # Safety
    /// All work using this function must have completed on this worker.
    pub unsafe fn drop_function(&mut self, id: u64) -> Result<()> {
        self.functions
            .remove(&id)
            .map(drop)
            .ok_or(NativeFailure::InvalidHandle {
                kind: "function",
                id,
            })
    }
    /// # Safety
    /// Drop functions obtained from this model before dropping the model.
    pub unsafe fn drop_model(&mut self, id: u64) -> Result<()> {
        if self.functions.values().any(|f| f.model == id) {
            return Err(NativeFailure::InvalidData(
                "model still has live functions".into(),
            ));
        }
        self.models
            .remove(&id)
            .map(drop)
            .ok_or(NativeFailure::InvalidHandle { kind: "model", id })
    }

    unsafe fn inject(&self, value: &mut NativeValue, case: &CStr) -> Result<()> {
        // SAFETY: Verified enum metadata has its enum witnesses and case tag.
        unsafe {
            if value.metadata.layout.flags & 0x0020_0000 == 0 {
                return Err(NativeFailure::Binding("enum witnesses absent".into()));
            }
            let tag = self.symbol(case)?.cast::<u32>().read();
            let inject: unsafe extern "C" fn(*mut c_void, u32, *mut c_void) =
                mem::transmute(value.metadata.witness(13));
            inject(value.ptr(), tag, value.metadata.pointer as _);
            value.initialized = true;
            Ok(())
        }
    }
    unsafe fn dtype(&self, scalar: &NativeValue) -> Result<NativeDType> {
        // SAFETY: Scalar is initialized with ScalarType metadata.
        unsafe {
            let get: unsafe extern "C" fn(*mut c_void, *mut c_void) -> u32 =
                mem::transmute(scalar.metadata.witness(11));
            let tag = get(scalar.ptr(), scalar.metadata.pointer as _);
            for dtype in [
                NativeDType::F16,
                NativeDType::Bf16,
                NativeDType::F32,
                NativeDType::I32,
                NativeDType::I64,
                NativeDType::Bool,
            ] {
                if self.symbol(dtype.case())?.cast::<u32>().read() == tag {
                    return Ok(dtype);
                }
            }
            Err(NativeFailure::Unsupported(format!(
                "native scalar type tag {tag}"
            )))
        }
    }
    unsafe fn string_words(&self, words: [usize; 2]) -> Result<String> {
        // SAFETY: Input is an owned Swift String; exported APIs do the decoding.
        unsafe {
            let _string = OwnedWord {
                word: words[1],
                release: self.release(c"swift_bridgeObjectRelease")?,
            };
            let release = self.release(c"swift_release")?;
            let bytes = self.call(
                c"$sSS11utf8CStrings15ContiguousArrayVys4Int8VGvg",
                [words[0], words[1], 0],
                ptr::null_mut(),
                0,
            )?;
            let bytes = OwnedWord {
                word: bytes,
                release,
            };
            let md = self.symbol(c"$ss4Int8VN")? as usize;
            let count = self.call(
                c"$ss15ContiguousArrayV5countSivg",
                [bytes.word, md, 0],
                ptr::null_mut(),
                0,
            )?;
            if !(1..=1_048_576).contains(&count) {
                return Err(NativeFailure::Binding("invalid native UTF8 length".into()));
            }
            let mut buffer = Vec::with_capacity(count);
            for index in 0..count {
                let mut byte = 0u8;
                self.call(
                    c"$ss15ContiguousArrayVyxSicig",
                    [index, bytes.word, md],
                    ptr::from_mut(&mut byte).cast(),
                    0,
                )?;
                buffer.push(byte);
            }
            if buffer.pop() != Some(0) {
                return Err(NativeFailure::Binding(
                    "native string lacks terminator".into(),
                ));
            }
            String::from_utf8(buffer).map_err(|e| NativeFailure::Binding(e.to_string()))
        }
    }
    unsafe fn strings(&self, word: usize) -> Result<Vec<String>> {
        // SAFETY: Input is the +1 Array<String> returned by a verified accessor.
        unsafe {
            let array = OwnedWord {
                word,
                release: self.release(c"swift_bridgeObjectRelease")?,
            };
            let md = self.symbol(c"$sSSN")? as usize;
            let count = self.call(c"$sSa5countSivg", [word, md, 0], ptr::null_mut(), 0)?;
            if count > 16384 {
                return Err(NativeFailure::Binding("excessive native name count".into()));
            }
            let mut names = Vec::with_capacity(count);
            for index in 0..count {
                let mut words = [0usize; 2];
                self.call(
                    c"$sSayxSicig",
                    [index, array.word, md],
                    words.as_mut_ptr().cast(),
                    0,
                )?;
                names.push(self.string_words(words)?);
            }
            Ok(names)
        }
    }
    unsafe fn integers(&self, word: usize) -> Result<Vec<isize>> {
        // SAFETY: Input is an owned Array<Int>, read through count/subscript.
        unsafe {
            let array = OwnedWord {
                word,
                release: self.release(c"swift_bridgeObjectRelease")?,
            };
            let md = self.symbol(c"$sSiN")? as usize;
            let count = self.call(c"$sSa5countSivg", [word, md, 0], ptr::null_mut(), 0)?;
            if count > 64 {
                return Err(NativeFailure::Unsupported("tensor rank exceeds 64".into()));
            }
            let mut result = vec![0isize; count];
            for (index, value) in result.iter_mut().enumerate() {
                self.call(
                    c"$sSayxSicig",
                    [index, array.word, md],
                    ptr::from_mut(value).cast(),
                    0,
                )?;
            }
            Ok(result)
        }
    }
    unsafe fn int_array(&self, values: &[usize]) -> Result<OwnedWord> {
        // SAFETY: Counts and dimensions have been prevalidated as Swift Ints.
        unsafe {
            let md = self.symbol(c"$sSiN")? as usize;
            let (array_md, state) = self.pair(c"$sSaMa", [0, md, 0], ptr::null_mut(), 0)?;
            if array_md == 0 || state != 0 {
                return Err(NativeFailure::Binding(
                    "incomplete Int array metadata".into(),
                ));
            }
            let zero = 0isize;
            let release = self.release(c"swift_bridgeObjectRelease")?;
            let modify = self.symbol(c"$sSayxSiciM")?;
            let word = self.call(
                c"$sSa9repeating5countSayxGx_SitcfC",
                [ptr::from_ref(&zero) as usize, values.len(), md],
                ptr::null_mut(),
                0,
            )?;
            let mut array = OwnedWord { word, release };
            for (index, value) in values.iter().enumerate() {
                let mut scratch = [0usize; 4];
                let (resume, element) = arm64::call_sync_pair(
                    modify,
                    [scratch.as_mut_ptr() as usize, index, array_md],
                    ptr::null_mut(),
                    ptr::from_mut(&mut array.word) as usize,
                );
                (element as *mut isize).write(*value as isize);
                arm64::call_sync(
                    resume as _,
                    [scratch.as_mut_ptr() as usize, 0, 0],
                    ptr::null_mut(),
                    0,
                );
            }
            Ok(array)
        }
    }

    unsafe fn inspect_function(&self, function: &NativeValue) -> Result<NativeFunctionDescriptor> {
        // SAFETY: All descriptor operations borrow live native values.
        unsafe {
            let mut descriptor = NativeValue::allocate(
                self.metadata(c"$s13CoreAIRuntime27InferenceFunctionDescriptorVMa")?,
            )?;
            self.call(
                c"$s13CoreAIRuntime17InferenceFunctionV10descriptorAA0cD10DescriptorVvg",
                [0; 3],
                descriptor.ptr(),
                function.address(),
            )?;
            descriptor.initialized = true;
            let name = self.pair(
                c"$s13CoreAIRuntime27InferenceFunctionDescriptorV4nameSSvg",
                [0; 3],
                ptr::null_mut(),
                descriptor.address(),
            )?;
            let name = self.string_words([name.0, name.1])?;
            let mut groups = Vec::new();
            for (names,get) in [
                (c"$s13CoreAIRuntime27InferenceFunctionDescriptorV10inputNamesSaySSGvg",c"$s13CoreAIRuntime27InferenceFunctionDescriptorV05inputE02ofAA0C5ValueV0E0OSgSS_tF"),
                (c"$s13CoreAIRuntime27InferenceFunctionDescriptorV11outputNamesSaySSGvg",c"$s13CoreAIRuntime27InferenceFunctionDescriptorV06outputE02ofAA0C5ValueV0E0OSgSS_tF"),
                (c"$s13CoreAIRuntime27InferenceFunctionDescriptorV10stateNamesSaySSGvg",c"$s13CoreAIRuntime27InferenceFunctionDescriptorV05stateE02ofAA0C5ValueV0E0OSgSS_tF"),
            ] {
                let word=self.call(names,[0;3],ptr::null_mut(),descriptor.address())?;
                let mut group=Vec::new();
                for name in self.strings(word)? { group.push(self.inspect_tensor(&descriptor,get,name)?); }
                groups.push(group);
            }
            let mut groups = groups.into_iter();
            Ok(NativeFunctionDescriptor {
                name,
                inputs: groups.next().unwrap_or_default(),
                outputs: groups.next().unwrap_or_default(),
                states: groups.next().unwrap_or_default(),
            })
        }
    }
    unsafe fn inspect_tensor(
        &self,
        descriptor: &NativeValue,
        getter: &CStr,
        name: String,
    ) -> Result<NativeTensorDescriptor> {
        // SAFETY: Optional enum, associated payload projection and take match
        // OwnedReference.swift and its compiled VWT11/12/4 sequence.
        unsafe {
            let enum_md = self.metadata(c"$s13CoreAIRuntime14InferenceValueV10DescriptorOMa")?;
            let mut optional = NativeValue::allocate(self.optional(enum_md)?)?;
            let key = self.string(&name)?;
            self.call(
                getter,
                [key.words[0], key.words[1], 0],
                optional.ptr(),
                descriptor.address(),
            )?;
            optional.initialized = true;
            let mut value = optional
                .take_optional(enum_md)?
                .ok_or_else(|| NativeFailure::Binding(format!("missing descriptor for {name}")))?;
            let tag: unsafe extern "C" fn(*mut c_void, *mut c_void) -> u32 =
                mem::transmute(enum_md.witness(11));
            let nd_tag=self.symbol(c"$s13CoreAIRuntime14InferenceValueV10DescriptorO7ndArrayyAeA07NDArrayE0VcAEmFWC")?.cast::<u32>().read();
            if tag(value.ptr(), enum_md.pointer as _) != nd_tag {
                return Err(NativeFailure::Unsupported(format!(
                    "non-tensor value {name}"
                )));
            }
            let payload_md = self.metadata(c"$s13CoreAIRuntime17NDArrayDescriptorVMa")?;
            let mut payload = NativeValue::allocate(payload_md)?;
            let project: unsafe extern "C" fn(*mut c_void, *mut c_void) =
                mem::transmute(enum_md.witness(12));
            let take: unsafe extern "C" fn(*mut c_void, *mut c_void, *mut c_void) -> *mut c_void =
                mem::transmute(payload_md.witness(4));
            project(value.ptr(), enum_md.pointer as _);
            take(payload.ptr(), value.ptr(), payload_md.pointer as _);
            value.initialized = false;
            payload.initialized = true;
            let shape = self.call(
                c"$s13CoreAIRuntime17NDArrayDescriptorV5shapeSaySiGvg",
                [0; 3],
                ptr::null_mut(),
                payload.address(),
            )?;
            let shape = self.integers(shape)?;
            let mut scalar = NativeValue::allocate(self.metadata(super::SCALAR_METADATA)?)?;
            self.call(
                c"$s13CoreAIRuntime17NDArrayDescriptorV10scalarTypeAA0C0V06ScalarF0Ovg",
                [0; 3],
                scalar.ptr(),
                payload.address(),
            )?;
            scalar.initialized = true;
            Ok(NativeTensorDescriptor {
                name,
                shape,
                dtype: self.dtype(&scalar)?,
            })
        }
    }

    unsafe fn tensor(&self, data: &NativeTensor) -> Result<NativeValue> {
        // SAFETY: Callers validate scalar shape and full byte count first.
        unsafe {
            validate_tensor(data)?;
            let mut value = NativeValue::allocate(self.metadata(super::NDARRAY_METADATA)?)?;
            let mut scalar = NativeValue::allocate(self.metadata(super::SCALAR_METADATA)?)?;
            self.inject(&mut scalar, data.dtype.case())?;
            let mut shape = self.int_array(&data.shape)?;
            let initialize = self.symbol(
                c"$s13CoreAIRuntime7NDArrayV5shape10scalarTypeACSaySiG_AC06ScalarF0OtcfC",
            )?;
            arm64::call_sync(
                initialize,
                [shape.word, scalar.address(), 0],
                value.ptr(),
                0,
            );
            // Forget only the reference consumed by the native initializer.
            shape.word = 0;
            scalar.initialized = false;
            value.initialized = true;
            self.write_tensor(&mut value, &data.bytes)?;
            Ok(value)
        }
    }
    unsafe fn write_tensor(&self, value: &mut NativeValue, bytes: &[u8]) -> Result<()> {
        // SAFETY: The caller exclusively owns this initialized tensor, before
        // inserting any views. The view owns the byte-pointer access lifetime.
        unsafe {
            let mut view = NativeValue::allocate(
                self.metadata(c"$s13CoreAIRuntime7NDArrayV14MutableRawViewVMa")?,
            )?;
            self.call(
                c"$s13CoreAIRuntime7NDArrayV14mutableRawViewAC07MutableeF0VyF",
                [0; 3],
                view.ptr(),
                value.address(),
            )?;
            view.initialized = true;
            let start = self.call(
                c"$s13CoreAIRuntime7NDArrayV14MutableRawViewV6_startSvyF",
                [0; 3],
                ptr::null_mut(),
                view.address(),
            )?;
            let count = self.call(
                c"$s13CoreAIRuntime7NDArrayV14MutableRawViewV16storageByteCountSiyF",
                [0; 3],
                ptr::null_mut(),
                view.address(),
            )?;
            if (start == 0 && count != 0) || count != bytes.len() {
                return Err(NativeFailure::Binding(
                    "native mutable storage byte count mismatch".into(),
                ));
            }
            if count != 0 {
                ptr::copy_nonoverlapping(bytes.as_ptr(), start as *mut u8, count);
            }
            Ok(())
        }
    }
    unsafe fn read_tensor(&self, value: &NativeValue) -> Result<NativeTensor> {
        // SAFETY: Native work has completed; only immutable views are created.
        unsafe {
            let shape = self.call(
                c"$s13CoreAIRuntime7NDArrayV5shapeSaySiGvg",
                [0; 3],
                ptr::null_mut(),
                value.address(),
            )?;
            let shape = self.integers(shape)?;
            if shape.iter().any(|d| *d < 0) {
                return Err(NativeFailure::Unsupported(
                    "unresolved output dimension".into(),
                ));
            }
            let shape: Vec<usize> = shape.into_iter().map(|d| d as usize).collect();
            let strides = self.call(
                c"$s13CoreAIRuntime7NDArrayV7stridesSaySiGvg",
                [0; 3],
                ptr::null_mut(),
                value.address(),
            )?;
            let strides = self.integers(strides)?;
            let mut expected = vec![0isize; shape.len()];
            let mut stride = 1usize;
            for i in (0..shape.len()).rev() {
                expected[i] = isize::try_from(stride)
                    .map_err(|_| NativeFailure::Unsupported("output strides overflow".into()))?;
                stride = stride
                    .checked_mul(shape[i])
                    .ok_or_else(|| NativeFailure::Unsupported("output size overflow".into()))?;
            }
            if stride != 0 && strides != expected {
                return Err(NativeFailure::Unsupported(
                    "noncontiguous output tensor".into(),
                ));
            }
            let mut scalar = NativeValue::allocate(self.metadata(super::SCALAR_METADATA)?)?;
            self.call(
                c"$s13CoreAIRuntime7NDArrayV10scalarTypeAC06ScalarE0Ovg",
                [0; 3],
                scalar.ptr(),
                value.address(),
            )?;
            scalar.initialized = true;
            let dtype = self.dtype(&scalar)?;
            let expected = crate::dtype::element_count(&shape, dtype.byte_width())
                .map_err(|e| NativeFailure::Unsupported(e.to_string()))?
                * dtype.byte_width();
            let mut view =
                NativeValue::allocate(self.metadata(c"$s13CoreAIRuntime7NDArrayV7RawViewVMa")?)?;
            self.call(
                c"$s13CoreAIRuntime7NDArrayV7rawViewAC03RawE0VyF",
                [0; 3],
                view.ptr(),
                value.address(),
            )?;
            view.initialized = true;
            let (start, count) = self.pair(
                c"$s13CoreAIRuntime7NDArrayV7RawViewV5bytess0D4SpanVvg",
                [0; 3],
                ptr::null_mut(),
                view.address(),
            )?;
            if (start == 0 && count != 0) || count != expected {
                return Err(NativeFailure::Binding(
                    "native output storage byte count mismatch".into(),
                ));
            }
            let mut bytes = vec![0u8; count];
            if count != 0 {
                ptr::copy_nonoverlapping(start as *const u8, bytes.as_mut_ptr(), count);
            }
            Ok(NativeTensor {
                dtype,
                shape,
                bytes,
            })
        }
    }
    unsafe fn insert_input(
        &self,
        inputs: &mut NativeValue,
        tensor: &NativeValue,
        name: &str,
    ) -> Result<()> {
        // SAFETY: The tensor remains immutable until Inputs is destroyed, and
        // insert consumes the RawView while copying its lifetime dependence.
        unsafe {
            let key = self.string(name)?;
            let mut view =
                NativeValue::allocate(self.metadata(c"$s13CoreAIRuntime7NDArrayV7RawViewVMa")?)?;
            self.call(
                c"$s13CoreAIRuntime7NDArrayV7rawViewAC03RawE0VyF",
                [0; 3],
                view.ptr(),
                tensor.address(),
            )?;
            view.initialized = true;
            self.call(c"$s13CoreAIRuntime17InferenceFunctionV6InputsV6insert_3foryAA7NDArrayV7RawViewVn_SStF",[view.address(),key.words[0],key.words[1]],ptr::null_mut(),inputs.address())?;
            view.initialized = false;
            Ok(())
        }
    }
    unsafe fn insert_mutable(
        &self,
        views: &mut NativeValue,
        tensor: &mut NativeValue,
        name: &str,
    ) -> Result<()> {
        // SAFETY: Exclusive tensor storage remains live until consumed Views
        // completes. No other view of these state/output tensors is created.
        unsafe {
            let key = self.string(name)?;
            let mut view = NativeValue::allocate(
                self.metadata(c"$s13CoreAIRuntime7NDArrayV14MutableRawViewVMa")?,
            )?;
            self.call(
                c"$s13CoreAIRuntime7NDArrayV14mutableRawViewAC07MutableeF0VyF",
                [0; 3],
                view.ptr(),
                tensor.address(),
            )?;
            view.initialized = true;
            self.call(c"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsV6insert_3foryAA7NDArrayV0E7RawViewVn_SStF",[view.address(),key.words[0],key.words[1]],ptr::null_mut(),views.address())?;
            view.initialized = false;
            Ok(())
        }
    }

    /// # Safety
    /// Requires the recorded run/Inputs/MutableViews ABI. This blocks until the
    /// actual native task completes. No pointer or borrowed native view escapes.
    pub unsafe fn run(
        &mut self,
        function: u64,
        inputs: Vec<(String, NativeTensor)>,
        states: Vec<(String, NativeTensor)>,
        output_views: Vec<(String, NativeTensor)>,
    ) -> Result<NativeRunResult> {
        if self.uses_owned_stream(function)? {
            if !output_views.is_empty() {
                return Err(NativeFailure::Unsupported(
                    "owned output views are unavailable on the GPU stream path; use explicit Metal bindings".into(),
                ));
            }
            // SAFETY: The helper validates and retains every native owner until
            // stream completion, including when the public future is abandoned.
            return unsafe { self.run_owned_on_stream(function, inputs, states) };
        }
        let gpu = self.function_compute(function)? == NativeCompute::GpuPreferred;
        // SAFETY: Complete validation precedes native tensor construction. All
        // native argument allocations outlive both child and task completion.
        unsafe {
            let function = self
                .functions
                .get(&function)
                .ok_or(NativeFailure::InvalidHandle {
                    kind: "function",
                    id: function,
                })?;
            validate_group(&inputs, &function.descriptor.inputs, true)?;
            validate_group(&states, &function.descriptor.states, true)?;
            validate_group(&output_views, &function.descriptor.outputs, false)?;
            // Declare owned buffers BEFORE their dependent view containers so
            // every early-error unwind destroys view containers first.
            let native_inputs: Vec<_> = inputs
                .iter()
                .map(|(n, t)| self.tensor(t).map(|v| (n.clone(), v)))
                .collect::<Result<_>>()?;
            let mut native_states: Vec<_> = states
                .iter()
                .map(|(n, t)| self.tensor(t).map(|v| (n.clone(), v)))
                .collect::<Result<_>>()?;
            let mut native_output_views: Vec<_> = output_views
                .iter()
                .map(|(n, t)| self.tensor(t).map(|v| (n.clone(), v)))
                .collect::<Result<_>>()?;
            let mut input_views = NativeValue::allocate(
                self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV6InputsVMa")?,
            )?;
            self.call(
                c"$s13CoreAIRuntime17InferenceFunctionV6InputsVAEycfC",
                [0; 3],
                input_views.ptr(),
                0,
            )?;
            input_views.initialized = true;
            for (name, tensor) in &native_inputs {
                self.insert_input(&mut input_views, tensor, name)?;
            }
            let md = self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVMa")?;
            let mut state_views = NativeValue::allocate(md)?;
            let mut output_views = NativeValue::allocate(md)?;
            self.call(
                c"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC",
                [0; 3],
                state_views.ptr(),
                0,
            )?;
            state_views.initialized = true;
            self.call(
                c"$s13CoreAIRuntime17InferenceFunctionV12MutableViewsVAEycfC",
                [0; 3],
                output_views.ptr(),
                0,
            )?;
            output_views.initialized = true;
            for (name, tensor) in &mut native_states {
                self.insert_mutable(&mut state_views, tensor, name)?;
            }
            for (name, tensor) in &mut native_output_views {
                self.insert_mutable(&mut output_views, tensor, name)?;
            }
            let mut outputs = NativeValue::allocate(
                self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV7OutputsVMa")?,
            )?;
            let result=self.runtime.await_native(c"$s13CoreAIRuntime17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVAC6InputsV_AC07MutableI0VnAMntYaKFTu",
                [outputs.address(),input_views.address(),state_views.address(),output_views.address()],function.value.address(),true)?;
            state_views.initialized = false;
            output_views.initialized = false;
            if result.error != 0 {
                return Err(self.failure(result.error, "run"));
            }
            outputs.initialized = true;
            Self::lifecycle(&result)?;
            let value_md = self.metadata(c"$s13CoreAIRuntime14InferenceValueVMa")?;
            let optional_value_md = self.optional(value_md)?;
            let tensor_md = self.metadata(super::NDARRAY_METADATA)?;
            let optional_tensor_md = self.optional(tensor_md)?;
            let mut returned = Vec::new();
            for descriptor in &function.descriptor.outputs {
                let name = &descriptor.name;
                let key = self.string(name)?;
                let mut optional = NativeValue::allocate(optional_value_md)?;
                self.call(
                    c"$s13CoreAIRuntime17InferenceFunctionV7OutputsV6removeyAA0C5ValueVSgSSF",
                    [key.words[0], key.words[1], 0],
                    optional.ptr(),
                    outputs.address(),
                )?;
                optional.initialized = true;
                if let Some(mut value) = optional.take_optional(value_md)? {
                    let mut array = NativeValue::allocate(optional_tensor_md)?;
                    self.call(
                        c"$s13CoreAIRuntime14InferenceValueV7ndArrayAA7NDArrayVSgvg",
                        [0; 3],
                        array.ptr(),
                        value.address(),
                    )?;
                    value.initialized = false;
                    array.initialized = true;
                    let array = array.take_optional(tensor_md)?.ok_or_else(|| {
                        NativeFailure::Unsupported(format!("output {name} is not NDArray"))
                    })?;
                    if gpu {
                        handles::validate_gpu_handle(&self.tensor_handle_info(&array)?)?;
                    }
                    let tensor = self.read_tensor(&array)?;
                    validate_against(&tensor, descriptor)?;
                    returned.push((name.clone(), tensor));
                } else if let Some((_, tensor)) =
                    native_output_views.iter().find(|(n, _)| n == name)
                {
                    if gpu {
                        handles::validate_gpu_handle(&self.tensor_handle_info(tensor)?)?;
                    }
                    let tensor = self.read_tensor(tensor)?;
                    validate_against(&tensor, descriptor)?;
                    returned.push((name.clone(), tensor));
                } else {
                    return Err(NativeFailure::Binding(format!(
                        "native run omitted output {name}"
                    )));
                }
            }
            let remaining = self.call(
                c"$s13CoreAIRuntime17InferenceFunctionV7OutputsV5countSivg",
                [0; 3],
                ptr::null_mut(),
                outputs.address(),
            )?;
            if remaining != 0 {
                return Err(NativeFailure::Unsupported(
                    "native run returned undescribed outputs".into(),
                ));
            }
            let mut returned_states = Vec::new();
            for (name, tensor) in &native_states {
                if gpu {
                    handles::validate_gpu_handle(&self.tensor_handle_info(tensor)?)?;
                }
                returned_states.push((name.clone(), self.read_tensor(tensor)?));
            }
            Ok(NativeRunResult {
                outputs: returned,
                states: returned_states,
            })
        }
    }
}
fn validate_tensor(tensor: &NativeTensor) -> Result<()> {
    let width = tensor.dtype.byte_width();
    let bytes = crate::dtype::element_count(&tensor.shape, width)
        .map_err(|e| NativeFailure::InvalidData(e.to_string()))?
        * width;
    if bytes != tensor.bytes.len() {
        return Err(NativeFailure::InvalidData(
            "tensor shape/dtype/byte count mismatch".into(),
        ));
    }
    if tensor.dtype == NativeDType::Bool && tensor.bytes.iter().any(|b| *b > 1) {
        return Err(NativeFailure::InvalidData(
            "bool tensor bytes must be 0 or 1".into(),
        ));
    }
    Ok(())
}
fn validate_against(tensor: &NativeTensor, descriptor: &NativeTensorDescriptor) -> Result<()> {
    validate_tensor(tensor)?;
    if descriptor.dtype != tensor.dtype
        || descriptor.shape.len() != tensor.shape.len()
        || descriptor
            .shape
            .iter()
            .zip(&tensor.shape)
            .any(|(a, b)| *a >= 0 && *a as usize != *b)
    {
        return Err(NativeFailure::InvalidData(format!(
            "tensor does not match descriptor {}",
            descriptor.name
        )));
    }
    Ok(())
}

fn validate_group(
    values: &[(String, NativeTensor)],
    descriptors: &[NativeTensorDescriptor],
    required: bool,
) -> Result<()> {
    let mut names = HashSet::new();
    for (name, tensor) in values {
        if name.contains('\0') || !names.insert(name) {
            return Err(NativeFailure::InvalidData(
                "duplicate or invalid tensor name".into(),
            ));
        }
        let descriptor = descriptors
            .iter()
            .find(|d| d.name == *name)
            .ok_or_else(|| NativeFailure::InvalidData(format!("unknown tensor name {name}")))?;
        validate_against(tensor, descriptor)?;
    }
    if required && values.len() != descriptors.len() {
        return Err(NativeFailure::InvalidData("missing named tensors".into()));
    }
    Ok(())
}

#[cfg(test)]
mod dynamic_signature_tests {
    use super::*;

    #[test]
    fn native_empty_storage_keeps_the_nonzero_dimension_guard() {
        let limit = crate::dtype::MAX_TENSOR_BYTES;
        let mut tensor = NativeTensor {
            dtype: NativeDType::F32,
            shape: vec![0, limit / 4],
            bytes: vec![],
        };
        assert!(validate_tensor(&tensor).is_ok());
        tensor.shape[1] += 1;
        assert!(validate_tensor(&tensor).is_err());
        tensor.shape = vec![isize::MAX as usize, 2];
        assert!(validate_tensor(&tensor).is_err());
    }

    #[test]
    fn dynamic_dimensions_accept_concrete_calls_without_relaxing_fixed_dimensions() {
        let descriptor = NativeTensorDescriptor {
            name: "x".into(),
            shape: vec![-1, 3],
            dtype: NativeDType::F32,
        };
        for rows in [0, 1, 2, 7] {
            let tensor = NativeTensor {
                dtype: NativeDType::F32,
                shape: vec![rows, 3],
                bytes: vec![0; rows * 3 * 4],
            };
            assert!(validate_against(&tensor, &descriptor).is_ok());
        }
        for (dtype, shape, bytes) in [
            (NativeDType::F32, vec![2, 4], vec![0; 32]),
            (NativeDType::F32, vec![6], vec![0; 24]),
            (NativeDType::I32, vec![2, 3], vec![0; 24]),
            (NativeDType::F32, vec![2, 3], vec![0; 20]),
            (NativeDType::F32, vec![usize::MAX, 3], vec![]),
        ] {
            assert!(
                validate_against(
                    &NativeTensor {
                        dtype,
                        shape,
                        bytes
                    },
                    &descriptor
                )
                .is_err()
            );
        }
    }
}
