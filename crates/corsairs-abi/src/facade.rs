use crate::native::{
    NativeCompute, NativeDType, NativeFailure, NativeFunctionDescriptor, NativeLoadOptions,
    NativeSession, NativeTensor, NativeTensorDescriptor,
};
use crate::{
    api_error::Error,
    dtype::{DType, Tensor},
    worker::{Task, Worker},
};
use std::collections::BTreeMap;
use std::path::{Path, PathBuf};
use std::sync::Arc;

mod function_batch;
#[cfg(feature = "abi-research")]
pub use function_batch::FunctionBatchLoadReport;
pub use function_batch::FunctionLoadRequest;
mod batch;
pub use batch::ModelLoadRequest;
#[cfg(feature = "abi-research")]
pub use batch::{BatchLoadMetrics, BatchLoadReport};
mod handles;
pub use handles::{NativeRunResult, TensorHandle, TensorHandleMap};
mod metal;
pub use metal::{
    MetalBuffer, MetalBufferMap, MetalObject, MetalQueue, MetalRunResult, MetalValue, MetalValueMap,
};

/// The requested specialization policy. GPU preference allows Core AI to use
/// other available compute units; it is not proof of GPU execution.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum Compute {
    #[default]
    CpuOnly,
    GpuPreferred,
}

/// Requested specialization choices retained for each loaded model.
///
/// These choices configure Core AI; they do not prove a particular compute
/// device, compilation strategy, or performance outcome was selected.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct LoadOptions {
    /// Requested compute policy.
    pub compute: Compute,
    /// Frequent-reshape hint. None preserves the SDK's constructor default.
    /// Some(false) explicitly disables the hint; Some(true) enables it.
    pub expect_frequent_reshapes: Option<bool>,
}
impl LoadOptions {
    /// Choose compute policy while leaving the reshape hint at its SDK default.
    pub const fn new(compute: Compute) -> Self {
        Self {
            compute,
            expect_frequent_reshapes: None,
        }
    }
    /// Explicitly set the frequent-reshape specialization hint for this model.
    pub const fn with_expect_frequent_reshapes(mut self, enabled: bool) -> Self {
        self.expect_frequent_reshapes = Some(enabled);
        self
    }
}
impl From<Compute> for LoadOptions {
    fn from(compute: Compute) -> Self {
        Self::new(compute)
    }
}

/// A named tensor's declared shape and scalar type.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TensorDescriptor {
    /// Native operand name.
    pub name: String,
    /// Required scalar type.
    pub dtype: DType,
    /// Dimensions; None denotes a dynamic dimension. Every invocation must
    /// supply concrete dimensions, preserving the signature's fixed dimensions.
    pub shape: Vec<Option<usize>>,
}

/// The named signature of a loaded function.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FunctionDescriptor {
    /// Native function name.
    pub name: String,
    /// Required named input tensors.
    pub inputs: Vec<TensorDescriptor>,
    /// Named output tensors.
    pub outputs: Vec<TensorDescriptor>,
    /// Required named state tensors.
    pub states: Vec<TensorDescriptor>,
}

/// An owned collection of tensors indexed by native operand name.
/// Inserting an existing name replaces its value, like a Rust map.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct TensorMap(BTreeMap<String, Tensor>);
impl TensorMap {
    /// Construct an empty collection.
    pub fn new() -> Self {
        Self::default()
    }
    /// Insert a tensor, returning any replaced value.
    pub fn insert(&mut self, name: impl Into<String>, tensor: Tensor) -> Option<Tensor> {
        self.0.insert(name.into(), tensor)
    }
    /// Borrow a named tensor.
    pub fn get(&self, name: &str) -> Option<&Tensor> {
        self.0.get(name)
    }
    /// Take a named tensor out of this collection.
    pub fn remove(&mut self, name: &str) -> Option<Tensor> {
        self.0.remove(name)
    }
    /// Number of named tensors.
    pub fn len(&self) -> usize {
        self.0.len()
    }
    /// Whether the collection is empty.
    pub fn is_empty(&self) -> bool {
        self.0.is_empty()
    }
    /// Iterate in lexicographic name order.
    pub fn iter(&self) -> impl Iterator<Item = (&str, &Tensor)> {
        self.0.iter().map(|(name, tensor)| (name.as_str(), tensor))
    }
    fn into_native(self) -> Vec<(String, NativeTensor)> {
        self.0
            .into_iter()
            .map(|(name, tensor)| {
                let (dtype, shape, bytes) = tensor.into_parts();
                (
                    name,
                    NativeTensor {
                        dtype: to_native_dtype(dtype),
                        shape,
                        bytes,
                    },
                )
            })
            .collect()
    }
    fn from_native(tensors: Vec<(String, NativeTensor)>) -> Result<Self, Error> {
        let mut result = Self::new();
        for (name, tensor) in tensors {
            let value =
                Tensor::from_bytes(from_native_dtype(tensor.dtype), tensor.shape, tensor.bytes)?;
            if result.insert(name.clone(), value).is_some() {
                return Err(Error::DuplicateName(name));
            }
        }
        Ok(result)
    }
}
impl<K: Into<String>> FromIterator<(K, Tensor)> for TensorMap {
    fn from_iter<T: IntoIterator<Item = (K, Tensor)>>(iter: T) -> Self {
        Self(iter.into_iter().map(|(k, v)| (k.into(), v)).collect())
    }
}
impl<const N: usize, K: Into<String>> From<[(K, Tensor); N]> for TensorMap {
    fn from(value: [(K, Tensor); N]) -> Self {
        value.into_iter().collect()
    }
}

