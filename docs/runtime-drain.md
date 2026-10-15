# Releasing a runtime stage

`Runtime::drain() -> Task<()>` waits for work submitted before the call and for
all queued cleanup caused by that work. This includes releases generated when
an abandoned task's result is destroyed, failed requests drop their captured
handles, or releasing one object releases another. One drain replaces repeated
`flush()` calls when releasing a stage:

```rust,no_run
use corsairs::{Function, Model, Runtime, TensorHandle};

fn finish_stage(
    runtime: &Runtime,
    model: Model,
    function: Function,
    carry: TensorHandle,
) -> Result<TensorHandle, corsairs::Error> {
    drop(function);
    drop(model);
    runtime.drain().wait()?;
    // The application still owns this carry, so drain preserves its storage.
    Ok(carry)
}
```

Drop unwanted tasks and stage handles before calling `drain`. A completed task
that has not been consumed or dropped still owns its result. The operation does
not destroy externally held models, functions, tensor handles, Metal resources,
or completed results. Other clones retain the same ownership. It does not
cancel work, clear Core AI's internal caches, or promise that macOS immediately
evicts compiler/weight mappings or GPU allocations.

The submission boundary is finite and captured when `drain()` is called, rather
than when its task is first polled. Independent later submissions and handles
dropped later from another thread do not extend that boundary. Earlier work's
cleanup can run before those newer requests; ordinary inference requests retain
their relative submission order. An infinite cleanup cascade or a native call
that never returns cannot be made quiescent by this operation.

`flush()` retains its lighter, ordered-marker contract. A release caused by an
earlier request can be enqueued after that marker, so one `flush()` does not
establish transitive cleanup. `drain()` counts pending work by its originating
request and lets cleanup enqueued on the worker inherit that origin. While
draining, the worker defers newer independent requests until all origins within
the captured boundary have completed. It never infers quiescence by observing
an empty queue or by running a fixed number of marker passes.

Dropping the drain task does not cancel the barrier. A pending synchronous
`wait()` on the runtime's own worker returns `Error::ReentrantWait`. If the
worker has stopped, a drain resolves to `Error::WorkerUnavailable`; that error
does not assert successful cleanup. As elsewhere in the worker, a panic from
an operation or completion callback stops the session and resolves queued
requests through their completion guards.

## Verification

Pure Rust worker tests cover 128-level release cascades from abandoned results
and failed requests, cleanup caused by completion callbacks, newer blocking work
ahead of older cleanup, retained completed results, multiple barriers, abandoned
drain tasks, reentrant waiting, and stopped/panicked workers. Run them with:

```sh
cargo test --offline -p corsairs worker::tests
```

The ignored native test
`facade::tests::native_dropped_futures_release_model_and_function_handles`
uses one drain at each stage and checks live native model/function/tensor counts
after abandoned loads, failed function loads, owned runs, retained runs and
validation failures. It also checks that an externally held upload survives the
drain and remains downloadable. The current
[native lifecycle run](evidence/v0.2-drain-lifecycle-final-native.json) passes all
five ignored lifecycle tests, including this test, with 29 pure Rust tests
filtered out. The [current core report](evidence/v0.2/final-core/checks.json) and
[build manifest](evidence/v0.2/final-core/build-manifest.json) retain the final
source hashes and debug/release native checks. Prior reports using repeated
`flush()` calls are separate evidence and do not verify this drain contract.
