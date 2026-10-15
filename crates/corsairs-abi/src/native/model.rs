use super::{Error, MODEL_METADATA, Runtime, arm64, errors::ErrorSupport, value::Value};
use std::ffi::{CStr, CString, c_void};
use std::mem;
use std::path::Path;
use std::ptr::{self, NonNull};

struct Word {
    value: usize,
    release: unsafe extern "C" fn(*mut c_void),
}

impl Drop for Word {
    fn drop(&mut self) {
        // SAFETY: Owns one native word with its compiler-established destructor.
        unsafe { (self.release)(self.value as *mut c_void) };
    }
}

/// Every string/array operation uses exported accessors, never guessed layouts.
pub(crate) struct Text {
    string_init: *mut c_void,
    array_count: *mut c_void,
    array_at: *mut c_void,
    utf8: *mut c_void,
    bytes_count: *mut c_void,
    bytes_at: *mut c_void,
    string_metadata: usize,
    byte_metadata: usize,
    bridge_release: unsafe extern "C" fn(*mut c_void),
    release: unsafe extern "C" fn(*mut c_void),
}

impl Text {
    pub(crate) fn load(runtime: &Runtime) -> Result<Self, Error> {
        let symbol = |name| runtime.library.symbol(name).map(NonNull::as_ptr);
        // SAFETY: Both release functions have the C runtime ABI. The two
        // releases are deliberately distinct for String/Array vs ContiguousArray.
        let (bridge_release, release) = unsafe {
            (
                mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void)>(symbol(
                    c"swift_bridgeObjectRelease",
                )?),
                mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void)>(symbol(
                    c"swift_release",
                )?),
            )
        };
        Ok(Self {
            string_init: symbol(c"$sSS7cStringSSSPys4Int8VG_tcfC")?,
            array_count: symbol(c"$sSa5countSivg")?,
            array_at: symbol(c"$sSayxSicig")?,
            utf8: symbol(c"$sSS11utf8CStrings15ContiguousArrayVys4Int8VGvg")?,
            bytes_count: symbol(c"$ss15ContiguousArrayV5countSivg")?,
            bytes_at: symbol(c"$ss15ContiguousArrayVyxSicig")?,
            string_metadata: symbol(c"$sSSN")? as usize,
            byte_metadata: symbol(c"$ss4Int8VN")? as usize,
            bridge_release,
            release,
        })
    }

    pub(crate) unsafe fn string(&self, text: &CStr) -> NativeString {
        // SAFETY: Public copying CString initializer returns two owned words.
        let (a, b) = unsafe {
            arm64::call_sync_pair(
                self.string_init,
                [text.as_ptr() as usize, 0, 0],
                ptr::null_mut(),
                0,
            )
        };
        NativeString {
            words: [a, b],
            _owner: Word {
                value: b,
                release: self.bridge_release,
            },
        }
    }

    unsafe fn names(&self, names: usize) -> Result<Vec<String>, Error> {
        let names = Word {
            value: names,
            release: self.bridge_release,
        };
        // SAFETY: Known Array<String> count signature; borrowed owned-array word.
        let count = unsafe {
            arm64::call_sync(
                self.array_count,
                [names.value, self.string_metadata, 0],
                ptr::null_mut(),
                0,
            )
        };
        if count > 16384 {
            return Err(Error("invalid native function-name count".into()));
        }
        let mut result = Vec::with_capacity(count);
        for index in 0..count {
            let mut string = [0usize; 2];
            // SAFETY: Checked index, two-word String result, metadata for String.
            unsafe {
                arm64::call_sync(
                    self.array_at,
                    [index, names.value, self.string_metadata],
                    string.as_mut_ptr().cast(),
                    0,
                );
            }
            let _string = Word {
                value: string[1],
                release: self.bridge_release,
            };
            // SAFETY: utf8CString borrows both String words, returns owned array.
            let bytes = unsafe {
                arm64::call_sync(self.utf8, [string[0], string[1], 0], ptr::null_mut(), 0)
            };
            let bytes = Word {
                value: bytes,
                release: self.release,
            };
            // SAFETY: Verified ContiguousArray<Int8> count getter.
            let count = unsafe {
                arm64::call_sync(
                    self.bytes_count,
                    [bytes.value, self.byte_metadata, 0],
                    ptr::null_mut(),
                    0,
                )
            };
            if !(1..=1_048_576).contains(&count) {
                return Err(Error("invalid UTF8 count".into()));
            }
            let mut utf8 = Vec::with_capacity(count);
            for index in 0..count {
                let mut byte = 0u8;
                // SAFETY: Checked index, one-byte indirect result, Int8 metadata.
                unsafe {
                    arm64::call_sync(
                        self.bytes_at,
                        [index, bytes.value, self.byte_metadata],
                        ptr::from_mut(&mut byte).cast(),
                        0,
                    );
                }
                utf8.push(byte);
            }
            if utf8.pop() != Some(0) {
                return Err(Error("native UTF8 missing terminator".into()));
            }
            result.push(String::from_utf8(utf8).map_err(|e| Error(e.to_string()))?);
        }
        Ok(result)
    }
}

pub(crate) struct NativeString {
    pub(crate) words: [usize; 2],
    _owner: Word,
}

