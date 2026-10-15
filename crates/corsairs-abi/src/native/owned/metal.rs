//! Owned Metal resources and the compiler-verified encoded-inference path.
use super::*;
use std::arch::asm;

#[link(name = "objc")]
unsafe extern "C" {
    fn objc_retain(object: *mut c_void) -> *mut c_void;
    fn objc_release(object: *mut c_void);
    fn objc_autoreleasePoolPush() -> *mut c_void;
    fn objc_autoreleasePoolPop(pool: *mut c_void);
    fn sel_registerName(name: *const std::ffi::c_char) -> *mut c_void;
}

/// One retained Metal object, including across a queued foreign import.
pub struct NativeMetalObject(NonNull<c_void>);
// SAFETY: Constructed only for retained MTLCommandQueue/MTLBuffer objects, whose
// SDK protocols are thread-safe. The unsafe importer supplies that type contract.
unsafe impl Send for NativeMetalObject {}
impl NativeMetalObject {
    /// # Safety
    /// Pointer is a live MTLCommandQueue or MTLBuffer and remains live for this
    /// call. The caller accepts the external alias/concurrency import contract.
    /// Imported buffer backing remains mapped, validly initialized and
    /// nonpurgeable for every retained view/job, including external no-copy data.
    pub unsafe fn retain(pointer: *mut c_void) -> Result<Self> {
        let pointer = NonNull::new(pointer)
            .ok_or_else(|| NativeFailure::InvalidData("null Metal object".into()))?;
        // SAFETY: The caller supplies a valid retainable Metal object.
        unsafe { objc_retain(pointer.as_ptr()) };
        Ok(Self(pointer))
    }
    pub fn as_raw(&self) -> *mut c_void {
        self.0.as_ptr()
    }
    unsafe fn duplicate(&self) -> Self {
        // SAFETY: This owner keeps the Metal reference live for the retain.
        unsafe { objc_retain(self.as_raw()) };
        Self(self.0)
    }
}
impl Drop for NativeMetalObject {
    fn drop(&mut self) {
        // SAFETY: Balance this object's unique retained reference.
        unsafe { objc_release(self.as_raw()) };
    }
}

struct Pool(*mut c_void);
impl Pool {
    unsafe fn new() -> Self {
        // SAFETY: Each operation owns its thread-local autorelease pool.
        Self(unsafe { objc_autoreleasePoolPush() })
    }
}
impl Drop for Pool {
    fn drop(&mut self) {
        // SAFETY: All scoped autoreleased temporaries are finished on this thread.
        unsafe { objc_autoreleasePoolPop(self.0) };
    }
}

type Message = unsafe extern "C" fn(*mut c_void, *mut c_void) -> usize;
type Message2 = unsafe extern "C" fn(*mut c_void, *mut c_void, usize, usize) -> usize;
type MessageVoid = unsafe extern "C" fn(*mut c_void, *mut c_void);
struct Support {
    message: Message,
    message2: Message2,
    message_void: MessageVoid,
    device: unsafe extern "C" fn() -> *mut c_void,
    _metal: super::super::loader::Library,
}
impl Support {
    unsafe fn load() -> Result<Rc<Self>> {
        // SAFETY: Fixed system libraries and compiler-established C ABI entries.
        unsafe {
            let metal = super::super::loader::Library::open(
                c"/System/Library/Frameworks/Metal.framework/Versions/A/Metal",
            )?;
            let objc = super::super::loader::Library::open(c"/usr/lib/libobjc.A.dylib")?;
            let address = objc.symbol(c"objc_msgSend")?.as_ptr();
            Ok(Rc::new(Self {
                message: mem::transmute::<*mut c_void, Message>(address),
                message2: mem::transmute::<*mut c_void, Message2>(address),
                message_void: mem::transmute::<*mut c_void, MessageVoid>(address),
                device: mem::transmute::<*mut c_void, unsafe extern "C" fn() -> *mut c_void>(
                    metal.symbol(c"MTLCreateSystemDefaultDevice")?.as_ptr(),
                ),
                _metal: metal,
            }))
        }
    }
    unsafe fn get(&self, object: &NativeMetalObject, name: &CStr) -> usize {
        // SAFETY: Callers select verified zero-argument Metal properties/methods.
        unsafe { (self.message)(object.as_raw(), sel_registerName(name.as_ptr())) }
    }
}
struct QueueRecord {
    stream: OwnedWord,
    queue: NativeMetalObject,
    device: NativeMetalObject,
    support: Rc<Support>,
}
struct BufferRecord {
    object: NativeMetalObject,
    queue: Rc<QueueRecord>,
    offset: usize,
    bytes: usize,
    dtype: NativeDType,
    shape: Vec<usize>,
}
enum ValueKind {
    Buffer(Rc<BufferRecord>),
    Encoded {
        future: NativeValue,
        array: NativeValue,
    },
}
struct ValueRecord {
    kind: ValueKind,
    queue: Rc<QueueRecord>,
    dtype: NativeDType,
    shape: Vec<usize>,
    // Retain actual backing owners; pointer identity/ranges remain meaningful
    // even after the original public buffer handles have been released.
    origins: Vec<Rc<BufferRecord>>,
}
#[derive(Default)]
pub(super) struct Store {
    values: HashMap<u64, Rc<ValueRecord>>,
    buffers: HashMap<u64, Rc<BufferRecord>>,
    queues: HashMap<u64, Rc<QueueRecord>>,
    // Private convenience-run stream, reused across calls/models/generations.
    // It is separate from the public object stores counted by lifecycle probes.
    run_queue: Option<Rc<QueueRecord>>,
}
impl Store {
    pub(super) fn clear(&mut self) {
        self.values.clear();
        self.buffers.clear();
        self.queues.clear();
        self.run_queue = None;
    }
}

