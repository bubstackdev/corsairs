//! Opaque native tensor handles; public values contain no native addresses.
use super::*;
use crate::native::NativeTensorHandle;
use std::fmt;

struct TensorHandleInner {
    runtime: Runtime,
    id: u64,
    dtype: DType,
    shape: Vec<usize>,
    strides: Vec<isize>,
}
impl Drop for TensorHandleInner {
    fn drop(&mut self) {
        let id = self.id;
        self.runtime.worker.release(move |session| {
            // SAFETY: The final Arc follows every job retaining this handle.
            // Native storage is destroyed only on its owning session worker.
            let _ = unsafe { session.drop_tensor(id) };
        });
    }
}

/// A retained native tensor allocation owned by one runtime's worker.
///
/// Clones share the same native tensor, rather than copying its contents. State
/// passed to `Function::run_native` is mutated in place; all clones observe that
/// state through later downloads. Operations are serialized on the runtime.
#[derive(Clone)]
pub struct TensorHandle(Arc<TensorHandleInner>);
impl fmt::Debug for TensorHandle {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("TensorHandle")
            .field("dtype", &self.dtype())
            .field("shape", &self.shape())
            .field("strides", &self.strides())
            .finish_non_exhaustive()
    }
}
impl TensorHandle {
    fn new(runtime: Runtime, info: NativeTensorHandle) -> Self {
        Self(Arc::new(TensorHandleInner {
            runtime,
            id: info.id,
            dtype: from_native_dtype(info.dtype),
            shape: info.shape,
            strides: info.strides,
        }))
    }
    /// Scalar type, available without downloading tensor contents.
    pub fn dtype(&self) -> DType {
        self.0.dtype
    }
    /// Resolved dimensions, available without a host payload copy.
    pub fn shape(&self) -> &[usize] {
        &self.0.shape
    }
    /// Native strides in scalar elements. These can differ from row-major order.
    pub fn strides(&self) -> &[isize] {
        &self.0.strides
    }
    /// Copy completed native contents into a contiguous owned Rust tensor.
    /// Nonnegative strides are packed in row-major order; negative strides are
    /// unsupported until their native storage-origin contract is established.
    pub fn download(&self) -> Task<Tensor> {
        self.0.runtime.download(self)
    }
}

/// Named retained native tensors. Cloning this map retains the same allocations.
#[derive(Clone, Debug, Default)]
pub struct TensorHandleMap(BTreeMap<String, TensorHandle>);
impl TensorHandleMap {
    /// Construct an empty native tensor map.
    pub fn new() -> Self {
        Self::default()
    }
    /// Insert a handle, returning a previously associated handle if present.
    pub fn insert(&mut self, name: impl Into<String>, value: TensorHandle) -> Option<TensorHandle> {
        self.0.insert(name.into(), value)
    }
    /// Borrow a named handle.
    pub fn get(&self, name: &str) -> Option<&TensorHandle> {
        self.0.get(name)
    }
    /// Remove and return a named handle.
    pub fn remove(&mut self, name: &str) -> Option<TensorHandle> {
        self.0.remove(name)
    }
    /// Number of named handles.
    pub fn len(&self) -> usize {
        self.0.len()
    }
    /// Whether the map contains no handles.
    pub fn is_empty(&self) -> bool {
        self.0.is_empty()
    }
    /// Iterate in lexicographic name order.
    pub fn iter(&self) -> impl Iterator<Item = (&str, &TensorHandle)> {
        self.0.iter().map(|(name, value)| (name.as_str(), value))
    }
    fn ids(&self) -> Vec<(String, u64)> {
        self.0
            .iter()
            .map(|(name, value)| (name.clone(), value.0.id))
            .collect()
    }
    fn belongs_to(&self, runtime: &Runtime) -> bool {
        self.0
            .values()
            .all(|value| runtime.worker.same_worker(&value.0.runtime.worker))
    }
}
impl<K: Into<String>> FromIterator<(K, TensorHandle)> for TensorHandleMap {
    fn from_iter<T: IntoIterator<Item = (K, TensorHandle)>>(iter: T) -> Self {
        Self(
            iter.into_iter()
                .map(|(name, value)| (name.into(), value))
                .collect(),
        )
    }
}
impl<const N: usize, K: Into<String>> From<[(K, TensorHandle); N]> for TensorHandleMap {
    fn from(value: [(K, TensorHandle); N]) -> Self {
        value.into_iter().collect()
    }
}

/// Retained native outputs and the same state handles updated in place.
/// Chaining these outputs into another native run avoids a Rust byte round trip.
#[derive(Clone, Debug)]
pub struct NativeRunResult {
    /// Newly retained native output tensors.
    pub outputs: TensorHandleMap,
    /// The supplied state handles, after native in-place updates.
    pub states: TensorHandleMap,
}