#[derive(Debug)]
pub struct ModelReport {
    pub cycles: usize,
    pub loaded: usize,
    pub destroyed: usize,
    pub caught: usize,
    pub errors_released: usize,
    pub function_names: Vec<String>,
    pub error_type: String,
    pub native_completions: usize,
}

impl Runtime {
    /// Err after starting still leaves model's initialization flag correct.
    /// Native URL/options consumption is handled entirely inside this helper.
    pub(crate) unsafe fn initialize_model(
        &self,
        path: &CStr,
        model: &mut Value<'_, '_>,
    ) -> Result<Option<String>, Error> {
        let symbol = |name| self.library.symbol(name).map(NonNull::as_ptr);
        let url_init = symbol(c"$s10Foundation3URLV15fileURLWithPathACSSh_tcfC")?;
        let cpu = symbol(c"$s15CoreAIDelegates21SpecializationOptionsV7cpuOnlyACvgZ")?;
        let text = Text::load(self)?;
        let errors = ErrorSupport::load(self)?;
        // SAFETY: Known non-generic URL and SpecializationOptions accessors.
        let url_metadata = unsafe { self.metadata(c"$s10Foundation3URLVMa")? };
        // SAFETY: Same verified metadata accessor signature.
        let options_metadata =
            unsafe { self.metadata(c"$s15CoreAIDelegates21SpecializationOptionsVMa")? };
        let mut url = Value::allocate(&url_metadata)?;
        let mut options = Value::allocate(&options_metadata)?;
        // SAFETY: Copies the terminated path, retaining its owned native String.
        let string = unsafe { text.string(path) };
        // SAFETY: URL initializer borrows the two String words.
        unsafe {
            arm64::call_sync(
                url_init,
                [string.words[0], string.words[1], 0],
                url.storage.as_ptr(),
                0,
            );
        }
        url.initialized = true;
        drop(string);
        // SAFETY: cpuOnly getter initializes indirect options result.
        unsafe { arm64::call_sync(cpu, [0; 3], options.storage.as_ptr(), 0) };
        options.initialized = true;
        // SAFETY: Verified async initializer consumes URL/options on success and
        // failure. Await Err only occurs before scheduling, preserving ownership.
        let result = unsafe {
            self.await_native(
                c"$s13CoreAIRuntime7AIModelV0A11AIDelegatesE10contentsOf7optionsAC10Foundation3URLV_AD21SpecializationOptionsVtYaKcfCTu",
                [model.storage.as_ptr() as usize, url.storage.as_ptr() as usize, options.storage.as_ptr() as usize, 0],
                0, true,
            )?
        };
        url.initialized = false;
        options.initialized = false;
        let error_type = if result.error != 0 {
            // SAFETY: x20 transferred one owned native error.
            let error = unsafe { errors.take(result.error as *mut c_void) };
            Some(errors.name(&error)?)
        } else {
            model.initialized = true;
            None
        };
        if !result.tls_clear || result.identities != 2 || result.resumes != 1 {
            return Err(Error(format!("model async lifecycle mismatch: {result:?}")));
        }
        Ok(error_type)
    }

    /// Load a real asset asynchronously, read its function names, and destroy it.
    ///
    /// # Safety
    /// Requires the recorded macOS27 arm64 Foundation/CoreAI ownership and Swift
    /// concurrency contracts. Executes a supplied local asset with CPU options.
    pub unsafe fn model_probe(&self, path: &Path, cycles: usize) -> Result<ModelReport, Error> {
        if !(1..=1_000_000).contains(&cycles) {
            return Err(Error("model cycles must be between 1 and 1000000".into()));
        }
        let path = path
            .to_str()
            .ok_or_else(|| Error("asset path must be UTF8".into()))?;
        let path = CString::new(path).map_err(|e| Error(e.to_string()))?;
        let names = self
            .library
            .symbol(c"$s13CoreAIRuntime7AIModelV13functionNamesSaySSGvg")?
            .as_ptr();
        let text = Text::load(self)?;
        // SAFETY: Known model metadata accessor.
        let model_metadata = unsafe { self.metadata(MODEL_METADATA)? };
        let mut report = ModelReport {
            cycles,
            loaded: 0,
            destroyed: 0,
            caught: 0,
            errors_released: 0,
            function_names: Vec::new(),
            error_type: String::new(),
            native_completions: 0,
        };
        for _ in 0..cycles {
            let mut model = Value::allocate(&model_metadata)?;
            // SAFETY: Empty model storage and verified async initializer contract.
            if let Some(name) = unsafe { self.initialize_model(&path, &mut model)? } {
                report.caught += 1;
                report.errors_released += 1;
                if report.error_type.is_empty() {
                    report.error_type = name;
                } else if report.error_type != name {
                    return Err(Error("model error type changed".into()));
                }
            } else {
                report.loaded += 1;
                // SAFETY: Getter borrows initialized model x20, transfers Array.
                let word = unsafe {
                    arm64::call_sync(
                        names,
                        [0; 3],
                        ptr::null_mut(),
                        model.storage.as_ptr() as usize,
                    )
                };
                // SAFETY: Consume getter's owned Array<String> through accessors.
                let actual = unsafe { text.names(word)? };
                if report.loaded == 1 {
                    report.function_names = actual;
                } else if report.function_names != actual {
                    return Err(Error("model function names changed".into()));
                }
                drop(model);
                report.destroyed += 1;
            }
            report.native_completions += 1;
        }
        Ok(report)
    }
}
