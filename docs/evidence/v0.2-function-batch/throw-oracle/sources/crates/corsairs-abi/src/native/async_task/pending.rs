//! Split-phase Swift calls with a completion join on every drop path.
use super::*;
#[cfg(any(feature = "abi-research", test))]
use std::time::Instant;

#[derive(Clone, Copy)]
pub(crate) enum Scheduling {
    Inline,
    Global,
}

#[derive(Clone, Debug)]
#[cfg(any(feature = "abi-research", test))]
pub struct OverlapEvent {
    pub task: usize,
    pub stage: &'static str,
    pub elapsed_nanos: u64,
}
#[derive(Clone, Debug)]
#[cfg(any(feature = "abi-research", test))]
pub struct OverlapReport {
    pub peak_in_flight: usize,
    pub active_at_join: usize,
    pub entries: usize,
    pub returns: usize,
    pub events: Vec<OverlapEvent>,
}
pub struct OverlapProbe {
    #[cfg(any(feature = "abi-research", test))]
    epoch: Instant,
    active: AtomicUsize,
    peak: AtomicUsize,
    entries: AtomicUsize,
    returns: AtomicUsize,
    #[cfg(any(feature = "abi-research", test))]
    events: Mutex<Vec<OverlapEvent>>,
}
impl OverlapProbe {
    #[cfg(any(feature = "abi-research", test))]
    pub fn new(capacity: usize) -> Self {
        Self {
            epoch: Instant::now(),
            active: AtomicUsize::new(0),
            peak: AtomicUsize::new(0),
            entries: AtomicUsize::new(0),
            returns: AtomicUsize::new(0),
            events: Mutex::new(Vec::with_capacity(capacity * 2)),
        }
    }
    pub(super) fn entered(&self) -> usize {
        let active = self.active.fetch_add(1, Ordering::SeqCst) + 1;
        self.peak.fetch_max(active, Ordering::SeqCst);
        let task = self.entries.fetch_add(1, Ordering::SeqCst) + 1;
        #[cfg(any(feature = "abi-research", test))]
        self.event(task, "entry");
        task
    }
    pub(super) fn returned(&self, _task: usize) {
        self.active.fetch_sub(1, Ordering::SeqCst);
        self.returns.fetch_add(1, Ordering::SeqCst);
        #[cfg(any(feature = "abi-research", test))]
        self.event(_task, "return");
    }
    #[cfg(any(feature = "abi-research", test))]
    fn event(&self, task: usize, stage: &'static str) {
        let elapsed_nanos = self.epoch.elapsed().as_nanos().min(u64::MAX as u128) as u64;
        self.events
            .lock()
            .unwrap_or_else(|e| e.into_inner())
            .push(OverlapEvent {
                task,
                stage,
                elapsed_nanos,
            });
    }
    #[cfg(any(feature = "abi-research", test))]
    pub fn report(&self) -> OverlapReport {
        OverlapReport {
            peak_in_flight: self.peak.load(Ordering::SeqCst),
            active_at_join: self.active.load(Ordering::SeqCst),
            entries: self.entries.load(Ordering::SeqCst),
            returns: self.returns.load(Ordering::SeqCst),
            events: self
                .events
                .lock()
                .unwrap_or_else(|e| e.into_inner())
                .clone(),
        }
    }
}

pub(crate) struct PendingCall<'runtime> {
    _runtime: &'runtime Runtime,
    state: Arc<State>,
    task: *mut c_void,
    release: unsafe extern "C" fn(*mut c_void),
    error_release: unsafe extern "C" fn(*mut c_void),
    result: Option<AsyncResult>,
    joined: bool,
}
impl PendingCall<'_> {
    fn join(&mut self) {
        if self.joined {
            return;
        }
        let mut result = self
            .state
            .completion
            .lock()
            .unwrap_or_else(|e| e.into_inner());
        while !result.done {
            result = self
                .state
                .ready
                .wait(result)
                .unwrap_or_else(|e| e.into_inner());
        }
        let mut output = AsyncResult {
            error: mem::take(&mut result.error),
            identities: result.identities,
            resumes: result.resumes,
            #[cfg(feature = "abi-research")]
            other_thread: result.resumed_on_other_thread,
            tls_clear: result.completion_tls_clear,
        };
        drop(result);
        // SAFETY: Native completion released running+1 before signaling; this
        // unique owner balances caller+1 after the post-native-completion join.
        unsafe {
            (self.release)(self.task);
        }
        self.task = ptr::null_mut();
        // SAFETY: Same thread-confinement/current-task contract as start_native.
        output.tls_clear &=
            unsafe { arm64::call_sync(self.state.current as _, [0; 3], ptr::null_mut(), 0) } == 0;
        self.result = Some(output);
        self.joined = true;
    }
    pub(crate) fn wait(mut self) -> AsyncResult {
        self.join();
        self.result.take().expect("joined native call")
    }
}
impl Drop for PendingCall<'_> {
    fn drop(&mut self) {
        self.join();
        if let Some(result) = self.result.take()
            && result.error != 0
        {
            // SAFETY: An abandoned result still owns precisely this Error +1.
            unsafe {
                (self.error_release)(result.error as _);
            }
        }
    }
}

