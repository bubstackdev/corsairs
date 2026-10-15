# Corsairs

**CORe AI — RS**, with an extra S. Safe Rust inference using Apple's existing Core AI implementation.

Corsairs loads `.aimodel` assets, inspects named function signatures, and executes owned contiguous tensors with named inputs, outputs, and state. Native calls run on a dedicated worker; the public API carries owned Rust values. No Python interpreter or custom Swift wrapper is required by the application.

The v0.1 candidate targets Apple Silicon on macOS 27 with Rust 1.99 or later. The recorded host is macOS 27.0.1 (26A434), Rust 1.99.0, and Xcode/SDK 27. Debug and release each passed 32 differential configurations and 16 negative cases against pinned `coreai-core 1.0.0b3`, plus 40,000 checked stateless/stateful stress inferences. This establishes the bounded subset below on the recorded host; full Python API parity and other OS builds remain outside that evidence.

## Inference

This example expects an asset whose `main` function accepts a float32 `[2, 3]` input named `x` and returns `y`.

```rust,no_run
use corsairs::{Compute, Runtime, Tensor, TensorMap};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let runtime = Runtime::new()?;
    let model = runtime.load_model("model.aimodel", Compute::CpuOnly).wait()?;
    println!("functions: {:?}", model.function_names());

    let function = model.load_function("main").wait()?;
    println!("signature: {:?}", function.descriptor());

    let inputs = TensorMap::from([(
        "x",
        Tensor::from_vec([2, 3], vec![1.0f32, -2.0, 0.0, 0.5, 100.0, -0.25])?,
    )]);
    let result = function.run(inputs, TensorMap::new()).wait()?;
    let y = result.outputs.get("y").ok_or("missing y output")?;
    println!("{:?}: {:?}", y.shape(), y.to_vec::<f32>()?);
    Ok(())
}
```

Loading and execution return `Task<T>`, which implements `Future<Output = Result<T, Error>>`. Use `.await` inside an async application or `.wait()` in synchronous code. Submission starts immediately; dropping the task discards interest in its result while its owned request and native storage remain alive through completion. It does not cancel native work.

## Tensors and state

| Tensor dtype | Rust element type |
| --- | --- |
| float16 | `Float16` |
| float32 | `f32` |
| int32 | `i32` |
| int64 | `i64` |
| bool | `bool` |

`Tensor::from_vec` checks the shape and element count. `Tensor::zeros` initializes owned storage. `Tensor::from_bytes` accepts exact little-endian scalar bytes and validates boolean encodings. `to_vec::<T>()` checks the dtype and copies typed values. `Float16::from_bits` preserves binary16 bits; `from_f32` and `to_f32` provide numerical conversion.

`Function::descriptor()` exposes input, output, and state names, dtypes, and shapes. Inputs and state are checked against that signature before native execution. Each completed `RunResult` contains both `outputs` and updated `states`; pass the returned state map into the next call:

```rust,no_run
use corsairs::{Function, TensorMap};

fn step(
    function: &Function,
    inputs: TensorMap,
    states: TensorMap,
) -> Result<TensorMap, corsairs::Error> {
    let result = function.run(inputs, states).wait()?;
    Ok(result.states)
}
```

Cloned runtime/model/function handles share the same worker and retain their native resources. Calls on one runtime execute in submission order. Tensor clones make independent byte copies; inputs are copied into native storage and outputs/state are copied back into Rust-owned storage. `Runtime::flush()` waits for prior work and releases.

v0.1 accepts resolved static tensor signatures, rank at most 64, and at most 1 GiB of storage per tensor. Scalar and empty tensors are supported; for an empty tensor, the same size guard applies to the product of its nonzero dimensions and scalar width. Unresolved/dynamic signatures and non-tensor values return unsupported-feature errors.

## Compute and scope

`Compute::CpuOnly` selects CPU-only specialization. `Compute::GpuPreferred` requests GPU preference while permitting Core AI's fallback choices; it does not guarantee that every operation executes on a GPU. Compare numerical results with the same configuration: backend behavior may differ for subnormals and NaN payloads.

v0.1 covers existing assets, descriptors, the five dtypes above, contiguous owned storage, named inference/state, and typed errors. Graph authoring, custom Metal kernels, images/pixel buffers, packed low-bit formats, shared GPU storage, profiling callbacks, explicit Neural Engine control, and native cancellation are deferred.

The default feature set is empty. `abi-research` exposes unsafe experimental probes for development; it is outside the ordinary safe API. Native framework initialization and model specialization need an execution environment that permits Core AI allocation/cache access.

The initial tiny feed-forward benchmark showed higher round-trip latency than Python: CPU-only median approximately 1.17 ms in Rust versus 69 µs in Python, and GPU-preferred approximately 1.65 ms versus 530 µs. Each used ten warmups and one hundred samples, including owned host tensor copies and completion. The cause is unresolved; these measurements support no speedup claim or conclusion about larger models. Cold compilation/loading was not measured.

## Examples and diagnostics

The package includes [a feed-forward example](examples/feedforward.rs), [a stateful sequence](examples/stateful.rs), and their tiny model assets. Both examples forbid unsafe code.

```sh
cargo run --example feedforward
cargo run --example stateful
cargo run --bin corsairs -- --help
```

The `corsairs` CLI supports `inspect`, `run`, and `bench`; run `--help` for exact arguments. Input files contain contiguous little-endian scalar bytes. The CLI accepts an explicit CPU-only or GPU-preferred compute selection.

## License

Licensed under either the [MIT license](LICENSE-MIT) or the [Apache License, Version 2.0](LICENSE-APACHE), at your option.
