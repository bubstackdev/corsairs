# Experiment 001: direct native metadata and tensor lifetime

Date: 2026-10-15. Platform: Apple Silicon macOS 27.0.1 (26A434), SDK 27.0, Rust 1.99.0 stable, Apple Swift 6.4.

## Result

Stable Rust can call the selected existing Core AI Swift ABI entry points directly using explicit ARM64 register lowering. No embedded Python, custom Swift wrapper, or experimental Rust language feature is used by the Cargo application.

The experiment requested native metadata, constructed float32 NDArray values with shape [2, 2], read shape/scalar type through public accessors, and destroyed each value through its native VWT. Both debug and release completed 1,000 cycles. The independent standalone Swift tensor reference returned the same shape and float32 type.

| Type | Runtime size | Stride | Alignment |
| --- | ---: | ---: | ---: |
| NDArray | 49 | 56 | 8 |
| ScalarType | 1 | 1 | 1 |
| AIModel | 8 | 8 | 8 |
| InferenceFunction | 1160 | 1160 | 8 |

Debug and release metadata agree with Swift's MemoryLayout values for all four types. The application uses runtime layouts; these observed sizes are not constants in the binding.

## Evidence

- [Rust formatting, clippy, metadata/error tests, debug/release builds, and Swift metadata comparison](evidence/experiment-001/checks.json): passed.
- [Compiler calibration](evidence/experiment-001/calibration.json): reproduced the experimental Rust/Swift aggregate mismatch without executing those diagnostic declarations.
- [Native Swift reference](evidence/experiment-001/swift-tensor.json): exit 0, shape [2, 2], float32. REA `ev_a9477869eafa9433f01aec99d79f9fb160f18ec26aae436000c1e79a9c26e606`.
- [Native Rust debug](evidence/experiment-001/rust-debug-tensor.json): exit 0, 1,000 initialized/destroyed tensors. REA `ev_f5dbcdbab7c472551b4182741b222859f420cf71ff15a04fdbbe4203eb465321`.
- [Native Rust release](evidence/experiment-001/rust-release-tensor.json): exit 0, 1,000 initialized/destroyed tensors. REA `ev_d2aead3b121bd2cba4414780313ac4d1d2951d49d261cc70bf5ed1b85f26b95c`.
- [Checked comparison results and binary digests](evidence/experiment-001/verified-results.json).
- [Initial native call observation](evidence/experiment-001/initial-native-tensor.json): recorded the actual CoreAIRuntime initializer entry with a Rust caller. REA `ev_e765cb686e37518628e29418ccc0826a7fa973d5fffe13582c75b3eece6d380c`.
- [One interrupted debug observation](evidence/experiment-001/rust-debug-event-limit.json) hit the tool's event limit and was killed before running the experiment. It is retained as incomplete evidence, not included in the passing results.

REA ran each selected executable as an owned process, captured output, and closed its session afterward. Its call-entry instrumentation does not observe return values; output assertions come from the executable. The retained evidence records target digests and launch identity limitations. Debugger timing is not a performance measurement.

## Launch-environment finding

Launching either the Rust tensor experiment or the standalone Swift tensor reference through this session's sandboxed shell produced SIGTRAP in CoreAIRuntime during the initializer. Launching both through REA's native process runner succeeded. Metadata queries also succeeded in the shell.

This establishes a launch-environment dependency, not its exact underlying cause. No GPU/device denial, missing entitlement, or particular service failure was proved. The default check runs metadata comparisons; `--native` explicitly adds tensor execution and fails if the standalone Swift oracle cannot run. Reproduce native comparisons from a terminal with framework access or through the native runner.

## Interpretation and next experiment

The first direct synchronous call path is demonstrated on this platform. Runtime metadata and value-witness destruction work for the selected values. The [contract ledger](abi-contracts.md) records register placement and consumed/borrowed values, including the generic Array accessors' ordinary self arguments.

This does not establish initialized tensor contents, zero-copy access, leak freedom, inference, error/async correctness, full Python API parity, or speed. The counters show completed create/destroy loops, not an independent heap-leak measurement. A safe public tensor API remains premature.

Next: initialize and inspect tensor contents using verified public buffer/view contracts, establish lifetime across views, then implement the throwing and asynchronous machinery needed for model loading and inference. Track runtime and authoring coverage against the [parity plan](parity.md).
