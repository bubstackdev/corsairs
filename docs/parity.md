# Feature and accuracy parity

Corsairs' long-term objective is complete feature and accuracy parity with the published `coreai-core` runtime and graph-authoring API. The implemented v0.1 candidate is a bounded safe Rust inference subset. Its retained evidence establishes that tested subset on one Apple Silicon macOS host; it does not establish total Python API parity.

## Published reference

The acquired and inspected baseline is `coreai-core 1.0.0b3`, wheel `coreai_core-1.0.0b3-cp312-cp312-macosx_26_0_arm64.whl`, SHA-256 `8db70074eb049b0a86bd263e137ea173f3298f7f1b60ec1a7f7c592f4c26c4a9`. The [reference lock](../fixtures/parity-v01/reference-lock.json), retained [PyPI release metadata](../fixtures/parity-v01/reference-pypi.json), [initial native Python report](../fixtures/parity-v01/python-results.initial.json), and [fixture manifest](../fixtures/parity-v01/suite.json) retain package/interpreter/dependency, asset/input/output, and compute identities. Historical b2 experiments remain useful ABI evidence but are not substituted for this b3 baseline.

The [API inventory](../fixtures/parity-v01/API-INVENTORY.md) and its [machine-readable form](../fixtures/parity-v01/api-inventory.json) enumerate public exports and class members, including dynamically exported native members. They record Rust counterparts, bounded supported/deferred scope, and retained validation reports. The runtime inventory contains 18 top-level symbols and 98 entries including members/private declared exports; authoring contains 174 public exports and 305 entries. Private raw `coreai._compiler` escape hatches are outside Apple's versioned public facade.

## Verified v0.1 subset

| Area | Implemented and exercised boundary | Evidence |
| --- | --- | --- |
| Model/function loading | Existing `.aimodel` assets, function enumeration/selection, resolved static named input/output/state descriptors | All sixteen fixtures, both compute configurations, debug and release |
| Tensor values | Owned contiguous float16, float32, int32, int64 and bool; exact bytes, dtype, shape and strides; scalar/empty shapes; wide integers and IEEE special values | Frozen Python goldens and safe Rust differential driver |
| Execution/state | Named inputs/outputs, persistent function across a three-step named accumulator sequence, returned owned updated state, repeated calls | Exact output/state bytes after each step; long stateful stress |
| Compute selection | CPU-only and GPU-preferred specialization | Same asset/input/configuration against b3; preferred GPU is not proof of per-operation GPU execution |
| Safe async ownership | Runtime-independent `.await` and `.wait`, worker-confined native values, owned requests/results, abandoned inference/model/function futures | Public driver forbids unsafe code; future-drop and lifecycle probes |
| Failures | Missing assets/functions/inputs/state, unknown input names, incompatible input dtype/shape and state shape; separate malformed-asset probes | Sixteen typed negative configurations, plus six malformed-asset attempts and healthy-load recovery |
| Platform | Apple Silicon arm64, macOS 27.0.1 build 26A434, recorded SDK/compiler pairing | [Compatibility](compatibility.md) and source/binary build manifest |

Owned tensors are limited to rank 64 and 1 GiB each; empty tensors also have a nonzero-dimension size guard. Static descriptors must resolve to one of the five supported scalar types. Input/state names, ranks, dimensions and dtypes are checked before native execution. Inputs are copied into native storage and completed outputs/state into owned contiguous Rust storage. These bounds define v0.1, rather than the framework's maximum capabilities.

The [debug report](evidence/v0.1/checks-debug.json) and [release report](evidence/v0.1/checks-release.json) each pass all 32 positive backend configurations and 16 typed negative configurations. Each profile also completed 10,000 stateless and 10,000 stateful calls per backend: 40,000 checked stress inferences per profile, 80,000 across both. Each backend/profile additionally exercised 100 load/drop cycles and 100 abandoned futures each for inference, model loading, and function loading. [The build manifest](evidence/v0.1/build-manifest.json) binds exact source/compiler/rlib/driver identities. These runs exercise lifetime behavior through completion; they do not constitute a general proof of leak freedom or every possible concurrency interleaving.