impl Runtime {
    /// Copy one owned Rust tensor into native storage retained by this runtime.
    /// The pending request owns the tensor until upload completes, even if its
    /// returned future is dropped.
    pub fn upload(&self, tensor: Tensor) -> Task<TensorHandle> {
        let runtime = self.clone();
        self.worker.submit(move |session| {
            let (dtype, shape, bytes) = tensor.into_parts();
            // SAFETY: The DTO contains only owned Rust bytes; native creation
            // and subsequent storage ownership stay on this session's worker.
            let handle = unsafe {
                session
                    .upload_tensor(NativeTensor {
                        dtype: to_native_dtype(dtype),
                        shape,
                        bytes,
                    })
                    .map_err(native_error)?
            };
            Ok(TensorHandle::new(runtime, handle))
        })
    }

    /// Download a handle belonging to this runtime. Cross-runtime handles return
    /// an error before native storage is accessed.
    pub fn download(&self, tensor: &TensorHandle) -> Task<Tensor> {
        let same_worker = self.worker.same_worker(&tensor.0.runtime.worker);
        let tensor = tensor.clone();
        self.worker.submit(move |session| {
            if !same_worker {
                return Err(Error::Unsupported(
                    "tensor handle belongs to another runtime".into(),
                ));
            }
            // SAFETY: The captured Arc retains this session-local handle until
            // its serialized native read and host copy have completed.
            let value = unsafe { session.download_tensor(tensor.0.id).map_err(native_error)? };
            Tensor::from_bytes(from_native_dtype(value.dtype), value.shape, value.bytes)
        })
    }
}

impl Function {
    /// Execute from retained native tensors without copying payloads through
    /// Rust host buffers between runs. This is not a device zero-copy guarantee.
    ///
    /// State handles mutate in place and retain their identity. The same handle
    /// cannot appear as both an input and state, or under two state names.
    /// Conservatively tracked source/output lineages that overlap are also
    /// rejected for mutable use, even when the framework made distinct buffers.
    /// All inference-derived tensors share a reserved possible-alias origin:
    /// outputs of unrelated calls/models may share constants or backend storage.
    /// Consequently two inference-derived handles cannot be combined when one
    /// is mutable state. Downloading then uploading makes a fresh allocation,
    /// with an explicit host copy, if independent mutable storage is required.
    /// Clones share state contents. A failed native operation can leave state
    /// modified; no rollback is promised. All handles must belong to this
    /// function's runtime. Dropping the future retains submitted resources.
    pub fn run_native(
        &self,
        inputs: TensorHandleMap,
        states: TensorHandleMap,
    ) -> Task<NativeRunResult> {
        let function = self.clone();
        let runtime = self.0.model.0.runtime.clone();
        let same_worker = inputs.belongs_to(&runtime) && states.belongs_to(&runtime);
        runtime.worker.clone().submit(move |session| {
            if !same_worker {
                return Err(Error::Unsupported(
                    "tensor handle belongs to another runtime".into(),
                ));
            }
            validate_handles(&function.0.descriptor.inputs, &inputs, "input")?;
            validate_handles(&function.0.descriptor.states, &states, "state")?;
            // SAFETY: Owned handle maps and function remain captured until true
            // completion. The native store rejects mutable alias IDs before views.
            let result = unsafe {
                session
                    .run_native(function.0.id, inputs.ids(), states.ids())
                    .map_err(native_error)?
            };
            let mut outputs = TensorHandleMap::new();
            // Give every returned ID an Arc before any fallible map validation,
            // so an error also queues cleanup for outputs not yet inserted.
            let handles: Vec<_> = result
                .outputs
                .into_iter()
                .map(|(name, info)| (name, TensorHandle::new(runtime.clone(), info)))
                .collect();
            for (name, handle) in handles {
                if outputs.insert(name.clone(), handle).is_some() {
                    return Err(Error::DuplicateName(name));
                }
            }
            // Reuse the original state Arcs. Creating separate Arcs for the same
            // ID would let one finalizer invalidate another still-live handle.
            debug_assert!(
                result.states.iter().all(|(name, info)| states
                    .get(name)
                    .is_some_and(|state| state.0.id == info.id))
            );
            Ok(NativeRunResult { outputs, states })
        })
    }
}

