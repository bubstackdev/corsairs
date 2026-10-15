//! Experimental, platform-specific calls into Apple's existing Core AI framework.
//!
//! These are investigation tools, not a stable or safe tensor API. Native values
//! must follow the exact contracts recorded in `docs/abi-contracts.md`.

#[cfg(not(all(target_os = "macos", target_arch = "aarch64")))]
compile_error!("The initial Corsairs ABI experiment targets Apple Silicon macOS only.");

mod arm64;
mod async_task;
#[cfg(feature = "abi-research")]
mod buffer;
mod errors;
#[cfg(feature = "abi-research")]
mod inference;
mod loader;
mod metadata;
#[cfg(feature = "abi-research")]
mod model;
mod owned;
#[cfg(feature = "abi-research")]
mod task;
mod task_create;
#[cfg(feature = "abi-research")]
mod tensor;
mod text;
#[cfg(feature = "abi-research")]
mod value;

#[cfg(feature = "abi-research")]
pub use async_task::SuspensionReport;
#[cfg(feature = "abi-research")]
pub use errors::ErrorReport;
#[cfg(feature = "abi-research")]
pub use inference::InferenceReport;
pub use loader::Error;
pub use metadata::{Metadata, TypeLayout};
#[cfg(feature = "abi-research")]
pub use model::ModelReport;
pub use owned::{
    NativeCompute, NativeDType, NativeFailure, NativeFunctionDescriptor, NativeSession,
    NativeTensor, NativeTensorDescriptor,
};
#[cfg(feature = "abi-research")]
pub use owned::{NativeFunction, NativeModel, NativeRunResult};
#[cfg(feature = "abi-research")]
pub use task::TaskReport;
#[cfg(feature = "abi-research")]
pub use tensor::TensorReport;

use loader::Library;
use std::ffi::CStr;

/// Holds the framework open for the lifetime of every native call and value.
pub struct Runtime {
    library: Library,
}

impl Runtime {
    /// Open the OS framework. The caller must use the documented SDK/OS pairing.
    ///
    /// # Safety
    /// This loads and can initialize Apple's native library. This experimental
    /// binding has only been investigated on macOS 27, Apple Silicon.
    pub unsafe fn open() -> Result<Self, Error> {
        // SAFETY: Fixed system-framework path; the returned handle is owned here.
        let library = unsafe {
            Library::open(c"/System/Library/Frameworks/CoreAI.framework/Versions/A/CoreAI")?
        };
        Ok(Self { library })
    }

    /// Request complete metadata for a verified non-generic nominal type.
    ///
    /// # Safety
    /// `accessor` must name a metadata accessor with the verified Swift signature
    /// `(MetadataRequest) -> MetadataResponse`, not an arbitrary exported symbol.
    pub unsafe fn metadata(&self, accessor: &CStr) -> Result<Metadata<'_>, Error> {
        let function = self.library.symbol(accessor)?;
        // SAFETY: Caller supplies the accessor contract; request 0 asks for
        // complete metadata synchronously. The framework remains loaded.
        let (pointer, state) = unsafe { arm64::metadata_accessor(function.as_ptr(), 0) };
        // SAFETY: The verified accessor returns a metadata address and state.
        unsafe { Metadata::from_response(pointer, state) }
    }
}

pub const NDARRAY_METADATA: &CStr = c"$s13CoreAIRuntime7NDArrayVMa";
pub const SCALAR_METADATA: &CStr = c"$s13CoreAIRuntime7NDArrayV10ScalarTypeOMa";
pub const MODEL_METADATA: &CStr = c"$s13CoreAIRuntime7AIModelVMa";
pub const FUNCTION_METADATA: &CStr = c"$s13CoreAIRuntime17InferenceFunctionVMa";