#[derive(Clone, Debug)]
pub struct NativeMetalTensor {
    pub id: u64,
    pub dtype: NativeDType,
    pub shape: Vec<usize>,
}
#[derive(Clone, Copy, Debug)]
pub enum NativeMetalInput {
    Buffer(u64),
    Value(u64),
}

unsafe fn call6(
    target: *mut c_void,
    args: [usize; 6],
    out: *mut c_void,
    receiver: usize,
) -> (usize, usize, usize) {
    let first: usize;
    let second: usize;
    let error: usize;
    // SAFETY: Every caller supplies one compiler-verified lowered call shape.
    unsafe {
        asm!("blr x16",in("x16") target,inlateout("x0") args[0]=>first,inlateout("x1") args[1]=>second,inlateout("x2") args[2]=>_,inlateout("x3") args[3]=>_,inlateout("x4") args[4]=>_,inlateout("x5") args[5]=>_,inlateout("x8") out=>_,inlateout("x20") receiver=>_,inlateout("x21") 0usize=>error,lateout("x22") _,clobber_abi("C"));
    }
    (first, second, error)
}

fn count(dtype: NativeDType, shape: &[usize]) -> Result<usize> {
    crate::dtype::element_count(shape, dtype.byte_width())
        .map(|n| n * dtype.byte_width())
        .map_err(|e| NativeFailure::InvalidData(e.to_string()))
}
fn invalid(kind: &'static str, id: u64) -> NativeFailure {
    NativeFailure::InvalidHandle { kind, id }
}
fn overlaps(a: &BufferRecord, b: &BufferRecord) -> bool {
    overlaps_ranges(
        (a.object.as_raw() as usize, a.offset, a.bytes),
        (b.object.as_raw() as usize, b.offset, b.bytes),
    )
}
fn overlaps_ranges(a: (usize, usize, usize), b: (usize, usize, usize)) -> bool {
    a.0 == b.0 && a.2 != 0 && b.2 != 0 && a.1 < b.1 + b.2 && b.1 < a.1 + a.2
}
fn matches_descriptor(
    dtype: NativeDType,
    shape: &[usize],
    d: &NativeTensorDescriptor,
) -> Result<()> {
    if dtype != d.dtype
        || shape.len() != d.shape.len()
        || shape
            .iter()
            .zip(&d.shape)
            .any(|(actual, wanted)| *wanted >= 0 && *actual != *wanted as usize)
    {
        Err(NativeFailure::InvalidData(format!(
            "Metal tensor {} does not match its descriptor",
            d.name
        )))
    } else {
        Ok(())
    }
}

