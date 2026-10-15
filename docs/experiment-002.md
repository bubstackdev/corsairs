# Experiment 002: tensor contents and synchronous errors

Date: 2026-10-15. Same Apple Silicon macOS 27.0.1 / SDK 27 / Rust 1.99.0 / Swift 6.4 pairing as Experiment 001.

## Results

Rust writes and reads float32 tensor storage through native views and matches an independent Swift executable bit for bit. Debug and release each completed 1,000 tensor lifetimes, with three write/read rounds per tensor. Each mutable view is destroyed before obtaining the read-only view, and every view is destroyed before the next mutation or tensor destruction.

The 12 tested bit patterns cover 1, -2.5, signed zeros, signed infinities, quiet NaN payloads, the smallest positive subnormal, maximum finite float32, minimum positive normal float32, and a rounded representation of 1/3. Bytes are copied without float arithmetic, so this verifies storage preservation rather than kernel arithmetic accuracy.

Rust also exercised 1,000 invalid empty bookmarks in each build profile. Each operation threw an owned error in x21, which Rust projected, identified as `CoreAIDelegates.AIModelCacheError`, and released with `swift_errorRelease`. The independent Swift oracle reports the same concrete error type. The unsuccessful optional model output remains uninitialized and is not destroyed.

## Evidence and reproduction

- [Checks, source digests, compiler outputs, and Swift error oracle](evidence/experiment-002/checks.json): passed formatting, clippy, tests, builds, metadata comparisons, invalid-count checks, and error comparisons.
- [Swift buffer oracle](evidence/experiment-002/swift-buffer.json): REA `ev_fc7a2f175d57fd233373fe97439d931dd4374281641bfcd40fc26536edec136c`.
- [Debug buffer loop](evidence/experiment-002/rust-debug-buffer.json): REA `ev_24c84228d3326f4cce1579d00716058ef9e0560e3703358749beba9cbd89018a`.
- [Release buffer loop](evidence/experiment-002/rust-release-buffer.json): REA `ev_86dc909a267243c65bb43b84da5d74170c92d61d8a0236ab1ad1bdde6b7559f2`.
- [Debug error loop](evidence/experiment-002/rust-debug-bookmark-error.json): REA `ev_6b29852c72c3021a41590bc3b16238475ad5f3be3e8d194410534838c9eab7d4`.
- [Release error loop](evidence/experiment-002/rust-release-bookmark-error.json): REA `ev_9a3e236d201141784bc88da3c9b45d0169b8571b66f5159b2666cbfcf92b8fb8`.
- [Verified comparisons and binary digests](evidence/experiment-002/verified-results.json).
- [Initial observation of actual native view accessor entries](evidence/experiment-002/initial-buffer-observation.json): REA `ev_4eabaf7250e36ac6ff2ae7b29642a9034b7bb3ce402f4f6e2c587f04252a8ff6`.

Run `python3 scripts/check.py` for compiler, metadata, and error comparisons. Run `python3 scripts/check.py --native --cycles 1000` from an environment with native framework access for buffer comparisons too. The shell launch limitation from Experiment 001 still applies to tensors; REA's native runner completed all retained tensor comparisons. Debugger timing is not a speed measurement.

The buffer implementation follows the public inlinable MutableRawView.mutableBytes body from the SDK. That body calls the ABI-public `_start` and `storageByteCount` helpers. Rust calls those same existing helpers, using runtime-sized view storage. The read-only public bytes getter returns a RawSpan pair in x0/x1; no internal NDArray or view field layout is guessed.

## Scope and next work

The synchronous throw and cleanup mechanism is verified for one Core AI error, not the complete error surface. A missing asset path was unsuitable as a throwing-constructor fixture because creating a lazy asset handle can succeed; the invalid empty bookmark gives a clean, reproducible native error.

Counts show completed destruction/release loops, not independent proof of leak freedom. Noncontiguous layouts, other dtypes, copy-on-write, Metal buffer sharing, kernel arithmetic, inference, and general async safety remain unverified.

The next gate is genuine Swift task creation and completion. A synchronous x21 throw must not be confused with asynchronous error completion through x20. The [ABI ledger](abi-contracts.md) records the implemented contracts and the [parity plan](parity.md) tracks the broader runtime/authoring target.
