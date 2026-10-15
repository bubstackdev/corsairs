use super::{Error, Runtime, arm64};
#[cfg(feature = "abi-research")]
use super::{MODEL_METADATA, Metadata, value::Value};
use std::ffi::c_void;
use std::mem;
use std::ptr::{self, NonNull};

#[cfg(feature = "abi-research")]
#[derive(Debug)]
pub struct ErrorReport {
    pub attempts: usize,
    pub caught: usize,
    pub released: usize,
    pub error_type: String,
}

pub(crate) struct OwnedError<'support, 'runtime> {
    pointer: *mut c_void,
    support: &'support ErrorSupport<'runtime>,
}

impl Drop for OwnedError<'_, '_> {
    fn drop(&mut self) {
        // SAFETY: Owns one error reference and its matching C release function.
        unsafe { (self.support.release)(self.pointer) };
    }
}

#[repr(C)]
struct ErrorProjection {
    value: *const c_void,
    metadata: *const c_void,
    conformance: *const c_void,
}

type ProjectError = unsafe extern "C" fn(*mut c_void, *mut *const c_void, *mut ErrorProjection);
type DynamicType = unsafe extern "C" fn(*const c_void, *const c_void, bool) -> *const c_void;

pub(crate) struct ErrorSupport<'runtime> {
    _runtime: &'runtime Runtime,
    release: unsafe extern "C" fn(*mut c_void),
    project: ProjectError,
    dynamic_type: DynamicType,
    type_name: *mut c_void,
}

impl<'runtime> ErrorSupport<'runtime> {
    pub(crate) fn load(runtime: &'runtime Runtime) -> Result<Self, Error> {
        let symbol = |name| runtime.library.symbol(name).map(NonNull::as_ptr);
        // SAFETY: Runtime headers and Swift IR establish these C signatures.
        // swift_getTypeName is Swift ABI and deliberately not cast to a C fn.
        Ok(unsafe {
            Self {
                _runtime: runtime,
                release: mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void)>(symbol(
                    c"swift_errorRelease",
                )?),
                project: mem::transmute::<*mut c_void, ProjectError>(symbol(
                    c"swift_getErrorValue",
                )?),
                dynamic_type: mem::transmute::<*mut c_void, DynamicType>(symbol(
                    c"swift_getDynamicType",
                )?),
                type_name: symbol(c"swift_getTypeName")?,
            }
        })
    }

    /// Take the +1 error returned by a verified throwing continuation.
    pub(crate) unsafe fn take(&self, pointer: *mut c_void) -> OwnedError<'_, 'runtime> {
        OwnedError {
            pointer,
            support: self,
        }
    }

    pub(crate) fn name(&self, error: &OwnedError<'_, '_>) -> Result<String, Error> {
        let mut scratch: *const c_void = ptr::null();
        let mut projection = ErrorProjection {
            value: ptr::null(),
            metadata: ptr::null(),
            conformance: ptr::null(),
        };
        // SAFETY: Error owns a valid box. Projection and scratch remain live;
        // projected payload/metadata borrow that box, with no extra ownership.
        unsafe { (self.project)(error.pointer, &mut scratch, &mut projection) };
        if projection.value.is_null() || projection.metadata.is_null() {
            return Err(Error("native error projection returned null".into()));
        }
        // SAFETY: C operation emitted for Swift type(of: error).
        let metadata = unsafe { (self.dynamic_type)(projection.value, projection.metadata, true) };
        if metadata.is_null() {
            return Err(Error("native error has no dynamic metadata".into()));
        }
        // SAFETY: Swift ABI returns borrowed cached UTF8 pointer and length.
        let (name, length) = unsafe {
            arm64::call_sync_pair(
                self.type_name,
                [metadata as usize, 1, 0],
                ptr::null_mut(),
                0,
            )
        };
        if name == 0 || length == 0 || length > 16384 {
            return Err(Error("invalid native error type name".into()));
        }
        // SAFETY: Runtime owns this cache; copy before error/runtime can drop.
        let bytes = unsafe { std::slice::from_raw_parts(name as *const u8, length) };
        std::str::from_utf8(bytes)
            .map(str::to_owned)
            .map_err(|e| Error(e.to_string()))
    }
}

impl Runtime {
    /// Exercise a real synchronous Core AI throw with an invalid empty bookmark.
    ///
    /// # Safety
    /// Requires the macOS 27 arm64 Data, Optional, Core AI, error-register and
    /// runtime reflection contracts in the ledger. Probes the failure path only.
    #[cfg(feature = "abi-research")]
    pub unsafe fn bookmark_error_probe(&self, cycles: usize) -> Result<ErrorReport, Error> {
        if !(1..=1_000_000).contains(&cycles) {
            return Err(Error(
                "bookmark-error cycles must be between 1 and 1000000".into(),
            ));
        }
        let symbol = |name| self.library.symbol(name).map(NonNull::as_ptr);
        let data_init = symbol(c"$s10Foundation4DataVACycfC")?;
        let model_init = symbol(c"$s13CoreAIRuntime7AIModelV0A11AIDelegatesE17resolvingBookmarkACSg10Foundation4DataV_tKcfC")?;
        let optional = symbol(c"$sSqMa")?;
        let errors = ErrorSupport::load(self)?;
        // SAFETY: Known non-generic model metadata accessor.
        let model_metadata = unsafe { self.metadata(MODEL_METADATA)? };
        // SAFETY: Optional accessor takes request0, base metadata x0/x1 and
        // returns complete metadata/state in x0/x1.
        let (pointer, state) = unsafe {
            arm64::call_sync_pair(
                optional,
                [0, model_metadata.address(), 0],
                ptr::null_mut(),
                0,
            )
        };
        // SAFETY: Verified Optional metadata response, runtime remains borrowed.
        let optional_metadata = unsafe { Metadata::from_response(pointer as *mut c_void, state)? };
        let mut report = ErrorReport {
            attempts: cycles,
            caught: 0,
            released: 0,
            error_type: String::new(),
        };
        for _ in 0..cycles {
            let mut model = Value::allocate(&optional_metadata)?;
            // SAFETY: Data() returns two owned words, no indirect result.
            let data = unsafe { arm64::call_sync_pair(data_init, [0; 3], ptr::null_mut(), 0) };
            // SAFETY: Init consumes Data on success/error. Optional result only
            // becomes initialized when the synchronous x21 error is null.
            let error = unsafe {
                arm64::call_throwing(model_init, [data.0, data.1, 0], model.storage.as_ptr(), 0)
            };
            if error.is_null() {
                model.initialized = true;
                return Err(Error(
                    "empty bookmark unexpectedly resolved without throwing".into(),
                ));
            }
            // SAFETY: The throwing call transferred an owned native error.
            let error = unsafe { errors.take(error) };
            report.caught += 1;
            let name = errors.name(&error)?;
            if report.error_type.is_empty() {
                report.error_type = name;
            } else if report.error_type != name {
                return Err(Error(
                    "error type changed between identical requests".into(),
                ));
            }
            drop(error);
            report.released += 1;
        }
        Ok(report)
    }
}
