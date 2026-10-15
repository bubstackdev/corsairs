# Metal execution ABI research and native proofs

This is compiler and SDK evidence for macOS 27 arm64. [MetalReference.swift](../experiments/swift/MetalReference.swift) compiles to retained [IR](evidence/v0.2-metal-proof/metal.ll), [SIL](evidence/v0.2-metal-proof/metal.sil), and [assembly](evidence/v0.2-metal-proof/metal.s). The [manifest](evidence/v0.2-metal-proof/compiler-manifest.json) pins these outputs, source files, SDK interfaces/headers, and standalone Rust build records. The standalone proof subsequently passed complete native runs in [release, one cycle](evidence/v0.2-metal-proof/release-one-native.json), [release, 100 cycles](evidence/v0.2-metal-proof/release-hundred-native.json), and [debug, 100 cycles](evidence/v0.2-metal-proof/debug-hundred-retry-native.json). Each verified exact shared-buffer and readiness-NDArray output bytes and one fenced `CoreAIRuntime.CoreAIError`. The first debug observation hit its event limit and is not counted as a pass. The production ownership API is described separately in [Metal ownership](metal-ownership.md).

## Swift contracts

All symbols below begin `$s13CoreAIRuntime`. Ordinary metadata accessors use request 0 and the existing complete metadata/state response. Class constructors return an owned object reference in x0; class metadata goes in x20. Imported Objective-C Metal protocol values lower to one object pointer, without a Swift witness-table argument.

| Symbol suffix | Lowered contract |
| --- | --- |
| `13ComputeStreamC12commandQueueACSo010MTLCommandF0_p_tcfC` | x0=consumed queue +1, x20=ComputeStream metadata; owned stream object in x0. Retain an additional queue reference when the application keeps its own queue. |
| `13ComputeStreamC20currentWorkCompletedyyYaFTu` | Nonthrowing async descriptor; x20=borrowed stream object, x22=child context, no ordinary arguments. The existing task/continuation gate can await it. |
| `17InferenceFunctionV10AsyncValueC12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarL0OSaySiGAqN010InterleaveP0VSgtcfC` | x0=consumed MTLBuffer +1, x1=byte offset, x2=consumed ScalarType storage, x3=consumed shape Array word, x4=consumed strides Array word, x5=consumed Optional<InterleaveLayout> storage; x20=AsyncValue metadata; owned object returned in x0. |
| `17InferenceFunctionV17AsyncMutableValueV12unsafeBuffer10byteOffset10scalarType5shape7strides16interleaveLayoutAESo9MTLBuffer_p_SiAA7NDArrayV06ScalarM0OSaySiGAqN010InterleaveQ0VSgtcfC` | Same ordinary x0..x5 arguments/consumption, x8=fresh runtime-sized AsyncMutableValue storage; no class metadata self. |
| `17InferenceFunctionV10AsyncValueCyAeA7NDArrayVcfC` | x0=consumed NDArray storage, x20=AsyncValue metadata; owned object returned in x0. |
| `17InferenceFunctionV17AsyncMutableValueVyAeA7NDArrayVcfC` | x0=consumed NDArray storage; x8=fresh AsyncMutableValue. |
| `17InferenceFunctionV17AsyncMutableViewsVAEycfC` | x8=fresh runtime-sized empty views container. |
| `17InferenceFunctionV17AsyncMutableViewsV6insert_3foryAC0eF5ValueVz_SStF` | x0=inout AsyncMutableValue storage, x1/x2=borrowed String, x20=inout views. The views borrow the mutable value. |
| `17InferenceFunctionV6encode6inputs6states11outputViews2toSDySSAC10AsyncValueCGAK_AC0k7MutableI0VnAMnAA13ComputeStreamCtKF` | Sync throwing: x0=borrowed input Dictionary word, x1=consumed state views storage, x2=consumed output views storage, x3=borrowed stream object, x20=borrowed function storage, x21=0 on entry. On success x0=owned output Dictionary; on error x21=owned Error and x0 is not an owned result. |
| `17InferenceFunctionV10AsyncValueC7ndArrayAA7NDArrayVSgvgTu` | Throwing async: x0=Optional<NDArray> result storage, x20=borrowed AsyncValue object, x22=child; owned error in x20 on resume. |
| `17InferenceFunctionV17AsyncMutableValueV7ndArrayAA7NDArrayVSgvgTu` | Same result/continuation shape, but entry x20 is **consumed AsyncMutableValue storage**, rather than an object reference. Mark that value consumed after a started call completes on either outcome. |

Construct the absent interleave argument using the InterleaveLayout payload VWT slot7 `(optionalStorage, tag=1, emptyCases=1, payloadMetadata)`. The compiler emits this sequence. Zero-filled storage is not an established Optional representation. Use the existing generic Int array construction for shapes and empty strides.

There is no owning `NDArray(metalBuffer:)` initializer in this inspected interface. The similarly named Metal-buffer initializers belong to `NDArray.RawView` and `MutableRawView` and borrow their buffer. Owning async input/output values use the consuming `unsafeBuffer` initializers above.

## Dictionary and Objective-C contracts

The proof uses public generic Dictionary operations, rather than object-layout guesses:

| Swift symbol | Lowering |
| --- | --- |
| `$sS2Dyxq_GycfC` | x0=String metadata address `$sSSN`, x1=AsyncValue class metadata, x2=String Hashable witness address `$sSSSHsWP`; owned empty Dictionary word returned in x0. |
| `$sSDMa` | x0=request0, x1=String metadata, x2=AsyncValue metadata, x3=String Hashable witness; metadata/state returned in x0/x1. |
| `$sSDyq_Sgxcis` | x0=consumed Optional<AsyncValue> storage, x1=consumed String key storage, x2=Dictionary metadata, x20=inout Dictionary word address. Both argument values are consumed. |
| `$sSD11removeValue6forKeyq_Sgx_tF` | x8=Optional<AsyncValue> result, x0=borrowed String key storage, x1=Dictionary metadata, x20=inout Dictionary word address. |

