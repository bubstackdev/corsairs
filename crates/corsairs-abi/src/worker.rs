use crate::api_error::Error;
use std::collections::{BTreeMap, VecDeque};
use std::future::Future;
use std::pin::Pin;
use std::sync::{Arc, Mutex, mpsc};
use std::task::{Context, Poll, Waker};

struct ResultState<T> {
    result: Option<Result<T, Error>>,
    waker: Option<Waker>,
}

/// A runtime-independent future. Dropping it does not cancel native work or
/// release that work's inputs; the worker owns the request until completion.
#[must_use = "the request has been submitted; await or wait for its result"]
pub struct Task<T> {
    state: Arc<Mutex<ResultState<T>>>,
    worker_thread: std::thread::ThreadId,
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
        let mut state = self.state.lock().unwrap_or_else(|e| e.into_inner());
        if let Some(result) = state.result.take() {
            return Poll::Ready(result);
        }
        if state
            .waker
            .as_ref()
            .is_none_or(|old| !old.will_wake(context.waker()))
        {
            state.waker = Some(context.waker().clone());
        }
        Poll::Pending
    }
}

struct Complete<T> {
    state: Option<Arc<Mutex<ResultState<T>>>>,
}
impl<T> Complete<T> {
    fn finish(mut self, result: Result<T, Error>) {
        self.publish(result);
    }
    fn publish(&mut self, result: Result<T, Error>) {
        if let Some(state) = self.state.take() {
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
            completion,
        } = *self;
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
            Message::Drain { cutoff, completion } => {
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
        let completion = Complete {
            state: Some(Arc::clone(&state)),
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
            worker_thread: self.thread,
        }
    }
    pub(crate) fn drain(&self) -> Task<()> {
        let state = Arc::new(Mutex::new(ResultState {
            result: None,
            waker: None,
        }));
        let completion = Complete {
            state: Some(Arc::clone(&state)),
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
