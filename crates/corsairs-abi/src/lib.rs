//! Safe Rust inference with Apple Core AI on Apple Silicon macOS 27.
//!
//! Native calls are serialized on a dedicated worker. Tensors and returned
//! state use owned Rust storage; pending work survives a dropped future.
//! v0.1 supports resolved static signatures and owned contiguous float16,
//! float32, int32, int64, and bool tensors, with rank at most 64 and storage
//! at most 1 GiB per tensor. GPU preference permits native fallback.
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
pub use dtype::{DType, Float16, MAX_TENSOR_BYTES, MAX_TENSOR_RANK, Tensor, TensorElement};
pub use facade::{
    Compute, Function, FunctionDescriptor, Model, RunResult, Runtime, TensorDescriptor, TensorMap,
};
pub use worker::Task;
