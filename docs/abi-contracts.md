# Verified ABI contracts

This ledger records the macOS 27 / arm64 contracts used by the experiments and the v0.1 owned API. It is not a general declaration generator. Existing Swift framework code and runtime libraries execute in the Rust process; no custom Swift wrapper executes there. The supported release subset and its additional descriptor/state contracts are recorded below.

## Call mechanism

Stable Rust inline ARM64 assembly calls dynamically resolved existing symbols. Each call shape explicitly places arguments and results in registers, avoiding Rust's experimental Swift type classification. Rust's C calling convention is used only for functions independently established to have a C ABI.

`arm64::metadata_accessor` supplies x0 and captures x0/x1. `arm64::call_sync` supplies x0–x2, optional x8 indirect result, and optional x20 self, returning x0. `call_sync_pair` also captures x1. `call_throwing` initializes x21 to zero and captures the owned synchronous error object there. All declare C caller-saved registers and Swift-specific x20/x21/x22 clobbers. No read-only/no-memory/no-stack promise is made. These synchronous helpers never call an async entry; `async_task.rs` uses separate native task/continuation machinery described below.

Compiler references: [TensorReference.swift](../experiments/swift/TensorReference.swift), [ConventionReference.swift](../experiments/swift/ConventionReference.swift). Regenerate IR with `python3 scripts/check.py`. Unoptimized IR is retained for generic Array accessors whose optimized implementations inline.

## Symbols used by the first experiment

| Symbol suffix or name | Lowered contract | Ownership and verification |
| --- | --- | --- |
| `$s13CoreAIRuntime7NDArrayVMa` | x0=request; x0=metadata, x1=state | Blocking request 0; require state 0. Runtime executed, Swift layout oracle agrees. |
| `$s13CoreAIRuntime7NDArrayV10ScalarTypeOMa` | Same metadata contract | Runtime executed, enum witnesses checked. |
| `$s13CoreAIRuntime7AIModelVMa` | Same metadata contract | Runtime-sized initialized model and destruction now verified in Experiment 004. |
| `$s13CoreAIRuntime17InferenceFunctionVMa` | Same metadata contract | Runtime-sized function initialization/Optional movement/destruction verified in Experiment 004. |
| `$sSiN` | Address of global Int metadata | Use symbol address, not the first word stored there. |
| `$sSa9repeating5countSayxGx_SitcfC` | x0=Int address, x1=count, x2=Int metadata; x0=owned Array word | Existing generic Array constructor; creates initialized [2, 2]. |
| `$s13CoreAIRuntime7NDArrayV10ScalarTypeO7float32yA2EmFWC` | Aligned i32 data constant | Load enum tag; do not call it or treat it as enum storage. Observed tag 29; not hardcoded. |
| `$s13CoreAIRuntime7NDArrayV5shape10scalarTypeACSaySiG_AC06ScalarF0OtcfC` | x8=NDArray result, x0=owned Array word, x1=owned indirect ScalarType | Consumes both inputs. Release their raw Rust allocations without destroying the consumed native values. Swift SIL independently establishes ownership. |
| `$s13CoreAIRuntime7NDArrayV5shapeSaySiGvg` | x20=borrowed NDArray address; x0=owned Array word | Balance returned Array with bridge release. |
| `$sSa5countSivg` | x0=Array word, x1=Int metadata; x0=count | Array value self is an ordinary argument, not a swiftself context. |
| `$sSayxSicig` | x8=Int result, x0=index, x1=Array word, x2=Int metadata | Borrow Array; check count before indexing. No array object layout is assumed. |
| `$s13CoreAIRuntime7NDArrayV10scalarTypeAC06ScalarE0Ovg` | x8=ScalarType result, x20=borrowed NDArray address | Initializes result; destroy result after inspection. |
| `swift_bridgeObjectRelease` | C ABI void(Array word) | Exactly once for an owned, unconsumed returned Array. |