impl NativeSession {
    #[cfg(test)]
    pub(crate) fn live_metal_counts(&self) -> (usize, usize, usize) {
        (
            self.metal.queues.len(),
            self.metal.buffers.len(),
            self.metal.values.len(),
        )
    }
    #[cfg(test)]
    pub(crate) fn owned_stream_identity(&self) -> Option<usize> {
        self.metal.run_queue.as_ref().map(|queue| queue.stream.word)
    }
    /// # Safety
    /// All native Metal methods run exclusively on this session's worker.
    pub unsafe fn metal_queue(&mut self, imported: Option<NativeMetalObject>) -> Result<u64> {
        // SAFETY: Verified Metal C/Objective-C and Swift stream constructors.
        unsafe {
            let _pool = Pool::new();
            let support = Support::load()?;
            let (device, queue) = if let Some(queue) = imported {
                let device = NativeMetalObject::retain(support.get(&queue, c"device") as _)?;
                (device, queue)
            } else {
                let device = NativeMetalObject(
                    NonNull::new((support.device)())
                        .ok_or_else(|| NativeFailure::Unsupported("no Metal device".into()))?,
                );
                let queue = NativeMetalObject(
                    NonNull::new(support.get(&device, c"newCommandQueue") as _).ok_or_else(
                        || NativeFailure::Binding("Metal queue allocation failed".into()),
                    )?,
                );
                (device, queue)
            };
            let metadata = self.metadata(c"$s13CoreAIRuntime13ComputeStreamCMa")?;
            let create = self.symbol(
                c"$s13CoreAIRuntime13ComputeStreamC12commandQueueACSo010MTLCommandF0_p_tcfC",
            )?;
            let release = self.release(c"swift_release")?;
            let passed = queue.duplicate();
            let raw = passed.as_raw();
            mem::forget(passed);
            let stream = OwnedWord {
                word: arm64::call_sync(
                    create,
                    [raw as usize, 0, 0],
                    ptr::null_mut(),
                    metadata.pointer,
                ),
                release,
            };
            if stream.word == 0 {
                return Err(NativeFailure::Binding("null ComputeStream".into()));
            }
            let record = Rc::new(QueueRecord {
                stream,
                queue,
                device,
                support,
            });
            self.metal_fence_record(&record)?;
            let id = self.id()?;
            self.metal.queues.insert(id, record);
            Ok(id)
        }
    }
    unsafe fn metal_fence_record(&self, queue: &QueueRecord) -> Result<()> {
        // SAFETY: The retained stream and queue remain live across both fences.
        unsafe {
            let result = self.runtime.await_native(
                c"$s13CoreAIRuntime13ComputeStreamC20currentWorkCompletedyyYaFTu",
                [0; 4],
                queue.stream.word,
                false,
            )?;
            Self::lifecycle(&result)?;
            let command = queue.support.get(&queue.queue, c"commandBuffer") as *mut c_void;
            if command.is_null() {
                return Err(NativeFailure::Binding(
                    "Metal fence allocation failed".into(),
                ));
            }
            let command = NativeMetalObject::retain(command)?;
            (queue.support.message_void)(command.as_raw(), sel_registerName(c"commit".as_ptr()));
            (queue.support.message_void)(
                command.as_raw(),
                sel_registerName(c"waitUntilCompleted".as_ptr()),
            );
            if queue.support.get(&command, c"status") != 4 {
                return Err(NativeFailure::Binding(
                    "Metal command fence did not complete successfully".into(),
                ));
            }
            Ok(())
        }
    }
    /// # Safety
    /// Requires a session-local queue. The caller preserves external ordering.
    pub unsafe fn metal_fence(&self, id: u64) -> Result<()> {
        // SAFETY: Lookup retains the queue across the native fence.
        unsafe {
            let _pool = Pool::new();
            self.metal_fence_record(
                self.metal
                    .queues
                    .get(&id)
                    .ok_or_else(|| invalid("Metal queue", id))?,
            )
        }
    }
    /// # Safety
    /// Imported objects follow the explicit foreign ownership/alias contract.
    pub unsafe fn metal_buffer(
        &mut self,
        queue: u64,
        dtype: NativeDType,
        shape: Vec<usize>,
        imported: Option<(NativeMetalObject, usize)>,
    ) -> Result<NativeMetalTensor> {
        // SAFETY: Size, shared storage, device and alignment precede buffer use.
        unsafe {
            let _pool = Pool::new();
            let bytes = count(dtype, &shape)?;
            let queue = self
                .metal
                .queues
                .get(&queue)
                .cloned()
                .ok_or_else(|| invalid("Metal queue", queue))?;
            let fresh = imported.is_none();
            let (object, offset) = if let Some(value) = imported {
                value
            } else {
                let raw = (queue.support.message2)(
                    queue.device.as_raw(),
                    sel_registerName(c"newBufferWithLength:options:".as_ptr()),
                    bytes.max(dtype.byte_width()),
                    0,
                );
                (
                    NativeMetalObject(NonNull::new(raw as _).ok_or_else(|| {
                        NativeFailure::Binding("Metal buffer allocation failed".into())
                    })?),
                    0,
                )
            };
            if queue.support.get(&object, c"device") != queue.device.as_raw() as usize {
                return Err(NativeFailure::InvalidData(
                    "Metal buffer belongs to a different device".into(),
                ));
            }
            if queue.support.get(&object, c"storageMode") != 0 {
                return Err(NativeFailure::Unsupported(
                    "host access currently requires shared Metal storage".into(),
                ));
            }
            let extent = queue.support.get(&object, c"length");
            let end = offset
                .checked_add(bytes)
                .ok_or_else(|| NativeFailure::InvalidData("Metal byte extent overflow".into()))?;
            let start = queue.support.get(&object, c"contents");
            let logical_start = start
                .checked_add(offset)
                .ok_or_else(|| NativeFailure::InvalidData("Metal address overflow".into()))?;
            if end > extent
                || !offset.is_multiple_of(dtype.byte_width())
                || start == 0
                || !logical_start.is_multiple_of(dtype.byte_width())
            {
                return Err(NativeFailure::InvalidData(
                    "Metal buffer extent/alignment mismatch".into(),
                ));
            }
            if fresh && bytes != 0 {
                ptr::write_bytes(logical_start as *mut u8, 0, bytes);
            }
            let record = Rc::new(BufferRecord {
                object,
                queue,
                offset,
                bytes,
                dtype,
                shape: shape.clone(),
            });
            let id = self.id()?;
            self.metal.buffers.insert(id, record);
            Ok(NativeMetalTensor { id, dtype, shape })
        }
    }
    /// # Safety
    /// All host reads/writes follow completion of the same persistent queue.
    pub unsafe fn metal_write(&self, id: u64, value: NativeTensor) -> Result<()> {
        // SAFETY: Validate full storage before fencing and mutating shared bytes.
        unsafe {
            let _pool = Pool::new();
            validate_tensor(&value)?;
            let buffer = self
                .metal
                .buffers
                .get(&id)
                .ok_or_else(|| invalid("Metal buffer", id))?;
            if value.dtype != buffer.dtype
                || value.shape != buffer.shape
                || value.bytes.len() != buffer.bytes
            {
                return Err(NativeFailure::InvalidData(
                    "Metal upload shape/dtype mismatch".into(),
                ));
            }
            self.metal_fence_record(&buffer.queue)?;
            if buffer.bytes != 0 {
                ptr::copy_nonoverlapping(
                    value.bytes.as_ptr(),
                    (buffer.queue.support.get(&buffer.object, c"contents") + buffer.offset)
                        as *mut u8,
                    buffer.bytes,
                );
            }
            Ok(())
        }
    }
    unsafe fn metal_read_buffer(&self, buffer: &BufferRecord) -> Result<NativeTensor> {
        // SAFETY: Shared buffer reference stays live and is fenced before copy.
        unsafe {
            self.metal_fence_record(&buffer.queue)?;
            let mut bytes = vec![0; buffer.bytes];
            if buffer.bytes != 0 {
                ptr::copy_nonoverlapping(
                    (buffer.queue.support.get(&buffer.object, c"contents") + buffer.offset)
                        as *const u8,
                    bytes.as_mut_ptr(),
                    buffer.bytes,
                );
            }
            Ok(NativeTensor {
                dtype: buffer.dtype,
                shape: buffer.shape.clone(),
                bytes,
            })
        }
    }
    /// # Safety
    /// IDs are session-local; no external CPU/GPU writes race these copies.
    pub unsafe fn metal_download(&self, input: NativeMetalInput) -> Result<NativeTensor> {
        // SAFETY: Records own all referenced storage for the completed copy.
        unsafe {
            let _pool = Pool::new();
            match input {
                NativeMetalInput::Buffer(id) => self.metal_read_buffer(
                    self.metal
                        .buffers
                        .get(&id)
                        .ok_or_else(|| invalid("Metal buffer", id))?,
                ),
                NativeMetalInput::Value(id) => {
                    let value = self
                        .metal
                        .values
                        .get(&id)
                        .ok_or_else(|| invalid("Metal value", id))?;
                    match &value.kind {
                        ValueKind::Buffer(buffer) => self.metal_read_buffer(buffer),
                        ValueKind::Encoded { array, .. } => {
                            self.metal_fence_record(&value.queue)?;
                            self.read_packed(array)
                        }
                    }
                }
            }
        }
    }
    /// # Safety
    /// Exporting retains a Metal object; caller accepts external synchronization.
    pub unsafe fn metal_export(&self, queue: bool, id: u64) -> Result<NativeMetalObject> {
        // SAFETY: The session owns these valid queue/buffer objects.
        unsafe {
            if queue {
                Ok(self
                    .metal
                    .queues
                    .get(&id)
                    .ok_or_else(|| invalid("Metal queue", id))?
                    .queue
                    .duplicate())
            } else {
                Ok(self
                    .metal
                    .buffers
                    .get(&id)
                    .ok_or_else(|| invalid("Metal buffer", id))?
                    .object
                    .duplicate())
            }
        }
    }
    pub fn drop_metal_queue(&mut self, id: u64) {
        self.metal.queues.remove(&id);
    }
    pub fn drop_metal_buffer(&mut self, id: u64) {
        self.metal.buffers.remove(&id);
    }
    pub fn drop_metal_value(&mut self, id: u64) {
        self.metal.values.remove(&id);
    }