Optional/class values and Dictionary storage can use their complete metadata/VWT. A retained AsyncValue copied into an Optional supplies the dictionary's independent ownership; the key setter also consumes its String. Do not run those consumed argument destructors again. Owned Dictionary words use bridge-object release; owned native Swift class objects use Swift reference release.

Installed Metal headers declare `MTLCreateSystemDefaultDevice` as returning a retained nullable Objective-C object. Swift compiler output confirms `newCommandQueue` and `newBufferWithLength:options:` also return owned objects. Shared storage options equal zero in the installed header and emitted call. Objective-C dispatch uses receiver/selector in x0/x1, with length/options in x2/x3. `contents` returns a borrowed pointer; `length` returns a word. Additional [property compiler evidence](evidence/v0.2-metal-properties/manifest.json) establishes `device`, `storageMode`, and `status` dispatch. Keep the buffer alive and prevent concurrent GPU/CPU access while using its mapping. The application can create one queue and pass an additional retained reference into its long-lived ComputeStream.

## Completion and ownership boundary

Apple documents that [encode](https://developer.apple.com/documentation/coreai/inferencefunction/encode(inputs:states:outputviews:to:)) may return while inference continues, and supports feeding its returned async outputs into subsequent encodes. Explicit output bindings are updated in place and omitted from the returned dictionary; every declared state requires a state view. [currentWorkCompleted](https://developer.apple.com/documentation/coreai/computestream/currentworkcompleted()) waits for previously encoded stream work. These are separate from successful deferred result retrieval: the stream fence is nonthrowing, while async NDArray getters throw.

The production safe layer retains stream/queue, function/model, inputs, mutable values, and buffers until completion, even after a dropped public future or an encode error. CPU mapping/readback waits for a fence and throwing result readiness. It checks input/output/state alias restrictions, device identity, shared-storage bounds, offset/alignment, and shape/dtype before unsafe native buffer construction. Explicit mutable state/output bindings require fixed descriptor shapes; dynamic outputs use automatic allocation. The initial API fences each inference, preserving a persistent application queue while limiting pipelining.

Externally supplied Metal objects require an explicit unsafe import contract covering validity, retention, device compatibility, aliasing, concurrent writes, and lifetime through queued work. Backing storage must remain mapped, initialized and nonpurgeable for all retained owners/jobs: a retained buffer alone does not prevent purge/discard, no-copy backing invalidation, or racing application access. The implementation uses existing system Metal/Objective-C runtimes and verified C/Swift calls, with no third-party dependencies or production Swift wrapper.

## Standalone proof and remaining gates

[build_metal_proof.py](../scripts/build_metal_proof.py) copies and hashes current crate sources under `target/metal-proof/source`, adding the [backend](../experiments/rust/metal_proof_backend.rs) only to that disposable copy. Its [driver](../experiments/rust/metal_proof.rs) loads the tiny float32 `[2,3]` x+x model, creates one queue/stream and two persistent shared buffers, binds output `y`, fences, awaits throwing mutable-output readiness, and compares direct buffer bytes plus materialized NDArray bytes. A final deliberately missing input must throw; its work is drained before cleanup. A failed post-encode fence aborts rather than freeing potentially pending storage. Debug/release builds and strict clippy pass; compilation performs no native execution.

```sh
python3 scripts/build_metal_proof.py
python3 scripts/build_metal_proof.py --release
# Execute only in the native runner after review:
target/metal-proof/build/release/corsairs-metal-proof \
  fixtures/parity-v01/double_float32/model.aimodel 1
```

The standalone native runs establish their fixed x+x fixture, shared output binding, readiness and encode-error fence. The subsequent [production core matrix](evidence/v0.2-core/checks-metal.json) passed 64 Metal configurations per debug/release profile; [lifecycle execution](evidence/v0.2-lifecycle-native-observation.json) passed retained import/export, repeated calls, chaining and abandoned-job cleanup. [Krea execution](evidence/v0.2-krea-metal-observation.json) matched recorded reference hashes with one persistent queue and reused output bindings. These reports pin their own sources/builds and do not retroactively extend the standalone proof.

The [application kernel observation](evidence/v0.2-metal-app-kernel-native.json) separately passed exit 0: a test-only Metal kernel submitted on the exported queue changed input to 3×, its command moved from status 2 (committed) before `MetalQueue::fence` to status 4 (completed) afterward, and the next Core AI x+x result matched 6× without a host write after the kernel. Its [initial build manifest](evidence/v0.2-metal-app/release-initial-build.json) and [initial helper source](evidence/v0.2-metal-app/MetalApplicationKernel-initial.m) retain the executed version. The helper's [drain-on-release revision](evidence/v0.2-metal-app/release-drain-build.json), paired with the unchanged Rust executable, also [passed native execution](evidence/v0.2-metal-app-kernel-drain-native.json), exit 0 with complete coverage and the same status 2→4 and exact values. That rerun covers the normal path; the explicit release wait also drains early-error cleanup, without an injected GPU-failure observation. The helper is never loaded by production.

Arbitrary deferred errors, private/managed buffers, different-object aliasing, and cross-queue external concurrency remain outside these observations or the supported safe boundary. Compiler acceptance and these functional fixtures do not establish zero-copy materialization or a performance benefit.
