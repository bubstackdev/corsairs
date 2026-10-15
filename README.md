# Corsairs

**CORe AI — RS**, with an extra S. Safe Rust inference using Apple's existing Core AI implementation.

Corsairs loads `.aimodel` assets, inspects function signatures, and executes named inputs, outputs, and state. Applications use owned Rust tensors and asynchronous tasks backed by a dedicated native worker. The application embeds no Python and loads no custom Swift wrapper.

The v0.1 release targets Apple Silicon macOS 27. It provides a bounded inference subset of `coreai-core 1.0.0b3`; complete runtime and graph-authoring parity remains the longer-term objective. Debug and release each passed all 32 differential configurations, 16 negative cases, and 40,000 checked stress inferences. The [release archive](dist/corsairs-0.1.0.crate) also passed extracted-package and isolated-consumer examples. See [the release gates and publication record](docs/v0.1-release.md).

The published v0.2 adds dynamic signatures, per-model reshape settings, [retained native tensors](docs/native-tensors.md), [Metal interoperability](docs/metal-ownership.md), and [concurrent model/function loading](docs/parallel-loads.md). The [Krea acceptance run](docs/v0.2-krea.md) matches Swift's encoded text, all eight latent steps, and decoded pixels. [BF16 tensors](docs/bfloat16-abi.md) and [transitive cleanup draining](docs/runtime-drain.md) also pass [H3's original-weight block, all 50 schedule pairs, and staged synthetic backbone](docs/v0.2-h3.md). See [the v0.2 publication record](docs/v0.2-release.md).

Current v0.3 development qualifies a [larger checked tensor boundary](docs/v0.3-large-tensors.md) for H3's long hidden tensors and RGB outputs. The published v0.2 limit remains 1 GiB.

## Use

Requires Apple Silicon, macOS 27, and Rust 1.99+. The recorded host is macOS 27.0.1 (26A434) with Rust 1.99.0. Xcode/SDK 27, Apple Swift 6.4, and Python are development/reference tools.