    unsafe fn metal_async_buffer(
        &self,
        buffer: &BufferRecord,
        mutable: bool,
    ) -> Result<NativeValue> {
        // SAFETY: The buffer was validated for shared storage/bounds/alignment.
        unsafe {
            let metadata = self.metadata(if mutable {
                c"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVMa"
            } else {
                c"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMa"
            })?;
            let constructor=self.symbol(if mutable { c"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfC" } else { c"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfC" })?;
            let interleave_md =
                self.metadata(c"$s13CoreAIRuntime7NDArrayV16InterleaveLayoutVMa")?;
            let mut none = NativeValue::allocate(self.optional(interleave_md)?)?;
            let tag: unsafe extern "C" fn(*mut c_void, u32, u32, *mut c_void) =
                mem::transmute(interleave_md.witness(7));
            tag(none.ptr(), 1, 1, interleave_md.pointer as _);
            none.initialized = true;
            let mut scalar = NativeValue::allocate(self.metadata(super::super::SCALAR_METADATA)?)?;
            self.inject(&mut scalar, buffer.dtype.case())?;
            let mut shape = self.int_array(&buffer.shape)?;
            let mut strides = self.int_array(&[])?;
            let mut value = NativeValue::allocate(metadata)?;
            let passed = buffer.object.duplicate();
            let raw = passed.as_raw();
            mem::forget(passed);
            let (word, _, _) = call6(
                constructor,
                [
                    raw as usize,
                    buffer.offset,
                    scalar.address(),
                    shape.word,
                    strides.word,
                    none.address(),
                ],
                value.ptr(),
                if mutable { 0 } else { metadata.pointer },
            );
            scalar.initialized = false;
            shape.word = 0;
            strides.word = 0;
            none.initialized = false;
            if !mutable {
                if word == 0 {
                    return Err(NativeFailure::Binding("null AsyncValue".into()));
                }
                value.ptr().cast::<usize>().write(word);
            }
            value.initialized = true;
            Ok(value)
        }
    }
    unsafe fn metal_ready_fenced(
        &self,
        value: &mut NativeValue,
        mutable: bool,
        queue: &QueueRecord,
    ) -> Result<NativeValue> {
        // SAFETY: Uses verified consuming struct or borrowed class readiness.
        // Once the getter starts, retain its raw native Error or initialized
        // result through the actual post-readiness fence. Preflight failures
        // before starting the getter create no new asynchronous materialization.
        unsafe {
            let tensor = self.metadata(super::super::NDARRAY_METADATA)?;
            let mut result = NativeValue::allocate(self.optional(tensor)?)?;
            let receiver = if mutable {
                value.address()
            } else {
                value.ptr().cast::<usize>().read()
            };
            let outcome=self.runtime.await_native(if mutable {c"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueV7ndArrayAA7NDArrayVSgvgTu"}else{c"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC7ndArrayAA7NDArrayVSgvgTu"},[result.address(),0,0,0],receiver,true);
            if let Ok(outcome) = &outcome {
                if mutable {
                    value.initialized = false;
                }
                result.initialized = outcome.error == 0;
            }
            if let Err(problem) = self.metal_fence_record(queue) {
                eprintln!("cannot establish completion after Metal readiness: {problem}");
                std::process::abort();
            }
            let outcome = outcome?;
            if outcome.error != 0 {
                return Err(self.failure(outcome.error, "metal_readiness"));
            }
            Self::lifecycle(&outcome)?;
            result
                .take_optional(tensor)?
                .ok_or_else(|| NativeFailure::Unsupported("encoded value is not NDArray".into()))
        }
    }

