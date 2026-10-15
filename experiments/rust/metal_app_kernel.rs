//! Unpublished application-side FFI helper proof; production remains wrapper-free.
#![deny(unsafe_op_in_unsafe_fn)]
use corsairs::{Compute, DType, MetalBufferMap, MetalValueMap, Runtime, Tensor};
use std::{
    ffi::{CStr, CString, c_char, c_int, c_void},
    ptr::NonNull,
};

unsafe extern "C" {
    fn dlopen(path: *const c_char, flags: c_int) -> *mut c_void;
    fn dlsym(handle: *mut c_void, name: *const c_char) -> *mut c_void;
    fn dlclose(handle: *mut c_void) -> c_int;
}
type Submit = unsafe extern "C" fn(*mut c_void, *mut c_void, usize, u32, *mut *mut c_void) -> c_int;
type Status = unsafe extern "C" fn(*mut c_void) -> u64;
type Release = unsafe extern "C" fn(*mut c_void);
struct Helper {
    library: NonNull<c_void>,
    submit: Submit,
    status: Status,
    release: Release,
}
impl Helper {
    unsafe fn open(path: &CStr) -> Result<Self, Box<dyn std::error::Error>> {
        // SAFETY: Explicit development helper path with the retained C prototypes.
        unsafe {
            let library = NonNull::new(dlopen(path.as_ptr(), 2 | 4))
                .ok_or("cannot open application kernel helper")?;
            let symbol = |name: &CStr| {
                NonNull::new(dlsym(library.as_ptr(), name.as_ptr()))
                    .ok_or("missing application helper symbol")
            };
            let functions = (|| {
                Ok::<_, &str>((
                    symbol(c"corsairs_app_scale")?,
                    symbol(c"corsairs_app_status")?,
                    symbol(c"corsairs_app_release")?,
                ))
            })();
            let (submit, status, release) = match functions {
                Ok(value) => value,
                Err(error) => {
                    dlclose(library.as_ptr());
                    return Err(error.into());
                }
            };
            Ok(Self {
                library,
                submit: std::mem::transmute::<*mut c_void, Submit>(submit.as_ptr()),
                status: std::mem::transmute::<*mut c_void, Status>(status.as_ptr()),
                release: std::mem::transmute::<*mut c_void, Release>(release.as_ptr()),
            })
        }
    }
}
impl Drop for Helper {
    fn drop(&mut self) {
        // SAFETY: Commands borrow this helper, so all calls finish before unload.
        unsafe {
            dlclose(self.library.as_ptr());
        }
    }
}
struct Command<'a> {
    raw: NonNull<c_void>,
    helper: &'a Helper,
}
impl Command<'_> {
    fn status(&self) -> u64 {
        // SAFETY: This retained command and its defining helper remain live.
        unsafe { (self.helper.status)(self.raw.as_ptr()) }
    }
}
impl Drop for Command<'_> {
    fn drop(&mut self) {
        // SAFETY: Balance the helper's transferred command reference before unload.
        unsafe { (self.helper.release)(self.raw.as_ptr()) }
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let arguments = std::env::args().skip(1).collect::<Vec<_>>();
    if arguments.len() != 2 {
        return Err("expected MODEL HELPER_DYLIB".into());
    }
    let helper_path = CString::new(arguments[1].as_str())?;
    // SAFETY: This proof loads its explicit development-only compiled C helper.
    let helper = unsafe { Helper::open(&helper_path)? };
    let runtime = Runtime::new()?;
    let model = runtime
        .load_model(&arguments[0], Compute::GpuPreferred)
        .wait()?;
    let function = model.load_function("main").wait()?;
    let queue = runtime.metal_queue().wait()?;
    let input = queue
        .upload(Tensor::from_vec([2, 3], vec![1f32, -2., 0.5, 7., 0., -1.])?)
        .wait()?;
    let output = queue.buffer(DType::Float32, vec![2, 3]).wait()?;
    // SAFETY: The application submits only this bounded f32 kernel, on the same
    // retained queue; no competing mappings/queues or backing invalidation exist.
    let raw_queue = unsafe { queue.export_queue() }.wait()?;
    // SAFETY: Same contract; buffer scalar type, offset and six-element extent
    // match the helper, and guards outlive GPU completion and native inference.
    let raw_input = unsafe { input.export_buffer() }.wait()?;
    let mut command = std::ptr::null_mut();
    // SAFETY: Verified C arguments, retained Metal protocol objects, and checked
    // shared f32 buffer bounds. Helper commits to this exact persistent queue.
    let code = unsafe {
        (helper.submit)(
            raw_queue.as_raw(),
            raw_input.as_raw(),
            input.byte_offset(),
            6,
            &mut command,
        )
    };
    if code != 0 {
        return Err(format!("application kernel helper failed with {code}").into());
    }
    let command = Command {
        raw: NonNull::new(command).ok_or("helper returned no command")?,
        helper: &helper,
    };
    let status_before = command.status();
    queue.fence().wait()?;
    let status_after = command.status();
    if status_after != 4 {
        return Err(
            format!("application command not completed after fence: {status_after}").into(),
        );
    }
    if input.download().wait()?.to_vec::<f32>()? != [3., -6., 1.5, 21., 0., -3.] {
        return Err("queue fence did not expose application kernel writes".into());
    }
    let result = function
        .encode(
            &queue,
            MetalValueMap::from([("x", input)]),
            MetalBufferMap::new(),
            MetalBufferMap::from([("y", output)]),
        )
        .wait()?;
    let actual = result
        .outputs
        .get("y")
        .ok_or("missing output")?
        .download()
        .wait()?
        .to_vec::<f32>()?;
    if actual != [6., -12., 3., 42., 0., -6.] {
        return Err(
            format!("Core AI did not observe ordered application kernel: {actual:?}").into(),
        );
    }
    println!(
        "{{\"passed\":true,\"application_kernel\":\"input *= 3\",\"coreai\":\"x+x\",\"status_before_fence\":{status_before},\"status_after_fence\":{status_after},\"same_queue\":true,\"host_write_after_kernel\":false,\"production_helper\":false}}"
    );
    Ok(())
}
