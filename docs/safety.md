# Safety and ownership

This document records the experimental foundation and current ownership boundary. The `corsairs` crate incorporates the ABI implementation as a private native module, with research access behind `abi-research`. The published v0.1 facade and worker passed the recorded native release checks and [scoped source/contract review](evidence/v0.1-safety-review.md). That historical review does not cover the new v0.2 modules. It discloses the reviewer's implementation contributions and is not an external audit or proof of memory safety.

## Safe boundary

The ordinary API accepts owned Rust data and opaque retained handles. A dedicated worker creates, uses, and destroys native model/function/tensor values. Queued requests contain Rust tensor bytes, checked shapes/dtypes, names, compute choices, and session IDs. Native completion may use Apple's runtime threads internally, under the verified async call contract. Explicit model batches own disjoint argument/result allocations while native loads overlap, then join every started operation before reflection or cleanup.

Unsafe Metal import/export methods are an explicit foreign-pointer boundary. Imported Objective-C queue/buffer objects are retained immediately, before a request is queued. Their narrowly scoped owner is `Send` under the Metal protocol/thread-safety and caller-supplied import contract; native Swift values remain worker-confined. The application must coordinate external GPU work, initialization, distinct-object heap aliasing, and CPU access. Safe methods expose no borrowed mutable CPU mapping.

Tensor construction checks rank/dimensions, element-count multiplication, byte count, dtype representation, and boolean byte encoding. Rank remains limited to 64. Storage and CPU execution accept at most 4 GiB per tensor. GPU-preferred inference accepts at most 2 GiB per concrete tensor and referenced storage span. Fixed signatures and concrete inputs/bindings are checked before dispatch; dynamic outputs after fenced readiness and before host copying or publication. This accepted-result policy does not bound unknown intermediate tensors, graph working memory, allocation, or execution time. Stateful owned/native GPU calls require fixed signatures within 1 GiB. [Large qualification](v0.3-large-tensors.md) records the supported configurations and failed 4.27 GB lifecycle observation. Dynamic signature dimensions are retained as `None`; every execution supplies concrete shapes and checks names, dtypes, ranks, and fixed dimensions. Returned native tensors must have concrete shapes. Non-tensor descriptors remain unsupported.

Owned `Tensor` values use contiguous host storage. `Float16` and `BFloat16` have distinct dtype identities and preserve raw scalar bits; BF16 widening uses an exact bit shift and numerical narrowing has a documented NaN policy. `TensorHandle` retains an NDArray, and its clones share contents. Native mutable-state checks reject overlapping possible-alias lineages, including a reserved origin shared by all inference-produced arrays. This conservatism can reject independent allocations. Explicit downloads pack checked nonnegative strides into row-major storage; negative strides are rejected until their native origin contract is established. See [native tensor ownership](native-tensors.md).

The Metal path retains its queue/stream, function/model, input values, buffers, and mutable bindings until completion. Each encode currently fences and invokes throwing readiness checks before publication. An encode error can follow partial submission, so error cleanup also fences. Failure to establish a post-submission fence aborts instead of freeing possibly pending resources. Owned shared buffers are initialized; imports check device, storage mode, byte bounds, and scalar alignment. Explicit mutable bindings require fixed descriptor shapes, avoiding an unproven dynamic-output buffer-size contract. See [the Metal ABI contracts](metal-abi.md).

Arbitrary symbol invocation remains private in the default build. The explicit `abi-research` feature exposes unsafe probes for investigation, outside the normal facade.

The safe public API must not turn a native precondition failure into a Rust-safety promise. Invalid user requests must yield typed errors before an unsafe native call. Descriptor or capability information that cannot be verified must produce an unsupported-feature error or remain outside the safe subset.

## Established native contracts

- Native value allocation uses the runtime metadata's stride and alignment. Allocation and initialization are tracked separately. A destructor runs only for a fully initialized value that has not transferred ownership.
- Consuming native arguments relinquish the native value on the documented success and error paths; their Rust allocation remains owned and is freed separately. Optional payload moves use native value witnesses.
- Native metadata and values borrow the framework lifetime. Symbol resolution does not grant a generic calling convention; each assembly thunk must correspond to a documented, compiler-verified signature.
- Mutable tensor access is exclusive and scoped. Destroy the mutable view before creating an immutable view or starting inference. Copy initialized bytes while the native view and its owner remain alive; no borrowed native pointer escapes.
- Synchronous Swift throws return an owned error through x21; asynchronous throws use x20. Project error information while the error is live and balance the owned reference with `swift_errorRelease`.
- A real Swift task owns a child async context allocated/deallocated through Swift's task allocator. A post-native-completion wrapper signals Rust only after native task completion has run. Native buffers and argument/result storage remain alive until this signal.

