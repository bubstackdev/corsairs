use std::arch::asm;
use std::ffi::c_void;

pub(crate) unsafe fn create_task(
    function: *mut c_void,
    void_metadata: *mut c_void,
    descriptor: *const u8,
) -> (*mut c_void, *mut c_void) {
    let task: *mut c_void;
    let context: *mut c_void;
    // SAFETY: Caller supplies one of our static, link-relative descriptors with
    // a verified throwing-Void async entry and declared context size.
    // SAFETY: Swift task-create takes five word arguments. Flags=0 prevents
    // auto-enqueue; no task options/captures are supplied; result type is Void.
    unsafe {
        asm!(
            "blr x16",
            in("x16") function,
            inlateout("x0") 0usize => task,
            inlateout("x1") 0usize => context,
            inlateout("x2") void_metadata => _,
            inlateout("x3") descriptor => _,
            inlateout("x4") 0usize => _,
            lateout("x20") _,
            lateout("x21") _,
            lateout("x22") _,
            clobber_abi("C"),
        );
    }
    (task, context)
}
