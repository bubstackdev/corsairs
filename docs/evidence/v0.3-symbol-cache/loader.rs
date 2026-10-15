use std::collections::HashMap;
use std::ffi::{CStr, CString, c_char, c_int, c_void};
use std::fmt;
use std::ptr::{self, NonNull};
use std::sync::Mutex;

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

/// Successful addresses belong to one open library, never to a process-global
/// cache. Own name bytes because callers may supply a temporary CString.
#[derive(Default)]
struct SymbolCache(Mutex<HashMap<CString, usize>>);

impl SymbolCache {
    fn resolve(
        &self,
        name: &CStr,
        lookup: impl FnOnce() -> Result<usize, Error>,
    ) -> Result<usize, Error> {
        // Hold the lock through lookup so concurrent first requests resolve
        // once. No resolved function is invoked while this lock is held.
        let mut symbols = self
            .0
            .lock()
            .unwrap_or_else(|poisoned| poisoned.into_inner());
        if let Some(&address) = symbols.get(name) {
            return Ok(address);
        }
        // Do not retain failures: a later lookup must obtain its own loader
        // error and may succeed after another dependent image has been loaded.
        let address = lookup()?;
        symbols.insert(name.to_owned(), address);
        Ok(address)
    }
}

pub(crate) struct Library {
    handle: NonNull<c_void>,
    symbols: SymbolCache,
}

impl Library {
    pub(crate) unsafe fn open(path: &CStr) -> Result<Self, Error> {
        // SAFETY: Same caller-authorized path, with normal scoped loading.
        unsafe { Self::open_flags(path, 2 | 4) }
    }

    pub(crate) unsafe fn open_flags(path: &CStr, flags: c_int) -> Result<Self, Error> {
        // SAFETY: Caller authorizes loading this path; CStr provides termination.
        let pointer = unsafe { dlopen(path.as_ptr(), flags) };
        let handle = NonNull::new(pointer).ok_or_else(|| last_error("dlopen"))?;
        Ok(Self {
            handle,
            symbols: SymbolCache::default(),
        })
    }

    pub(crate) fn symbol(&self, name: &CStr) -> Result<NonNull<c_void>, Error> {
        let address = self.symbols.resolve(name, || {
            // SAFETY: The owned handle is live; the name is terminated.
            // Clear thread-local loader state before this first resolution;
            // neither operation invokes the resolved symbol or asserts its ABI.
            let pointer = unsafe {
                dlerror();
                dlsym(self.handle.as_ptr(), name.as_ptr())
            };
            let pointer =
                NonNull::new(pointer).ok_or_else(|| last_error(&name.to_string_lossy()))?;
            // Preserve exposed provenance for reconstruction on a cache hit.
            // Only successful non-null symbol addresses enter this cache.
            Ok(pointer.as_ptr().expose_provenance())
        })?;
        Ok(NonNull::new(ptr::with_exposed_provenance_mut(address))
            .expect("cached dynamic symbols are non-null"))
    }
}

impl Drop for Library {
    fn drop(&mut self) {
        // SAFETY: This is the unique owner of the successful dlopen handle.
        unsafe { dlclose(self.handle.as_ptr()) };
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

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::atomic::{AtomicUsize, Ordering};

    #[test]
    fn owns_names_and_keys_by_content() {
        let symbols = SymbolCache::default();
        let name = CString::new("temporary-name").unwrap();
        assert_eq!(symbols.resolve(&name, || Ok(17)).unwrap(), 17);
        drop(name);
        assert_eq!(
            symbols
                .resolve(c"temporary-name", || panic!("cached lookup repeated"))
                .unwrap(),
            17
        );
        assert_eq!(symbols.resolve(c"other-name", || Ok(23)).unwrap(), 23);
        // A separate library must resolve even an identical name independently.
        assert_eq!(
            SymbolCache::default()
                .resolve(c"temporary-name", || Ok(31))
                .unwrap(),
            31
        );
    }

    #[test]
    fn retries_failed_resolutions() {
        let symbols = SymbolCache::default();
        let failure = symbols.resolve(c"eventually-available", || Err(Error("first error".into())));
        assert_eq!(failure.unwrap_err().to_string(), "first error");
        assert_eq!(
            symbols.resolve(c"eventually-available", || Ok(47)).unwrap(),
            47
        );
        assert_eq!(
            symbols
                .resolve(c"eventually-available", || panic!(
                    "successful lookup repeated"
                ))
                .unwrap(),
            47
        );
    }

    #[test]
    fn concurrent_first_lookups_resolve_once() {
        let symbols = SymbolCache::default();
        let resolutions = AtomicUsize::new(0);
        std::thread::scope(|scope| {
            for _ in 0..16 {
                scope.spawn(|| {
                    for _ in 0..100 {
                        for (name, address) in [(c"first", 59), (c"second", 61)] {
                            assert_eq!(
                                symbols
                                    .resolve(name, || {
                                        resolutions.fetch_add(1, Ordering::SeqCst);
                                        Ok(address)
                                    })
                                    .unwrap(),
                                address
                            );
                        }
                    }
                });
            }
        });
        assert_eq!(resolutions.load(Ordering::SeqCst), 2);
    }
}
