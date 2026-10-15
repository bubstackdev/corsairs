use super::{Error, Runtime, arm64};
use std::ffi::{CStr, c_void};
use std::{mem, ptr};

pub(crate) struct NativeString {
    pub(crate) words: [usize; 2],
    release: unsafe extern "C" fn(*mut c_void),
}
impl Drop for NativeString {
    fn drop(&mut self) {
        // SAFETY: The copying String constructor returned one owned bridge word.
        unsafe { (self.release)(self.words[1] as _) };
    }
}
pub(crate) struct Text {
    initialize: *mut c_void,
    release: unsafe extern "C" fn(*mut c_void),
}
impl Text {
    pub(crate) fn load(runtime: &Runtime) -> Result<Self, Error> {
        let initialize = runtime
            .library
            .symbol(c"$sSS7cStringSSSPys4Int8VG_tcfC")?
            .as_ptr();
        let release = runtime
            .library
            .symbol(c"swift_bridgeObjectRelease")?
            .as_ptr();
        // SAFETY: Verified C runtime bridge release, not a Swift ABI cast.
        let release =
            unsafe { mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void)>(release) };
        Ok(Self {
            initialize,
            release,
        })
    }
    pub(crate) unsafe fn string(&self, text: &CStr) -> NativeString {
        // SAFETY: Caller retains the supplying runtime; public copying String
        // initializer reads terminated UTF8 and returns two owned words.
        let (a, b) = unsafe {
            arm64::call_sync_pair(
                self.initialize,
                [text.as_ptr() as usize, 0, 0],
                ptr::null_mut(),
                0,
            )
        };
        NativeString {
            words: [a, b],
            release: self.release,
        }
    }
}
