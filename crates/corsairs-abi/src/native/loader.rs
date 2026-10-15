use std::ffi::{CStr, c_char, c_int, c_void};
use std::fmt;
use std::ptr::NonNull;

#[derive(Debug)]
pub struct Error(pub String);

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(&self.0)
    }
}

impl std::error::Error for Error {}

unsafe extern "C" {
    fn dlopen(path: *const c_char, flags: c_int) -> *mut c_void;
    fn dlsym(handle: *mut c_void, symbol: *const c_char) -> *mut c_void;
    fn dlclose(handle: *mut c_void) -> c_int;
    fn dlerror() -> *const c_char;
}

pub(crate) struct Library(NonNull<c_void>);

impl Library {
    pub(crate) unsafe fn open(path: &CStr) -> Result<Self, Error> {
        // SAFETY: Same caller-authorized path, with normal scoped loading.
        unsafe { Self::open_flags(path, 2 | 4) }
    }

    pub(crate) unsafe fn open_flags(path: &CStr, flags: c_int) -> Result<Self, Error> {
        // SAFETY: Caller authorizes loading this path; CStr provides termination.
        let pointer = unsafe { dlopen(path.as_ptr(), flags) };
        NonNull::new(pointer)
            .map(Self)
            .ok_or_else(|| last_error("dlopen"))
    }

    pub(crate) fn symbol(&self, name: &CStr) -> Result<NonNull<c_void>, Error> {
        // SAFETY: The owned handle is live; the name is terminated. Resolution
        // alone does not call the symbol or assert its ABI.
        let pointer = unsafe { dlsym(self.0.as_ptr(), name.as_ptr()) };
        NonNull::new(pointer).ok_or_else(|| last_error(&name.to_string_lossy()))
    }
}

impl Drop for Library {
    fn drop(&mut self) {
        // SAFETY: This is the unique owner of the successful dlopen handle.
        unsafe { dlclose(self.0.as_ptr()) };
    }
}

fn last_error(operation: &str) -> Error {
    // SAFETY: dlerror returns a thread-local C string or null. Copy immediately.
    let pointer = unsafe { dlerror() };
    let detail = if pointer.is_null() {
        "unknown dynamic loader error".to_owned()
    } else {
        // SAFETY: Non-null dlerror result is terminated and valid until next call.
        unsafe { CStr::from_ptr(pointer) }
            .to_string_lossy()
            .into_owned()
    };
    Error(format!("{operation}: {detail}"))
}
