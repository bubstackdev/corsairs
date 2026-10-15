# Minimal internal explicit-stream repair

Independent design assessment; no production edits. The [migration observation](migration-checks.json) demonstrates both an NDArray input and a ready NDArray output reused as input to encode. It supports a repair candidate for the run/internal-completion contrast; it does not establish a definitive SDK cause or qualify arbitrary graphs.

## Recommended boundary

Use one **lazy, session-owned queue/ComputeStream** for stateless GPU-preferred owned/retained calls. Keep it on the existing worker and preserve the model's requested specialization options. A common helper accepts owned/borrowed prepared NDArrays and returns ready owned NDArrays; host bytes are copied only at the existing owned-input upload/owned-output download boundaries. Retained chains need no Rust payload round trip.

Prefer all stateless GPU-preferred calls over a size-dependent route: it removes an arbitrary dispatch threshold and covers dynamic outputs whose byte count cannot be known beforehand. CPU-only continues through run. This changes tiny-GPU overhead and warrants a fresh exact-parity/latency gate. Routing only large or dynamic signatures preserves more legacy behavior, but its admission predicate must cover every input/state/output descriptor and actual input extent; checking inputs alone misses a small-input/large-output graph.

Store the requested compute policy on model/function records, including batched load/materialization insertions. Do not infer it from array size or the existence of a Metal queue. A GPU preference still permits framework-controlled operation placement.

## Ownership and common engine

1. Validate names/dtypes/fixed dimensions and resolve all required support before submission. Obtain a retained local reference to the persistent stream before borrowing function/input records.
2. For each immutable retained NDArray, create an owned VWT-slot-2 copy for the calibrated consuming `AsyncValue.init(NDArray)` constructor. The original tensor record stays initialized. Keep the resulting futures and all native input owners through completion and error cleanup.
3. Reuse the existing dictionary/encode/throwing-readiness ABI. The required sequence is encode → actual stream/queue fence → readiness for **every** output → actual stream/queue fence again. The second fence is part of the passing Swift probe and is absent from the current production Metal helper.
4. Capture readiness/descriptor failures without returning early; establish the final fence before dropping any prepared input, output, future or borrowed owner. An inability to establish completion after submission must keep the current fail-closed behavior, rather than return while resources may be used.
5. Return owned ready NDArrays. A future getter returns its own NDArray ownership, so the future can be released after final completion. Existing owned code may then download; retained code installs values using its existing shape/stride/dtype checks, all-ID-before-insert rule and lineage union/global inference-origin policy.

The cleanest reusable engine works over prepared native future values and returns ready arrays without inserting public Metal store IDs. If a minimal bridge instead reuses current `metal_encode` through temporary private ValueRecords, use `Encoded { future, array }` with **two** VWT copies: one retained array owner and one consumed into the future. Remove all private input/output IDs on success and every error path. Extract or copy ready output arrays before removing their records. Do not bypass regular tensor lineage or conflate its origins with Metal buffer origins. A deliberately persistent internal queue must not look like a leaked public queue in store-count tests.

## Stateful boundary

Do not assume a copied NDArray used to construct AsyncMutableValue will update the original record through copy-on-write. A real stateful adaptation moves exclusive state NDArrays into mutable futures, awaits their consuming readiness, and restores returned NDArrays/metadata to the same public state identities on both success and supported native-error outcomes. Preserve mutable-alias rejection and native error ownership.

For this stateless-first repair, reject large/unbounded stateful GPU cases before dispatch until that protocol is implemented and tested; retain the established stateful path only inside its documented qualified envelope. Unknown output bounds need an explicit policy, rather than a check after execution. Public explicit-buffer Metal state paths have different ownership and must retain their own qualification/limits. No new blanket byte-only backend limit is inferred.

The integration gate should cover both compute settings, six dtypes, scalar/empty/strided outputs, dynamic signatures, multiple outputs, errors/dropped futures, regular tensor lineage, model/function batch loading, exact large RGB immediate readback/chaining and the existing H3/Krea hashes. Existing public Metal app-queue ordering and lifetime tests must continue to pass. Record the new helper's extra waits/fences in performance measurements.