/// Owned outputs and the updated state after one completed inference call.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RunResult {
    /// Function outputs copied into contiguous Rust-owned storage.
    pub outputs: TensorMap,
    /// State tensors after execution; pass these into the next step.
    pub states: TensorMap,
}

/// A Core AI session backed by one dedicated native worker.
///
/// Clones share the worker and serialize native calls. Native values stay on
/// that thread; public tensors/results are independently owned Rust data.
#[derive(Clone)]
pub struct Runtime {
    worker: Worker<NativeSession>,
}
impl Runtime {
    /// Start a native worker on a supported Apple Silicon macOS 27 installation.
    pub fn new() -> Result<Self, Error> {
        let version = std::process::Command::new("/usr/bin/sw_vers")
            .arg("-productVersion")
            .output()
            .map_err(|e| Error::Unsupported(format!("cannot determine macOS version: {e}")))?;
        let version =
            String::from_utf8(version.stdout).map_err(|e| Error::Unsupported(e.to_string()))?;
        if !version.trim().starts_with("27.") {
            return Err(Error::Unsupported(format!(
                "requires macOS 27; detected {}",
                version.trim()
            )));
        }
        let worker = Worker::start(|| {
            // SAFETY: Version/platform checked, session created and destroyed
            // inside its sole worker; public requests never carry native pointers.
            unsafe { NativeSession::open().map_err(native_error) }
        })?;
        Ok(Self { worker })
    }
    /// Submit asynchronous asset loading with an explicit compute policy.
    /// The frequent-reshape hint retains the SDK's constructor default.
    pub fn load_model(&self, path: impl AsRef<Path>, compute: Compute) -> Task<Model> {
        self.load_model_with_options(path, compute.into())
    }
    /// Submit asset loading with per-model specialization options.
    /// An omitted frequent-reshape override leaves the SDK default unchanged.
    pub fn load_model_with_options(
        &self,
        path: impl AsRef<Path>,
        options: LoadOptions,
    ) -> Task<Model> {
        let path = path.as_ref().to_path_buf();
        let runtime = self.clone();
        self.worker.submit(move |session| {
            // SAFETY: Only this worker owns the session and all native storage.
            let model = unsafe {
                let native_options = NativeLoadOptions {
                    compute: match options.compute {
                        Compute::CpuOnly => NativeCompute::CpuOnly,
                        Compute::GpuPreferred => NativeCompute::GpuPreferred,
                    },
                    expect_frequent_reshapes: options.expect_frequent_reshapes,
                };
                if native_options.expect_frequent_reshapes.is_none() {
                    session.load_model(&path, native_options.compute)
                } else {
                    session.load_model_with_options(&path, native_options)
                }
                .map_err(native_error)?
            };
            Ok(Model(Arc::new(ModelInner {
                runtime,
                id: model.id,
                names: model.function_names,
                path,
                options,
            })))
        })
    }
    /// Fence work and releases already queued when this method is called.
    /// Cleanup enqueued by one of those jobs can follow this fence; this does
    /// not wait for handles still held by the caller or for transitive cleanup.
    pub fn flush(&self) -> Task<()> {
        self.worker.submit(|_| Ok(()))
    }
    /// Wait for earlier requests and every queued release they cause, including
    /// cleanup of abandoned results and failed requests. The submission boundary
    /// is captured by this call; later independent requests do not extend it.
    ///
    /// Handles and completed results still held by the application remain alive.
    /// Drop stage handles and unwanted tasks before calling this method. Their
    /// native releases finish before this task resolves, but Core AI or the OS
    /// may retain caches and mapped pages. This does not promise memory eviction.
    /// As with other tasks, synchronously waiting on this worker is rejected.
    pub fn drain(&self) -> Task<()> {
        self.worker.drain()
    }
}