See [the ABI ledger](abi-contracts.md) for exact symbols, register assignments, ownership notes, and supporting compiler references. [Experiment 004](experiment-004.md) records the tested implementation and limits.

The pinned b3 [API inventory](../fixtures/parity-v01/API-INVENTORY.md) defines supported/deferred scope and links its Rust validation; its labels are not a safety proof. The [differential fixture suite](../fixtures/parity-v01/README.md) provides exact Python output/state goldens for both compute selections. Complete Rust [debug](evidence/v0.1/checks-debug.json) and [release](evidence/v0.1/checks-release.json) comparisons pass the recorded grid.

## Futures, shutdown, and failure paths

Submission starts immediately; polling is not needed to keep a request alive. Dropping a public future detaches interest in its result while the worker owns the queued/running request, native arguments, result storage, and completion state. The completion path still destroys/discards an unobserved result normally. Dropping a future does not cancel native work. `Task::cancel_handle` can prevent a request that is still queued: the cancelled task resolves immediately, and the worker later drops the request's captured inputs under its causal root, so `drain()` still covers their release. A request the worker has claimed always runs to completion; Core AI has no cancellation path ([investigation](cancellation.md)). Final handle releases are queued on the owning worker. `Runtime::flush()` is a queue marker; release jobs caused by preceding jobs can follow it. `Runtime::drain()` captures a submission boundary and joins preceding jobs plus their transitive cleanup. Later independent submissions and handles the caller still retains are outside that boundary. Neither operation promises Core AI cache eviction or a particular resident memory decrease.

The experiment deliberately has no timeout that frees live task state. It pins the existing Swift concurrency image once for process lifetime with `RTLD_NODELETE`, because an executor epilogue can execute after completion signaling. Caller/callback synchronization state has independent owned references. The safe layer must preserve these lifetimes through shutdown and error handling.

No Rust panic may unwind through a C/Swift callback or assembly boundary. Review callback allocation, synchronization poisoning, worker panic, channel disconnect, startup failure, and process-shutdown behavior. A closed request channel must not cause destruction of values still owned by an active native operation. Errors should preserve useful native identity/detail while avoiding dependence on a particular localized error message.

The worker resolves pending requests after a Rust worker panic or channel failure. Wakers run outside completion locks. A pending synchronous wait attempted from that same worker returns `ReentrantWait`; an already-ready result remains readable there. Rust panic handling does not contain native framework traps, aborts, hangs, or hostile model parsing.

## Required validation

Release validation covers the six supported tensor dtypes, malformed requests, async loading errors, model/function/tensor destruction order, repeated load/drop, named-state sequences, and future drops while queued and while work is active. Consumer examples forbid unsafe code. The retained review inspects the safe-to-unsafe transitions, native thread confinement, and async ownership protocol.

The retained [native dropped-future test](evidence/v0.1-native-drop-counts.json) passed after model/function futures were discarded and queued releases were flushed. The [binary16 conversion comparison](evidence/v0.1-float16-conversion.json) checks 1,386,555 vectors in debug and release against NumPy, with exact finite/infinity conversion and explicit NaN class/sign rules. Complete native [debug](evidence/v0.1/checks-debug.json) and [release](evidence/v0.1/checks-release.json) suites each pass 40,000 checked inferences, 100 load/drop cycles per compute selection, and 100 of each future-drop kind per selection. [Malformed-asset tests](evidence/v0.1/malformed-assets.json) check three bad-asset variants under both selections and recovery through a valid load; [the native run](evidence/v0.1/native-malformed-and-drops.json) retains the additional handle-count test. [Final package verification](evidence/v0.1/package-verification.json) passes extracted-package and isolated default-feature consumer examples, all forbidding unsafe code.

The retained stress results exceed the 10,000-cycle release gate and use matching Python configurations with explicit numerical comparison rules. Successful destructor/reference counts are useful evidence but do not independently prove absence of leaks, aliasing errors, races, or use-after-free. A debugger observation is not a performance benchmark. Unverified behavior outside the reviewed v0.1 boundary remains deferred in [the release contract](v0.1-release.md).

## v0.3 stream and size policy review

The [focused ownership/cap review](evidence/v0.3-release-preparation/stream-cap-review.md)
checks the final stream bridge, returned-value span validation and error/result
retention through readiness fences. Stateful returned spans and pre-fence error
release findings were corrected before final qualification. This is a scoped
source review, not an external audit or proof of general framework safety.
[Final qualification and known native exclusions](v0.3-release.md) retain the
concrete bounds, failed diagnostics and selected passing observations.
