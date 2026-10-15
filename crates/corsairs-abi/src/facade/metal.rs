//! Persistent Metal ownership with explicit completion before host access.
use super::*;
use crate::native::{NativeMetalInput, NativeMetalObject, NativeMetalTensor};
use std::ffi::c_void;
use std::fmt;

/// A retained Objective-C Metal object exported for application interoperability.
/// Its reference remains owned until this guard drops. External GPU work must
/// also retain every resource it uses and follow the export's unsafe contract.
pub struct MetalObject {
    object: NativeMetalObject,
    _queue: MetalQueue,
    _buffer: Option<MetalBuffer>,
}
impl MetalObject {
    /// Borrow the Objective-C object pointer while this retained guard lives.
    /// Dereferencing or importing this pointer into another API is unsafe.
    pub fn as_raw(&self) -> *mut c_void {
        self.object.as_raw()
    }
}
impl fmt::Debug for MetalObject {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("MetalObject").finish_non_exhaustive()
    }
}
struct QueueInner {
    runtime: Runtime,
    id: u64,
}
impl Drop for QueueInner {
    fn drop(&mut self) {
        let id = self.id;
        self.runtime
            .worker
            .release(move |session| session.drop_metal_queue(id));
    }
}
/// One persistent application Metal command queue and Core AI compute stream.
/// Calls currently fence each inference; submission pipelining is deferred.
#[derive(Clone)]
pub struct MetalQueue(Arc<QueueInner>);
impl fmt::Debug for MetalQueue {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("MetalQueue").finish_non_exhaustive()
    }
}
impl Runtime {
    /// Create a persistent queue on the system's default Metal device.
    pub fn metal_queue(&self) -> Task<MetalQueue> {
        self.metal_queue_request(Ok(None))
    }
    /// Import and immediately retain an application-owned Objective-C queue.
    ///
    /// # Safety
    /// `queue` is a live MTLCommandQueue for this call. Serialize external
    /// submission with library operations on it; never race CPU resource access
    /// with GPU work. Keep every externally submitted resource alive through
    /// completion. Dropping the returned future does not cancel its retained job.
    pub unsafe fn import_metal_queue(&self, queue: *mut c_void) -> Task<MetalQueue> {
        // SAFETY: Caller supplies the retainable Metal protocol object contract.
        let retained = unsafe { NativeMetalObject::retain(queue) }
            .map(Some)
            .map_err(native_error);
        self.metal_queue_request(retained)
    }
    fn metal_queue_request(
        &self,
        object: Result<Option<NativeMetalObject>, Error>,
    ) -> Task<MetalQueue> {
        let runtime = self.clone();
        self.worker.submit(move |session| {
            // SAFETY: Only this session worker constructs and owns the stream.
            let id = unsafe { session.metal_queue(object?).map_err(native_error)? };
            Ok(MetalQueue(Arc::new(QueueInner { runtime, id })))
        })
    }
}
impl MetalQueue {
    /// Fence all previously submitted Core AI and application work on this queue.
    pub fn fence(&self) -> Task<()> {
        let queue = self.clone();
        self.0.runtime.worker.submit(move |session| {
            // SAFETY: Queue remains retained across both native fences.
            unsafe { session.metal_fence(queue.0.id).map_err(native_error) }
        })
    }
    /// Allocate zero-initialized shared storage for a fixed concrete tensor.
    pub fn buffer(&self, dtype: DType, shape: impl Into<Vec<usize>>) -> Task<MetalBuffer> {
        self.buffer_request(dtype, shape.into(), 0, Ok(None), None)
    }
    /// Copy an owned tensor into persistent shared Metal storage once.
    pub fn upload(&self, tensor: Tensor) -> Task<MetalBuffer> {
        self.buffer_request(
            tensor.dtype(),
            tensor.shape().to_vec(),
            0,
            Ok(None),
            Some(tensor),
        )
    }
    /// Import and immediately retain initialized shared Metal storage.
    ///
    /// # Safety
    /// `buffer` is a live MTLBuffer for this call and its logical tensor bytes
    /// have valid initialized scalar encodings (boolean bytes are zero/one).
    /// Its backing storage must stay mapped, initialized and nonpurgeable until
    /// every retained library import/view and queued job is gone. Do not discard
    /// it with Empty/Volatile purgeability or free/invalidate external no-copy
    /// memory during that lifetime. External work uses the same coordinated queue;
    /// no CPU mapping or GPU write may race library operations. Different Metal
    /// objects that alias the same heap/suballocation are excluded. Reimporting
    /// the same object is allowed; overlapping mutable ranges are rejected.
    /// The library checks device, storage mode, extent and scalar alignment.
    pub unsafe fn import_buffer(
        &self,
        buffer: *mut c_void,
        byte_offset: usize,
        dtype: DType,
        shape: impl Into<Vec<usize>>,
    ) -> Task<MetalBuffer> {
        // SAFETY: Caller provides the foreign buffer ownership/alias contract.
        let object = unsafe { NativeMetalObject::retain(buffer) }
            .map(|object| Some((object, byte_offset)))
            .map_err(native_error);
        self.buffer_request(dtype, shape.into(), byte_offset, object, None)
    }
    fn buffer_request(
        &self,
        dtype: DType,
        shape: Vec<usize>,
        offset: usize,
        object: Result<Option<(NativeMetalObject, usize)>, Error>,
        initial: Option<Tensor>,
    ) -> Task<MetalBuffer> {
        let queue = self.clone();
        self.0.runtime.worker.submit(move |session| {
            // SAFETY: Native construction validates all bounds before use.
            let info = unsafe {
                session
                    .metal_buffer(queue.0.id, to_native_dtype(dtype), shape, object?)
                    .map_err(native_error)?
            };
            if let Some(initial) = initial {
                let (dtype, shape, bytes) = initial.into_parts();
                // SAFETY: Initial bytes are owned and upload is queue-fenced.
                if let Err(error) = unsafe {
                    session.metal_write(
                        info.id,
                        NativeTensor {
                            dtype: to_native_dtype(dtype),
                            shape,
                            bytes,
                        },
                    )
                } {
                    session.drop_metal_buffer(info.id);
                    return Err(native_error(error));
                }
            }
            Ok(MetalBuffer::new(queue, offset, info))
        })
    }
    /// Export an additional retained queue reference for application kernels.
    ///
    /// # Safety
    /// Coordinate all external queue submissions with library operations. Every
    /// referenced resource must survive external completion. Use `fence` before
    /// CPU mapping/reuse; do not create racing work on another queue.
    pub unsafe fn export_queue(&self) -> Task<MetalObject> {
        let queue = self.clone();
        self.0.runtime.worker.submit(move |session| {
            // SAFETY: Export retains the live queue; caller accepts coordination.
            let object = unsafe {
                session
                    .metal_export(true, queue.0.id)
                    .map_err(native_error)?
            };
            Ok(MetalObject {
                object,
                _queue: queue,
                _buffer: None,
            })
        })
    }
}
struct BufferInner {
    queue: MetalQueue,
    id: u64,
    dtype: DType,
    shape: Vec<usize>,
    offset: usize,
}
impl Drop for BufferInner {
    fn drop(&mut self) {
        let id = self.id;
        self.queue
            .0
            .runtime
            .worker
            .release(move |session| session.drop_metal_buffer(id));
    }
}
/// Persistent shared Metal storage. Clones share contents; host access copies
/// through queued methods rather than exposing a safe mutable byte mapping.
#[derive(Clone)]
pub struct MetalBuffer(Arc<BufferInner>);
impl fmt::Debug for MetalBuffer {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("MetalBuffer")
            .field("dtype", &self.dtype())
            .field("shape", &self.shape())
            .field("byte_offset", &self.byte_offset())
            .finish_non_exhaustive()
    }
}
impl MetalBuffer {
    fn new(queue: MetalQueue, offset: usize, info: NativeMetalTensor) -> Self {
        Self(Arc::new(BufferInner {
            queue,
            id: info.id,
            dtype: from_native_dtype(info.dtype),
            shape: info.shape,
            offset,
        }))
    }
    /// Scalar type of this logical tensor view.
    pub fn dtype(&self) -> DType {
        self.0.dtype
    }
    /// Concrete tensor dimensions.
    pub fn shape(&self) -> &[usize] {
        &self.0.shape
    }
    /// Byte offset inside its underlying Metal object.
    pub fn byte_offset(&self) -> usize {
        self.0.offset
    }
    /// Copy initialized host bytes after prior queue work completes.
    pub fn write(&self, tensor: Tensor) -> Task<()> {
        let buffer = self.clone();
        self.0.queue.0.runtime.worker.submit(move |session| {
            let (dtype, shape, bytes) = tensor.into_parts();
            // SAFETY: Job retains storage and native method validates then fences.
            unsafe {
                session
                    .metal_write(
                        buffer.0.id,
                        NativeTensor {
                            dtype: to_native_dtype(dtype),
                            shape,
                            bytes,
                        },
                    )
                    .map_err(native_error)
            }
        })
    }
    /// Fence and copy shared contents into independently owned Rust bytes.
    pub fn download(&self) -> Task<Tensor> {
        MetalValue::from(self.clone()).download()
    }
    /// Export an additional retained buffer object for application kernels.
    ///
    /// # Safety
    /// External accesses must respect `byte_offset`, extent and dtype, be ordered
    /// on this buffer's queue, and never race host/library access. Distinct aliasing
    /// Metal objects and unretained GPU resource use are outside this contract.
    /// Keep backing mapped, validly initialized and nonpurgeable for all retained
    /// library views/jobs; never discard it or invalidate external no-copy memory.
    pub unsafe fn export_buffer(&self) -> Task<MetalObject> {
        let buffer = self.clone();
        self.0.queue.0.runtime.worker.submit(move |session| {
            // SAFETY: Retains the buffer; caller accepts external coordination.
            let object = unsafe {
                session
                    .metal_export(false, buffer.0.id)
                    .map_err(native_error)?
            };
            Ok(MetalObject {
                object,
                _queue: buffer.0.queue.clone(),
                _buffer: Some(buffer),
            })
        })
    }
}
struct EncodedInner {
    queue: MetalQueue,
    id: u64,
    dtype: DType,
    shape: Vec<usize>,
    _function: Function,
}
impl Drop for EncodedInner {
    fn drop(&mut self) {
        let id = self.id;
        self.queue
            .0
            .runtime
            .worker
            .release(move |session| session.drop_metal_value(id));
    }
}
#[derive(Clone)]
enum Value {
    Buffer(MetalBuffer),
    Encoded(Arc<EncodedInner>),
}
/// A retained read-only input/output view suitable for another encoded call.
/// It is a shared native view, rather than a snapshot of mutable buffer bytes.
#[derive(Clone)]
pub struct MetalValue(Value);
impl fmt::Debug for MetalValue {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("MetalValue")
            .field("dtype", &self.dtype())
            .field("shape", &self.shape())
            .finish_non_exhaustive()
    }
}
impl From<MetalBuffer> for MetalValue {
    fn from(value: MetalBuffer) -> Self {
        Self(Value::Buffer(value))
    }
}
impl From<&MetalBuffer> for MetalValue {
    fn from(value: &MetalBuffer) -> Self {
        Self::from(value.clone())
    }
}
impl MetalValue {
    fn queue(&self) -> &MetalQueue {
        match &self.0 {
            Value::Buffer(v) => &v.0.queue,
            Value::Encoded(v) => &v.queue,
        }
    }
    fn native(&self) -> NativeMetalInput {
        match &self.0 {
            Value::Buffer(v) => NativeMetalInput::Buffer(v.0.id),
            Value::Encoded(v) => NativeMetalInput::Value(v.id),
        }
    }
    /// Scalar type after completed native readiness.
    pub fn dtype(&self) -> DType {
        match &self.0 {
            Value::Buffer(v) => v.dtype(),
            Value::Encoded(v) => v.dtype,
        }
    }
    /// Resolved dimensions after completed native readiness.
    pub fn shape(&self) -> &[usize] {
        match &self.0 {
            Value::Buffer(v) => v.shape(),
            Value::Encoded(v) => &v.shape,
        }
    }
    /// Fence and copy this value into owned Rust storage.
    pub fn download(&self) -> Task<Tensor> {
        let value = self.clone();
        self.queue().0.runtime.worker.submit(move |session| {
            // SAFETY: Captured view retains storage and queue until copy ends.
            let tensor = unsafe {
                session
                    .metal_download(value.native())
                    .map_err(native_error)?
            };
            Tensor::from_bytes(from_native_dtype(tensor.dtype), tensor.shape, tensor.bytes)
        })
    }
}