struct ModelInner {
    runtime: Runtime,
    id: u64,
    names: Vec<String>,
    path: PathBuf,
    options: LoadOptions,
}
impl Drop for ModelInner {
    fn drop(&mut self) {
        let id = self.id;
        self.runtime.worker.release(move |session| {
            // SAFETY: Function objects retain a Model clone; function release is
            // queued before this final model release on the same worker.
            let _ = unsafe { session.drop_model(id) };
        });
    }
}

/// A loaded model. Functions and pending requests keep its resources alive.
#[derive(Clone)]
pub struct Model(Arc<ModelInner>);
impl Model {
    /// Names of functions in this model.
    pub fn function_names(&self) -> &[String] {
        &self.0.names
    }
    /// Path used to load this model.
    pub fn path(&self) -> &Path {
        &self.0.path
    }
    /// Requested specialization policy.
    pub fn compute(&self) -> Compute {
        self.0.options.compute
    }
    /// The requested options used at load time, including an optional override.
    /// None records that the SDK default was preserved, not an effective value.
    pub fn load_options(&self) -> LoadOptions {
        self.0.options
    }
    /// Load and inspect one named function.
    pub fn load_function(&self, name: impl Into<String>) -> Task<Function> {
        let model = self.clone();
        let name = name.into();
        self.0.runtime.worker.submit(move |session| {
            if !model.function_names().contains(&name) {
                return Err(Error::FunctionNotFound(name));
            }
            // SAFETY: Model retained by this request; session and native handles
            // are accessed exclusively on their owning worker.
            let function = unsafe {
                session
                    .load_function(model.0.id, &name)
                    .map_err(native_error)?
            };
            Ok(Function(Arc::new(FunctionInner {
                id: function.id,
                descriptor: descriptor(function.descriptor),
                model,
            })))
        })
    }
}

struct FunctionInner {
    id: u64,
    descriptor: FunctionDescriptor,
    model: Model,
}
impl Drop for FunctionInner {
    fn drop(&mut self) {
        let id = self.id;
        self.model.0.runtime.worker.release(move |session| {
            // SAFETY: All pending run requests own a Function clone. This final
            // release therefore follows all runs and precedes model destruction.
            let _ = unsafe { session.drop_function(id) };
        });
    }
}

/// A loaded function with a checked tensor signature.
#[derive(Clone)]
pub struct Function(Arc<FunctionInner>);
impl Function {
    /// Immutable input, output and state descriptors.
    pub fn descriptor(&self) -> &FunctionDescriptor {
        &self.0.descriptor
    }
    /// Submit inference with owned named inputs and state. Updated state is
    /// returned in RunResult; calls on this runtime execute in submission order.
    pub fn run(&self, inputs: TensorMap, states: TensorMap) -> Task<RunResult> {
        let function = self.clone();
        self.0.model.0.runtime.worker.submit(move |session| {
            validate(&function.0.descriptor.inputs, &inputs, "input")?;
            validate(&function.0.descriptor.states, &states, "state")?;
            // SAFETY: Owned inputs/state and a retained function live inside
            // this request until native completion, even if its future is dropped.
            let result = unsafe {
                session
                    .run(
                        function.0.id,
                        inputs.into_native(),
                        states.into_native(),
                        Vec::new(),
                    )
                    .map_err(native_error)?
            };
            Ok(RunResult {
                outputs: TensorMap::from_native(result.outputs)?,
                states: TensorMap::from_native(result.states)?,
            })
        })
    }
}