## Metadata and value witnesses

Metadata[-1 word] points to its VWT. The 64-bit table has eight function-pointer slots followed by size at byte 64, stride at 72, u32 flags at 80, and extra inhabitant count at 84. Alignment is `(flags & 0xff) + 1`; reject incomplete flag `0x00400000`. Enum witness flag is `0x00200000`.

| Slot | C ABI used | Requirement |
| --- | --- | --- |
| 1, destroy | void(value address, metadata) | Value initialized and not consumed; invalidates value, does not free allocation. |
| 4, initializeWithTake | pointer(destination, source, payload metadata) | Move initialized payload into fresh storage; source becomes uninitialized. |
| 6, getEnumTagSinglePayload | u32(optional address, u32 empty cases, payload metadata) | Matching Optional<Payload>; empty cases=1, zero=Some, one=None. |
| 11, getEnumTag | u32(value address, metadata) | Initialized enum, enum-witness flag present. |
| 12, destructiveProjectEnumData | void(value address, enum metadata) | Matching initialized associated-value enum; project before moving its payload with the payload VWT. The original enum must not subsequently be destroyed. |
| 13, destructiveInjectEnumTag | void(value address, u32 tag, metadata) | Uninitialized storage for the matching payload-free enum case. |

Storage uses runtime stride/alignment. Native initialization and Rust allocation ownership are tracked separately. Local RAII guards destroy initialized values before freeing storage and keep metadata/framework borrows alive. A completed destructor call is not proof that the native runtime has no leaks.