macro_rules! named_map {
    ($name:ident,$item:ty,$doc:literal) => {
        #[doc=$doc]
        #[derive(Clone, Debug, Default)]
        pub struct $name(BTreeMap<String, $item>);
        impl $name {
            /// Construct an empty map.
            pub fn new() -> Self {
                Self::default()
            }
            /// Insert a named view, returning any replaced view.
            pub fn insert(
                &mut self,
                name: impl Into<String>,
                value: impl Into<$item>,
            ) -> Option<$item> {
                self.0.insert(name.into(), value.into())
            }
            /// Borrow a named view.
            pub fn get(&self, name: &str) -> Option<&$item> {
                self.0.get(name)
            }
            /// Remove a named view.
            pub fn remove(&mut self, name: &str) -> Option<$item> {
                self.0.remove(name)
            }
            /// Number of named views.
            pub fn len(&self) -> usize {
                self.0.len()
            }
            /// Whether this map contains no views.
            pub fn is_empty(&self) -> bool {
                self.0.is_empty()
            }
            /// Iterate in lexicographic name order.
            pub fn iter(&self) -> impl Iterator<Item = (&str, &$item)> {
                self.0.iter().map(|(n, v)| (n.as_str(), v))
            }
        }
        impl<K: Into<String>, V: Into<$item>> FromIterator<(K, V)> for $name {
            fn from_iter<T: IntoIterator<Item = (K, V)>>(iter: T) -> Self {
                Self(
                    iter.into_iter()
                        .map(|(n, v)| (n.into(), v.into()))
                        .collect(),
                )
            }
        }
        impl<const N: usize, K: Into<String>, V: Into<$item>> From<[(K, V); N]> for $name {
            fn from(values: [(K, V); N]) -> Self {
                values.into_iter().collect()
            }
        }
    };
}
named_map!(
    MetalValueMap,
    MetalValue,
    "Named retained Metal inputs or outputs."
);
named_map!(
    MetalBufferMap,
    MetalBuffer,
    "Named persistent mutable Metal buffer bindings."
);

