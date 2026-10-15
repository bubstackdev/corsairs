//! One verified suspending child call, completed through a genuine Swift task.
use super::{Error, Runtime, arm64, loader::Library, task_create::create_task};
use std::arch::global_asm;
use std::ffi::{CStr, c_void};
use std::mem;
use std::ptr::{self, NonNull};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Arc, Condvar, Mutex, OnceLock};
use std::thread::ThreadId;

mod pending;
mod sync_call;
#[cfg(any(feature = "abi-research", test))]
pub(crate) use pending::OverlapReport;
pub(crate) use pending::{OverlapProbe, PendingCall, Scheduling};

// Root80: native header0/8, child16, original ResumeParent24, owned Arc32,
// callee arguments40/48/56/64, borrowed self72. Both frames are native-owned.
global_asm!(
    ".section __TEXT,__text,regular,pure_instructions",
    ".p2align 2",
    "_corsairs_async_entry:",
    "stp x29, x30, [sp, #-32]!",
    "mov x29, sp",
    "str x22, [sp, #16]",
    "mov x0, x22",
    "bl _corsairs_async_prepare",
    "ldr x22, [sp, #16]",
    "mov x16, x1",
    "mov x17, x0",
    "ldp x0, x1, [x22, #40]",
    "ldr x2, [x22, #56]",
    "ldr x3, [x22, #64]",
    "ldr x20, [x22, #72]",
    "mov x22, x17",
    "ldp x29, x30, [sp], #32",
    "br x16",
    ".p2align 2",
    ".globl _corsairs_async_resume",
    "_corsairs_async_resume:",
    "stp x29, x30, [sp, #-32]!",
    "mov x29, sp",
    "ldr x22, [x22]",
    "str x22, [sp, #16]",
    "mov x0, x22",
    "mov x1, x20",
    "bl _corsairs_async_returned",
    "ldr x22, [sp, #16]",
    "ldp x29, x30, [sp], #32",
    "ldr x16, [x22, #8]",
    "mov x20, #0",
    "br x16",
    ".p2align 2",
    ".globl _corsairs_async_complete",
    "_corsairs_async_complete:",
    "stp x19, x22, [sp, #-32]!",
    "stp x29, x30, [sp, #16]",
    "add x29, sp, #16",
    // Preload before native completion can free the root/task allocation.
    "ldp x16, x19, [x22, #24]",
    "blr x16",
    "mov x0, x19",
    "ldp x29, x30, [sp, #16]",
    "ldp x19, x22, [sp], #32",
    "b _corsairs_async_signal",
    ".section __TEXT,__const",
    ".p2align 3",
    ".globl _corsairs_async_descriptor",
    "_corsairs_async_descriptor:",
    ".long _corsairs_async_entry - _corsairs_async_descriptor",
    ".long 80",
);

unsafe extern "C" {
    static corsairs_async_descriptor: u8;
    fn corsairs_async_resume();
    fn corsairs_async_complete();
}

static PIN: OnceLock<Result<(), String>> = OnceLock::new();

fn pin_executor() -> Result<(), Error> {
    PIN.get_or_init(|| {
        // SAFETY: Fixed system runtime. SDK RTLD_NODELETE=0x80 keeps the image
        // mapped while worker epilogues run after our completion signal. The
        // dlopen handle itself is balanced; this is one process-lifetime pin.
        unsafe { Library::open_flags(c"/usr/lib/swift/libswift_Concurrency.dylib", 2 | 4 | 0x80) }
            .map(drop)
            .map_err(|e| e.to_string())
    })
    .clone()
    .map_err(Error)
}

#[derive(Default, Debug)]
struct Completion {
    done: bool,
    entry_thread: Option<ThreadId>,
    resumed_on_other_thread: bool,
    identities: usize,
    resumes: usize,
    completion_tls_clear: bool,
    error: usize,
}

struct State {
    // Fixed, verified native function addresses; kept mapped until completion.
    alloc: usize,
    dealloc: usize,
    current: usize,
    entry: usize,
    context_size: usize,
    throwing: bool,
    expected_task: AtomicUsize,
    trace_task: AtomicUsize,
    completion: Mutex<Completion>,
    ready: Condvar,
    overlap: Option<Arc<OverlapProbe>>,
}

#[repr(C)]
struct NextCall {
    context: usize,
    entry: usize,
}

// The root's Arc +1 remains owned by the native completion wrapper. Borrowing
// here never consumes that reference; there is exactly one from_raw in signal.
unsafe fn state_from_root<'a>(root: *mut usize) -> &'a State {
    // SAFETY: Our private root80 was initialized before scheduling this task.
    unsafe { &*(*root.add(4) as *const State) }
}

#[unsafe(no_mangle)]
extern "C" fn corsairs_async_prepare(root: *mut usize) -> NextCall {
    // SAFETY: Called only from our private native async entry with live root80.
    let state = unsafe { state_from_root(root) };
    if let Some(probe) = &state.overlap {
        let task = probe.entered();
        state.trace_task.store(task, Ordering::Relaxed);
    }
    // SAFETY: Verified no-arg Swift ABI getter, within the real running task.
    let current = unsafe { arm64::call_sync(state.current as _, [0; 3], ptr::null_mut(), 0) };
    {
        let mut result = state.completion.lock().unwrap_or_else(|e| e.into_inner());
        result.entry_thread = Some(std::thread::current().id());
        result.identities += usize::from(current == state.expected_task.load(Ordering::Relaxed));
    }
    // SAFETY: Native task-local allocation using the descriptor's context size.
    let child = unsafe {
        arm64::call_sync(
            state.alloc as _,
            [state.context_size, 0, 0],
            ptr::null_mut(),
            0,
        )
    } as *mut usize;
    // The native allocator is non-null or aborts; it does not return an error.
    // SAFETY: Newly allocated child has at least the native two-word header.
    unsafe {
        *root.add(2) = child as usize;
        *child = root as usize;
        *child.add(1) = corsairs_async_resume as *const () as usize;
    }
    NextCall {
        context: child as usize,
        entry: state.entry,
    }
}