fn validate_handles(
    descriptors: &[TensorDescriptor],
    values: &TensorHandleMap,
    kind: &'static str,
) -> Result<(), Error> {
    for (name, _) in values.iter() {
        if !descriptors.iter().any(|d| d.name == name) {
            return Err(Error::UnexpectedTensor {
                kind,
                name: name.into(),
            });
        }
    }
    for descriptor in descriptors {
        let value = values
            .get(&descriptor.name)
            .ok_or_else(|| Error::MissingTensor {
                kind,
                name: descriptor.name.clone(),
            })?;
        if descriptor.dtype != value.dtype()
            || descriptor.shape.len() != value.shape().len()
            || descriptor
                .shape
                .iter()
                .zip(value.shape())
                .any(|(wanted, actual)| wanted.is_some_and(|wanted| wanted != *actual))
        {
            return Err(Error::DescriptorMismatch {
                name: descriptor.name.clone(),
                reason: "native handle shape/dtype does not match".into(),
            });
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[ignore = "requires permitted native Core AI and CORSAIRS_TEST_MODEL x+x fixture"]
    fn native_gpu_stream_reuses_queue_and_drains_private_handles() {
        let runtime = Runtime::new().unwrap();
        let path = std::env::var_os("CORSAIRS_TEST_MODEL").expect("CORSAIRS_TEST_MODEL");
        let model = runtime
            .load_model(PathBuf::from(path), Compute::GpuPreferred)
            .wait()
            .unwrap();
        let function = model.load_function("main").wait().unwrap();
        let input = runtime
            .upload(Tensor::from_vec([2, 3], vec![1f32; 6]).unwrap())
            .wait()
            .unwrap();
        let mut identity = None;
        for _ in 0..20 {
            let owned = function
                .run(
                    TensorMap::from([("x", Tensor::from_vec([2, 3], vec![1f32; 6]).unwrap())]),
                    TensorMap::new(),
                )
                .wait()
                .unwrap();
            assert_eq!(
                owned.outputs.get("y").unwrap().to_vec::<f32>().unwrap(),
                [2.; 6]
            );
            drop(function.run_native(
                TensorHandleMap::from([("x", input.clone())]),
                TensorHandleMap::new(),
            ));
            runtime.drain().wait().unwrap();
            let (current, tensors, metal) = runtime
                .worker
                .submit(|session| {
                    Ok((
                        session.owned_stream_identity(),
                        session.live_tensor_count(),
                        session.live_metal_counts(),
                    ))
                })
                .wait()
                .unwrap();
            assert!(current.is_some());
            assert_eq!(*identity.get_or_insert(current), current);
            assert_eq!(tensors, 1);
            assert_eq!(metal, (0, 0, 0));
        }
        assert_eq!(
            input.download().wait().unwrap().to_vec::<f32>().unwrap(),
            [1.; 6]
        );
        drop((input, function, model));
        runtime.drain().wait().unwrap();
        assert_eq!(
            runtime
                .worker
                .submit(|session| Ok((
                    session.live_counts(),
                    session.live_tensor_count(),
                    session.live_metal_counts()
                )))
                .wait()
                .unwrap(),
            ((0, 0), 0, (0, 0, 0))
        );
    }

    #[test]
    #[ignore = "requires permitted native Core AI and CORSAIRS_TEST_MODEL x+x fixture"]
    fn native_handles_retain_chain_and_release_abandoned_results() {
        let runtime = Runtime::new().unwrap();
        let path = std::env::var_os("CORSAIRS_TEST_MODEL").expect("CORSAIRS_TEST_MODEL");
        let model = runtime
            .load_model(PathBuf::from(path), Compute::CpuOnly)
            .wait()
            .unwrap();
        let first = model.load_function("main").wait().unwrap();
        let second = model.load_function("main").wait().unwrap();
        {
            let original = runtime
                .upload(Tensor::from_vec([2, 3], vec![1f32; 6]).unwrap())
                .wait()
                .unwrap();
            let retained = original.clone();
            drop(original);
            assert_eq!(
                retained.download().wait().unwrap().to_vec::<f32>().unwrap(),
                [1.; 6]
            );
            let result = first
                .run_native(
                    TensorHandleMap::from([("x", retained)]),
                    TensorHandleMap::new(),
                )
                .wait()
                .unwrap();
            let next = result.outputs.get("y").unwrap().clone();
            let result = second
                .run_native(TensorHandleMap::from([("x", next)]), TensorHandleMap::new())
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
                [4.; 6]
            );
        }
        runtime.flush().wait().unwrap();
        runtime.flush().wait().unwrap();
        assert_eq!(
            runtime
                .worker
                .submit(|session| Ok(session.live_tensor_count()))
                .wait()
                .unwrap(),
            0
        );
        for _ in 0..20 {
            drop(runtime.upload(Tensor::from_vec([2, 3], vec![2f32; 6]).unwrap()));
        }
        runtime.flush().wait().unwrap();
        runtime.flush().wait().unwrap();
        assert_eq!(
            runtime
                .worker
                .submit(|session| Ok(session.live_tensor_count()))
                .wait()
                .unwrap(),
            0
        );
        for _ in 0..20 {
            let input = runtime
                .upload(Tensor::from_vec([2, 3], vec![3f32; 6]).unwrap())
                .wait()
                .unwrap();
            drop(first.run_native(
                TensorHandleMap::from([("x", input)]),
                TensorHandleMap::new(),
            ));
        }
        runtime.flush().wait().unwrap();
        runtime.flush().wait().unwrap();
        assert_eq!(
            runtime
                .worker
                .submit(|session| Ok(session.live_tensor_count()))
                .wait()
                .unwrap(),
            0
        );
    }
}
