//! Safe Rust inference with Apple Core AI on Apple Silicon macOS 27.
//!
//! A dedicated worker owns native values. Ordinary calls run in queue order;
//! explicit model batches enqueue independent native loads before joining them.
//! Tensors and returned state use owned Rust storage or retained native handles;
//! pending work survives a dropped future.
//! Supports static and dynamic signatures and owned contiguous float16,
//! bfloat16, float32, int32, int64, and bool tensors, with rank at most 64 and
//! storage at most 4 GiB per tensor. GPU-preferred inference accepts at most
//! 2 GiB per concrete tensor and referenced storage span; dynamic results are
//! checked after completion. Stateful owned/native GPU calls require fixed
//! signatures within 1 GiB. GPU preference permits native fallback.
//!
//! ```no_run
//! use corsairs::{Runtime, Compute, Tensor, TensorMap};
//! # fn example() -> Result<(), corsairs::Error> {
//! let runtime = Runtime::new()?;
//! let model = runtime.load_model("model.aimodel", Compute::CpuOnly).wait()?;
//! let function = model.load_function("main").wait()?;
//! let inputs = TensorMap::from([("x", Tensor::from_vec([2, 3], vec![1.0f32; 6])?)]);
//! let result = function.run(inputs, TensorMap::new()).wait()?;
//! # Ok(())
//! # }
//! ```

#[cfg(not(feature = "abi-research"))]
mod native;
#[cfg(feature = "abi-research")]
#[doc(hidden)]
pub mod native;

mod api_error;
mod dtype;
mod facade;
mod worker;

pub use api_error::Error;
pub use dtype::{
    BFloat16, DType, Float8E4M3Fn, Float8E5M2, Float16, MAX_GPU_INFERENCE_TENSOR_BYTES,
    MAX_TENSOR_BYTES, MAX_TENSOR_RANK, Tensor, TensorElement,
};
#[cfg(feature = "abi-research")]
pub use facade::FunctionBatchLoadReport;
pub use facade::FunctionLoadRequest;
pub use facade::{AssetCount, AssetFunction, AssetInfo, AssetMetadata, AssetSummary, AssetValue};
#[cfg(feature = "abi-research")]
pub use facade::{BatchLoadMetrics, BatchLoadReport};
pub use facade::{
    Compute, Function, FunctionDescriptor, LoadOptions, Model, ModelLoadRequest, NativeRunResult,
    RunResult, Runtime, TensorDescriptor, TensorHandle, TensorHandleMap, TensorMap,
};
pub use facade::{
    MetalBuffer, MetalBufferMap, MetalObject, MetalQueue, MetalRunResult, MetalValue, MetalValueMap,
};
pub use worker::{Cancel, CancelHandle, Task};