impl Runtime {
    /// # Safety
    /// The argument/result allocations and receiver must remain live until the
    /// returned pending call joins or drops. Err means the call never started.
    pub(crate) unsafe fn start_native(
        &self,
        descriptor: &CStr,
        arguments: [usize; 4],
        receiver: usize,
        throwing: bool,
        scheduling: Scheduling,
        overlap: Option<Arc<OverlapProbe>>,
    ) -> Result<PendingCall<'_>, Error> {
        pin_executor()?;
        let symbol = |name| self.library.symbol(name).map(NonNull::as_ptr);
        let create = symbol(c"swift_task_create")?;
        let schedule = symbol(match scheduling {
            Scheduling::Inline => c"swift_job_run",
            Scheduling::Global => c"swift_task_enqueueTaskOnExecutor",
        })?;
        let current = symbol(c"swift_task_getCurrent")?;
        let alloc = symbol(c"swift_task_alloc")?;
        let dealloc = symbol(c"swift_task_dealloc")?;
        let retain = symbol(c"swift_retain")?;
        let release = symbol(c"swift_release")?;
        let error_release = symbol(c"swift_errorRelease")?;
        let void = symbol(c"$sytN")?;
        let descriptor = symbol(descriptor)?.cast::<u8>();
        // SAFETY: Verified native async descriptor is rel32entry + u32size.
        let (offset, size) = unsafe {
            (
                descriptor.cast::<i32>().read(),
                descriptor.add(4).cast::<u32>().read() as usize,
            )
        };
        if !(16..=1_048_576).contains(&size) {
            return Err(Error("invalid native async context size".into()));
        }
        let entry = (descriptor as usize).wrapping_add_signed(offset as isize);
        if entry == 0 || entry & 3 != 0 {
            return Err(Error("invalid native async entry".into()));
        }
        // SAFETY: Reject nested use: this blocking research driver starts outside
        // a Swift task and uses the native generic executor, not a main actor.
        if unsafe { arm64::call_sync(current, [0; 3], ptr::null_mut(), 0) } != 0 {
            return Err(Error(
                "async probe requires a thread outside a Swift task".into(),
            ));
        }
        let state = Arc::new(State {
            alloc: alloc as usize,
            dealloc: dealloc as usize,
            current: current as usize,
            entry,
            context_size: size,
            throwing,
            expected_task: AtomicUsize::new(0),
            trace_task: AtomicUsize::new(0),
            completion: Mutex::new(Completion::default()),
            ready: Condvar::new(),
            overlap,
        });
        // SAFETY: Verified C retain/release runtime ABI.
        let (retain, release) = unsafe {
            (
                mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void) -> *mut c_void>(
                    retain,
                ),
                mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void)>(release),
            )
        };
        // SAFETY: Flags0 leaves a private unscheduled window. Void metadata is
        // symbol+8, as established by the independent Swift compiler oracle.
        let (task, root) = unsafe {
            create_task(
                create,
                void.cast::<u8>().add(8).cast(),
                ptr::addr_of!(corsairs_async_descriptor),
            )
        };
        if task.is_null() || root.is_null() {
            // Runtime task allocation cannot partially fail: OOM aborts. This
            // branch diagnoses an ABI mismatch rather than scheduling it.
            if !task.is_null() {
                // SAFETY: Balance the caller reference if task was returned.
                unsafe { release(task) };
            }
            return Err(Error("native task creation returned null".into()));
        }
        state.expected_task.store(task as usize, Ordering::Relaxed);
        let root = root.cast::<usize>();
        // SAFETY: Returned context equals entry x22. Runtime adapter fields are
        // at negative offsets; our declared80byte frame owns slots16..79.
        unsafe {
            *root.add(3) = *root.add(1);
            *root.add(4) = Arc::into_raw(Arc::clone(&state)) as usize;
            *root.add(1) = corsairs_async_complete as *const () as usize;
            ptr::copy_nonoverlapping(arguments.as_ptr(), root.add(5), 4);
            *root.add(9) = receiver;
            // Match Swift's create+enqueue ownership: the retained running +1
            // is consumed by completeTaskAndRelease. The original caller +1
            // stays in PendingCall until native completion has joined.
            retain(task);
            // Compiler oracle enqueue_reference.ll lowers (task, executor) to
            // x0/x1/x2; SerialExecutorRef::generic() is {nullptr,0}. Unlike a
            // raw enqueueGlobal, this entry also updates task status records.
            arm64::call_sync(schedule, [task as usize, 0, 0], ptr::null_mut(), 0);
        }

        // SAFETY: Fixed Swift error-release C ABI, resolved before scheduling.
        let error_release = unsafe {
            mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void)>(error_release)
        };
        Ok(PendingCall {
            _runtime: self,
            state,
            task,
            release,
            error_release,
            result: None,
            joined: false,
        })
    }

    /// # Safety
    /// Fixed lowered synchronous call only. All arguments, receiver and output
    /// storage remain owned until the returned pending task joins or drops.
    pub(crate) unsafe fn start_sync_native(
        &self,
        function: &CStr,
        arguments: [usize; 4],
        receiver: usize,
        overlap: Option<Arc<OverlapProbe>>,
    ) -> Result<PendingCall<'_>, Error> {
        pin_executor()?;
        let symbol = |name| self.library.symbol(name).map(NonNull::as_ptr);
        let create = symbol(c"swift_task_create")?;
        let schedule = symbol(c"swift_task_enqueueTaskOnExecutor")?;
        let current = symbol(c"swift_task_getCurrent")?;
        let alloc = symbol(c"swift_task_alloc")?;
        let dealloc = symbol(c"swift_task_dealloc")?;
        let retain = symbol(c"swift_retain")?;
        let release = symbol(c"swift_release")?;
        let error_release = symbol(c"swift_errorRelease")?;
        let void = symbol(c"$sytN")?;
        let entry = symbol(function)? as usize;
        // SAFETY: Reject nested use: this blocking research driver starts outside
        // a Swift task and uses the native generic executor, not a main actor.
        if unsafe { arm64::call_sync(current, [0; 3], ptr::null_mut(), 0) } != 0 {
            return Err(Error(
                "async probe requires a thread outside a Swift task".into(),
            ));
        }
        let state = Arc::new(State {
            alloc: alloc as usize,
            dealloc: dealloc as usize,
            current: current as usize,
            entry,
            context_size: 0,
            throwing: true,
            expected_task: AtomicUsize::new(0),
            trace_task: AtomicUsize::new(0),
            completion: Mutex::new(Completion::default()),
            ready: Condvar::new(),
            overlap,
        });
        // SAFETY: Verified C retain/release runtime ABI.
        let (retain, release) = unsafe {
            (
                mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void) -> *mut c_void>(
                    retain,
                ),
                mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void)>(release),
            )
        };
        // SAFETY: Flags0 leaves a private unscheduled window. Void metadata is
        // symbol+8, as established by the independent Swift compiler oracle.
        let (task, root) = unsafe {
            create_task(
                create,
                void.cast::<u8>().add(8).cast(),
                ptr::addr_of!(super::sync_call::corsairs_sync_descriptor),
            )
        };
        if task.is_null() || root.is_null() {
            // Runtime task allocation cannot partially fail: OOM aborts. This
            // branch diagnoses an ABI mismatch rather than scheduling it.
            if !task.is_null() {
                // SAFETY: Balance the caller reference if task was returned.
                unsafe { release(task) };
            }
            return Err(Error("native task creation returned null".into()));
        }
        state.expected_task.store(task as usize, Ordering::Relaxed);
        let root = root.cast::<usize>();
        // SAFETY: Returned context equals entry x22. Runtime adapter fields are
        // at negative offsets; our declared80byte frame owns slots16..79.
        unsafe {
            *root.add(3) = *root.add(1);
            *root.add(4) = Arc::into_raw(Arc::clone(&state)) as usize;
            *root.add(1) = corsairs_async_complete as *const () as usize;
            ptr::copy_nonoverlapping(arguments.as_ptr(), root.add(5), 4);
            *root.add(9) = receiver;
            // Match Swift's create+enqueue ownership: the retained running +1
            // is consumed by completeTaskAndRelease. The original caller +1
            // stays in PendingCall until native completion has joined.
            retain(task);
            // Compiler oracle enqueue_reference.ll lowers (task, executor) to
            // x0/x1/x2; SerialExecutorRef::generic() is {nullptr,0}. Unlike a
            // raw enqueueGlobal, this entry also updates task status records.
            arm64::call_sync(schedule, [task as usize, 0, 0], ptr::null_mut(), 0);
        }

        // SAFETY: Fixed Swift error-release C ABI, resolved before scheduling.
        let error_release = unsafe {
            mem::transmute::<*mut c_void, unsafe extern "C" fn(*mut c_void)>(error_release)
        };
        Ok(PendingCall {
            _runtime: self,
            state,
            task,
            release,
            error_release,
            result: None,
            joined: false,
        })
    }
}
