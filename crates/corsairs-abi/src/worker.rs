use crate::api_error::Error;
use std::collections::{BTreeMap, VecDeque};
use std::future::Future;
use std::pin::Pin;
use std::sync::atomic::{AtomicU8, Ordering};
use std::sync::{Arc, Mutex, Weak, mpsc};
use std::task::{Context, Poll, Waker};

struct ResultState<T> {
    result: Option<Result<T, Error>>,
    waker: Option<Waker>,
}

fn resolve<T>(state: &Mutex<ResultState<T>>, result: Result<T, Error>) {
    let waker = {
        let mut state = state.lock().unwrap_or_else(|e| e.into_inner());
        state.result = Some(result);
        state.waker.take()
    };
    // Waking outside the lock permits a reentrant executor poll.
    if let Some(waker) = waker {
        waker.wake();
    }
}

// A request moves from QUEUED to exactly one of STARTED (claimed by the worker,
// or resolved without running) or CANCELLED (claimed by a cancel handle).
const QUEUED: u8 = 0;
const STARTED: u8 = 1;
const CANCELLED: u8 = 2;

/// A runtime-independent future. Dropping it does not cancel native work or
/// release that work's inputs; the worker owns the request until completion.
/// Use [`Task::cancel_handle`] to prevent a request that has not started.
#[must_use = "the request has been submitted; await or wait for its result"]
pub struct Task<T> {
    state: Arc<Mutex<ResultState<T>>>,
    phase: Arc<AtomicU8>,
    worker_thread: std::thread::ThreadId,
}

/// The outcome of [`CancelHandle::cancel`].
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Cancel {
    /// The request had not started and never will. Its task resolves to
    /// [`Error::Cancelled`]; the worker later drops its inputs in order.
    Prevented,
    /// The request had already started or finished. Core AI cannot stop
    /// running work, so the task resolves normally.
    TooLate,
}

trait Cancellable: Send + Sync {
    fn cancel(&self) -> Cancel;
}
struct Target<T> {
    phase: Arc<AtomicU8>,
    // Weak: a handle must never keep a request's result alive.
    state: Weak<Mutex<ResultState<T>>>,
}
impl<T: Send> Cancellable for Target<T> {
    fn cancel(&self) -> Cancel {
        match self
            .phase
            .compare_exchange(QUEUED, CANCELLED, Ordering::AcqRel, Ordering::Acquire)
        {
            Ok(_) => {
                // No result can exist: publishing requires claiming first.
                if let Some(state) = self.state.upgrade() {
                    resolve(&state, Err(Error::Cancelled));
                }
                Cancel::Prevented
            }
            Err(CANCELLED) => Cancel::Prevented,
            Err(_) => Cancel::TooLate,
        }
    }
}

/// Cancels a submitted request if it has not yet reached Core AI.
///
/// Requests on one runtime execute in submission order. Cancelling one does
/// not cancel later requests, including ones that depend on its effects.
/// Handles are cheap to clone, may be sent to other threads, and do not retain
/// the request or its result.
#[derive(Clone)]
pub struct CancelHandle(Arc<dyn Cancellable>);
impl CancelHandle {
    /// Prevent the request if it is still queued. Calling this again, or from
    /// a clone, reports the same outcome.
    pub fn cancel(&self) -> Cancel {
        self.0.cancel()
    }
}
impl std::fmt::Debug for CancelHandle {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("CancelHandle").finish_non_exhaustive()
    }
}

impl<T: Send + 'static> Task<T> {
    /// A handle that can prevent this request before it starts.
    pub fn cancel_handle(&self) -> CancelHandle {
        CancelHandle(Arc::new(Target {
            phase: Arc::clone(&self.phase),
            state: Arc::downgrade(&self.state),
        }))
    }
}

