# Experiment 004: suspension, model loading, and exact inference

Date: 2026-10-15. macOS 27.0.1 (26A434), arm64, SDK 27, Rust 1.99.0, Apple Swift 6.4.

## Result

The Rust executable now loads and executes a real Core AI model directly, using Apple's existing Swift task runtime. The tiny float32 [2, 3] graph computes `y = x + x`. Rust, standalone Swift, and the published Python API produce exactly the same 24 output bytes:

```
input  = [1, -2, 0, 0.5, 100, -0.25]
output = [2, -4, 0, 1, 200, -0.5]
shape  = [2, 3], dtype = float32, strides = [3, 1]
output SHA-256 = 7f27af1a2550ecd2c12dbcfdb4fa57fc7b9320080b0c217f8c31e1236f33f2df
```

The complete native check passed in debug and release. Per profile it ran 1,000 suspending tasks, 1,000 missing-asset errors with balanced error release, 1,000 successful model load/read-name/drop cycles, and 1,000 inference calls on one loaded function and immutable input tensor. Every inference verified metadata, exact output bits, one named output, and an empty output collection after removing `y`. Existing tensor/buffer/error/task checks also passed after the shared buffer helpers changed.

The final suspension run observed 999 thread migrations per profile. Task.yield can resume immediately; migration is measured rather than required. All 1,000 resumes had correct native task identity and completed the post-native-completion protocol.

## Native task and value ownership

An 80-byte root frame holds the native header, child context, original completion, owned Rust Arc reference, four arguments, and borrowed function self. Flags zero leaves the task unscheduled while Rust installs those fields. Apple's job runner establishes genuine task/executor state. The async entry allocates a child using the native descriptor's size, sets its parent/resume header, and tail-calls the existing native entry. Its continuation deallocates that child in LIFO order.

A wrapper preloads the original completion and Arc pointer, calls native completion, then signals Rust. Native completion has already finished and released the running task reference at that point. Caller and callback hold separate Arc references, so waking the caller cannot free synchronization state still used by the callback. The caller releases its own native task reference after the signal. The concurrency image is pinned once with the SDK's RTLD_NODELETE flag because the worker's executor epilogue can still run afterward. No timeout frees live task data; cancellation remains unimplemented.

Throwing asynchronous calls return an owned error in x20; synchronous throws use x21. Nonthrowing Task.yield leaves x20 unspecified, so its continuation ignores that register. Model URL/options and inference mutable views are marked consumed on both native success and error. Inputs and function storage remain alive through inference completion. The input tensor remains immutable until Inputs is destroyed. Optional payloads move through VWT operations, and string/array conversion uses exported accessors without guessing layouts.

## References and evidence

- [Full passing checks, command outputs, toolchain identity, and source/fixture hashes](evidence/experiment-004/checks.json), launched through [the native runner](evidence/experiment-004/native-check-observation.json).
- [Rust inference entry/resume/completion observation](evidence/experiment-004/rust-inference-observation.json) and [independent Swift execution](evidence/experiment-004/swift-inference-observation.json). Both exited zero with complete observation coverage; debugger timing is not a performance measurement.
- [Published Python execution](evidence/experiment-004/python-reference-observation.json), [its result](../fixtures/double_f32_2x3/python-reference.json), and [fixture manifest/asset hashes](../fixtures/double_f32_2x3/manifest.json). The OS-backed extension used CPU-only specialization and matched the expected bytes exactly.
- Compiler sources: [suspension](../experiments/swift/SuspensionReference.swift), [independent clang async oracle](../experiments/c/SuspensionReference.c), [model/string accessors](../experiments/swift/LoadReference.swift), and [inference/Optional/coroutine lowering](../experiments/swift/InferenceReference.swift). Retained IR/SIL/assembly is in [the evidence directory](evidence/experiment-004/).
- [ABI and ownership ledger](abi-contracts.md).

The fixture was prepared offline with Apple's cached `coreai-core 1.0.0b2` authoring tools. Python is development/reference tooling only. No custom Swift library or Python interpreter is linked, embedded, or invoked by the Rust application. The desired published b3 baseline has not been acquired; this result establishes one b2 differential fixture rather than full package parity. Native drop/reference balances do not independently prove leak freedom.

## Reproduction and next work

```
cargo run --offline -p corsairs-lab -- suspend 1000
cargo run --offline -p corsairs-lab -- model fixtures/double_f32_2x3/double_f32_2x3.aimodel 1000
cargo run --offline -p corsairs-lab -- infer fixtures/double_f32_2x3/double_f32_2x3.aimodel 1000
python3 scripts/check.py
python3 scripts/check.py --native --cycles 1000
```

Native checks require an environment that permits Core AI tensor allocation and model specialization/cache access. The ordinary sandbox traps even in the standalone Swift tensor oracle; REA's native runner completed the full check. A sandbox failure is never counted as parity.

Next: acquire and inventory b3, vary input contents and operator fixtures, extend dtypes/layouts and negative cases, and establish state/options/cancellation behavior. Safe Rust APIs, Rust graph authoring, broader numerical acceptance, and performance measurement remain open.
