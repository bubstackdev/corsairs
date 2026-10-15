# Stream repair and GPU cap: independent source review

Reviewed 2026-10-15. Scope: current production stream dispatch, native value
ownership, private ID cleanup, per-model compute propagation, readiness error
ordering and the 2 GiB accepted-value/referenced-span policy. Read-only review;
no build, native launch, source edit, commit or publication was performed.

**No unresolved concrete defect found in the source snapshot below.** This is a
bounded source review, not a claim that every framework graph or shape is safe.
Native qualification remains the release owner's separate evidence.

## Findings resolved during review

1. **Readiness error destruction preceded the final fence.** The previous helper
   could project/release a Swift error or destroy an initialized optional result
   before the post-readiness fence. The current
   [helper](../../../crates/corsairs-abi/src/native/owned/metal.rs#L572) retains
   the raw `Result`, owned native error pointer and initialized result through
   `metal_fence_record`; only then does it project a native/lifecycle error or
   consume the optional. Preflight metadata failures occur before starting that
   getter. A failure to establish completion still aborts, rather than releasing
   resources whose completion is unknown.
2. **Stateful returned native output span bypassed the new cap.** Descriptor
   preflight restricts this path to fixed signatures within 1 GiB, but a fixed
   small shape alone does not restrict a padded returned NDArray's stride span.
   The initial patch checked actual stateful output shape/dtype without applying
   `validate_gpu_handle`. The current
   [returned-handle path](../../../crates/corsairs-abi/src/native/owned/handles.rs#L348)
   checks actual shape and referenced span before publication. The legacy
   [owned output](../../../crates/corsairs-abi/src/native/owned.rs#L1210),
   output-view and returned-state paths likewise check native metadata before
   host copying. This was a source-reachable policy gap; no native padded-output
   reproduction is claimed.

## Ownership and bounds checked

- [Single model initialization](../../../crates/corsairs-abi/src/native/owned.rs#L519)
  and [batch commit](../../../crates/corsairs-abi/src/native/owned/batch.rs#L249)
  retain the requested compute policy with each model. Function dispatch obtains
  that model's policy, including a function loaded from a model batch.
- The [private stream bridge](../../../crates/corsairs-abi/src/native/owned/metal.rs#L1041)
  retains a persistent queue and uses initialized Swift VWT copies for the
  NDArray-to-AsyncValue constructor. Each inserted private input ID is tracked
  immediately; every returned private output ID is tracked before extraction.
  All transaction-private values and the temporary public-queue-map entry are
  removed after every `Result`. The persistent queue intentionally survives.
  Copied returned NDArrays own their storage after those private IDs are removed.
- The [owned bridge](../../../crates/corsairs-abi/src/native/owned/run_stream.rs#L129)
  tracks every uploaded input and all returned output IDs before fallible host
  downloads, and removes them on success or error. Retained output insertion
  allocates all public IDs before committing records. Mutable states are restored
  before error propagation.
- The [cap helper](../../../crates/corsairs-abi/src/native/owned/handles.rs#L437)
  checks logical payload separately from checked nonnegative-stride extent.
  This covers small packed values with large padded spans, and large broadcast
  values with short spans. Negative strides remain unsupported. Empty shapes
  preserve the shared nonzero-axis product guard; empty values touch zero bytes.
- A Metal `BufferRecord.bytes` is the contiguous **view's required range**, not
  the underlying MTLBuffer allocation length. Its
  [construction](../../../crates/corsairs-abi/src/native/owned/metal.rs#L324)
  independently checks `offset + bytes`, allocation length, address addition,
  storage mode, device and scalar alignment. Passing a small view inside a larger
  allocation is consistent with the policy and is not a cap bypass. Strided
  encoded/native values instead use the checked actual NDArray span.
- Fixed descriptors and concrete inputs/bindings are checked before dispatch.
  Automatic outputs are checked after throwing readiness and its final fence,
  before store insertion or host-copy allocation. The cap does not bound graph
  intermediates or total GPU memory: an oversized dynamic result can execute
  before typed rejection. Stateful convenience calls preserve the tighter fixed
  1 GiB signature envelope; CPU dispatch retains its existing path.

## Reviewed SHA-256 identities

These hashes include the two fixes above and the test-only private stream
identity accessor. Recheck them if production sources change.

| Workspace path | SHA-256 |
| --- | --- |
| `crates/corsairs-abi/src/dtype.rs` | `5b1d11dfad12328f97a05bb5f02480d88552920db301473ce37700888dc877d4` |
| `crates/corsairs-abi/src/native/owned.rs` | `c4cd3290b62430c32783305c8ac7297beddafc4998e05e843a02457031b9e527` |
| `crates/corsairs-abi/src/native/owned/batch.rs` | `afed7d4c972bcb2abad7f56f2926d536c84b76649f028de0812c3d321d137e44` |
| `crates/corsairs-abi/src/native/owned/handles.rs` | `f593c3e7c946c5a2e59d6519b8dee5b528b80fa628ff2de46cc41493452e59b7` |
| `crates/corsairs-abi/src/native/owned/metal.rs` | `e2ac48cb571f5bb69da31ce8faf38eb2df54f9859100877bcbfcd073770f31c4` |
| `crates/corsairs-abi/src/native/owned/run_stream.rs` | `c5867088ad087b1811e915d556b946f26c9fcb0897cf9ec8f35b6e8ad81c22bd` |