The fixture set covers arithmetic, matrix multiplication, keepdims reduction, gather indexing, reshape, named multi-input execution, a two-layer feedforward graph, five scalar types, scalar and empty tensors, IEEE edge values, wide int64 values, and named state. Broader operation/dtype/layout/model coverage remains future work. Separate [malformed-asset evidence](evidence/v0.1/malformed-assets.json) covers truncated bytecode, nonsensical bytecode, and a plain-text `.aimodel` file under both compute configurations, followed by loading a healthy model/function on each runtime. All six malformed attempts returned typed native failures without trapping, and both recovery loads passed. These probes add specific corrupt-asset coverage beyond the sixteen missing/name/shape/type negative configurations; they do not exhaust malformed metadata or compiler failure modes.

## Comparison rules and backend observations

Rust comparisons use the identical prepared model, input bytes, compute policy and state sequence as Python. [Backend-specific goldens](../fixtures/parity-v01/backend-goldens.json) freeze exact Python bytes and metadata. The safe driver compares output and updated-state values after every step, including signed zeros, NaN payloads and subnormals present in these fixtures. Rust returns owned updated state for the next call, preserving the reference sequence's values and transitions through Rust idioms.

Independent mathematical expectations remain separate. The initial Python GPU-preferred float-edge run canonicalized a quiet NaN payload and flushed a subnormal result to zero, while CPU preserved the mathematical result. That original failed math comparison is retained. An [independent Python repeat](../fixtures/parity-v01/python-results-float_edges-gpu-preferred.json) produced the same bytes, verified in [the stability record](../fixtures/parity-v01/float-edges-stability.json). Debug and release Rust match those exact same-configuration Python bytes. No tolerance was widened to accommodate a Rust mismatch. [Backend semantics](../fixtures/parity-v01/BACKEND-SEMANTICS.md) records the bits, source documentation and limits of the delegate inference.

Negative tests compare failure meaning through typed Rust errors. Python exception classes/text are retained in its reference report; v0.1 does not promise their literal reproduction or native localized error-code access. Native traps, timeouts and environment failures remain failed/unavailable evidence. The ordinary shell's model-cache error does not count as a successful native comparison.

## Deferred full-parity work

| Surface | Deferred behavior |
| --- | --- |
| Tensor/storage breadth | Other scalar types, bfloat/float8/packed low-bit formats, arbitrary strides/views, shared/zero-copy GPU buffers, images/pixel buffers, NumPy/PyTorch/DLPack interoperability |
| Models/assets | Unresolved dynamic shapes, broader model value kinds, asset metadata/summaries/editing, full cache administration and specialization surface |
| Execution | Native cancellation, dependency/event controls, broader concurrent/stateful sequences, representative large-model/decode workloads |
| Compute | Explicit Neural Engine selection, availability enumeration, native allowed/preferred-kind getters, custom specialization/debug settings |
| Diagnostics | Profiling callbacks, intermediate logging, compile identifiers and the complete native error/diagnostic surface |
| Graph authoring | All public graph/type/operation construction, validation, custom Metal kernels, configuration and asset serialization from Rust |
| Compatibility | Other OS/SDK builds, x86_64, iOS and other platforms, and a tested version matrix beyond the recorded pairing |

The named-state fixture uses b3's explicitly identified private graph/handle/token authoring seam because its public graph decorator exposes tensor/image specifications without handle I/O constructors. Its runtime reference uses the published Python API. Preparing a fixture with Python does not establish Rust authoring parity. Dropping a Rust future retains in-flight resources and does not request native cancellation.

## Performance and next gates

The [same-host benchmark](benchmarks.md) records higher current Rust latency than Python on the tiny feedforward round trip. It retains equivalent boundaries, raw samples, identities and launch conditions. No speedup follows from the implementation language; the measured cost breakdown is unresolved.

The [accepted release contract](v0.1-release.md) tracks release-candidate gates. Future parity work should add a Rust counterpart and differential fixture to each deferred inventory entry, expand actual model/operator/layout/negative coverage, establish cancellation/dependency contracts before exposing them, and extend the compatibility matrix with new native evidence. Full authoring must round-trip assets and preserve their execution behavior. Accuracy and feature coverage precede performance claims.
