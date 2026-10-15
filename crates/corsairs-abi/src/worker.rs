use crate::api_error::Error;
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

pub(crate) struct Worker<S> {
    sender: Arc<mpsc::Sender<Box<dyn Work<S>>>>,
    thread: std::thread::ThreadId,
}
impl<S> Clone for Worker<S> {
    fn clone(&self) -> Self {
        Self {
            sender: Arc::clone(&self.sender),
            thread: self.thread,
        }
    }
}
impl<S: 'static> Worker<S> {
    pub(crate) fn start(
        initialize: impl FnOnce() -> Result<S, Error> + Send + 'static,
    ) -> Result<Self, Error> {
        let (sender, receiver) = mpsc::channel::<Box<dyn Work<S>>>();
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
                while let Ok(request) = receiver.recv() {
                    // A Rust panic stops this session. Dropping completion guards
                    // resolves this and queued requests, so no future waits forever.
                    if std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
                        request.execute(&mut session)
                    }))
                    .is_err()
                    {
                        break;
                    }
                }
            })
            .map_err(|e| Error::WorkerStart(e.to_string()))?;
        let thread = handle.thread().id();
        drop(handle);
        started.recv().map_err(|_| Error::WorkerUnavailable)??;
        Ok(Self {
            sender: Arc::new(sender),
            thread,
        })
    }
    pub(crate) fn submit<T: Send + 'static>(
        &self,
        operation: impl FnOnce(&mut S) -> Result<T, Error> + Send + 'static,
    ) -> Task<T> {
        let state = Arc::new(Mutex::new(ResultState {
            result: None,
            waker: None,
        }));
        let completion = Complete {
            state: Some(Arc::clone(&state)),
        };
        // On send failure, the returned request drops its completion guard and
        // publishes WorkerUnavailable. A dropped Task never drops the request.
        let _ = self.sender.send(Box::new(Request {
            operation,
            completion,
        }));
        Task {
            state,
            worker_thread: self.thread,
        }
    }
    pub(crate) fn release(&self, operation: impl FnOnce(&mut S) + Send + 'static) {
        drop(self.submit(move |session| {
            operation(session);
            Ok(())
        }));
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
        release.send(()).unwrap();
        assert_eq!(crashing.wait(), Err(Error::WorkerUnavailable));
        assert_eq!(pending.wait(), Err(Error::WorkerUnavailable));
        assert_eq!(
            worker.submit(|_| Ok(8)).wait(),
            Err(Error::WorkerUnavailable)
        );
    }
}
