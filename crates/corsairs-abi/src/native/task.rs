//! A real, deliberately nonsuspending Swift task. This is not an async executor.
use super::task_create::create_task;
use super::{Error, Runtime, arm64};
use std::arch::global_asm;
use std::ffi::c_void;
use std::mem;
use std::ptr::{self, NonNull};
use std::sync::Mutex;
use std::sync::atomic::{AtomicPtr, AtomicUsize, Ordering};

// Descriptor matches Swift's compiled throwing-Void async leaf: relative entry
// offset followed by context size. x22 is the native task context, whose second
// word is ResumeParent. No custom capture object or borrowed Rust data escapes.
global_asm!(
    ".section __TEXT,__text,regular,pure_instructions",
    ".p2align 2",
    "_corsairs_void_task_entry:",
    "stp x29, x30, [sp, #-32]!",
    "mov x29, sp",
    "str x22, [sp, #16]",
    "bl _corsairs_observe_current_task",
    "ldr x22, [sp, #16]",
    "ldp x29, x30, [sp], #32",
    "ldr x0, [x22, #8]",
    "mov x20, #0",
    "br x0",
    ".section __TEXT,__const",
    ".p2align 3",
    ".globl _corsairs_void_task_descriptor",
    "_corsairs_void_task_descriptor:",
    ".long _corsairs_void_task_entry - _corsairs_void_task_descriptor",
    ".long 16",
);

unsafe extern "C" {
    static corsairs_void_task_descriptor: u8;
}

static LOCK: Mutex<()> = Mutex::new(());
static GET_CURRENT: AtomicPtr<c_void> = AtomicPtr::new(ptr::null_mut());
static OBSERVED_TASK: AtomicUsize = AtomicUsize::new(0);
static OBSERVED_COUNT: AtomicUsize = AtomicUsize::new(0);

struct CurrentHook;
impl Drop for CurrentHook {
    fn drop(&mut self) {
        GET_CURRENT.store(ptr::null_mut(), Ordering::Relaxed);
    }
}

#[unsafe(no_mangle)]
extern "C" fn corsairs_observe_current_task() {
    let function = GET_CURRENT.load(Ordering::Relaxed);
    if !function.is_null() {
        // SAFETY: task_probe serializes execution and installs the verified
        // swift_task_getCurrent symbol before running our nonsuspending body.
        let task = unsafe { arm64::call_sync(function, [0; 3], ptr::null_mut(), 0) };
        OBSERVED_TASK.store(task, Ordering::Relaxed);
        OBSERVED_COUNT.fetch_add(1, Ordering::Relaxed);
    }
}

struct TaskHandle {
    pointer: *mut c_void,
    release: unsafe extern "C" fn(*mut c_void),
}

impl Drop for TaskHandle {
    fn drop(&mut self) {
        // SAFETY: Owns the caller's +1 reference. The known nonsuspending job has
        // completed before this guard drops, including validation error paths.
        unsafe { (self.release)(self.pointer) };
    }
}

#[derive(Debug)]
pub struct TaskReport {
    pub cycles: usize,
    pub bodies_executed: usize,
    pub task_identity_matches: usize,
    pub tls_restored: usize,
}

impl Runtime {
    /// Create and synchronously finish a real Swift task with no suspension.
    ///
    /// # Safety
    /// Requires the macOS 27 arm64 task runtime contracts in the ledger. The
    /// hardcoded body must never suspend or capture borrowed data. This does not
    /// establish an executor or support for arbitrary asynchronous Core AI calls.
    pub unsafe fn task_probe(&self, cycles: usize) -> Result<TaskReport, Error> {
        if !(1..=1_000_000).contains(&cycles) {
            return Err(Error("task cycles must be between 1 and 1000000".into()));
        }
        let _lock = LOCK
            .lock()
            .map_err(|_| Error("task probe lock poisoned".into()))?;
        let symbol = |name| self.library.symbol(name).map(NonNull::as_ptr);
        let create = symbol(c"swift_task_create")?;
        let run = symbol(c"swift_job_run")?;
        let get_current = symbol(c"swift_task_getCurrent")?;
        let retain = symbol(c"swift_retain")?;
        let release = symbol(c"swift_release")?;
        let full_void = symbol(c"$sytN")?;
        // SAFETY: Unlike Int's symbol, this exported Void symbol names full
        // metadata. Installed Swift IR passes symbol+8 as the metadata address.
        let void_metadata = unsafe { full_void.cast::<u8>().add(8).cast::<c_void>() };
        // SAFETY: Swift runtime retain/release use these C ABI signatures.
        let (retain, release) = unsafe {
            (
                mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void) -> *mut c_void>(
                    retain,
                ),
                mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void)>(release),
            )
        };
        GET_CURRENT.store(get_current, Ordering::Relaxed);
        let _hook = CurrentHook;
        OBSERVED_COUNT.store(0, Ordering::Relaxed);
        let mut report = TaskReport {
            cycles,
            bodies_executed: 0,
            task_identity_matches: 0,
            tls_restored: 0,
        };
        for _ in 0..cycles {
            // SAFETY: Verified no-argument Swift ABI getter returns borrowed task.
            let before = unsafe { arm64::call_sync(get_current, [0; 3], ptr::null_mut(), 0) };
            if before != 0 {
                return Err(Error(
                    "task probe requires a thread outside a Swift task".into(),
                ));
            }
            // SAFETY: Creates an unscheduled task for only our known leaf body.
            let (task, context) = unsafe {
                create_task(
                    create,
                    void_metadata,
                    ptr::addr_of!(corsairs_void_task_descriptor),
                )
            };
            if task.is_null() {
                return Err(Error("task creation returned null".into()));
            }
            let handle = TaskHandle {
                pointer: task,
                release,
            };
            if context.is_null() {
                return Err(Error("task creation returned null context".into()));
            }
            OBSERVED_TASK.store(0, Ordering::Relaxed);
            // SAFETY: Keep caller +1 and add running +1, matching Swift's own
            // immediate-task path. Native completion releases the running ref.
            unsafe { retain(task) };
            // SAFETY: Flags=0 means not enqueued. swift_job_run establishes a real
            // task/executor context (generic executor=two zero words). Our body
            // never suspends, so this returns after native task completion.
            unsafe { arm64::call_sync(run, [task as usize, 0, 0], ptr::null_mut(), 0) };
            if OBSERVED_TASK.load(Ordering::Relaxed) != task as usize {
                return Err(Error(
                    "body did not observe its native task identity".into(),
                ));
            }
            report.task_identity_matches += 1;
            // SAFETY: Same verified getter after the job has synchronously ended.
            let after = unsafe { arm64::call_sync(get_current, [0; 3], ptr::null_mut(), 0) };
            if before != after {
                return Err(Error("native current-task TLS was not restored".into()));
            }
            report.tls_restored += 1;
            drop(handle);
        }
        report.bodies_executed = OBSERVED_COUNT.load(Ordering::Relaxed);
        if report.bodies_executed != cycles {
            return Err(Error("wrong number of native task bodies".into()));
        }
        Ok(report)
    }
}