impl<T> Task<T> {
    /// Block the calling thread until this request completes. Do not call from
    /// an executor thread that must remain available to other tasks. A pending
    /// request cannot be synchronously waited on its own native worker; that
    /// reentrant call returns Error::ReentrantWait instead of deadlocking.
    pub fn wait(self) -> Result<T, Error> {
        struct WakeThread(std::thread::Thread);
        impl std::task::Wake for WakeThread {
            fn wake(self: Arc<Self>) {
                self.0.unpark();
            }
            fn wake_by_ref(self: &Arc<Self>) {
                self.0.unpark();
            }
        }
        let waker = Waker::from(Arc::new(WakeThread(std::thread::current())));
        let mut context = Context::from_waker(&waker);
        let mut task = self;
        loop {
            match Pin::new(&mut task).poll(&mut context) {
                Poll::Ready(result) => return result,
                Poll::Pending => {
                    if std::thread::current().id() == task.worker_thread {
                        return Err(Error::ReentrantWait);
                    }
                    std::thread::park();
                }
            }
        }
    }
}
impl<T> Future for Task<T> {
    type Output = Result<T, Error>;
    fn poll(self: Pin<&mut Self>, context: &mut Context<'_>) -> Poll<Self::Output> {
        // Raw-waker clone/drop callbacks can reenter the runtime. Neither may
        // run under the result lock, just like the wake callback in publish.
        let replacement = context.waker().clone();
        let mut state = self.state.lock().unwrap_or_else(|e| e.into_inner());
        if let Some(result) = state.result.take() {
            return Poll::Ready(result);
        }
        let previous = if state
            .waker
            .as_ref()
            .is_none_or(|old| !old.will_wake(context.waker()))
        {
            state.waker.replace(replacement)
        } else {
            None
        };
        drop(state);
        drop(previous);
        Poll::Pending
    }
}

struct Complete<T> {
    state: Option<Arc<Mutex<ResultState<T>>>>,
    phase: Arc<AtomicU8>,
}
impl<T> Complete<T> {
    /// Claim the request for execution or resolution. False if cancelled; the
    /// cancel handle has then already resolved the task, so disarm this.
    fn claim(&mut self) -> bool {
        let claimed = !matches!(
            self.phase
                .compare_exchange(QUEUED, STARTED, Ordering::AcqRel, Ordering::Acquire),
            Err(CANCELLED)
        );
        if !claimed {
            self.state = None;
        }
        claimed
    }
    fn finish(mut self, result: Result<T, Error>) {
        self.publish(result);
    }
    fn publish(&mut self, result: Result<T, Error>) {
        if self.claim()
            && let Some(state) = self.state.take()
        {
            resolve(&state, result);
        }
    }
}
impl<T> Drop for Complete<T> {
    fn drop(&mut self) {
        self.publish(Err(Error::WorkerUnavailable));
    }
}

trait Work<S>: Send {
    fn execute(self: Box<Self>, session: &mut S);
}
struct Request<F, T> {
    operation: F,
    completion: Complete<T>,
}
impl<S, F, T> Work<S> for Request<F, T>
where
    F: FnOnce(&mut S) -> Result<T, Error> + Send,
    T: Send,
{
    fn execute(self: Box<Self>, session: &mut S) {
        let Self {
            operation,
            mut completion,
        } = *self;
        if !completion.claim() {
            // Cancelled while queued. Dropping the operation here releases its
            // captures under this request's causal root, as execution would.
            return;
        }
        let result = operation(session);
        completion.finish(result);
    }
}

enum Message<S> {
    Work {
        root: u64,
        request: Box<dyn Work<S>>,
    },
    Drain {
        cutoff: u64,
        completion: Complete<()>,
    },
}

#[derive(Default)]
struct Submissions {
    last_root: u64,
    active_root: Option<u64>,
    outstanding: BTreeMap<u64, usize>,
}
impl Submissions {
    fn finished(&mut self, root: u64) {
        let count = self.outstanding.get_mut(&root).expect("registered request");
        *count -= 1;
        if *count == 0 {
            self.outstanding.remove(&root);
        }
    }
    fn includes_pending(&self, cutoff: u64) -> bool {
        self.outstanding.range(..=cutoff).next().is_some()
    }
}

fn execute<S>(
    root: u64,
    request: Box<dyn Work<S>>,
    session: &mut S,
    submissions: &Mutex<Submissions>,
) -> bool {
    submissions
        .lock()
        .unwrap_or_else(|e| e.into_inner())
        .active_root = Some(root);
    // Keep the causal scope through completion publication, waking, and the
    // destruction of an abandoned result or a panicking request's captures.
    let result =
        std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| request.execute(session)));
    let succeeded = result.is_ok();
    // A custom panic payload can itself own handles. Destroy it before taking
    // the registry lock, while releases still inherit this request's root.
    drop(result);
    let mut submissions = submissions.lock().unwrap_or_else(|e| e.into_inner());
    submissions.active_root = None;
    submissions.finished(root);
    succeeded
}