fn validate(
    descriptors: &[TensorDescriptor],
    values: &TensorMap,
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
        if value.dtype() != descriptor.dtype {
            return Err(Error::DescriptorMismatch {
                name: descriptor.name.clone(),
                reason: format!("requires {}, got {}", descriptor.dtype, value.dtype()),
            });
        }
        if descriptor.shape.len() != value.shape().len()
            || descriptor
                .shape
                .iter()
                .zip(value.shape())
                .any(|(wanted, actual)| wanted.is_some_and(|wanted| wanted != *actual))
        {
            return Err(Error::DescriptorMismatch {
                name: descriptor.name.clone(),
                reason: format!(
                    "requires shape {:?}, got {:?}",
                    descriptor.shape,
                    value.shape()
                ),
            });
        }
    }
    Ok(())
}
fn to_native_dtype(dtype: DType) -> NativeDType {
    match dtype {
        DType::Float16 => NativeDType::F16,
        DType::BFloat16 => NativeDType::Bf16,
        DType::Float32 => NativeDType::F32,
        DType::Int32 => NativeDType::I32,
        DType::Int64 => NativeDType::I64,
        DType::Bool => NativeDType::Bool,
    }
}
fn from_native_dtype(dtype: NativeDType) -> DType {
    match dtype {
        NativeDType::F16 => DType::Float16,
        NativeDType::Bf16 => DType::BFloat16,
        NativeDType::F32 => DType::Float32,
        NativeDType::I32 => DType::Int32,
        NativeDType::I64 => DType::Int64,
        NativeDType::Bool => DType::Bool,
    }
}
fn descriptor(value: NativeFunctionDescriptor) -> FunctionDescriptor {
    fn tensor(value: NativeTensorDescriptor) -> TensorDescriptor {
        TensorDescriptor {
            name: value.name,
            dtype: from_native_dtype(value.dtype),
            shape: value
                .shape
                .into_iter()
                .map(|n| usize::try_from(n).ok())
                .collect(),
        }
    }
    FunctionDescriptor {
        name: value.name,
        inputs: value.inputs.into_iter().map(tensor).collect(),
        outputs: value.outputs.into_iter().map(tensor).collect(),
        states: value.states.into_iter().map(tensor).collect(),
    }
}
fn native_error(error: NativeFailure) -> Error {
    match error {
        NativeFailure::Binding(s) => Error::Binding(s),
        NativeFailure::FunctionNotFound(name) => Error::FunctionNotFound(name),
        NativeFailure::InvalidData(s) => Error::DescriptorMismatch {
            name: "request".into(),
            reason: s,
        },
        NativeFailure::InvalidHandle { kind, id } => Error::InvalidHandle { kind, id },
        NativeFailure::Unsupported(s) => Error::Unsupported(s),
        NativeFailure::Native {
            operation,
            type_name,
        } => Error::Native {
            operation,
            type_name,
        },
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn load_options_preserve_defaults_and_explicit_false() {
        assert_eq!(LoadOptions::default(), LoadOptions::new(Compute::CpuOnly));
        for compute in [Compute::CpuOnly, Compute::GpuPreferred] {
            assert_eq!(LoadOptions::from(compute).expect_frequent_reshapes, None);
            for enabled in [true, false] {
                let options = LoadOptions::new(compute).with_expect_frequent_reshapes(enabled);
                assert_eq!(options.compute, compute);
                assert_eq!(options.expect_frequent_reshapes, Some(enabled));
            }
        }
    }
    #[test]
    fn mixed_fixed_and_dynamic_dimensions_validate_concrete_tensors() {
        let descriptors = [TensorDescriptor {
            name: "x".into(),
            dtype: DType::Float32,
            shape: vec![Some(2), None, Some(3)],
        }];
        for shape in [vec![2, 0, 3], vec![2, 1, 3], vec![2, 7, 3]] {
            let inputs = TensorMap::from([("x", Tensor::zeros(DType::Float32, shape).unwrap())]);
            assert!(validate(&descriptors, &inputs, "input").is_ok());
        }
        for shape in [vec![3, 1, 3], vec![2, 7, 4], vec![2, 3], vec![2, 1, 3, 1]] {
            let inputs = TensorMap::from([("x", Tensor::zeros(DType::Float32, shape).unwrap())]);
            assert!(matches!(
                validate(&descriptors, &inputs, "input"),
                Err(Error::DescriptorMismatch { .. })
            ));
        }
    }
    #[test]
    fn public_handles_and_owned_results_are_send_sync() {
        fn check<T: Send + Sync>() {}
        check::<Runtime>();
        check::<Model>();
        check::<Function>();
        check::<Tensor>();
        check::<TensorMap>();
        check::<RunResult>();
        check::<Task<RunResult>>();
    }
    #[test]
    #[ignore = "requires native Core AI services; CORSAIRS_TEST_MODEL points to a float32[2,3] x+x asset"]
    fn native_dropped_futures_release_model_and_function_handles() {
        let path = std::env::var_os("CORSAIRS_TEST_MODEL").expect("set CORSAIRS_TEST_MODEL");
        let runtime = Runtime::new().unwrap();
        // These requests have no receiving future when native completion occurs.
        for _ in 0..20 {
            drop(runtime.load_model(&path, Compute::CpuOnly));
        }
        runtime.drain().wait().unwrap();
        assert_eq!(
            runtime
                .worker
                .submit(|session| Ok(session.live_counts()))
                .wait()
                .unwrap(),
            (0, 0)
        );
        let model = runtime.load_model(&path, Compute::CpuOnly).wait().unwrap();
        for _ in 0..20 {
            drop(model.load_function("main"));
        }
        runtime.drain().wait().unwrap();
        assert_eq!(
            runtime
                .worker
                .submit(|session| Ok(session.live_counts()))
                .wait()
                .unwrap(),
            (1, 0)
        );
        let function = model.load_function("main").wait().unwrap();
        let inputs = TensorMap::from([("x", Tensor::from_vec([2, 3], vec![1f32; 6]).unwrap())]);
        for _ in 0..100 {
            drop(function.run(inputs.clone(), TensorMap::new()));
        }
        drop(function);
        drop(model);
        runtime.drain().wait().unwrap();
        assert_eq!(
            runtime
                .worker
                .submit(|session| Ok(session.live_counts()))
                .wait()
                .unwrap(),
            (0, 0)
        );
        // A failed function request must also release its captured model after
        // the caller discards both the model and the unsuccessful future.
        for _ in 0..10 {
            let model = runtime.load_model(&path, Compute::CpuOnly).wait().unwrap();
            let failed = model.load_function("__corsairs_missing_function__");
            drop(model);
            drop(failed);
        }
        runtime.drain().wait().unwrap();
        assert_eq!(
            runtime
                .worker
                .submit(|session| Ok(session.live_counts()))
                .wait()
                .unwrap(),
            (0, 0)
        );

        let model = runtime.load_model(&path, Compute::CpuOnly).wait().unwrap();
        let function = model.load_function("main").wait().unwrap();
        let input = runtime
            .upload(Tensor::from_vec([2, 3], vec![1f32; 6]).unwrap())
            .wait()
            .unwrap();
        for _ in 0..20 {
            drop(function.run_native(
                TensorHandleMap::from([("x", input.clone())]),
                TensorHandleMap::new(),
            ));
            // Validation errors destroy the same retained function captures.
            drop(function.run_native(TensorHandleMap::new(), TensorHandleMap::new()));
        }
        drop(function);
        drop(model);
        runtime.drain().wait().unwrap();
        assert_eq!(
            runtime
                .worker
                .submit(|session| Ok((session.live_counts(), session.live_tensor_count())))
                .wait()
                .unwrap(),
            ((0, 0), 1)
        );
        // Drain preserves the externally retained upload and it remains usable.
        assert_eq!(
            runtime
                .download(&input)
                .wait()
                .unwrap()
                .to_vec::<f32>()
                .unwrap(),
            vec![1f32; 6]
        );
        drop(input);
        runtime.drain().wait().unwrap();
        assert_eq!(
            runtime
                .worker
                .submit(|session| Ok((session.live_counts(), session.live_tensor_count())))
                .wait()
                .unwrap(),
            ((0, 0), 0)
        );
    }
    #[test]
    fn signatures_reject_names_dtype_and_shape_before_execution() {
        let desc = vec![TensorDescriptor {
            name: "x".into(),
            dtype: DType::Float32,
            shape: vec![Some(2), Some(3)],
        }];
        assert!(matches!(
            validate(&desc, &TensorMap::new(), "input"),
            Err(Error::MissingTensor { .. })
        ));
        let good = Tensor::zeros(DType::Float32, [2, 3]).unwrap();
        assert!(validate(&desc, &[("x", good.clone())].into(), "input").is_ok());
        assert!(matches!(
            validate(&desc, &[("y", good)].into(), "input"),
            Err(Error::UnexpectedTensor { .. })
        ));
        assert!(matches!(
            validate(
                &desc,
                &[("x", Tensor::zeros(DType::Int32, [2, 3]).unwrap())].into(),
                "input"
            ),
            Err(Error::DescriptorMismatch { .. })
        ));
        assert!(matches!(
            validate(
                &desc,
                &[("x", Tensor::zeros(DType::Float32, [3, 2]).unwrap())].into(),
                "input"
            ),
            Err(Error::DescriptorMismatch { .. })
        ));
    }
}