#[unsafe(no_mangle)]
extern "C" fn corsairs_async_returned(root: *mut usize, error: usize) {
    // SAFETY: Child's parent is our live root; x22 has been restored to it.
    let state = unsafe { state_from_root(root) };
    if let Some(probe) = &state.overlap {
        probe.returned(state.trace_task.load(Ordering::Relaxed));
    }
    // SAFETY: Same verified current-task getter as in the entry.
    let current = unsafe { arm64::call_sync(state.current as _, [0; 3], ptr::null_mut(), 0) };
    {
        let mut result = state.completion.lock().unwrap_or_else(|e| e.into_inner());
        result.resumes += 1;
        result.identities += usize::from(current == state.expected_task.load(Ordering::Relaxed));
        result.resumed_on_other_thread = result.entry_thread != Some(std::thread::current().id());
        // Nonthrowing async callees leave x20 unspecified. Only throwing
        // continuations carry an owned Error? there.
        result.error = if state.throwing { error } else { 0 };
    }
    // SAFETY: Strict LIFO deallocation of the single child after it returned.
    unsafe { arm64::call_sync(state.dealloc as _, [*root.add(2), 0, 0], ptr::null_mut(), 0) };
}

#[unsafe(no_mangle)]
extern "C" fn corsairs_async_signal(raw: *const State) {
    // SAFETY: Consumes exactly the Arc +1 installed before task scheduling.
    // The caller owns another Arc, so neither side can free the other's state.
    let state = unsafe { Arc::from_raw(raw) };
    // SAFETY: The wrapper called native completion before this function. Its
    // task reference is released and current-task TLS should now be empty.
    let current = unsafe { arm64::call_sync(state.current as _, [0; 3], ptr::null_mut(), 0) };
    let mut result = state.completion.lock().unwrap_or_else(|e| e.into_inner());
    result.completion_tls_clear = current == 0;
    result.done = true;
    state.ready.notify_one();
    // Guard drops before this callback's owned Arc, including if caller wakes.
}

#[derive(Debug)]
pub(crate) struct AsyncResult {
    pub(crate) error: usize,
    pub(crate) identities: usize,
    pub(crate) resumes: usize,
    #[cfg(feature = "abi-research")]
    pub(crate) other_thread: bool,
    pub(crate) tls_clear: bool,
}

#[cfg(feature = "abi-research")]
#[derive(Debug)]
pub struct SuspensionReport {
    pub cycles: usize,
    pub resumes: usize,
    pub task_identity_matches: usize,
    pub resumed_on_other_thread: usize,
    pub native_completions: usize,
    pub tls_restored: usize,
}

impl Runtime {
    /// Invoke one specifically verified async child and wait for native cleanup.
    /// Caller must keep all argument/result storage live and exclusively ceded
    /// to the callee until return. There is no timeout or cancellation shortcut.
    /// Err means the child was never started and its arguments remain owned by
    /// the caller. Ok transfers any returned owned error and confirms that the
    /// native child consumed its @in arguments on either success or failure.
    pub(crate) unsafe fn await_native(
        &self,
        descriptor: &CStr,
        arguments: [usize; 4],
        receiver: usize,
        throwing: bool,
    ) -> Result<AsyncResult, Error> {
        // SAFETY: The original complete-lifetime contract is unchanged.
        let pending = unsafe {
            self.start_native(
                descriptor,
                arguments,
                receiver,
                throwing,
                Scheduling::Inline,
                None,
            )?
        };
        Ok(pending.wait())
    }

    /// Await the OS Task.yield implementation in an actual native Swift task.
    ///
    /// # Safety
    /// Requires the macOS27 arm64 async context/descriptor contracts recorded in
    /// the ledger. This is a blocking research probe, not an executor API.
    #[cfg(feature = "abi-research")]
    pub unsafe fn suspension_probe(&self, cycles: usize) -> Result<SuspensionReport, Error> {
        if !(1..=1_000_000).contains(&cycles) {
            return Err(Error("suspend cycles must be between 1 and 1000000".into()));
        }
        let mut report = SuspensionReport {
            cycles,
            resumes: 0,
            task_identity_matches: 0,
            resumed_on_other_thread: 0,
            native_completions: 0,
            tls_restored: 0,
        };
        for _ in 0..cycles {
            // SAFETY: Fixed no-arg, nonthrowing async Void callee descriptor.
            let result = unsafe {
                self.await_native(c"$sScTss5NeverORszABRs_rlE5yieldyyYaFZTu", [0; 4], 0, false)?
            };
            if result.error != 0
                || result.resumes != 1
                || result.identities != 2
                || !result.tls_clear
            {
                return Err(Error(format!(
                    "suspending task lifecycle mismatch: {result:?}"
                )));
            }
            report.resumes += result.resumes;
            report.task_identity_matches += result.identities;
            report.resumed_on_other_thread += usize::from(result.other_thread);
            report.native_completions += 1;
            report.tls_restored += 1;
        }
        Ok(report)
    }
}
