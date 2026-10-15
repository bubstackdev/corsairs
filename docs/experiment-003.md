# Experiment 003: real Swift task creation and completion

Date: 2026-10-15. Same macOS 27 arm64 / SDK 27 / Rust 1.99.0 / Swift 6.4 pairing.

## Result

Rust creates and completes genuine Swift tasks without a custom Swift library. Both debug and release passed 1,000 cycles. Every body observed the created native task pointer, and each completed run restored nil current-task TLS on the calling thread.

The body is an ARM64 async entry assembled inside the Rust executable. A link-relative descriptor requests a 16-byte context. Apple's runtime supplies the real task and completion continuation. The body records its native identity through Rust, restores its frame/context, clears the async error carrier, and tail-calls that continuation.

The probe creates the task without automatic enqueueing, retains a running reference, and invokes the existing native job runner with a generic executor. The body never suspends. Runtime source establishes that completion and the running-reference release finish before this specific job_run returns. The Rust guard then releases the caller's reference while the runtime library remains alive.

This is not a fake context passed from ordinary Rust code, and it is not a general-purpose async executor. Return from job_run cannot establish completion for a future body that suspends.

## Verification

- [Passing checks, source digests, debug/release task loops, and standalone Swift awaited-task oracle](evidence/experiment-003/checks.json).
- [Native runtime observation](evidence/experiment-003/native-task-observation.json), REA `ev_2fd1a80294aa85f21dd31c8bfd4a86c91ba673a4453523b4cfa33a7371878047`: observed `swift_task_create`, `swift_job_run`, and the Rust body callback; process exited 0 with matching task identity and restored TLS.
- [Compiler task-create signature](evidence/experiment-003/task-reference-declarations.txt) and [async leaf/descriptor assembly](evidence/experiment-003/task-reference-leaf-assembly.txt).
- [ABI and reference-ownership ledger](abi-contracts.md).

Reproduce with `cargo run --offline -p corsairs-lab -- task 1000` or `python3 scripts/check.py`. No Swift reference executable runs inside the Rust process. Debugger timing is not a performance result, and completed reference balances do not independently prove leak freedom.

## Next gate

Implement a suspending native call with a verified child context, resume continuation, owned completion state, and error propagation. Model loading must retain its URL/options/result/error storage and Rust waiting state until native completion, including after the initial job runner returns. Cancellation needs a separate completion/cleanup contract. Only then should the tiny inference fixture run through the asynchronous Core AI API.