    unsafe fn metal_info(&self, array: &NativeValue) -> Result<(NativeDType, Vec<usize>)> {
        // SAFETY: Metadata getters borrow a ready, initialized NDArray.
        unsafe {
            let shape = self.call(
                c"$s13CoreAIRuntime7NDArrayV5shapeSaySiGvg",
                [0; 3],
                ptr::null_mut(),
                array.address(),
            )?;
            let shape = self
                .integers(shape)?
                .into_iter()
                .map(|n| {
                    usize::try_from(n)
                        .map_err(|_| NativeFailure::Unsupported("unresolved encoded shape".into()))
                })
                .collect::<Result<Vec<_>>>()?;
            let mut scalar = NativeValue::allocate(self.metadata(super::super::SCALAR_METADATA)?)?;
            self.call(
                c"$s13CoreAIRuntime7NDArrayV10scalarTypeAC06ScalarE0Ovg",
                [0; 3],
                scalar.ptr(),
                array.address(),
            )?;
            scalar.initialized = true;
            let dtype = self.dtype(&scalar)?;
            count(dtype, &shape)?;
            Ok((dtype, shape))
        }
    }

    /// # Safety
    /// Session-local retained resources only; all returned values are fenced
    /// and checked for throwing readiness before publication to Rust callers.
    pub unsafe fn metal_encode(
        &mut self,
        function: u64,
        queue: u64,
        inputs: Vec<(String, NativeMetalInput)>,
        states: Vec<(String, u64)>,
        outputs: Vec<(String, u64)>,
    ) -> Result<Vec<(String, NativeMetalTensor)>> {
        // SAFETY: Borrowed views and buffers stay owned through true completion.
        unsafe {
            let _pool = Pool::new();
            let gpu = self.function_compute(function)? == NativeCompute::GpuPreferred;
            let queue = self
                .metal
                .queues
                .get(&queue)
                .cloned()
                .ok_or_else(|| invalid("Metal queue", queue))?;
            let function = self
                .functions
                .get(&function)
                .ok_or_else(|| invalid("function", function))?;
            if gpu {
                super::run_stream::gpu_descriptors(&function.descriptor)?;
            }
            let mut input_records = Vec::new();
            for (name, input) in inputs {
                let value = match input {
                    NativeMetalInput::Buffer(id) => {
                        let b = self
                            .metal
                            .buffers
                            .get(&id)
                            .cloned()
                            .ok_or_else(|| invalid("Metal buffer", id))?;
                        Rc::new(ValueRecord {
                            kind: ValueKind::Buffer(Rc::clone(&b)),
                            queue: Rc::clone(&b.queue),
                            dtype: b.dtype,
                            shape: b.shape.clone(),
                            origins: vec![b],
                        })
                    }
                    NativeMetalInput::Value(id) => self
                        .metal
                        .values
                        .get(&id)
                        .cloned()
                        .ok_or_else(|| invalid("Metal value", id))?,
                };
                if !Rc::ptr_eq(&value.queue, &queue) {
                    return Err(NativeFailure::InvalidData(
                        "Metal inputs must belong to this queue".into(),
                    ));
                }
                let d = function
                    .descriptor
                    .inputs
                    .iter()
                    .find(|d| d.name == name)
                    .ok_or_else(|| {
                        NativeFailure::InvalidData(format!("unexpected Metal input {name}"))
                    })?;
                matches_descriptor(value.dtype, &value.shape, d)?;
                if gpu {
                    super::run_stream::gpu_shape(value.dtype, &value.shape)?;
                    match &value.kind {
                        ValueKind::Buffer(buffer) => super::run_stream::gpu_span(buffer.bytes)?,
                        ValueKind::Encoded { array, .. } => {
                            super::handles::validate_gpu_handle(&self.tensor_handle_info(array)?)?
                        }
                    }
                }
                if input_records
                    .iter()
                    .any(|(n, _): &(String, Rc<ValueRecord>)| *n == name)
                {
                    return Err(NativeFailure::InvalidData("duplicate Metal input".into()));
                }
                input_records.push((name, value));
            }
            if input_records.len() != function.descriptor.inputs.len() {
                return Err(NativeFailure::InvalidData("missing Metal input".into()));
            }
            let mut mutable = Vec::new();
            for (is_state, values, descriptors) in [
                (true, states, &function.descriptor.states),
                (false, outputs, &function.descriptor.outputs),
            ] {
                let mut names = HashSet::new();
                for (name, id) in values {
                    if !names.insert(name.clone()) {
                        return Err(NativeFailure::InvalidData(
                            "duplicate Metal mutable binding".into(),
                        ));
                    }
                    let b = self
                        .metal
                        .buffers
                        .get(&id)
                        .cloned()
                        .ok_or_else(|| invalid("Metal buffer", id))?;
                    if !Rc::ptr_eq(&b.queue, &queue) {
                        return Err(NativeFailure::InvalidData(
                            "Metal bindings must belong to this queue".into(),
                        ));
                    }
                    let d = descriptors.iter().find(|d| d.name == name).ok_or_else(|| {
                        NativeFailure::InvalidData(format!("unexpected Metal binding {name}"))
                    })?;
                    if d.shape.iter().any(|dimension| *dimension < 0) {
                        return Err(NativeFailure::Unsupported(
                            "explicit Metal output/state binding requires a fixed descriptor shape"
                                .into(),
                        ));
                    }
                    matches_descriptor(b.dtype, &b.shape, d)?;
                    if gpu {
                        super::run_stream::gpu_shape(b.dtype, &b.shape)?;
                        super::run_stream::gpu_span(b.bytes)?;
                    }
                    if input_records
                        .iter()
                        .flat_map(|(_, v)| v.origins.iter())
                        .any(|a| overlaps(a, &b))
                        || mutable.iter().any(
                            |(_, a, _, _): &(String, Rc<BufferRecord>, NativeValue, bool)| {
                                overlaps(a, &b)
                            },
                        )
                    {
                        return Err(NativeFailure::InvalidData(
                            "overlapping Metal mutable/input bindings".into(),
                        ));
                    }
                    let value = self.metal_async_buffer(&b, true)?;
                    mutable.push((name, b, value, is_state));
                }
                if is_state && names.len() != descriptors.len() {
                    return Err(NativeFailure::InvalidData(
                        "missing Metal state binding".into(),
                    ));
                }
            }
            // Preflight fence support before submission; all later fallible
            // preparation cleans up without any pending native borrow.
            self.metal_fence_record(&queue)?;
            let class_md =
                self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMa")?;
            let string_md =
                NativeMetadata::copy(&Metadata::from_response(self.symbol(c"$sSSN")?, 0)?);
            let hash = self.symbol(c"$sSSSHsWP")? as usize;
            let (pointer, state, _) = call6(
                self.symbol(c"$sSDMa")?,
                [0, string_md.pointer, class_md.pointer, hash, 0, 0],
                ptr::null_mut(),
                0,
            );
            let dict_md = NativeMetadata::copy(&Metadata::from_response(pointer as _, state)?);
            let opt_class = self.optional(class_md)?;
            let mut dictionary = NativeValue::allocate(dict_md)?;
            let word = self.call(
                c"$sS2Dyxq_GycfC",
                [string_md.pointer, class_md.pointer, hash],
                ptr::null_mut(),
                0,
            )?;
            dictionary.ptr().cast::<usize>().write(word);
            dictionary.initialized = true;
            let mut retained_inputs = Vec::new();
            let set = self.symbol(c"$sSDyq_Sgxcis")?;
            let copy: unsafe extern "C" fn(*mut c_void, *mut c_void, *mut c_void) -> *mut c_void =
                mem::transmute(class_md.witness(2));
            let some: unsafe extern "C" fn(*mut c_void, u32, u32, *mut c_void) =
                mem::transmute(class_md.witness(7));
            for (name, value) in &input_records {
                let borrowed = match &value.kind {
                    ValueKind::Buffer(buffer) => {
                        retained_inputs.push(self.metal_async_buffer(buffer, false)?);
                        retained_inputs.last().unwrap()
                    }
                    ValueKind::Encoded { future, .. } => future,
                };
                let mut optional = NativeValue::allocate(opt_class)?;
                copy(optional.ptr(), borrowed.ptr(), class_md.pointer as _);
                some(optional.ptr(), 0, 1, class_md.pointer as _);
                optional.initialized = true;
                let key = self.string(name)?;
                let mut key_value = NativeValue::allocate(string_md)?;
                ptr::copy_nonoverlapping(key.words.as_ptr(), key_value.ptr().cast::<usize>(), 2);
                mem::forget(key);
                key_value.initialized = true;
                arm64::call_sync(
                    set,
                    [optional.address(), key_value.address(), dict_md.pointer],
                    ptr::null_mut(),
                    dictionary.address(),
                );
                optional.initialized = false;
                key_value.initialized = false;
            }
            let views_md =
                self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVMa")?;
            let mut state_views = NativeValue::allocate(views_md)?;
            let mut output_views = NativeValue::allocate(views_md)?;
            for view in [&mut state_views, &mut output_views] {
                self.call(
                    c"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsVAEycfC",
                    [0; 3],
                    view.ptr(),
                    0,
                )?;
                view.initialized = true;
            }
            for (name, _, value, is_state) in &mutable {
                let name = self.string(name)?;
                let view = if *is_state {
                    &state_views
                } else {
                    &output_views
                };
                self.call(c"$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableViewsV6insert_3foryAC0eF5ValueVz_SStF",[value.address(),name.words[0],name.words[1]],ptr::null_mut(),view.address())?;
            }
            let mut returned = NativeValue::allocate(dict_md)?;
            let encode=self.symbol(c"$s13CoreAIRuntime17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKF")?;
            let remove = self.symbol(c"$sSD11removeValue6forKeyq_Sgx_tF")?;
            let errors = ErrorSupport::load(&self.runtime)?;
            let (word, _, error) = call6(
                encode,
                [
                    dictionary.ptr().cast::<usize>().read(),
                    state_views.address(),
                    output_views.address(),
                    queue.stream.word,
                    0,
                    0,
                ],
                ptr::null_mut(),
                function.value.address(),
            );
            state_views.initialized = false;
            output_views.initialized = false;
            if error == 0 {
                returned.ptr().cast::<usize>().write(word);
                returned.initialized = true;
            }
            let mut error = if error == 0 {
                None
            } else {
                Some(errors.take(error as _))
            };
            // An inability to establish completion cannot safely release these
            // borrowed native resources. Preflight has already resolved the ABI.
            if let Err(problem) = self.metal_fence_record(&queue) {
                eprintln!("cannot establish completion of encoded Metal work: {problem}");
                std::process::abort();
            }
            if let Some(error) = error.take() {
                return Err(NativeFailure::Native {
                    operation: "metal_encode",
                    type_name: errors.name(&error)?,
                });
            }
            drop(error);
            let mut first_error = None;
            for (_, buffer, value, _) in &mut mutable {
                match self
                    .metal_ready_fenced(value, true, &queue)
                    .and_then(|array| self.metal_info(&array))
                {
                    Ok((dtype, shape)) if dtype == buffer.dtype && shape == buffer.shape => {}
                    Ok(_) => {
                        first_error.get_or_insert_with(|| {
                            NativeFailure::Binding("bound Metal readiness metadata mismatch".into())
                        });
                    }
                    Err(error) => {
                        first_error.get_or_insert(error);
                    }
                }
            }
            let mut prepared = Vec::new();
            let mut seen_origins = HashSet::new();
            let origins = input_records
                .iter()
                .flat_map(|(_, v)| v.origins.iter().cloned())
                .chain(mutable.iter().map(|(_, b, _, _)| Rc::clone(b)))
                .filter(|buffer| {
                    seen_origins.insert((
                        buffer.object.as_raw() as usize,
                        buffer.offset,
                        buffer.bytes,
                    ))
                })
                .collect::<Vec<_>>();
            for descriptor in &function.descriptor.outputs {
                if let Some((_, buffer, _, _)) = mutable
                    .iter()
                    .find(|(name, _, _, state)| !*state && *name == descriptor.name)
                {
                    prepared.push((
                        descriptor.name.clone(),
                        Rc::new(ValueRecord {
                            kind: ValueKind::Buffer(Rc::clone(buffer)),
                            queue: Rc::clone(&queue),
                            dtype: buffer.dtype,
                            shape: buffer.shape.clone(),
                            origins: vec![Rc::clone(buffer)],
                        }),
                    ));
                    continue;
                }
                let key = self.string(&descriptor.name)?;
                let mut optional = NativeValue::allocate(opt_class)?;
                arm64::call_sync(
                    remove,
                    [key.words.as_ptr() as usize, dict_md.pointer, 0],
                    optional.ptr(),
                    returned.address(),
                );
                optional.initialized = true;
                let future = optional.take_optional(class_md)?;
                if let Some(mut future) = future {
                    match self
                        .metal_ready_fenced(&mut future, false, &queue)
                        .and_then(|array| {
                            if gpu {
                                super::handles::validate_gpu_handle(
                                    &self.tensor_handle_info(&array)?,
                                )?;
                            }
                            self.metal_info(&array).map(|info| (array, info))
                        }) {
                        Ok((array, (dtype, shape))) => {
                            matches_descriptor(dtype, &shape, descriptor)?;
                            prepared.push((
                                descriptor.name.clone(),
                                Rc::new(ValueRecord {
                                    kind: ValueKind::Encoded { future, array },
                                    queue: Rc::clone(&queue),
                                    dtype,
                                    shape,
                                    origins: origins.clone(),
                                }),
                            ));
                        }
                        Err(error) => {
                            first_error.get_or_insert(error);
                        }
                    }
                } else {
                    first_error.get_or_insert_with(|| {
                        NativeFailure::Binding(format!(
                            "missing encoded output {}",
                            descriptor.name
                        ))
                    });
                }
            }
            if let Some(error) = first_error {
                return Err(error);
            }
            let ids = (0..prepared.len())
                .map(|_| self.id())
                .collect::<Result<Vec<_>>>()?;
            let mut result = Vec::new();
            for ((name, value), id) in prepared.into_iter().zip(ids) {
                let info = NativeMetalTensor {
                    id,
                    dtype: value.dtype,
                    shape: value.shape.clone(),
                };
                self.metal.values.insert(id, value);
                result.push((name, info));
            }
            Ok(result)
        }
    }
}