/// Completed encoded outputs and the supplied state buffers updated in place.
#[derive(Clone, Debug)]
pub struct MetalRunResult {
    /// All outputs, including explicit bindings, retained for chaining.
    pub outputs: MetalValueMap,
    /// The caller's state buffers after readiness completed.
    pub states: MetalBufferMap,
}
impl Function {
    /// Encode on a persistent queue, fence and check throwing result readiness.
    /// No input/output payload is copied to Rust for chaining. This initial
    /// implementation fences every call and does not pipeline in-flight calls.
    /// Explicit output/state bindings require fixed descriptor dimensions.
    pub fn encode(
        &self,
        queue: &MetalQueue,
        inputs: MetalValueMap,
        states: MetalBufferMap,
        output_views: MetalBufferMap,
    ) -> Task<MetalRunResult> {
        let same_worker = self
            .0
            .model
            .0
            .runtime
            .worker
            .same_worker(&queue.0.runtime.worker);
        let queue = queue.clone();
        let function = self.clone();
        self.0.model.0.runtime.worker.submit(move |session| {
            if !same_worker
                || inputs
                    .0
                    .values()
                    .any(|v| !Arc::ptr_eq(&v.queue().0, &queue.0))
                || states
                    .0
                    .values()
                    .chain(output_views.0.values())
                    .any(|b| !Arc::ptr_eq(&b.0.queue.0, &queue.0))
            {
                return Err(Error::Unsupported(
                    "Metal resources must belong to this runtime and queue".into(),
                ));
            }
            let native_inputs = inputs.iter().map(|(n, v)| (n.into(), v.native())).collect();
            let native_states = states.iter().map(|(n, b)| (n.into(), b.0.id)).collect();
            let native_outputs = output_views
                .iter()
                .map(|(n, b)| (n.into(), b.0.id))
                .collect();
            // SAFETY: This job owns every handle through native fence/readiness,
            // even if the public future has already been dropped.
            let produced = unsafe {
                session
                    .metal_encode(
                        function.0.id,
                        queue.0.id,
                        native_inputs,
                        native_states,
                        native_outputs,
                    )
                    .map_err(native_error)?
            };
            let outputs = produced
                .into_iter()
                .map(|(name, info)| {
                    (
                        name,
                        MetalValue(Value::Encoded(Arc::new(EncodedInner {
                            queue: queue.clone(),
                            id: info.id,
                            dtype: from_native_dtype(info.dtype),
                            shape: info.shape,
                            _function: function.clone(),
                        }))),
                    )
                })
                .collect();
            Ok(MetalRunResult { outputs, states })
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn public_metal_handles_and_jobs_are_send_sync() {
        fn check<T: Send + Sync>() {}
        check::<MetalQueue>();
        check::<MetalBuffer>();
        check::<MetalValue>();
        check::<MetalRunResult>();
        check::<Task<MetalRunResult>>();
        fn send<T: Send>() {}
        send::<MetalObject>();
    }

    #[test]
    #[ignore = "requires permitted native Metal/Core AI and CORSAIRS_TEST_MODEL x+x float32[2,3]"]
    fn native_metal_import_reuse_abandoned_futures_and_cleanup() {
        let path = std::env::var_os("CORSAIRS_TEST_MODEL").expect("set CORSAIRS_TEST_MODEL");
        let runtime = Runtime::new().unwrap();
        let counts = |runtime: &Runtime| {
            runtime
                .worker
                .submit(|session| Ok(session.live_metal_counts()))
                .wait()
                .unwrap()
        };
        assert_eq!(counts(&runtime), (0, 0, 0));
        {
            let model = runtime
                .load_model(path, Compute::GpuPreferred)
                .wait()
                .unwrap();
            let function = model.load_function("main").wait().unwrap();
            let queue = runtime.metal_queue().wait().unwrap();
            let input = queue
                .upload(Tensor::from_vec([2, 3], vec![1f32, -2., 0.5, 7., 0., -1.]).unwrap())
                .wait()
                .unwrap();
            let output = queue.buffer(DType::Float32, vec![2, 3]).wait().unwrap();
            assert_eq!(
                output.download().wait().unwrap().to_vec::<f32>().unwrap(),
                vec![0.; 6]
            );
            // SAFETY: Exports are retained and external access is serialized;
            // these objects are imported on the same worker and physical queue.
            let exported_queue = unsafe { queue.export_queue() }.wait().unwrap();
            // SAFETY: Same contract as the retained queue export above.
            let exported_input = unsafe { input.export_buffer() }.wait().unwrap();
            // SAFETY: The retained export keeps the valid queue alive.
            let imported_queue = unsafe { runtime.import_metal_queue(exported_queue.as_raw()) }
                .wait()
                .unwrap();
            // SAFETY: Initialized shared storage; same physical queue, no races
            // or distinct aliasing object; ownership is independently retained.
            let imported_input = unsafe {
                imported_queue.import_buffer(exported_input.as_raw(), 0, DType::Float32, vec![2, 3])
            }
            .wait()
            .unwrap();
            let imported_output = imported_queue
                .buffer(DType::Float32, vec![2, 3])
                .wait()
                .unwrap();
            for _ in 0..100 {
                let result = function
                    .encode(
                        &imported_queue,
                        [("x", imported_input.clone())].into(),
                        MetalBufferMap::new(),
                        [("y", imported_output.clone())].into(),
                    )
                    .wait()
                    .unwrap();
                assert_eq!(
                    result
                        .outputs
                        .get("y")
                        .unwrap()
                        .download()
                        .wait()
                        .unwrap()
                        .to_vec::<f32>()
                        .unwrap(),
                    vec![2., -4., 1., 14., 0., -2.]
                );
            }
            // Captured automatic outputs can feed another explicit-buffer call.
            let first = function
                .encode(
                    &queue,
                    [("x", input.clone())].into(),
                    MetalBufferMap::new(),
                    MetalBufferMap::new(),
                )
                .wait()
                .unwrap();
            let second = function
                .encode(
                    &queue,
                    [("x", first.outputs.get("y").unwrap().clone())].into(),
                    MetalBufferMap::new(),
                    [("y", output.clone())].into(),
                )
                .wait()
                .unwrap();
            assert_eq!(
                second
                    .outputs
                    .get("y")
                    .unwrap()
                    .download()
                    .wait()
                    .unwrap()
                    .to_vec::<f32>()
                    .unwrap(),
                vec![4., -8., 2., 28., 0., -4.]
            );
            // Same-object foreign aliases must still be recognized.
            // SAFETY: Same retained initialized object/queue contract as above.
            let alias = unsafe {
                imported_queue.import_buffer(exported_input.as_raw(), 0, DType::Float32, vec![2, 3])
            }
            .wait()
            .unwrap();
            assert!(
                function
                    .encode(
                        &imported_queue,
                        [("x", imported_input.clone())].into(),
                        MetalBufferMap::new(),
                        [("y", alias)].into()
                    )
                    .wait()
                    .is_err()
            );
            // SAFETY: Valid object, intentionally invalid extent checked before use.
            assert!(
                // SAFETY: Same retained object; native validation rejects bounds.
                unsafe {
                    imported_queue.import_buffer(
                        exported_input.as_raw(),
                        0,
                        DType::Float32,
                        vec![200, 3],
                    )
                }
                .wait()
                .is_err()
            );
            for _ in 0..20 {
                drop(function.encode(
                    &queue,
                    [("x", input.clone())].into(),
                    MetalBufferMap::new(),
                    MetalBufferMap::new(),
                ));
                drop(function.encode(
                    &queue,
                    [("missing", input.clone())].into(),
                    MetalBufferMap::new(),
                    MetalBufferMap::new(),
                ));
                drop(queue.upload(Tensor::zeros(DType::Float32, [2, 3]).unwrap()));
            }
            queue.fence().wait().unwrap();
        }
        for _ in 0..8 {
            runtime.flush().wait().unwrap();
            if counts(&runtime) == (0, 0, 0) {
                break;
            }
        }
        assert_eq!(counts(&runtime), (0, 0, 0));
    }
}
