# Compatibility

The v0.1 target is Apple Silicon on macOS 27. This is a bounded support target, not evidence that every macOS 27 build has the same native behavior. Corsairs calls Apple's existing Core AI and Swift runtime implementations directly. The runtime application embeds no Python and links no custom Swift wrapper.

## Validated release environment

| Component | Investigated value | Evidence limit |
| --- | --- | --- |
| Hardware architecture | arm64, Apple Silicon | No x86_64 ABI support |
| Operating system | macOS 27.0.1, build 26A434 | One recorded OS build |
| SDK | macOS SDK 27, Xcode 27 | Independent Swift compiler references use this SDK |
| Swift compiler | Apple Swift 6.4 | Reference tooling, not a compiler embedded in the application |
| Rust compiler | Rust 1.99.0 | Existing manifests declare 1.99; no older compiler is verified |
| Python reference | `coreai-core 1.0.0b3`, CPython 3.12.14 | Python executed 32 positive configurations and 16 expected errors; both Rust profiles matched the 32 frozen Python configurations and passed the negative cases |

[Experiment 004](experiment-004.md) retains the original native run reports and compiler references. The v0.1 reference is `coreai_core-1.0.0b3-cp312-cp312-macosx_26_0_arm64.whl`, SHA-256 `8db70074eb049b0a86bd263e137ea173f3298f7f1b60ec1a7f7c592f4c26c4a9`. The wheel's platform tag is not evidence that Corsairs supports macOS 26. This compatibility matrix is limited to the recorded host; additional OS builds need their own validation.

The [b3 API inventory](../fixtures/parity-v01/API-INVENTORY.md) and [reference report](../fixtures/parity-v01/python-results.json) retain the full package identity and dependency versions. [Sixteen fixture assets](../fixtures/parity-v01/README.md) cover the five supported dtypes, operators, scalar/empty shapes, edge values, and a three-step named-state accumulator. Python execution is complete for CPU-only and GPU-preferred configurations. Complete Rust [debug](evidence/v0.1/checks-debug.json) and [release](evidence/v0.1/checks-release.json) reports each pass all 32 positive configurations, 16 negative cases, 40,000 stress inferences, and the specified lifecycle/future-drop loops.

## Framework and ABI boundary

The experiment opens `/System/Library/Frameworks/CoreAI.framework/Versions/A/CoreAI`. Exported Swift symbols, native metadata, value witnesses, synchronous throws, and async task contexts are recorded in [the ABI contract ledger](abi-contracts.md). A successful symbol lookup alone does not prove that a changed OS satisfies a call's ownership and lowering contract. New OS/SDK pairings need the compiler calibration and native differential suite before being added to the tested matrix.

The public release must report unsupported platforms and missing required capabilities before attempting an unsupported call. Source/API documentation must distinguish tested compute configurations from options merely present in an SDK. The v0.1 contract requires CPU-only and GPU-preferred comparison; explicit Neural Engine control is deferred. GPU-preferred describes the selected preference, not a guarantee that every operation executes on the GPU.

## Supported value boundary

The implemented facade supports resolved static `NDArray` input/output/state signatures with float16, float32, int32, int64, or bool elements. Unresolved/dynamic shapes, images, and other native value kinds are rejected. Input/state names, dtypes, ranks, and dimensions must match the inspected function signature.

Owned tensor storage is contiguous row-major data, limited to rank 64 and 1 GiB per tensor. Scalar tensors have rank zero and one element. Empty tensors are supported; their nonzero-dimension product multiplied by scalar width must also stay within the size limit. Inputs are copied into native storage and completed outputs/state are copied back into owned Rust storage. These are v0.1 bounds, not claims about the maximum native framework capabilities.

The ordinary dependency has no default features and keeps the native module private. `abi-research` exposes unsafe development probes and is outside the supported safe facade. One runtime owns one worker; clones share its serialized call queue. Independent runtimes have separate workers, rather than a promise of device-level parallel execution.

## Native launch environment

In this workspace's ordinary shell sandbox, Core AI's tensor initializer traps even in an independent standalone Swift executable. The same fixtures succeed through REA's native runner on this host. Native allocation, specialization, and model-cache access therefore require a permitted execution environment in addition to a compatible OS.

`python3 scripts/check.py` runs compiler calibration and the non-tensor checks. `python3 scripts/check.py --native --cycles 10000` additionally exercises the existing tensor/model/inference loops. Run the native check in a permitted host environment and retain its full result. A reference executable that cannot initialize the framework makes that comparison unavailable; it does not excuse a Rust failure or count as parity.

## Reference reproducibility

Every differential report must identify the OS build, architecture, SDK/compiler versions, exact Python wheel and dependency identities, asset and input hashes, output names/shapes/dtypes, state sequence, compute selection, and comparison rule. Python is used to prepare/reference fixtures during development only. Installing Python is not intended to be a Rust runtime prerequisite.

The first tiny fixture and its provenance live in [fixtures/double_f32_2x3](../fixtures/double_f32_2x3/README.md). The b3 suite freezes separate backend goldens, including observed GPU-preferred subnormal/NaN changes described in [backend semantics](../fixtures/parity-v01/BACKEND-SEMANTICS.md). Both Rust profiles pass across the recorded compute selections, five dtypes, descriptors, and stateful sequences. See [the accepted v0.1 scope](v0.1-release.md) and [measured performance limits](benchmarks.md).

The [final package verification](evidence/v0.1/package-verification.json) binds the distributable archive to the tested source identity and records native feed-forward/stateful examples from both the extracted package and an isolated default-feature consumer. Its packaged diagnostic CLI also inspected the model under GPU preference. The [local publish rehearsal](evidence/v0.1/local-publish-rehearsal.json) produces the identical archive. After publication, an independent [registry consumer](evidence/v0.1/registry-consumer.json) downloaded the identical crate from crates.io, compiled, and ran typed tensor assertions.