impl NativeSession {
    /// Stateless native-array execution on one persistent owned stream. Private
    /// Metal IDs are transaction-local; none cross the facade or survive errors.
    ///
    /// # Safety
    /// Inputs are initialized, validated, retained native arrays in this session.
    pub(super) unsafe fn encode_native_arrays(
        &mut self,
        function: u64,
        inputs: &[(String, u64)],
    ) -> Result<Vec<(String, NativeValue, NativeTensorHandle)>> {
        // SAFETY: All Swift copies/constructors use the calibrated NDArray and
        // AsyncValue contracts. Existing encode retains arguments and fences
        // both submission and readiness on success/error before returning.
        unsafe {
            let queue = if let Some(queue) = &self.metal.run_queue {
                Rc::clone(queue)
            } else {
                let id = self.metal_queue(None)?;
                let queue = self.metal.queues.remove(&id).expect("new private queue");
                self.metal.run_queue = Some(Rc::clone(&queue));
                queue
            };
            let queue_id = self.id()?;
            self.metal.queues.insert(queue_id, Rc::clone(&queue));
            let mut private_inputs = Vec::new();
            let mut private_outputs = Vec::new();
            let result = (|| {
                let metadata =
                    self.metadata(c"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCMa")?;
                let constructor = self.symbol(
                    c"$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCyAeA7NDArrayVcfC",
                )?;
                let mut arguments = Vec::new();
                for (name, id) in inputs {
                    let record = &self.tensors[id];
                    let array = record.value.copy_owned()?;
                    let mut consumed = array.copy_owned()?;
                    let mut future = NativeValue::allocate(metadata)?;
                    let object = arm64::call_sync(
                        constructor,
                        [consumed.address(), 0, 0],
                        ptr::null_mut(),
                        metadata.pointer,
                    );
                    consumed.initialized = false;
                    if object == 0 {
                        return Err(NativeFailure::Binding("null NDArray AsyncValue".into()));
                    }
                    future.ptr().cast::<usize>().write(object);
                    future.initialized = true;
                    let value = Rc::new(ValueRecord {
                        kind: ValueKind::Encoded { future, array },
                        queue: Rc::clone(&queue),
                        dtype: record.info.dtype,
                        shape: record.info.shape.clone(),
                        origins: Vec::new(),
                    });
                    let id = self.id()?;
                    self.metal.values.insert(id, value);
                    private_inputs.push(id);
                    arguments.push((name.clone(), NativeMetalInput::Value(id)));
                }
                let outputs =
                    self.metal_encode(function, queue_id, arguments, Vec::new(), Vec::new())?;
                private_outputs.extend(outputs.iter().map(|(_, value)| value.id));
                let mut arrays = Vec::new();
                for (name, value) in outputs {
                    let record = &self.metal.values[&value.id];
                    let ValueKind::Encoded { array, .. } = &record.kind else {
                        return Err(NativeFailure::Binding(
                            "automatic stream output is not native".into(),
                        ));
                    };
                    let info = self.tensor_handle_info(array)?;
                    arrays.push((name, array.copy_owned()?, info));
                }
                Ok(arrays)
            })();
            for id in private_outputs.into_iter().chain(private_inputs) {
                self.metal.values.remove(&id);
            }
            self.metal.queues.remove(&queue_id);
            result
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn large_metal_extents_use_the_shared_tensor_boundary() {
        assert_eq!(
            count(NativeDType::Bf16, &[1, 102816, 5376]).unwrap(),
            1_105_477_632
        );
        assert_eq!(
            count(NativeDType::F32, &[124, 1344, 768, 3]).unwrap(),
            1_535_901_696
        );
        assert_eq!(
            count(NativeDType::F32, &[345, 1344, 768, 3]).unwrap(),
            4_273_274_880
        );
        let limit = crate::dtype::MAX_TENSOR_BYTES;
        assert_eq!(count(NativeDType::F32, &[limit / 4]).unwrap(), limit);
        assert!(count(NativeDType::F32, &[limit / 4 + 1]).is_err());
        assert!(count(NativeDType::F32, &[0, limit / 4 + 1]).is_err());
    }
    #[test]
    fn aliases_share_object_origin_and_check_only_overlapping_bytes() {
        assert!(overlaps_ranges((1, 0, 24), (1, 0, 24)));
        assert!(overlaps_ranges((1, 0, 24), (1, 20, 24)));
        assert!(!overlaps_ranges((1, 0, 24), (1, 24, 24)));
        assert!(!overlaps_ranges((1, 0, 24), (2, 0, 24)));
        assert!(!overlaps_ranges((1, 0, 0), (1, 0, 24)));
    }
    #[test]
    fn metal_storage_counts_cover_scalar_empty_and_limits() {
        assert_eq!(count(NativeDType::F32, &[]).unwrap(), 4);
        assert_eq!(count(NativeDType::F16, &[0, 3]).unwrap(), 0);
        assert!(count(NativeDType::I64, &[usize::MAX]).is_err());
        assert!(count(NativeDType::Bool, &[1; 65]).is_err());
    }
}
