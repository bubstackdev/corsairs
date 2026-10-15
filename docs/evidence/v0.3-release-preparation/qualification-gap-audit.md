# Final v0.3 qualification audit

The read-only aggregate checker is
[`scripts/verify_release_v03.py`](../../../scripts/verify_release_v03.py).
It launches no subprocess, build, native framework, GPU or registry operation;
it writes only its selected aggregate report. Run from the workspace root:

```sh
python3 -B scripts/verify_release_v03.py
```

The current result is intentionally **failing** while clean-archive qualification
is pending.
The changing source of truth is
[`v0.3-final/aggregate.json`](../v0.3-final/aggregate.json), which lists every
passing gate and every missing, failed or mismatched requirement independently.
This audit's latest run had **22 of 23 gates passing**. The only remaining gap is
`package-clean`: the final clean VCS archive must be prepared and qualified after
the release commit. All selected native gates pass. No missing final gate is
filled from historical evidence.

## Evidence selection

The verifier requires clean individual core/lifecycle/BF16 observations and
excludes `core-lifecycle-bf16-native.json`, whose debugger stops make it unsuitable
for that gate despite successful child results. The selected hidden CPU receipt
is `h3-hidden-cpu-quiet-native.json`; it passes the strict criteria. The earlier
`h3-hidden-cpu-final-native.json` had partial coverage and exception stops and is
retained only as a diagnostic. The pinned `posix_spawn`/`waitpid` quiet parent
uses an error-only breakpoint in its own image, avoiding the earlier observation
problems. The checker validates its source/binary hashes, compile receipt and
recorded true/false child exit propagation. CPU 4 GiB selects the corresponding
fresh `limit-f32-cpu-quiet-native.json` receipt, which also passes. Release stress,
corrected GPU rejections and raw storage select their clean
`stress-release-retry-native.json`, `gpu-rejections-retry-native.json` and
`raw-storage-retry-native.json` receipts. The pre-retry rejection report remains
at `gpu-rejections-pre-retry.json`; the selected final result was copied byte-for-
byte from the actual successful retry's `checks.json`.

Legitimate fresh retry filenames can be selected using `--native-selection FILE`,
where FILE is a JSON object mapping a gate name, such as
`large-h3-hidden-cpu`, to a receipt path inside `docs/evidence/v0.3-final`.
The selected receipt must still pass all semantic and identity checks. All
selected native receipts require complete coverage, exit zero, complete stdout
and stderr, stable selected executable identity and no stops except launch
`signal SIGSTOP`. A successful child alone does not clear this gate. REA's
selected-file digest remains distinct from a loaded-image digest.

## Required counts and identities

- Current workspace/package Cargo manifests, lockfile and all Rust production,
  example and test files must match the final production freeze. The aggregate
  also records the current package README hash, verifier hash, every consumed
  evidence-file digest and a combined qualification identity.
- Static gates require both strict Clippy modes, formatting, strict rustdoc,
  41 passing pure library tests, six native ignores and the public doctest.
  The native lifecycle result must contain all six named tests within 47 passing
  library tests, plus the CLI and metadata tests.
- Core requires 32 retained-storage and 64 Metal configurations in each of
  debug/release, dynamic/options and handle probes, exact passing completion
  records and current source/binary manifests. BF16 requires 46 configurations,
  104 exact values and all 65,536 native/Metal raw encodings per profile.
- Each stress profile must contain the actual v0.1 checker parity/negative
  results, two successful backend stress events and emitted counts of 10,000
  stateless plus 10,000 stateful calls per backend, 100 load/drop cycles and 100
  abandoned requests of each kind. Both profiles total 80,000 inferences.
- Eight large reports cover four CPU and four GPU-preferred cases. Each must
  match its current frozen build, independently executed Swift full-byte hashes
  and all seven Rust path labels. The frozen helper must contain both three-
  iteration abandoned-future/drain loops. Boundary sizes include CPU 4 GiB,
  GPU exact 2 GiB and near-boundary RGB173; GPU RGB345 is not a passing gate.
- Raw storage requires six exact 4 GiB roundtrips, six maximal-empty roundtrips
  and twelve pre-runtime typed rejections. Krea requires all thirteen expected
  hashes, 32 Metal calls, eight steps and four outstanding model/function loads.
  H3 requires the 15-input functional 19,333-row case and exact outputs on every
  warmup/measured iteration in both selected retained/Metal phases.
- GPU rejections use the actual final producer fields: 19 inference checks,
  eleven typed GPU rejections and eight positive empty results, within 45 check
  events plus successful completion. Metadata/storage/recovery/drop-drain events
  and final build/source pins are retained rather than treated as leak counters.
- Final tiny benchmarks require the exact final build and published b3 identity,
  matching case/asset/input/golden hashes, CPU/GPU pairs with alternating language
  order, joined successful arms, ten warmups and 100 retained raw samples in each
  of two common phases, full-output exactness and recomputed median/p95 values.
  These are descriptive observations, with no universal speedup requirement.
- Candidate and clean archive qualification are distinct. Both require native
  success, all eight output-asserting archive/consumer example exits, CLI/BF16
  results, current README/source/normalized-manifest equality and every archive
  member hash. The clean gate additionally requires a clean VCS archive and
  `docs/evidence/v0.3/package-clean-verification.json`, selected by
  `v0.3-final/package-clean-native.json`. A dirty candidate never substitutes.

The aggregate does not publish, validate registry ownership or perform the
post-upload version-only consumer check. External multi-GB assets are linked to
retained full-hash preparation receipts; this small verifier does not reread
those model payloads during the native coordinator's serial windows.
