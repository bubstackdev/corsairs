//! Synchronous function materialization inside a genuine Swift task.
use super::*;

#[link(name = "objc")]
unsafe extern "C" {
    fn objc_autoreleasePoolPush() -> *mut c_void;
    fn objc_autoreleasePoolPop(pool: *mut c_void);
}
struct Pool(*mut c_void);
impl Drop for Pool {
    fn drop(&mut self) {
        // SAFETY: This synchronous callback ends on the thread that pushed it.
        unsafe { objc_autoreleasePoolPop(self.0) };
    }
}

// Same verified root80 completion ownership, with no child async context.
// Slots40/48/56 are lowered sync arguments,64 is indirect result,72 is self.
global_asm!(
    ".section __TEXT,__text,regular,pure_instructions",
    ".p2align 2",
    "_corsairs_sync_entry:",
    "stp x29, x30, [sp, #-32]!",
    "mov x29, sp",
    "str x22, [sp, #16]",
    "mov x0, x22",
    "bl _corsairs_sync_invoke",
    "ldr x22, [sp, #16]",
    "ldp x29, x30, [sp], #32",
    "ldr x16, [x22, #8]",
    "mov x20, #0",
    "br x16",
    ".section __TEXT,__const",
    ".p2align 3",
    ".globl _corsairs_sync_descriptor",
    "_corsairs_sync_descriptor:",
    ".long _corsairs_sync_entry - _corsairs_sync_descriptor",
    ".long 80",
);

unsafe extern "C" {
    pub(super) static corsairs_sync_descriptor: u8;
}

#[unsafe(no_mangle)]
extern "C" fn corsairs_sync_invoke(root: *mut usize) {
    // SAFETY: Scope native autoreleased temporaries before completion signaling,
    // while keeping owned output/error references outside autorelease ownership.
    let _pool = Pool(unsafe { objc_autoreleasePoolPush() });
    // SAFETY: Only our fixed native sync-body entry invokes this callback. The
    // original worker retains each name/model/result allocation until join.
    let state = unsafe { state_from_root(root) };
    // SAFETY: Verified no-argument Swift current-task getter, inside a real task.
    let current = unsafe { arm64::call_sync(state.current as _, [0; 3], ptr::null_mut(), 0) };
    {
        let mut result = state.completion.lock().unwrap_or_else(|e| e.into_inner());
        result.entry_thread = Some(std::thread::current().id());
        result.identities += usize::from(current == state.expected_task.load(Ordering::Relaxed));
    }
    // SAFETY: Fixed initialized root80 slots; no native reference is moved into
    // Rust helper threads. This callback only borrows raw native arguments for
    // the exact synchronous Swift call and never accesses NativeSession.
    let (arguments, out, receiver) = unsafe {
        (
            [*root.add(5), *root.add(6), *root.add(7)],
            *root.add(8),
            *root.add(9),
        )
    };
    if let Some(probe) = &state.overlap {
        state.trace_task.store(probe.entered(), Ordering::Relaxed);
    }
    // SAFETY: FunctionBatchReference.swift independently establishes the exact
    // synchronous throwing shape, including x8=result and x21=owned Error.
    let error = unsafe { arm64::call_throwing(state.entry as _, arguments, out as _, receiver) };
    if let Some(probe) = &state.overlap {
        probe.returned(state.trace_task.load(Ordering::Relaxed));
    }
    // SAFETY: Same current-task getter after the synchronous call returned.
    let current = unsafe { arm64::call_sync(state.current as _, [0; 3], ptr::null_mut(), 0) };
    let mut result = state.completion.lock().unwrap_or_else(|e| e.into_inner());
    result.identities += usize::from(current == state.expected_task.load(Ordering::Relaxed));
    result.resumes = 1;
    result.error = error as usize;
    // The root completes successfully as Void; PendingCall separately owns any
    // synchronous error +1 and publishes it only after native task completion.
}