fn run<S>(
    session: &mut S,
    receiver: &mpsc::Receiver<Message<S>>,
    submissions: &Mutex<Submissions>,
) {
    let mut deferred = VecDeque::new();
    loop {
        let message = match deferred.pop_front().or_else(|| receiver.recv().ok()) {
            Some(message) => message,
            None => return,
        };
        match message {
            Message::Work { root, request } => {
                if !execute(root, request, session, submissions) {
                    return;
                }
            }
            Message::Drain {
                cutoff,
                mut completion,
            } => {
                if !completion.claim() {
                    continue;
                }
                while submissions
                    .lock()
                    .unwrap_or_else(|e| e.into_inner())
                    .includes_pending(cutoff)
                {
                    // New user submissions cannot extend this drain. Only
                    // cleanup descended from a root within its cutoff runs
                    // ahead of the deferred, newer work.
                    let eligible = deferred.iter().position(
                        |message| matches!(message, Message::Work { root, .. } if *root <= cutoff),
                    );
                    let message = match eligible
                        .and_then(|index| deferred.remove(index))
                        .or_else(|| receiver.recv().ok())
                    {
                        Some(message) => message,
                        None => return,
                    };
                    match message {
                        Message::Work { root, request } if root <= cutoff => {
                            if !execute(root, request, session, submissions) {
                                return;
                            }
                        }
                        newer => deferred.push_back(newer),
                    }
                }
                if std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
                    completion.finish(Ok(()))
                }))
                .is_err()
                {
                    return;
                }
            }
        }
    }
}

