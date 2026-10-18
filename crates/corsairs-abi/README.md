# Corsairs

**CORe AI — RS**, with an extra S. Safe Rust inference using Apple's existing Core AI implementation.

Corsairs loads `.aimodel` assets, inspects named function signatures, and executes named inputs, outputs, and state. Applications can use owned tensors, retained native tensor handles, or persistent shared Metal buffers. Native ownership stays on a dedicated worker. No Python interpreter or custom Swift wrapper is required by the application.

The v0.3 API targets Apple Silicon on macOS 27 with Rust 1.99 or later. The recorded host is macOS 27.0.1 (26A434), Rust 1.99.0, and Xcode/SDK 27. The published v0.1 passed 32 differential configurations and 16 negative cases against pinned `coreai-core 1.0.0b3`, plus 40,000 checked stress inferences in each Rust profile. The v0.2 validation adds dynamic signatures, native storage, and BF16. The [Krea fixture](https://github.com/bubstackdev/corsairs/blob/main/docs/v0.2-krea.md) matches Swift's encoded text, all eight latent steps, and decoded pixels. [H3 acceptance](https://github.com/bubstackdev/corsairs/blob/main/docs/v0.2-h3.md) matches the original-weight block, all 50 schedule pairs, and a synthetic 50-block backbone with staged model acquisition. Full H3 generation, full Python API parity, and other OS builds remain outside that evidence.

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

Loading and execution return `Task<T>`, which implements `Future<Output = Result<T, Error>>`. Use `.await` inside an async application or `.wait()` in synchronous code. Submission starts immediately; dropping the task discards interest in its result while its owned request and native storage remain alive through completion. It does not cancel native work. To prevent a request that has not started, call `task.cancel_handle().cancel()`: `Cancel::Prevented` means it will never reach Core AI and the task resolves to `Error::Cancelled`; `Cancel::TooLate` means it already started or finished. Core AI provides no way to stop running work.

## Tensors and state

| Tensor dtype | Rust element type |
| --- | --- |
| float16 | `Float16` |
| bfloat16 | `BFloat16` |
| float32 | `f32` |
| float64 | `f64` |
| float8_e4m3fn / float8_e5m2 | `Float8E4M3Fn` / `Float8E5M2` |
| int8 / int16 / int32 / int64 | `i8` / `i16` / `i32` / `i64` |
| uint8 / uint16 / uint32 / uint64 | `u8` / `u16` / `u32` / `u64` |
| bool | `bool` |

On the Neural Engine, int8/uint8 overflow saturates instead of wrapping, and int16 values beyond ±2048 can be rounded even by layout-only operations. Compare results with the same compute configuration.

`Tensor::from_vec` checks the shape and element count. `Tensor::zeros` initializes owned storage. `Tensor::from_bytes` accepts exact little-endian scalar bytes and validates boolean encodings. `to_vec::<T>()` checks the dtype and copies typed values. `Float16::from_bits` and `BFloat16::from_bits` preserve their distinct 16-bit encodings. Both provide `from_f32` and `to_f32`; BF16 narrowing rounds to nearest with ties to even. Raw BF16 storage preserves every encoding, including NaN payloads.

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

Cloned runtime/model/function handles share the same worker and retain their native resources. Worker requests execute in submission order; an explicit `Runtime::load_models` batch starts independent native loads before joining all of them. `Tensor` clones make independent byte copies; `Function::run` copies inputs into native storage and completed outputs/state back into Rust storage. `Runtime::flush()` fences work and releases already queued; cleanup scheduled by those jobs may follow the fence. Use `Runtime::drain()` to wait for preceding submissions and cleanup they cause transitively. Drop retained handles before draining when switching resident stages. Draining does not release handles the application still owns or promise that the OS evicts cached pages.

Descriptors preserve dynamic dimensions as `None`. Every invocation supplies concrete shapes and must match the dtype, rank, and fixed dimensions. Outputs report their actual shapes after execution. Rank is limited to 64. Storage and CPU execution accept at most 4 GiB per tensor. GPU-preferred inference accepts at most 2 GiB per tensor and referenced storage span, including nonzero-dimension guards for empty tensors. Fixed signatures and concrete inputs/bindings are checked before dispatch; dynamic outputs are checked after fenced readiness, before host copying or publication. This accepted-result policy cannot bound unknown intermediate tensors, graph memory, allocation, or execution time; an oversized dynamic result may execute before rejection. Stateful owned/native GPU calls require fixed input/state/output signatures within 1 GiB; CPU-only execution and explicit Metal state bindings are alternatives. These limits do not guarantee graph/device capacity or simultaneous asset residency. Non-tensor values remain unsupported.

`Runtime::upload` returns a retained `TensorHandle`. Feed `TensorHandleMap` values through `Function::run_native` to keep intermediate NDArray storage native, then call `download()` explicitly. Handle clones share contents, including in-place state updates. Downloads pack nonnegative strides; negative strides are currently unsupported. Handles must belong to the same runtime, and conservative alias checks can reject mutable state derived from inference outputs.

## Compute and scope

`Compute::CpuOnly` selects CPU-only specialization. `Compute::GpuPreferred` requests GPU preference while permitting Core AI's fallback choices; it does not guarantee that every operation executes on a GPU. `Compute::NeuralEnginePreferred` prefers the Neural Engine with the same fallback; because operations may still run on the GPU, it uses the GPU stream and size bounds. Compare numerical results with the same configuration: backend behavior may differ for subnormals and NaN payloads.

`load_model_with_options` accepts `LoadOptions::new(compute).with_expect_frequent_reshapes(true)` for a per-model reshape hint. Omitting the hint preserves the SDK default. It does not replace offline fixed-shape specialization. `ModelLoadRequest` supplies independent paths/options to `Runtime::load_models`; errors join every started load before batch resources are released.

`Runtime::load_functions` accepts `FunctionLoadRequest` values to materialize functions from distinct retained models concurrently. This overlaps the expensive function-loading stage as well as asset opening. Functions retain their models, and every started call joins before errors or dropped results are cleaned up. Models in one function batch must belong to the same runtime and have distinct handles.

Stateless owned/native GPU calls use one private persistent Metal queue and Core AI stream per runtime, retaining native storage through readiness and completion fences.

`Runtime::metal_queue` creates a persistent Metal queue and Core AI stream. Shared `MetalBuffer` values provide checked tensor storage and explicit output/state bindings for `Function::encode`. Unsafe import/export methods connect application-owned queues and buffers under documented lifetime, aliasing, and synchronization contracts. Each encoded call currently fences and checks throwing readiness before returning; submission pipelining is deferred. Explicit mutable bindings require fixed descriptor shapes. Dynamic outputs can be allocated by Core AI. Private/managed buffer host access remains unsupported.

Graph authoring, application Metal kernels, images/pixel buffers, packed low-bit formats, profiling callbacks, explicit Neural Engine control, and cancellation of running native work remain outside the general inference API. Applications own model-specific schedules, kernels, tokenization, and asset/cache policy.

The default feature set is empty. `abi-research` exposes unsafe experimental probes for development; it is outside the ordinary safe API. Native framework initialization and model specialization need an execution environment that permits Core AI allocation/cache access.

The historical, uncached tiny feed-forward benchmark showed higher round-trip latency than Python: CPU-only median approximately 1.17 ms in Rust versus 69 µs in Python, and GPU-preferred approximately 1.65 ms versus 530 µs. Each used ten warmups and one hundred samples, including owned host tensor copies and completion. v0.3 caches native symbol resolution per loaded library. In three alternating before/after pairs on this host, tiny CPU owned-call medians fell from about 1.18 ms to 34 µs, with ten warmups and one hundred checked samples per process. The matched H3/Krea graph measurements remain similar to Python. These are scoped same-host observations, not a general speedup guarantee; see the repository's `docs/v0.3-symbol-cache.md` and `docs/v0.3-benchmarks.md`. Cold compilation/loading was not measured.

## Examples and diagnostics

The package includes [a feed-forward example](examples/feedforward.rs), [a stateful sequence](examples/stateful.rs), [native tensor chaining](examples/native_chain.rs), [Metal buffer chaining](examples/metal_chain.rs), and their tiny model assets. All four examples forbid unsafe code.

```sh
cargo run --example feedforward
cargo run --example stateful
cargo run --example native_chain
cargo run --example metal_chain
cargo run --bin corsairs -- --help
```

`Runtime::inspect_asset(path, statistics)` reads an asset's author, license, description, creation date, declared functions and, optionally, operation and storage statistics without loading a model. A path that is not a valid asset returns `Error::InvalidAsset`. `Runtime::device_architecture()` reports Core AI's device architecture name.

The `corsairs` CLI supports `inspect`, `run`, and `bench`; run `--help` for exact arguments. Input files contain contiguous little-endian scalar bytes. The CLI accepts an explicit `cpu`, `gpu-preferred`, or `neural-engine-preferred` compute selection.

## License

Licensed under either the [MIT license](LICENSE-MIT) or the [Apache License, Version 2.0](LICENSE-APACHE), at your option.
