# v0.1 differential fixtures

These are preparation/reference artifacts. The Rust library never imports Python.

The published reference is `coreai-core 1.0.0b3`, CPython 3.12 macOS arm64 wheel SHA-256 `8db70074eb049b0a86bd263e137ea173f3298f7f1b60ec1a7f7c592f4c26c4a9`. `reference-lock.json` and the retained `reference-pypi.json` pin its provenance. Wheel binaries stay under `.local/reference/` rather than in the fixture tree.

`suite.json` describes sixteen model assets, exact input bytes, independent NumPy expectations, state sequences, and asset hashes. Coverage includes f16/f32/i32/i64/bool arithmetic, matrix multiplication, reduction, indexing, reshape, two-layer feedforward, named inputs, IEEE edge values, wide integers, scalar and empty shapes, and a three-step named accumulator. All assets pass hash checks, Apple bytecode integrity checks, and source-program reloads recorded in `preparation-checks.json`.

`backend-goldens.json` points to frozen native Python output/state bytes for each fixture under CPU-only and GPU-preferred configurations. All 32 positive configurations executed; 16 negative cases returned expected errors. All scalar/empty cases executed successfully. The GPU-preferred float edge fixture differs from the independent math expectation; [the exact bits and interpretation](BACKEND-SEMANTICS.md) remain recorded. Rust parity compares against Python on the same model, input, and compute configuration, using exact output/state bytes and metadata. It must not silently substitute CPU mathematical results for the GPU-preferred baseline.

`backend-goldens-neural-engine-preferred.json` adds a separately frozen Neural Engine-preferred grid: 16 positive configurations and 8 expected negative errors from `python-results-neural-engine-preferred.json`. Its `float_edges` bytes equal the GPU-preferred observation. The original grid and its initial report are unchanged; see [compute units](../../docs/compute-units.md).

`python-results.initial.json` preserves the complete initial report, including its failed math comparison. `python-results.json` is the full-suite working report. Filtered runs use separate report files. The `goldens/` files are immutable snapshots until an explicit reviewed regeneration; `results/` contains working observations. `API-INVENTORY.md` and `api-inventory.json` enumerate b3's public runtime and authoring exports and class members with their planned v0.1 status. Python reference execution and Rust verification are separate fields.

The named state asset requires b3's private raw graph/handle/token authoring seam because its public graph decorator accepts tensor/image specifications and exports no handle read/write constructors. This is marked in the fixture manifest. Runtime calls use the published Python API. Rust authoring remains deferred for v0.1.

The retained [debug](../../docs/evidence/v0.1/checks-debug.json) and [release safe-API reports](../../docs/evidence/v0.1/checks-release.json) each pass all 32 backend configurations and 16 typed negatives. Each backend/profile also completed 10,000 stateless calls, 10,000 stateful calls, 100 load/drop cycles, and 100 abandoned futures each for inference, model loading, and function loading. [The build manifest](../../docs/evidence/v0.1/build-manifest.json) binds exact source/compiler/driver/rlib/fixture identities. Inventory generation validates these retained report and manifest hashes before marking the bounded runtime subset as tested. These observations apply to the recorded snapshot and host; they do not establish full API or other-platform parity.

Negative coverage runs each of these cases under both CPU-only and GPU-preferred configurations:

| Invalid request | Published Python outcome | Safe Rust outcome checked |
| --- | --- | --- |
| Missing model asset | RuntimeError containing native AIModelCacheError, code 3 | `Error::Native` with AIModelCacheError dynamic type |
| Unknown function | KeyError | `Error::FunctionNotFound` with requested name |
| Missing required input x | RuntimeError | `Error::MissingTensor` with input kind and x name |
| Unknown input name | RuntimeError | `Error::UnexpectedTensor` with input kind and supplied name |
| Wrong input shape | RuntimeError with actual/required shape | `Error::DescriptorMismatch` identifying x and shape |
| Wrong input dtype | RuntimeError with actual/required type | `Error::DescriptorMismatch` identifying x and scalar types |
| Missing accumulator state | RuntimeError naming missing state | `Error::MissingTensor` with state kind and accumulator name |
| Wrong accumulator shape | RuntimeError with actual/required shape | `Error::DescriptorMismatch` identifying accumulator and shape |

The Python report retains full exception text. Rust uses typed idiomatic failures and preserves the native dynamic type; this release does not promise identical Python exception classes/text or native localized error codes. Native errors that occur before the intended invalid request reaches its failure stage are environment/precondition failures rather than passing negative cases. The original shell specialization failure used AIModelCacheError code 0 and remains distinct from the native missing-asset reference outcome.

Separate [safe Rust malformed-asset probes](../../docs/evidence/v0.1/malformed-assets.json) rejected truncated bytecode, nonsensical bytecode, and a plain-text `.aimodel` file under both compute settings, then loaded a healthy model/function on the same runtimes. These six additional failures are not included in the sixteen Python differential negatives above.

The wheel SHA comes from the retained PyPI release JSON and is independently checked after download. TLS certificate verification remains enabled for the optional explicit-CDN-address download. `suite.json` separately pins source model files, binary inputs, mathematical expected outputs, and source text. Apple's `main.hash` contents are verified against the SHA-256 of `main.mlirb`. `backend-goldens.json` pins copied native Python results and the complete original observation report. No wheel hash is substituted for model/input/output provenance, and no executable reference failure can become a successful golden.