Primary source contracts: [Metadata.h](https://github.com/swiftlang/swift/blob/main/include/swift/ABI/Metadata.h), [MetadataValues.h](https://github.com/swiftlang/swift/blob/main/include/swift/ABI/MetadataValues.h), [ValueWitness.def](https://github.com/swiftlang/swift/blob/main/include/swift/ABI/ValueWitness.def), [ValueWitnessTable.h](https://github.com/swiftlang/swift/blob/main/include/swift/ABI/ValueWitnessTable.h), and [Swift calling convention](https://github.com/swiftlang/swift/blob/main/docs/ABI/CallingConvention.rst). These are corroborated by the installed Swift 6.4 compiler output, not assumed to be identical across future toolchains.

## Initial scoped float32 buffer views

The public inlinable `MutableRawView.mutableBytes` implementation invokes two `@usableFromInline` helpers; [BufferReference.swift](../experiments/swift/BufferReference.swift) confirms the exact emitted calls. These helpers are ABI-public but not directly accessible from arbitrary Swift source. Rust follows that published body without duplicating the native implementation or guessing fields.

| Symbol after `$s13CoreAIRuntime7NDArrayV` | Registers and lifetime |
| --- | --- |
| `14MutableRawViewVMa`, `7RawViewVMa` | Metadata accessor request/response; runtime-sized storage and VWT destruction. |
| `14mutableRawViewAC07MutableeF0VyF` | x8=mutable view output, x20=mutating tensor address; exclusive borrow of tensor. |
| `14MutableRawViewV6_startSvyF` | x20=view address; x0=borrowed writable pointer. |
| `14MutableRawViewV16storageByteCountSiyF` | x20=view address; x0=storage byte count. |
| `7rawViewAC03RawE0VyF` | x8=read-only view output, x20=borrowed tensor address. |
| `7RawViewV5bytess0D4SpanVvg` | x20=view address; x0=borrowed pointer, x1=byte count. |

The probes verify contiguous float32 [2, 2] and [2, 3] cases, require exactly element-count times four bytes and four-byte alignment, and copy into owned Rust output before dropping the view. Input bytes are initialized before reading; inference output bytes are read only after native completion and metadata checks. No native pointer escapes. Mutable and immutable views do not overlap. See [Experiment 002](experiment-002.md) and [Experiment 004](experiment-004.md).

## Synchronous bookmark errors

[ErrorReference.swift](../experiments/swift/ErrorReference.swift) and installed Swift IR/SIL establish:

| Symbol | Register/ownership contract |
| --- | --- |
| `$s10Foundation4DataVACycfC` | No arguments; owned Data words returned in x0/x1. |
| `$sSqMa` | x0=metadata request 0, x1=base type metadata; metadata/state in x0/x1. Used for Optional<AIModel>. |
| `$s13CoreAIRuntime7AIModelV0A11AIDelegatesE17resolvingBookmarkACSg10Foundation4DataV_tKcfC` | x8=optional model result, x0/x1=owned Data words (consumed on success or throw), x21=0 on entry. On throw x21 is an owned Error, and result remains uninitialized. |
| `swift_errorRelease` | C ABI void(Error pointer); release exactly once, including reflection failure paths. |
| `swift_getErrorValue` | C ABI void(Error, scratch-word address, projection address). Projection has three pointers: borrowed payload, type metadata, Error conformance. Keep error and scratch alive. |
| `swift_getDynamicType` | C ABI (payload, static metadata, existential-metatype=true) -> borrowed dynamic metadata. Matches Swift type(of:error). |
| `swift_getTypeName` | Swift ABI x0=metadata,x1=qualified=true; cached UTF-8 pointer/length in x0/x1. Copy bytes; do not release the runtime's cache. |

The successful Optional result would be destroyed with its VWT. On error, only its raw allocation is freed. The tested invalid empty bookmark throws `CoreAIDelegates.AIModelCacheError`; its payload is never reinterpreted as a guessed Rust enum. User-facing error descriptions and the remaining native error surface are not implemented.

Primary contracts: [Error.h](https://github.com/swiftlang/swift/blob/main/include/swift/Runtime/Error.h), [Casting.h](https://github.com/swiftlang/swift/blob/main/include/swift/Runtime/Casting.h), [HeapObject.h](https://github.com/swiftlang/swift/blob/main/include/swift/Runtime/HeapObject.h), and [cached type-name implementation](https://github.com/swiftlang/swift/blob/main/stdlib/public/runtime/Casting.cpp).

## Bounded native Swift task lifecycle

`task.rs` contains a custom descriptor and ARM64 async entry built as part of the Rust executable. It is a real Swift task body and uses Apple's existing task runtime. Its only work is a Rust callback that queries native task identity, followed by a tail call to its runtime-supplied completion. It neither suspends nor captures data.

| Contract | Verified form |
| --- | --- |
| Async descriptor | 8-byte alignment; i32(entry - descriptor), u32 context size 16. Matches compiled throwing-Void leaf. |
| `swift_task_create` | Swift ABI x0=flags 0 (not auto-enqueued), x1=null options, x2=Void metadata, x3=descriptor, x4=null capture; task/context returned in x0/x1. |
| Void metadata | Address of `$sytN` +8, exactly as emitted by installed Swift IR. This adjustment must not be generalized to unrelated metadata symbols. |
| Async entry | x22=native context, x20=null capture, x0=zero-size result storage. Save/restore native context, stack and link register around the Rust callback. |
| Successful async return | Load ResumeParent from [x22+8], set x20=0, tail branch with the original x22. Do not replace x22 with its null root Parent. |
| `swift_task_getCurrent` | Swift ABI, no arguments, borrowed current task pointer returned in x0. |
| `swift_job_run` | Swift ABI x0=unqueued task, x1/x2=generic executor words 0. Establishes real task/executor TLS. |
| Reference ownership | Caller owns task-create result. C `swift_retain` adds running reference before job_run; native completion consumes it. C `swift_release` balances caller reference after job_run returns. |

Only this known nonsuspending body makes return from `job_run` evidence of native task completion. Runtime source shows `completeTaskAndRelease` completes the future and releases the running reference before returning. A body signal before tail completion would not suffice. The probe checks the native pointer inside the body and nil task TLS before/after, rejects nesting inside an existing Swift task, and serializes/clears its callback hook with RAII.

Compiler references: [TaskReference.swift](../experiments/swift/TaskReference.swift). Runtime contracts: [Concurrency.h](https://github.com/swiftlang/swift/blob/main/include/swift/Runtime/Concurrency.h), [Task.h](https://github.com/swiftlang/swift/blob/main/include/swift/ABI/Task.h), [Task.cpp](https://github.com/swiftlang/swift/blob/main/stdlib/public/Concurrency/Task.cpp), and [Actor.cpp](https://github.com/swiftlang/swift/blob/main/stdlib/public/Concurrency/Actor.cpp). See [Experiment 003](experiment-003.md).

## Suspending native calls

`async_task.rs` executes only the signatures verified by [SuspensionReference.swift](../experiments/swift/SuspensionReference.swift), [LoadReference.swift](../experiments/swift/LoadReference.swift), and [InferenceReference.swift](../experiments/swift/InferenceReference.swift). The independent [clang async oracle](../experiments/c/SuspensionReference.c) corroborates register handling and post-native-completion signaling. It is not linked into Rust.

| Contract | Verified form |
| --- | --- |
| Root descriptor/frame | i32 relative entry, u32 size80. Header parent0/resume8; child16; original completion24; owned Arc pointer32; callee arguments40/48/56/64; borrowed self72. Runtime adapter data is at negative offsets. |
| Unscheduled setup | task_create flags0 returns the same context later supplied as x22 to our entry. Install fields before retain+job_run. Caller +1 and running +1 follow the nonsuspending gate's contracts. |
| Child descriptor | Read signed i32 entry offset relative to descriptor address, u32 context size at +4. No low-bit mask. |
| Native allocation | Swift ABI swift_task_alloc x0=size -> x0=child; child[0]=root, child[8]=resume function. swift_task_dealloc x0=child after restoring root x22; strict LIFO. |
| Child entry | Tail branch with x22=child, x0..x3=arguments, x20=borrowed function self when required. |
| Child resume | x22=child; restore parent x22, save async owned error x20 only for throwing callees, deallocate child, tail-call root resume with x20=0. Nonthrowing x20 is unspecified. |
| Task.yield | `$sScTss5NeverORszABRs_rlE5yieldyyYaFZTu`; nonthrowing Void, no arguments. Runtime schedules a continuation; neither thread migration nor a delay is guaranteed. |
| Root completion | Preload original completion and owned Arc before calling original native completion. Only then tail-call the Rust signal callback; never dereference the possibly freed root afterward. |
| Rust completion ownership | Callback consumes its own Arc +1; waiter owns a separate Arc. Condvar predicate loops handle spurious wakes. Callback guard drops before its Arc. Caller task +1 drops after signal. |
| Runtime lifetime | Pin `/usr/lib/swift/libswift_Concurrency.dylib` once using RTLD_NOW/LOCAL/NODELETE (SDK flag0x80); balance dlopen handle while retaining the image for worker epilogues after signal. CoreAI borrow covers every actual CoreAI call/value. |

Internal `await_native` returns Err only before scheduling. On Ok, the child has consumed its declared owned arguments and any returned error transfers to the caller, even if subsequent lifecycle validation fails. There is no timeout/cancellation path that frees outstanding work. The blocking driver rejects execution inside an existing Swift task.

### Split-phase model batches

The v0.2 batch adapter preserves the same root/child/completion layout but
separates starting from joining. After flags-zero task creation and private root
setup, it retains the running reference and calls
`swift_task_enqueueTaskOnExecutor`: x0=task, x1/x2=generic executor `{0,0}`.
The installed [Swift compiler reference](../experiments/swift/EnqueueReference.swift)
and [IR](../experiments/swift/EnqueueReference.ll) corroborate this register
lowering. [The calibration manifest](../experiments/swift/EnqueueCalibration.json)
pins upstream declarations and task lifecycle source; it does not assert an
exact source match to the installed OS runtime. Ordinary `await_native` retains
the existing `swift_job_run` path.

`PendingCall` holds the caller task reference and its own completion Arc until
the post-native-completion join. Dropping an unobserved call joins before
releasing any owned error. A `PreparedBatch` guard joins **all** started loads
before any argument/result/error fields are destroyed, including early return
and Rust unwind paths. Model IDs are allocated before transactional insertion.
Native session ownership never moves to a Rust helper thread. Development
overlap probes measure invocation lifetimes and expose only ordinal task labels;
they do not establish backend compute concurrency. [Model batch evidence and
limits](parallel-loads.md) record the separate native validation.

### Synchronous function bodies on Swift tasks

`async_task/sync_call.rs` uses a distinct root80 entry with no child async
descriptor. Its C callback invokes the existing synchronous throwing
`AIModel.loadFunction(named:)` ABI: x0/x1=borrowed String words,
x8=Optional<InferenceFunction> result storage, x20=borrowed model storage,
x21=owned error result. The
[strict Swift 6 reference](../experiments/swift/FunctionBatchReference.swift)
confirms borrowed arguments and a concurrent detached caller. SDK interfaces,
compiler outputs and their hashes are retained in the
[function calibration manifest](evidence/v0.2-function-batch/compiler-manifest.json).

The callback restores x22/LR/SP and stores any synchronous error separately.
It completes the outer native Void task with x20=0; the existing native
completion wrapper then signals the worker, which joins before reading output
storage or releasing caller ownership. Every started function task joins before
any batch owner/error cleanup, and records enter the session only after all
reflection and ID allocation succeed. Batches currently require distinct model
handles. No `Send` implementation is added for native session/value owners.

## Foundation values and model loading

| Symbol | Register/ownership contract |
| --- | --- |
| `$sSS7cStringSSSPys4Int8VG_tcfC` | x0=NUL-terminated UTF8 pointer; x0/x1=owned String words. Copies input. Release second word with swift_bridgeObjectRelease. |
| `$s10Foundation3URLV15fileURLWithPathACSSh_tcfC` | x8=fresh URL storage, x0/x1=borrowed String words. Metadata from `$s10Foundation3URLVMa`. |
| `$s15CoreAIDelegates21SpecializationOptionsV7cpuOnlyACvgZ` | x8=fresh options result. Metadata from same prefix plus `Ma` after the type's `V`. |
| `$s13CoreAIRuntime7AIModelV0A11AIDelegatesE10contentsOf7optionsAC10Foundation3URLV_AD21SpecializationOptionsVtYaKcfCTu` | Async descriptor; x0=model result address, x1=owned URL storage, x2=owned options storage. Consumes both on success/failure; x20 owned Error? on resume. Model initialized only if error is null. |
| `$s13CoreAIRuntime7AIModelV13functionNamesSaySSGvg` | x20=borrowed initialized model storage -> x0=owned Array<String>. |
| Array<String> access | Public Array count/subscript as above, element metadata `$sSSN`. Subscript writes owned16byte String result through x8. |
| `$sSS11utf8CStrings15ContiguousArrayVys4Int8VGvg` | x0/x1=borrowed String -> x0=owned ContiguousArray<Int8>. Release with swift_release, not bridge release. |
| `$ss15ContiguousArrayV5countSivg`, `$ss15ContiguousArrayVyxSicig` | Borrow array word and `$ss4Int8VN` element metadata. Count includes NUL; indexed getter writes one byte through x8. Validate/remove trailing NUL, copy UTF8 to Rust. |

The missing-asset async path identifies/releases `CoreAIDelegates.AIModelCacheError`, matching Swift. Source/ownership references for the URL constructor are retained in [string.ll](evidence/experiment-004/string.ll); successful loading and repeated cleanup are recorded in [checks.json](evidence/experiment-004/checks.json).

## Named inference calls

Symbols below use prefix `$s13CoreAIRuntime` unless a full name is shown. Nominal Inputs/MutableViews/Outputs/InferenceValue metadata use the ordinary `Ma` contract. Optional metadata uses `$sSqMa` with the matching payload metadata.

| Symbol suffix | Register/ownership contract |
| --- | --- |
| `7AIModelV12loadFunction5namedAA09InferenceE0VSgSS_tKF` | Sync throwing: x8=Optional<InferenceFunction>, x0/x1=borrowed String, x20=borrowed model; x21 owned Error? Result initialized only on null error. |
| `17InferenceFunctionV6InputsVAEycfC` | x8=fresh Inputs result. |
| `17InferenceFunctionV6InputsV6insert_3foryAA7NDArrayV7RawViewVn_SStF` | x0=consumed RawView storage, x1/x2=borrowed String, x20=inout Inputs. Keep underlying tensor immutable and live until Inputs destruction. |
| `17InferenceFunctionV12MutableViewsVAEycfC` | x8=fresh empty MutableViews; initialize separate states/outputViews values. |
| `17InferenceFunctionV3run6inputs6states11outputViewsAC7OutputsVAC6InputsV_AC07MutableI0VnAMntYaKFTu` | Async descriptor: x0=Outputs result, x1=borrowed Inputs storage, x2=consumed states, x3=consumed outputViews, x20=borrowed function, x22=child context. Both mutable view values consumed on success/error. |
| `17InferenceFunctionV7OutputsV5countSivg` | x20=borrowed Outputs -> x0=count. |
| `17InferenceFunctionV7OutputsV6removeyAA0C5ValueVSgSSF` | x8=Optional<InferenceValue>, x0/x1=borrowed name String, x20=inout Outputs. Outputs remains initialized. |
| `14InferenceValueV7ndArrayAA7NDArrayVSgvg` | x8=Optional<NDArray>, x20=consumed InferenceValue storage on either Some/None. |
| `7NDArrayV7stridesSaySiGvg` | x20=borrowed NDArray -> x0=owned Array<Int>; same ownership as shape. |
| `$sSaMa` | x0=request0, x1=Int metadata -> x0=Array<Int> metadata, x1=state0. |
| `$sSayxSiciM` | Public modify coroutine: x0=32byte align8 scratch, x1=index, x2=Array<Int> metadata, x20=inout array word -> x0=resume function, x1=mutable Int pointer. Store through yielded pointer, call resume x0=scratch,x1=false before moving/dropping array. Used to build [2,3]. |

Optional Some extraction uses the payload VWT slot6 with emptyCases1, then slot4 to move into separate payload storage. The Optional becomes uninitialized; only its raw allocation is freed. None remains initialized and is destroyed normally. No enum tag-byte or resilient payload layout is assumed. [InferenceReference.swift](../experiments/swift/InferenceReference.swift) and retained [IR](evidence/experiment-004/inference.ll)/[SIL](evidence/experiment-004/inference.sil) establish these exact signatures and consumption rules.

## v0.1 owned API and additional contracts

The default public API now provides owned `Runtime`, `Model`, `Function`, `Tensor`, named `TensorMap` inputs/state, and `Task` results. [owned.rs](../crates/corsairs-abi/src/native/owned.rs) implements the native object store; [facade.rs](../crates/corsairs-abi/src/facade.rs) and [worker.rs](../crates/corsairs-abi/src/worker.rs) keep its non-Send values on one dedicated thread. Requests/results carry owned Rust data and integer IDs. Pending work retains its model/function and buffers even when its public future is dropped. Functions are released before models, and all native values before their framework handle. The [boundary review](evidence/v0.1-safety-review.md) records the inspected files and limitations.

[OwnedReference.swift](../experiments/swift/OwnedReference.swift), compiled independently of Rust, establishes the additional contracts below. Original [IR](evidence/v0.1/owned-reference.ll), [SIL](evidence/v0.1/owned-reference.sil), [assembly](evidence/v0.1/owned-reference.s), and a [hash/retention manifest](evidence/v0.1/owned-reference-manifest.json) are retained. These compiler outputs establish signatures and ownership; native fixture runs establish observed behavior.

### GPU preference and descriptors

| Symbol | Register/ownership contract |
| --- | --- |
| `$s15CoreAIDelegates15ComputeUnitKindOMa` | Ordinary complete metadata response for the compute-unit enum. |
| `$s15CoreAIDelegates15ComputeUnitKindO3gpuyA2CmFWC` | Exported u32 case tag; inject with this enum's VWT slot13. No hardcoded tag or enum storage layout. |
| `$s15CoreAIDelegates21SpecializationOptionsV24preferredComputeUnitKindAcA0fgH0O_tcfC` | x8=fresh options result, x0=consumed indirect ComputeUnitKind. Uses the same owned options argument in the existing async model initializer. This requests GPU preference and allows fallback; it does not prove GPU execution. |

The following symbols use prefix `$s13CoreAIRuntime`. All descriptor storage uses its own complete nominal metadata/VWT.

| Symbol suffix | Register/ownership contract |
| --- | --- |
| `17InferenceFunctionV10descriptorAA0cD10DescriptorVvg` | x8=fresh InferenceFunctionDescriptor, x20=borrowed function. |
| `27InferenceFunctionDescriptorV4nameSSvg` | x20=borrowed descriptor; owned String words returned in x0/x1. |
| `27InferenceFunctionDescriptorV10inputNamesSaySSGvg`, `27InferenceFunctionDescriptorV11outputNamesSaySSGvg`, `27InferenceFunctionDescriptorV10stateNamesSaySSGvg` | x20=borrowed descriptor; owned Array<String> returned in x0. Read through generic Array accessors and release through bridge release. |
| `27InferenceFunctionDescriptorV05inputE02ofAA0C5ValueV0E0OSgSS_tF`, `27InferenceFunctionDescriptorV06outputE02ofAA0C5ValueV0E0OSgSS_tF`, `27InferenceFunctionDescriptorV05stateE02ofAA0C5ValueV0E0OSgSS_tF` | x8=fresh Optional<InferenceValue.Descriptor>, x0/x1=borrowed name String, x20=borrowed function descriptor. |
| `14InferenceValueV10DescriptorO7ndArrayyAeA07NDArrayE0VcAEmFWC` | Exported u32 associated-case tag. Extract Optional with its payload VWT; inspect Descriptor with its enum VWT11, project with VWT12, then move the NDArrayDescriptor payload with its payload VWT4. Never infer a resilient payload offset. |
| `17NDArrayDescriptorV5shapeSaySiGvg` | x20=borrowed NDArrayDescriptor; owned Array<Int> returned in x0. |
| `17NDArrayDescriptorV10scalarTypeAA0C0V06ScalarF0Ovg` | x8=fresh ScalarType, x20=borrowed NDArrayDescriptor. |
| `17InferenceFunctionV12MutableViewsV6insert_3foryAA7NDArrayV0E7RawViewVn_SStF` | x0=consumed MutableRawView storage, x1/x2=borrowed name String, x20=inout MutableViews. Underlying NDArray remains exclusively borrowed until the view container is consumed/destroyed and the call completes. |

Function inspection copies name/input/output/state descriptors into Rust data. Non-NDArray descriptors, unresolved negative dimensions, and unknown scalar cases return typed `Unsupported` errors before tensor construction. The public descriptor DTO can represent unknown dimensions, but v0.1 native loading rejects them.

### Typed tensors, named state, and copy boundaries

The same NDArray initializer and runtime enum witnesses support float16, float32, int32, int64, and bool. Case tags come from the `$s13CoreAIRuntime7NDArrayV10ScalarTypeO` exports `7float16yA2EmFWC`, `7float32yA2EmFWC`, `5int32yA2EmFWC`, `5int64yA2EmFWC`, and `4boolyA2EmFWC`. Scalars use two, four, four, eight, and one byte respectively. Boolean input bytes must be zero or one. Shape arrays of arbitrary supported rank use the verified repeating constructor plus modify coroutine, rather than Array object layout.

Input/state groups must exactly match declared names, shapes, and dtypes. Checked element/byte counts and the public limits (rank 64, storage 1 GiB, plus bounded nonzero-dimension products even for empty shapes) precede native tensor construction. Public tensors own contiguous little-endian bytes; cloning them makes independent Rust storage. This does not establish general Swift NDArray copy semantics.

Named states use separate initialized NDArrays and exclusive mutable views inserted into a states container. The run call borrows Inputs and consumes both MutableViews containers on success or error. Buffers are declared before dependent containers, keeping view cleanup before buffer cleanup on early errors. On successful native completion, state and output bytes are copied into owned Rust results; returned state can be supplied to the next run. The public v0.1 facade supplies an empty output-view container and uses returned outputs.

Readback verifies shape, supported dtype, canonical row-major strides for nonempty tensors, and exact storage byte count before copying. Nonempty noncontiguous output returns `Unsupported`. Scalar shape `[]` has one element. Zero-element shapes are supported; observed empty `[0,3]` strides are `[0,0]`, so canonical nonempty stride requirements do not apply. Empty copies perform no pointer dereference/copy operation, allowing a null empty span.

[Debug](evidence/v0.1/checks-debug.json) and [release](evidence/v0.1/checks-release.json) public-API drivers each pass the 32 CPU-only/GPU-preferred positive backend cases and 16 negative cases, plus 40,000 stateless/stateful calls and repeated load/drop/abandoned-future checks. The [fixture suite](../fixtures/parity-v01/suite.json) and [backend goldens](../fixtures/parity-v01/backend-goldens.json) retain exact names, shape, dtype, output/state bytes, and backend-specific arithmetic expectations. Coverage includes the five dtypes, scalar and empty tensors, multiple named inputs/outputs, and repeated named accumulator state. It establishes these fixtures and contracts, rather than all supported CoreAI operators. Rust float16 conversion has separate [NumPy differential evidence](evidence/v0.1-float16-conversion.json).

## Remaining unverified contracts

Other scalar types and noncontiguous output layouts, native NDArray sharing/copy behavior, shared Metal buffers, image storage, arbitrary Swift closures/async signatures/executors, cancellation, reference-count leak freedom, the broader native error surface, arbitrary inference operators/models, Rust model authoring, other OS/SDK versions, and other architectures remain unverified. Native crashes, traps, allocation aborts, and hangs are not converted into Rust errors. The safe API's validity remains conditional on the recorded macOS 27 arm64 native contracts.


## v0.3 stateless GPU completion

Stateless GPU-preferred owned/native calls use an owned persistent ComputeStream
and queue. Native NDArray values are retained with Swift VWT initializeWithCopy
(slot 2) into independent value allocations, then passed to the verified consuming
AsyncValue initializer. Ready outputs retain NDArray storage without a Rust byte
roundtrip. All temporary IDs are removed on every Result path; the private queue
survives drain until runtime destruction. Returned errors and initialized optional
results remain owned until the actual post-readiness stream/queue fence completes.
A failure to establish completion after submission aborts rather than release
potentially in-flight owners.

The [compiler/standalone investigation](evidence/v0.3-release-preparation/rgb345-isolation/internal-design.md)
and [final review](evidence/v0.3-release-preparation/stream-cap-review.md)
retain the consuming initializer, value-copy, readiness and ownership contracts.
[Current 4 GiB storage / 2 GiB GPU bounds](v0.3-release.md) supersede the historical
v0.1 owned-copy size statement above. Stateful convenience GPU signatures retain
fixed 1 GiB bounds; explicit Metal state bindings remain available.