Add [Corsairs from crates.io](https://crates.io/crates/corsairs) to a Rust project:

```sh
cargo add corsairs@0.2.0
```

Source: [bubstackdev/corsairs](https://github.com/bubstackdev/corsairs).

```rust,no_run
use corsairs::{Compute, Runtime, Tensor, TensorMap};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let runtime = Runtime::new()?;
    let model = runtime.load_model("model.aimodel", Compute::CpuOnly).wait()?;
    let function = model.load_function("main").wait()?;
    println!("{:?}", function.descriptor());

    let inputs = TensorMap::from([(
        "x",
        Tensor::from_vec([2, 3], vec![1.0f32; 6])?,
    )]);
    let result = function.run(inputs, TensorMap::new()).wait()?;
    for (name, tensor) in result.outputs.iter() {
        println!("{name}: {:?} {:?}", tensor.dtype(), tensor.shape());
    }
    Ok(())
}
```

This example expects a `main` function with float32 input `x` of shape `[2, 3]`. Loading and execution return `Task<T>`, which supports `.await` or synchronous `.wait()`. Submission starts immediately. Dropping a task leaves its owned request alive through native completion; it does not cancel native work.

Run the packaged examples and CLI from the workspace:

```sh
cargo run --offline -p corsairs --example feedforward
cargo run --offline -p corsairs --example stateful
cargo run --offline -p corsairs --bin corsairs -- --help
cargo run --offline -p corsairs --bin corsairs -- inspect crates/corsairs-abi/models/feedforward.aimodel
```

Both examples forbid unsafe code and include tiny model assets. The CLI supports `inspect`, `run`, and `bench`. See [the package README](crates/corsairs-abi/README.md) for tensor conversion, state handling, and task semantics.

## Supported subset

| Area | v0.1 behavior |
| --- | --- |
| Models | Existing assets, named functions, input/output/state descriptors |
| Tensor elements | `Float16`, `f32`, `i32`, `i64`, `bool` |
| Storage | Owned contiguous row-major tensors; native inputs and returned outputs/state are copied |
| Shape limits | Resolved static tensor signatures; rank at most 64; storage at most 1 GiB per tensor |
| Execution | Named inputs/outputs and caller-supplied named state, with updated state returned for the next step |
| Compute | CPU-only or GPU-preferred specialization |
| Ownership | Native values stay on one worker per runtime; cloned handles share its serialized queue |
| Errors | Checked tensor construction/signatures and typed native, binding, and worker errors |

Scalar and empty tensors are supported. For empty tensors, the 1 GiB guard also applies to the product of nonzero dimensions and scalar width. Unresolved/dynamic signatures and non-tensor values are rejected. GPU preference permits fallback choices and does not prove which device executed an operation.

Graph authoring, custom Metal kernels, images/pixel buffers, packed low-bit formats, shared GPU storage, profiling callbacks, explicit Neural Engine control, and native cancellation are deferred. The default feature set is empty; the native module is private. `abi-research` exposes unsafe development probes outside the normal API.

## Verification

The [pinned b3 inventory and fixtures](fixtures/parity-v01/README.md) contain sixteen assets and exact Python output/state goldens for CPU-only and GPU-preferred configurations. They cover arithmetic, matrix multiplication, reductions, indexing, shape operations, state updates, all five dtypes, scalar/empty shapes, and numerical edge values. Backend comparisons preserve observed subnormal and NaN behavior; [the recorded differences](fixtures/parity-v01/BACKEND-SEMANTICS.md) are retained separately from mathematical expectations.

The complete [debug](docs/evidence/v0.1/checks-debug.json) and [release](docs/evidence/v0.1/checks-release.json) reports each record 10,000 stateless and 10,000 stateful inferences per compute selection, plus 100 load/drop and 100 of each future-drop case per selection: 80,000 checked stress inferences across both profiles. [Malformed-asset recovery](docs/evidence/v0.1/malformed-assets.json), [native handle cleanup](docs/evidence/v0.1/native-malformed-and-drops.json), [binary16 conversion](docs/evidence/v0.1-float16-conversion.json), and [the scoped safety review](docs/evidence/v0.1-safety-review.md) provide additional evidence for the recorded subset.

The [initial benchmark](docs/benchmarks.md) found higher Rust round-trip latency than Python for the tiny feed-forward fixture: CPU-only medians approximately 1.17 ms versus 69 µs and GPU-preferred approximately 1.65 ms versus 530 µs. These measurements support no speedup claim. The report retains sample methodology, cache-warm loading observations, and its limits.

```sh
cargo test --offline -p corsairs --no-default-features
cargo doc --offline -p corsairs --no-default-features --no-deps
python3 scripts/check_v01.py
python3 scripts/check_v01.py --native --cycles 10000 --loads 100 --dropped 100
python3 scripts/check_v02.py --native
python3 scripts/check_float16.py
python3 scripts/check_bfloat16.py
python3 scripts/check_package_v02.py --native
```

The v0.2 workflow and external Krea/H3 fixture commands are in [the release gates](docs/v0.2-release.md). Historical v0.1 packaging and malformed-asset scripts write their original evidence locations; use the version-specific v0.2 workflow for this candidate.

Native allocation, specialization, and cache access need a permitted execution environment. This workspace's ordinary shell sandbox traps even in the independent Swift tensor oracle; native runner observations are retained as evidence. An unavailable reference environment never counts as a passing comparison. See [compatibility](docs/compatibility.md), [safety and ownership](docs/safety.md), and [the ABI ledger](docs/abi-contracts.md).

The Cargo workspace has no third-party dependencies. `crates/corsairs-abi` currently holds the public `corsairs` package; `crates/corsairs-lab` is the unpublished research CLI. `experiments/` and the older numbered experiment reports retain the compiler/native investigation that established the binding.

## License

Licensed under either the [MIT license](LICENSE-MIT) or the [Apache License, Version 2.0](LICENSE-APACHE), at your option.

