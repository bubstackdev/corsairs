# Compute units and Neural Engine preference

Recorded 2026-10-18 on macOS 27.0.1 (26A434), device architecture `h17c`, Xcode/SDK 27.

## What Core AI offers

`CoreAIDelegates.ComputeUnitKind` has three cases: `cpu`, `gpu` and
`neuralEngine`. `SpecializationOptions` can be built only as `.cpuOnly`,
`.default` or `init(preferredComputeUnitKind:)`. `allowedComputeUnitKinds` is
read-only. [`ComputeUnitsReference.swift`](../experiments/swift/ComputeUnitsReference.swift)
records ([report](evidence/compute-units/swift-oracle.json)):

| Options | Allowed units | Preferred |
| --- | --- | --- |
| `.cpuOnly` | CPU | none |
| `.default` | CPU, GPU, Neural Engine | none |
| prefer CPU / GPU / Neural Engine | CPU, GPU, Neural Engine | that unit |

All three units are available on this host. A preference therefore ranks units
and never excludes any; only CPU-only restricts execution. Under every
preference, the x+x fixture produces exact output through both `run` and
`ComputeStream` encode.

## Corsairs mapping

`Compute::NeuralEnginePreferred` builds `SpecializationOptions(preferredComputeUnitKind: .neuralEngine)`
with the same compiler-verified constructor as `GpuPreferred`, injecting the
`ComputeUnitKind.neuralEngine` case. Because unsupported operations may fall back
to the GPU, every non-CPU preference uses the qualified accelerated path: the
persistent GPU stream for stateless calls, the 2 GiB GPU inference bound, and
the 1 GiB stateful envelope. Neural Engine preference does not prove that any
operation ran on the Neural Engine. `Compute` is now `#[non_exhaustive]`.

## Parity

Python b3 reproduces the full v0.1 grid under `ComputeUnitKind.neural_engine()`
preference ([report](../fixtures/parity-v01/python-results-neural-engine-preferred.json)).
All 16 positive cases execute and all 8 negative cases return the expected errors.
`float_edges` produces exactly the GPU-preferred bytes, including subnormal flush
and NaN payload canonicalization (see [backend semantics](../fixtures/parity-v01/BACKEND-SEMANTICS.md)).
That digest is reviewed explicitly in the freezer.

These observations are frozen separately in
[`backend-goldens-neural-engine-preferred.json`](../fixtures/parity-v01/backend-goldens-neural-engine-preferred.json)
by `freeze_goldens.py --backend neural-engine-preferred`. The original CPU/GPU
`backend-goldens.json` and its immutable initial report are unchanged. The Rust
drivers read both golden sets, so the native grids now cover three backends in
debug and release:

- `check_v01.py --native`: 48 positive and 24 typed negative public-API configurations, plus 10,000 stateless and 10,000 stateful calls, 100 load/drop cycles and 100 abandoned futures of each kind per backend
- `check_v02.py --native`: native-storage parity 48/48 and Metal parity 96/96

## Not covered

- Which unit executes each operation; no delegate trace is collected.
- Large tensors or H3/Krea workloads under Neural Engine preference.
- `.default` (no preference) and CPU preference with GPU fallback, which are not exposed.
- Querying `availableKinds` from Rust: Swift `Set` results are not yet bound.
