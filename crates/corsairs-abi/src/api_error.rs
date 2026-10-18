use crate::dtype::DType;
use std::fmt;

/// Errors returned by the safe Corsairs API.
#[derive(Debug, Clone, PartialEq, Eq)]
#[non_exhaustive]
pub enum Error {
    /// A shape's element or byte count overflowed the supported address space.
    ShapeOverflow,
    /// The requested tensor exceeds v0.1's documented resource limits.
    TensorLimit(String),
    /// The supplied storage does not contain the shape's required elements.
    ElementCount { expected: usize, actual: usize },
    /// Typed access requested a different scalar type.
    DTypeMismatch { expected: DType, actual: DType },
    /// A boolean tensor contained a byte other than zero or one.
    InvalidBoolean { index: usize, value: u8 },
    /// A required named tensor was absent.
    MissingTensor { kind: &'static str, name: String },
    /// A supplied name does not occur in the function's signature.
    UnexpectedTensor { kind: &'static str, name: String },
    /// A name occurred twice in a collection.
    DuplicateName(String),
    /// The model does not contain the requested function.
    FunctionNotFound(String),
    /// A supplied tensor does not match its function descriptor.
    DescriptorMismatch { name: String, reason: String },
    /// The requested feature lies outside the supported release subset.
    Unsupported(String),
    /// An identifier is no longer present in the native session.
    InvalidHandle { kind: &'static str, id: u64 },
    /// Core AI threw an error. Its native dynamic type is preserved.
    Native {
        operation: &'static str,
        type_name: String,
    },
    /// A native ABI or dynamic loading requirement could not be satisfied.
    Binding(String),
    /// The worker stopped or could not accept the request.
    WorkerUnavailable,
    /// A synchronous wait would block the worker needed to execute that request.
    ReentrantWait,
    /// Creating the native worker failed.
    WorkerStart(String),
    /// The path is not a valid Core AI model asset.
    InvalidAsset(String),
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::ShapeOverflow => f.write_str("tensor shape exceeds the supported address space"),
            Self::TensorLimit(reason) => write!(f, "tensor exceeds the v0.1 limit: {reason}"),
            Self::ElementCount { expected, actual } => {
                write!(f, "tensor requires {expected} elements, got {actual}")
            }
            Self::DTypeMismatch { expected, actual } => {
                write!(f, "requested {expected}, tensor contains {actual}")
            }
            Self::InvalidBoolean { index, value } => {
                write!(f, "boolean element {index} has invalid byte {value}")
            }
            Self::MissingTensor { kind, name } => write!(f, "missing {kind} tensor {name:?}"),
            Self::UnexpectedTensor { kind, name } => write!(f, "unexpected {kind} tensor {name:?}"),
            Self::DuplicateName(name) => write!(f, "duplicate tensor name {name:?}"),
            Self::FunctionNotFound(name) => write!(f, "model has no function {name:?}"),
            Self::DescriptorMismatch { name, reason } => {
                write!(f, "tensor {name:?} does not match its descriptor: {reason}")
            }
            Self::Unsupported(reason) => write!(f, "unsupported: {reason}"),
            Self::InvalidHandle { kind, id } => write!(f, "invalid {kind} handle {id}"),
            Self::Native {
                operation,
                type_name,
            } => write!(f, "Core AI {operation} failed: {type_name}"),
            Self::Binding(reason) => write!(f, "Core AI binding error: {reason}"),
            Self::WorkerUnavailable => f.write_str("Core AI worker is unavailable"),
            Self::ReentrantWait => f.write_str(
                "cannot synchronously wait on this Core AI worker; await the task instead",
            ),
            Self::WorkerStart(reason) => write!(f, "could not start Core AI worker: {reason}"),
            Self::InvalidAsset(path) => write!(f, "not a valid Core AI model asset: {path}"),
        }
    }
}

impl std::error::Error for Error {}
