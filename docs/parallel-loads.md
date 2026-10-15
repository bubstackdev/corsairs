# Model batches

The v0.2 development API loads several assets through one `Runtime` while
preserving their individual specialization options and request order:

```rust,no_run
use corsairs::{Compute, LoadOptions, ModelLoadRequest, Runtime};

# fn example() -> Result<(), corsairs::Error> {
let runtime = Runtime::new()?;
let models = runtime.load_models(vec![
    ModelLoadRequest {
        path: "encoder.aimodel".into(),
        options: LoadOptions::new(Compute::CpuOnly),
    },
    ModelLoadRequest {
        path: "decoder.aimodel".into(),
        options: LoadOptions::new(Compute::GpuPreferred)
            .with_expect_frequent_reshapes(true),
    },
]).wait()?;
# Ok(())
# }
```

The worker prepares every argument and result allocation, enqueues the native
loads, and then joins every started load. If any load fails, successful models
from that batch are released before returning an error. Dropping the public
task still allows the entire batch to finish and clean up. An empty batch
returns an empty list. Other worker requests run after the batch has joined.

The returned models belong to the same session. Functions loaded from them can
exchange `TensorHandle` values without a host round trip. Creating several
independent runtimes would not provide that property. Single-model loading
retains its existing scheduling behavior.

Overlapping native invocation lifetimes do not prove GPU concurrency or lower
wall time. With `abi-research`, `Runtime::load_models_profiled` additionally
reports the invocation count, peak outstanding invocations, and entry/return
timestamps. Task labels in that report are ordinals. Ordinary `load_models`
allocates no diagnostic probe and collects no timing events.

The enqueue calibration combines the installed Apple Swift 6.4 compiler with
pinned upstream runtime declarations and implementation. It uses
`swift_task_enqueueTaskOnExecutor`, including task scheduling bookkeeping;
the adapter does not submit an unmarked task directly to a global job queue.
The caller and running task each retain one reference, with the caller release
following the native completion signal. See the retained
[compiler reference](../experiments/swift/EnqueueReference.swift),
[LLVM IR](../experiments/swift/EnqueueReference.ll), and
[calibration manifest](../experiments/swift/EnqueueCalibration.json).

The [native prototype run](evidence/v0.2-enqueued-load-prototype-native.json)
observed peak three outstanding invocation lifetimes in both a successful
three-model batch and a batch containing one missing asset. All three calls
returned in each case, and functions from the successful batch passed a retained
native tensor through two models. The
[native cleanup test](evidence/v0.2-enqueued-load-cleanup-prototype-native.json)
passed error cleanup and five abandoned batches with model counts returning to
baseline. These reports bind the disposable prototype binaries; final integrated
model-batch cleanup also passed in the retained
[integrated lifecycle run](evidence/v0.2-lifecycle-native-observation.json).
The [four-model Krea initializer run](evidence/v0.2-krea-parallel-observation.json)
observed four outstanding initializers and passed all thirteen output hashes.
Model initialization and function materialization are separate phases: overlap
in the initializer phase alone does not establish overlap in the expensive
function-loading phase.

## Function materialization

`Runtime::load_functions` materializes one named function per distinct model
through the same runtime and returns functions in request order:

```rust,no_run
use corsairs::{FunctionLoadRequest, Model, Runtime};

# fn load(runtime: &Runtime, models: Vec<Model>) -> Result<(), corsairs::Error> {
let functions = runtime.load_functions(models.into_iter().map(|model| {
    FunctionLoadRequest { model, name: "main".into() }
}).collect()).wait()?;
# Ok(())
# }
```

The current bounded API rejects repeated model handles within one function
batch, including different names on the same model. Models from another runtime
are rejected. An empty batch returns an empty list. A missing name produces
`Error::FunctionNotFound` after every started native invocation has joined;
successful functions from a failed batch are released. Dropped public tasks
preserve the same join and cleanup guarantees. Ordinary `Model::load_function`
keeps its existing synchronous-call implementation.