pub(crate) struct Worker<S> {
    sender: Arc<mpsc::Sender<Message<S>>>,
    submissions: Arc<Mutex<Submissions>>,
    thread: std::thread::ThreadId,
}
impl<S> Clone for Worker<S> {
    fn clone(&self) -> Self {
        Self {
            sender: Arc::clone(&self.sender),
            submissions: Arc::clone(&self.submissions),
            thread: self.thread,
        }
    }
}
impl<S: 'static> Worker<S> {
    pub(crate) fn same_worker(&self, other: &Self) -> bool {
        Arc::ptr_eq(&self.sender, &other.sender)
    }

    pub(crate) fn start(
        initialize: impl FnOnce() -> Result<S, Error> + Send + 'static,
    ) -> Result<Self, Error> {
        let (sender, receiver) = mpsc::channel::<Message<S>>();
        let submissions = Arc::new(Mutex::new(Submissions::default()));
        let worker_submissions = Arc::clone(&submissions);
        let (ready, started) = mpsc::sync_channel(1);
        let handle = std::thread::Builder::new()
            .name("corsairs-coreai".into())
            .spawn(move || {
                // S may be !Send: it is constructed, used and destroyed exclusively
                // on this thread. Only owned requests/results cross the channel.
                let mut session = match initialize() {
                    Ok(session) => {
                        if ready.send(Ok(())).is_err() {
                            return;
                        }
                        session
                    }
                    Err(error) => {
                        let _ = ready.send(Err(error));
                        return;
                    }
                };
                // A Rust panic stops this session. Dropping completion guards
                // resolves this and queued requests, so no future waits forever.
                run(&mut session, &receiver, &worker_submissions);
            })
            .map_err(|e| Error::WorkerStart(e.to_string()))?;
        let thread = handle.thread().id();
        drop(handle);
        started.recv().map_err(|_| Error::WorkerUnavailable)??;
        Ok(Self {
            sender: Arc::new(sender),
            submissions,
            thread,
        })
    }
    pub(crate) fn submit<T: Send + 'static>(
        &self,
        operation: impl FnOnce(&mut S) -> Result<T, Error> + Send + 'static,
    ) -> Task<T> {
        self.submit_inner(operation, false)
    }
    fn submit_inner<T: Send + 'static>(
        &self,
        operation: impl FnOnce(&mut S) -> Result<T, Error> + Send + 'static,
        cleanup: bool,
    ) -> Task<T> {
        let state = Arc::new(Mutex::new(ResultState {
            result: None,
            waker: None,
        }));
        let phase = Arc::new(AtomicU8::new(QUEUED));
        let completion = Complete {
            state: Some(Arc::clone(&state)),
            phase: Arc::clone(&phase),
        };
        let request: Box<dyn Work<S>> = Box::new(Request {
            operation,
            completion,
        });
        let rejected = {
            let mut submissions = self.submissions.lock().unwrap_or_else(|e| e.into_inner());
            let inherited = (cleanup && std::thread::current().id() == self.thread)
                .then_some(submissions.active_root)
                .flatten();
            let root = inherited.or_else(|| {
                submissions.last_root = submissions.last_root.checked_add(1)?;
                Some(submissions.last_root)
            });
            if let Some(root) = root {
                *submissions.outstanding.entry(root).or_default() += 1;
                // Sequence assignment and enqueue are atomic relative to drain.
                match self.sender.send(Message::Work { root, request }) {
                    Ok(()) => None,
                    Err(error) => {
                        submissions.finished(root);
                        Some(error.0)
                    }
                }
            } else {
                Some(Message::Work { root: 0, request })
            }
        };
        // A rejected request may own handles whose destructors enqueue more
        // releases. Drop it only after unlocking the submission registry.
        drop(rejected);
        Task {
            state,
            phase,
            worker_thread: self.thread,
        }
    }
    pub(crate) fn drain(&self) -> Task<()> {
        let state = Arc::new(Mutex::new(ResultState {
            result: None,
            waker: None,
        }));
        let phase = Arc::new(AtomicU8::new(QUEUED));
        let completion = Complete {
            state: Some(Arc::clone(&state)),
            phase: Arc::clone(&phase),
        };
        let rejected = {
            let submissions = self.submissions.lock().unwrap_or_else(|e| e.into_inner());
            self.sender
                .send(Message::Drain {
                    cutoff: submissions.last_root,
                    completion,
                })
                .err()
        };
        drop(rejected);
        Task {
            state,
            phase,
            worker_thread: self.thread,
        }
    }
    pub(crate) fn release(&self, operation: impl FnOnce(&mut S) + Send + 'static) {
        drop(self.submit_inner(
            move |session| {
                operation(session);
                Ok(())
            },
            true,
        ));
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::{
        cell::Cell,
        rc::Rc,
        sync::atomic::{AtomicUsize, Ordering},
    };

    #[test]
    fn polling_does_not_clone_or_drop_wakers_under_the_result_lock() {
        use std::mem::ManuallyDrop;
        use std::task::{RawWaker, RawWakerVTable};

        struct Inspect {
            state: Arc<Mutex<ResultState<()>>>,
            events: mpsc::Sender<(&'static str, bool)>,
        }
        impl Inspect {
            fn record(&self, event: &'static str) {
                let _ = self.events.send((event, self.state.try_lock().is_ok()));
            }
        }
        fn raw(owner: Arc<Inspect>) -> RawWaker {
            RawWaker::new(Arc::into_raw(owner).cast(), &VTABLE)
        }
        unsafe fn clone(data: *const ()) -> RawWaker {
            // SAFETY: Each raw waker owns an Arc; borrowing it must not consume it.
            let owner = ManuallyDrop::new(unsafe { Arc::from_raw(data.cast::<Inspect>()) });
            owner.record("clone");
            raw(Arc::clone(&owner))
        }
        unsafe fn wake(data: *const ()) {
            // SAFETY: wake consumes exactly this raw waker's Arc reference.
            let owner = unsafe { Arc::from_raw(data.cast::<Inspect>()) };
            owner.record("wake");
        }
        unsafe fn wake_by_ref(data: *const ()) {
            // SAFETY: A borrowed wake preserves the raw waker's owned reference.
            let owner = ManuallyDrop::new(unsafe { Arc::from_raw(data.cast::<Inspect>()) });
            owner.record("wake");
        }
        unsafe fn drop_waker(data: *const ()) {
            // SAFETY: drop consumes exactly this raw waker's Arc reference.
            let owner = unsafe { Arc::from_raw(data.cast::<Inspect>()) };
            owner.record("drop");
        }
        const VTABLE: RawWakerVTable = RawWakerVTable::new(clone, wake, wake_by_ref, drop_waker);

        let state = Arc::new(Mutex::new(ResultState {
            result: None,
            waker: None,
        }));
        let (events, observed) = mpsc::channel();
        // SAFETY: The vtable balances each Arc and only accesses synchronized data.
        let waker = unsafe {
            Waker::from_raw(raw(Arc::new(Inspect {
                state: Arc::clone(&state),
                events,
            })))
        };
        let mut task = Task {
            state: Arc::clone(&state),
            phase: Arc::new(AtomicU8::new(QUEUED)),
            worker_thread: std::thread::current().id(),
        };
        assert!(
            Pin::new(&mut task)
                .poll(&mut Context::from_waker(&waker))
                .is_pending()
        );
        assert!(
            Pin::new(&mut task)
                .poll(&mut Context::from_waker(&waker))
                .is_pending()
        );
        assert!(
            Pin::new(&mut task)
                .poll(&mut Context::from_waker(Waker::noop()))
                .is_pending()
        );
        state.lock().unwrap().result = Some(Ok(()));
        assert!(
            Pin::new(&mut task)
                .poll(&mut Context::from_waker(&waker))
                .is_ready()
        );
        drop(waker);
        let events: Vec<_> = observed.try_iter().collect();
        assert!(events.iter().any(|(event, _)| *event == "clone"));
        assert!(events.iter().any(|(event, _)| *event == "drop"));
        assert!(events.iter().all(|(_, unlocked)| *unlocked), "{events:?}");
    }

    #[test]
    fn replacing_a_waker_allows_its_destructor_to_wait_for_the_worker() {
        struct FenceOnDrop {
            worker: Worker<()>,
            release: mpsc::Sender<()>,
        }
        #[allow(
            clippy::manual_noop_waker,
            reason = "The owned waker's destructor is the behavior under test"
        )]
        impl std::task::Wake for FenceOnDrop {
            fn wake(self: Arc<Self>) {}
        }
        impl Drop for FenceOnDrop {
            fn drop(&mut self) {
                self.release.send(()).unwrap();
                self.worker.submit(|_| Ok(())).wait().unwrap();
            }
        }
        let (done, observed) = mpsc::channel();
        let thread = std::thread::spawn(move || {
            let worker = Worker::start(|| Ok(())).unwrap();
            let (release, gate) = mpsc::channel();
            let mut task = worker.submit(move |_| {
                gate.recv().unwrap();
                Ok(())
            });
            let waker = Waker::from(Arc::new(FenceOnDrop {
                worker: worker.clone(),
                release,
            }));
            assert!(
                Pin::new(&mut task)
                    .poll(&mut Context::from_waker(&waker))
                    .is_pending()
            );
            drop(waker);
            // The task owns the last old-waker reference; replacing it runs Drop
            // on this polling thread while the worker finishes the first job.
            let _ = Pin::new(&mut task).poll(&mut Context::from_waker(Waker::noop()));
            done.send(task.wait()).unwrap();
        });
        observed
            .recv_timeout(std::time::Duration::from_secs(5))
            .expect("waker cleanup deadlocked the polling thread and worker")
            .unwrap();
        thread.join().unwrap();
    }

    #[test]
    fn cancelling_a_queued_request_skips_it_and_resolves_immediately() {
        let worker = Worker::start(|| Ok(0usize)).unwrap();
        let (started, observed) = mpsc::sync_channel(0);
        let (unblock, gate) = mpsc::sync_channel(0);
        let blocking = worker.submit(move |_| {
            started.send(()).unwrap();
            gate.recv().unwrap();
            Ok(())
        });
        observed.recv().unwrap();
        let queued = worker.submit(|state| {
            *state += 1;
            Ok(())
        });
        let handle = queued.cancel_handle();
        assert_eq!(handle.cancel(), Cancel::Prevented);
        assert_eq!(handle.clone().cancel(), Cancel::Prevented);
        // Resolution does not wait for the blocked worker to reach the request.
        assert_eq!(queued.wait(), Err(Error::Cancelled));
        assert_eq!(blocking.cancel_handle().cancel(), Cancel::TooLate);
        unblock.send(()).unwrap();
        blocking.wait().unwrap();
        assert_eq!(worker.submit(|state| Ok(*state)).wait().unwrap(), 0);
    }

    #[test]
    fn started_and_finished_requests_are_too_late_to_cancel() {
        let worker = Worker::start(|| Ok(())).unwrap();
        let (started, observed) = mpsc::sync_channel(0);
        let (unblock, gate) = mpsc::sync_channel(0);
        let running = worker.submit(move |_| {
            started.send(()).unwrap();
            gate.recv().unwrap();
            Ok(7)
        });
        observed.recv().unwrap();
        assert_eq!(running.cancel_handle().cancel(), Cancel::TooLate);
        unblock.send(()).unwrap();
        let finished = worker.submit(|_| Ok(8));
        let handle = finished.cancel_handle();
        assert_eq!(running.wait(), Ok(7));
        assert_eq!(finished.wait(), Ok(8));
        assert_eq!(handle.cancel(), Cancel::TooLate);
    }

    #[test]
    fn cancelled_request_releases_captures_within_a_later_drain() {
        let worker = Worker::start(|| Ok(0usize)).unwrap();
        let releases = Arc::new(AtomicUsize::new(0));
        let cascade = Cascade {
            worker: worker.clone(),
            remaining: 32,
            releases: Arc::clone(&releases),
        };
        let (unblock, gate) = mpsc::sync_channel(0);
        drop(worker.submit(move |_| {
            gate.recv().unwrap();
            Ok(())
        }));
        let queued = worker.submit(move |_| Ok(cascade));
        assert_eq!(queued.cancel_handle().cancel(), Cancel::Prevented);
        drop(queued);
        let drain = worker.drain();
        unblock.send(()).unwrap();
        drain.wait().unwrap();
        assert_eq!(releases.load(Ordering::SeqCst), 32);
        assert_eq!(worker.submit(|state| Ok(*state)).wait().unwrap(), 32);
    }

    #[test]
    fn cancel_handles_do_not_retain_results() {
        let worker = Worker::start(|| Ok(())).unwrap();
        let sentinel = Arc::new(());
        let result = Arc::clone(&sentinel);
        let task = worker.submit(move |_| Ok(result));
        let handle = task.cancel_handle();
        drop(task);
        worker.drain().wait().unwrap();
        assert_eq!(Arc::strong_count(&sentinel), 1);
        assert_eq!(handle.cancel(), Cancel::TooLate);
    }

    #[test]
    fn a_queued_drain_can_be_cancelled() {
        let worker = Worker::start(|| Ok(())).unwrap();
        let (unblock, gate) = mpsc::sync_channel(0);
        let blocking = worker.submit(move |_| {
            gate.recv().unwrap();
            Ok(())
        });
        let drain = worker.drain();
        assert_eq!(drain.cancel_handle().cancel(), Cancel::Prevented);
        assert_eq!(drain.wait(), Err(Error::Cancelled));
        unblock.send(()).unwrap();
        blocking.wait().unwrap();
        worker.drain().wait().unwrap();
    }

    struct Cascade {
        worker: Worker<usize>,
        remaining: usize,
        releases: Arc<AtomicUsize>,
    }
    impl Drop for Cascade {
        fn drop(&mut self) {
            let worker = self.worker.clone();
            let remaining = self.remaining;
            let releases = Arc::clone(&self.releases);
            self.worker.release(move |state| {
                *state += 1;
                releases.fetch_add(1, Ordering::SeqCst);
                if remaining > 1 {
                    drop(Cascade {
                        worker,
                        remaining: remaining - 1,
                        releases,
                    });
                }
            });
        }
    }

    #[test]
    fn drain_includes_abandoned_results_and_error_capture_release_cascades() {
        for fail in [false, true] {
            let worker = Worker::start(|| Ok(0usize)).unwrap();
            let releases = Arc::new(AtomicUsize::new(0));
            let cascade = Cascade {
                worker: worker.clone(),
                remaining: 128,
                releases: Arc::clone(&releases),
            };
            let (unblock, gate) = mpsc::sync_channel(0);
            let task = worker.submit(move |_| {
                gate.recv().unwrap();
                if fail {
                    drop(cascade);
                    Err(Error::Binding("controlled request failure".into()))
                } else {
                    Ok(cascade)
                }
            });
            drop(task);
            let drain = worker.drain();
            unblock.send(()).unwrap();
            drain.wait().unwrap();
            assert_eq!(releases.load(Ordering::SeqCst), 128);
            assert_eq!(worker.submit(|state| Ok(*state)).wait().unwrap(), 128);
        }
    }

    #[test]
    fn drain_defers_later_work_without_releasing_held_results() {
        let worker = Worker::start(|| Ok(0usize)).unwrap();
        let releases = Arc::new(AtomicUsize::new(0));
        let held = Cascade {
            worker: worker.clone(),
            remaining: 5,
            releases: Arc::clone(&releases),
        };
        let (unblock_first, first_gate) = mpsc::sync_channel(0);
        let task = worker.submit(move |_| {
            first_gate.recv().unwrap();
            Ok(held)
        });
        let first_drain = worker.drain();
        let (later_started, later_observed) = mpsc::sync_channel(0);
        let (unblock_later, later_gate) = mpsc::sync_channel(0);
        let later = worker.submit(move |_| {
            later_started.send(()).unwrap();
            later_gate.recv().unwrap();
            Ok(())
        });
        unblock_first.send(()).unwrap();
        first_drain.wait().unwrap();
        assert_eq!(releases.load(Ordering::SeqCst), 0);
        // A completed task retains its result just like an application handle.
        let held = task.wait().unwrap();
        later_observed.recv().unwrap();
        drop(held);
        let second_drain = worker.drain();
        unblock_later.send(()).unwrap();
        second_drain.wait().unwrap();
        later.wait().unwrap();
        assert_eq!(releases.load(Ordering::SeqCst), 5);
    }

    #[test]
    fn drain_does_not_wait_for_new_work_ahead_of_causal_cleanup() {
        let worker = Worker::start(|| Ok(0usize)).unwrap();
        let releases = Arc::new(AtomicUsize::new(0));
        let cascade = Cascade {
            worker: worker.clone(),
            remaining: 64,
            releases: Arc::clone(&releases),
        };
        let (unblock_first, first_gate) = mpsc::sync_channel(0);
        drop(worker.submit(move |_| {
            first_gate.recv().unwrap();
            Ok(cascade)
        }));
        let drain = worker.drain();
        let (unblock_later, later_gate) = mpsc::sync_channel(0);
        let later = worker.submit(move |_| {
            later_gate.recv().unwrap();
            Ok(())
        });
        let later_drain = worker.drain();
        unblock_first.send(()).unwrap();
        // The later blocking job precedes all 64 cleanup jobs in the channel.
        // Drain must defer it and finish the entire earlier causal chain first.
        drain.wait().unwrap();
        assert_eq!(releases.load(Ordering::SeqCst), 64);
        unblock_later.send(()).unwrap();
        later.wait().unwrap();
        later_drain.wait().unwrap();
    }

    #[test]
    fn abandoned_drain_still_executes_cleanup() {
        let worker = Worker::start(|| Ok(0usize)).unwrap();
        let releases = Arc::new(AtomicUsize::new(0));
        let cascade = Cascade {
            worker: worker.clone(),
            remaining: 16,
            releases: Arc::clone(&releases),
        };
        let (unblock, gate) = mpsc::sync_channel(0);
        drop(worker.submit(move |_| {
            gate.recv().unwrap();
            Ok(cascade)
        }));
        drop(worker.drain());
        let drain = worker.drain();
        unblock.send(()).unwrap();
        drain.wait().unwrap();
        assert_eq!(releases.load(Ordering::SeqCst), 16);
    }

    #[test]
    fn drain_includes_cleanup_from_completion_callbacks() {
        struct ReleaseOnWake(Mutex<Option<Cascade>>);
        impl std::task::Wake for ReleaseOnWake {
            fn wake(self: Arc<Self>) {
                let cascade = self.0.lock().unwrap().take();
                drop(cascade);
            }
        }
        let worker = Worker::start(|| Ok(0usize)).unwrap();
        let releases = Arc::new(AtomicUsize::new(0));
        let waker = Waker::from(Arc::new(ReleaseOnWake(Mutex::new(Some(Cascade {
            worker: worker.clone(),
            remaining: 32,
            releases: Arc::clone(&releases),
        })))));
        let (unblock, gate) = mpsc::sync_channel(0);
        let mut task = worker.submit(move |_| {
            gate.recv().unwrap();
            Ok(())
        });
        assert!(
            Pin::new(&mut task)
                .poll(&mut Context::from_waker(&waker))
                .is_pending()
        );
        let drain = worker.drain();
        unblock.send(()).unwrap();
        drain.wait().unwrap();
        assert_eq!(releases.load(Ordering::SeqCst), 32);
        task.wait().unwrap();
    }

    #[test]
    fn panicking_drain_waker_resolves_queued_and_later_requests() {
        struct PanicOnWake;
        impl std::task::Wake for PanicOnWake {
            fn wake(self: Arc<Self>) {
                panic!("controlled drain waker failure");
            }
        }
        let worker = Worker::start(|| Ok(())).unwrap();
        let (unblock, gate) = mpsc::sync_channel(0);
        let first = worker.submit(move |_| {
            gate.recv().unwrap();
            Ok(())
        });
        let mut drain = worker.drain();
        let waker = Waker::from(Arc::new(PanicOnWake));
        assert!(
            Pin::new(&mut drain)
                .poll(&mut Context::from_waker(&waker))
                .is_pending()
        );
        let queued = worker.submit(|_| Ok(7));
        unblock.send(()).unwrap();
        first.wait().unwrap();
        // The barrier result is published before invoking the user's waker.
        drain.wait().unwrap();
        assert_eq!(queued.wait(), Err(Error::WorkerUnavailable));
        assert_eq!(worker.drain().wait(), Err(Error::WorkerUnavailable));
    }
    #[test]
    fn reentrant_waker_cannot_block_its_worker() {
        struct Reentrant {
            worker: Worker<()>,
            result: mpsc::SyncSender<Result<(), Error>>,
        }
        impl std::task::Wake for Reentrant {
            fn wake(self: Arc<Self>) {
                self.result
                    .send(self.worker.submit(|_| Ok(())).wait())
                    .unwrap();
            }
        }
        let worker = Worker::start(|| Ok(())).unwrap();
        let (release, gate) = mpsc::sync_channel(0);
        let mut task = worker.submit(move |_| {
            gate.recv().unwrap();
            Ok(5)
        });
        let (result, observed) = mpsc::sync_channel(0);
        let waker = Waker::from(Arc::new(Reentrant {
            worker: worker.clone(),
            result,
        }));
        assert!(
            Pin::new(&mut task)
                .poll(&mut Context::from_waker(&waker))
                .is_pending()
        );
        release.send(()).unwrap();
        assert_eq!(observed.recv().unwrap(), Err(Error::ReentrantWait));
        assert_eq!(task.wait().unwrap(), 5);
        worker.submit(|_| Ok(())).wait().unwrap();
    }
    #[test]
    fn reentrant_waker_cannot_wait_for_a_drain() {
        struct Reentrant {
            worker: Worker<()>,
            result: mpsc::SyncSender<Result<(), Error>>,
        }
        impl std::task::Wake for Reentrant {
            fn wake(self: Arc<Self>) {
                self.result.send(self.worker.drain().wait()).unwrap();
            }
        }
        let worker = Worker::start(|| Ok(())).unwrap();
        let (release, gate) = mpsc::sync_channel(0);
        let mut task = worker.submit(move |_| {
            gate.recv().unwrap();
            Ok(())
        });
        let (result, observed) = mpsc::sync_channel(0);
        let waker = Waker::from(Arc::new(Reentrant {
            worker: worker.clone(),
            result,
        }));
        assert!(
            Pin::new(&mut task)
                .poll(&mut Context::from_waker(&waker))
                .is_pending()
        );
        release.send(()).unwrap();
        assert_eq!(observed.recv().unwrap(), Err(Error::ReentrantWait));
        task.wait().unwrap();
        worker.drain().wait().unwrap();
    }
    #[test]
    fn worker_keeps_non_send_state_on_its_own_thread() {
        let worker = Worker::start(|| Ok(Rc::new(Cell::new(0)))).unwrap();
        let first = worker.submit(|state| {
            state.set(state.get() + 1);
            Ok(state.get())
        });
        let second = worker.submit(|state| {
            state.set(state.get() + 1);
            Ok(state.get())
        });
        assert_eq!(first.wait().unwrap(), 1);
        assert_eq!(second.wait().unwrap(), 2);
    }
    #[test]
    fn dropping_future_does_not_release_running_request() {
        struct Guard(Arc<AtomicUsize>);
        impl Drop for Guard {
            fn drop(&mut self) {
                self.0.fetch_add(1, Ordering::SeqCst);
            }
        }
        let count = Arc::new(AtomicUsize::new(0));
        let guard = Guard(Arc::clone(&count));
        let worker = Worker::start(|| Ok(())).unwrap();
        let (started, observed) = mpsc::sync_channel(0);
        let (release, gate) = mpsc::sync_channel(0);
        let task = worker.submit(move |_| {
            started.send(()).unwrap();
            gate.recv().unwrap();
            drop(guard);
            Ok(())
        });
        observed.recv().unwrap();
        drop(task);
        assert_eq!(count.load(Ordering::SeqCst), 0);
        release.send(()).unwrap();
        worker.submit(|_| Ok(())).wait().unwrap();
        assert_eq!(count.load(Ordering::SeqCst), 1);
    }
    #[test]
    fn panicked_worker_resolves_queued_and_later_requests() {
        let worker = Worker::start(|| Ok(())).unwrap();
        let (release, gate) = mpsc::sync_channel(0);
        let crashing: Task<()> = worker.submit(move |_| {
            gate.recv().unwrap();
            panic!("controlled worker failure")
        });
        let pending = worker.submit(|_| Ok(7));
        let drain = worker.drain();
        release.send(()).unwrap();
        assert_eq!(crashing.wait(), Err(Error::WorkerUnavailable));
        assert_eq!(pending.wait(), Err(Error::WorkerUnavailable));
        assert_eq!(drain.wait(), Err(Error::WorkerUnavailable));
        assert_eq!(worker.drain().wait(), Err(Error::WorkerUnavailable));
        assert_eq!(
            worker.submit(|_| Ok(8)).wait(),
            Err(Error::WorkerUnavailable)
        );
    }
}
