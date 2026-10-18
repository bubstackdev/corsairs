# Native cancellation investigation

Investigated 2026-10-18 on macOS 27.0.1 (26A434), Xcode/SDK 27, against
Corsairs `3991819` (v0.3.1).

**Conclusion:** Core AI provides no cancellation path. Once a load, `run`, or
stream encode reaches Core AI, it runs to completion. Corsairs can therefore
cancel only work that has not yet reached native code. Running native work can
be abandoned, as it is today, but never stopped.

## Evidence

**Public API.** No SDK 27 `.swiftinterface` for `CoreAI` or its subframeworks
(`CoreAIRuntime`, `CoreAIDelegates`, `CoreAICommon`, `CoreAIAsset`,
`CoreAICompiler`, `CoreAICache`) contains the word "cancel". `run(inputs:states:outputViews:)`
is a plain `async throws` with no token, deadline, or abort parameter.
`ComputeStream` exposes only `init(commandQueue:)` and `currentWorkCompleted()`,
and GPU work is committed to a caller-owned `MTLCommandQueue`. Metal cannot
cancel a committed command buffer.

**Implementation imports.** [Static scan](evidence/cancellation/static-imports.json):
none of those images, nor `ODIE.framework` (linked by `CoreAIRuntime`), imports
`swift_task_isCancelled`, `swift_task_addCancellationHandler`,
`Task.checkCancellation`, `CancellationError`, or any other cancellation symbol.
`CoreAIRuntime` does import `swift_task_create`, `swift_task_future_wait_throwing`
and continuation entry points, so it uses Swift concurrency without ever observing
cancellation. `Task.isCancelled` and `withTaskCancellationHandler` lower to these
runtime calls, so a cooperative check would appear as an import. The `CoreAI`
umbrella image only re-exports.

**Behavior.** [`CancellationReference.swift`](../experiments/swift/CancellationReference.swift)
cancels its own task before the first Core AI call and then performs each
operation on the x+x fixture. [Results](evidence/cancellation/swift-oracle.json):
on both CPU-only and GPU-preferred, model load + run, `run`, 100 consecutive
`run`s, and stream encode → `currentWorkCompleted()` → output read all complete
with exact bytes. None throws, and the task still reports cancelled afterwards.
`currentWorkCompleted()` still fences correctly under cancellation, so
cancellation would not weaken Corsairs' GPU completion fence.

Reproduce:

```sh
xcrun swiftc -parse-as-library -O -module-cache-path target/cancellation/module-cache \
  experiments/swift/CancellationReference.swift -o target/cancellation/cancellation-oracle
target/cancellation/cancellation-oracle fixtures/double_f32_2x3/double_f32_2x3.aimodel
```

**Limits.** This covers the recorded OS build and the public entry points Corsairs
uses. A private cancellation mechanism that is not built on Swift task
cancellation (for example an Objective-C or XPC call) is not ruled out, but none
is reachable through the public API. A later OS could add cancellation.

## What Corsairs can cancel

Each runtime has one worker thread that executes requests serially and blocks
during each native call. Requests queued behind a long model load or inference
are real, and they have not reached Core AI. Skipping them before execution is
safe: the request's captured inputs drop on the worker under the request's causal
root, exactly as an executed request's would, so `drain()` accounting is
unchanged.

| Request state | Cancellable | Notes |
| --- | --- | --- |
| Queued on the worker | Yes | Skip native submission; resolve the task with a cancellation error |
| Running native call | No | Core AI ignores cancellation; result is discarded if abandoned, as today |
| Encoded on the GPU stream | No | Committed Metal work completes; fence and result owners stay alive |
| Between application-level steps | App's choice | E.g. stop a diffusion loop between `run_native` calls |

Internal cleanup/release jobs must never be cancellable. They are submitted
through the same queue and currently use `drop(task)` to detach.

## Corsairs API

`Task::cancel_handle()` returns a `CancelHandle` that is `Clone`, `Send` and
`Sync`. `CancelHandle::cancel()` returns `Cancel::Prevented` if the request had
not started; the task then resolves immediately to `Error::Cancelled`. It returns
`Cancel::TooLate` if the worker had already claimed the request, and the task then
resolves normally. Dropping a task still detaches without cancelling, so
fire-and-forget submissions and internal releases are unaffected.

Each request carries an atomic phase. The worker claims it (queued → started)
immediately before executing, and a cancel handle claims it (queued → cancelled)
with a single compare-and-swap, so exactly one side wins. A skipped request's
captures drop on the worker inside its causal root, so `drain()` still includes
their releases. Handles hold only a weak reference to the result, so they never
keep outputs alive. A queued `drain()` can also be cancelled.

Requests on one runtime execute in submission order. Cancelling one does not
cancel later requests, including ones that depend on its effects, such as a
`run` that reads a `MetalBuffer::write` the application cancelled.

Coverage: worker tests for queued, running, finished, repeated and cloned
cancellation, drain inclusion of a skipped request's release cascade, result
non-retention, and cancelled drains; plus a native test where queued `run` and
`run_native` calls are cancelled behind a gated worker job, a later run still
produces exact output, and every handle is released.