The SDK declares `AIModel` and `InferenceFunction` as `Sendable`. The strict
Swift 6 [compiler reference](../experiments/swift/FunctionBatchReference.swift)
accepts a detached concurrent closure that calls the nonmutating synchronous
method with borrowed model/name arguments. Its retained
[SIL](evidence/v0.2-function-batch/reference.sil),
[IR](evidence/v0.2-function-batch/reference.ll), and
[assembly](evidence/v0.2-function-batch/reference.s) establish the synchronous
result/error convention; see the [manifest](evidence/v0.2-function-batch/compiler-manifest.json)
for compiler flags and SDK/source hashes.

A separate Swift task body invokes that synchronous ABI. It does not reinterpret
the method as an async descriptor. The owning Rust worker retains every model,
name and distinct output allocation until all tasks finish. Callbacks use only
stable native addresses and synchronized completion state, and never access the
session's Rust maps or `Rc` owners. An owned synchronous error returns through
`x21`, separately from the outer Void task's successful completion. A scoped
Objective-C pool drains callback temporaries before completion is signaled.

The [function prototype run](evidence/v0.2-function-batch-prototype-native.json)
observed three overlapping native invocation lifetimes on success and two in a
batch containing a missing function; all three calls joined. Returned functions
passed a native tensor through two models correctly. The
[cleanup test](evidence/v0.2-function-batch-cleanup-prototype-native.json) passed
error cleanup and five abandoned batches with no stored functions/models left
over. Those missing-name calls exercise an absent optional result. The separate
[deterministic Swift throw oracle](evidence/v0.2-function-batch/throw-oracle/README.md)
completed 200 invocations with 100 Error payloads created and destroyed, including
abandoned batches; it verifies the same synchronous ABI adapters and join/drop
guards without claiming a real malformed-model throw. The
[integrated lifecycle run](evidence/v0.2-lifecycle-final-native.json) passes the
production tests, and the final Krea function-phase result is described below.
Profiling remains behind `abi-research`; timing
counts overlapping call lifetimes and does not establish backend concurrency.

## Integrated Krea and preparation pairs

The final same-runtime Krea gate batches both loading phases and passes all three
first-segment carries, eight latent steps, final latent, and decoded pixels.
Its [independent verification](evidence/v0.2-krea/parallel-functions-payload-verification.json)
rehashes all 13 payloads and reconstructs peak four overlapping invocation
lifetimes in each phase, with four entries, four returns, and zero active after
each join. See the [full report](evidence/v0.2-krea/eight-step-parallel-functions.json)
and [native observation](evidence/v0.2-krea-parallel-functions-native.json).

Three separate load-only pairs measure serial versus dual-phase batch preparation
on the [same final build](evidence/v0.2-krea/load-paired/build.json):

| Pair | Execution order | Serial preparation, s | Batch preparation, s |
| --- | --- | ---: | ---: |
| 1 | Serial, batch | 1.741641 | 0.757413 |
| 2 | Batch, serial | 1.778410 | 0.753073 |
| 3 | Serial, batch | 1.759193 | 0.755380 |

Observed medians were **1.759 seconds serial and 0.755 seconds batch**, with
higher child RSS for batch loading in all three pairs. Median counters were
15,911,682,048 bytes serial and 24,273,190,912 bytes batch: a difference of
8,361,508,864 bytes, or **8.36 GB (7.79 GiB)**. This tradeoff is part of the result;
batching is not an established memory reduction. The
[aggregate](evidence/v0.2-krea/load-paired/aggregate.json) and
[phase verification](evidence/v0.2-krea/load-paired/verification.json) retain all
six reports and independently confirm peak four in both batch phases on every
pair. The [benchmark notes](benchmarks.md#v02-serialbatch-preparation-pairs)
include every RSS observation and timing boundary.

Each arm uses a fresh native process and fresh checker, loads the four models and
functions, checks signatures, then releases/flushes them without inference.
Source bytes are verified before timing and SDK/OS/filesystem caches are retained;
these are not cold starts. RSS is the Darwin cumulative child high-water counter
within each checker, including preparation helpers, rather than separate Metal
allocation accounting. System/thermal/cache state was not controlled or sampled.
Three alternating pairs on one host do not establish a general startup or
full-render performance guarantee.
