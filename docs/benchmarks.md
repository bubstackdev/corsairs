# Initial v0.1 benchmarks

The current safe Rust path had higher round-trip latency than the published Python bindings in this recorded tiny feedforward workload. Both produced exactly matching output bytes and metadata. These measurements support no speedup claim.

The [complete raw report](../fixtures/parity-v01/python-benchmark.json) retains every sample, loading observation, command, model hash, reference dependency identity, and Rust CLI hash. The model is [the prepared feedforward fixture](../fixtures/parity-v01/feedforward/graph.mlir): float32 input `[2, 3]`, two matrix multiplications with an intermediate bias and ReLU, and output `[2, 2]`.

## Warm owned-host round trips

Each configuration used ten warmup calls followed by one hundred measured calls. Values are microseconds per completed call.

| Compute configuration | Python median | Rust release median | Python p95 | Rust release p95 |
| --- | ---: | ---: | ---: | ---: |
| CPU-only | 69.125 | 1,171.542 | 104.833 | 1,326.917 |
| GPU-preferred | 529.833 | 1,648.083 | 1,250.292 | 2,059.375 |

The timed boundary includes cloning owned host inputs, allocating/initializing native tensors, submitting inference, awaiting completion, and copying output/state bytes into owned host storage. This fixture has no state. Imports, runtime initialization, model/function loading, and correctness checks are outside these per-call samples. Python uses `perf_counter_ns`; Rust uses `Instant`. Both report the upper middle sorted sample as the median and sample index `floor((n - 1) * 0.95)` as p95.

The two implementations use the identical asset, input bytes, and compute configuration. The benchmark checks output bytes, dtype, shape, and strides against the frozen Python backend golden before accepting the comparison. The output SHA-256 is `a2a7a317ce9b5613295fa447eec7272845a413f518596e5d6fc65aa562297588`; the asset bytecode SHA-256 is `920f670862f6a40e3875fd81a251d7b9eb24b6e373eda83fb693c9dfc6261b79`.

## Cache-warm loading observations

Previously specialized assets remained cached. These are single cache-warm model-loading observations; cold compilation/loading was not measured. Function loading is outside these figures.

| Compute configuration | Python load, µs | Rust release load, µs |
| --- | ---: | ---: |
| CPU-only | 4,982.584 | 23,186.792 |
| GPU-preferred | 1,080.125 | 29,769.209 |

## Environment and limits

The run used one Apple Silicon arm64 host, macOS 27.0.1 build 26A434, CPython 3.12.14 with pinned `coreai-core 1.0.0b3`, and the Rust release CLI. The [compatibility record](compatibility.md) and [retained build manifest](evidence/v0.1/build-manifest.json) identify the investigated toolchain. The benchmarked CLI SHA-256 was `605bf4c29bbf0d5e3b148bd0749e999f85dcd09a357907a7271b3bfcbd8c0f2b`.

REA launched the Python root process with an entry breakpoint before timing began. Its Rust CLI subprocesses ran without breakpoints. Runs were sequential in fixed order: Python CPU, Rust CPU, Python GPU-preferred, Rust GPU-preferred. There was one timing batch per configuration; no randomized order, confidence interval, controlled machine-load study, or repeated host matrix was collected. GPU preference allowed CPU and Neural Engine as well as GPU; it does not identify the delegate that executed each operation.

No profiler separated scheduling, allocation, synchronization, host copying, or device costs. The cause of the observed Rust latency is unresolved. This tiny workload and these launch conditions do not establish performance for larger models, sustained throughput, zero-copy storage, other OS builds, or device kernels in isolation.

## Reproduction

From a permitted native environment with the pinned development reference installed/prepared:

```sh
cargo build -p corsairs --release
python3.12 -I -B scripts/reference/benchmark.py --rust-cli target/release/corsairs
```

The independent benchmark script and Rust `bench` command both default to ten warmups and one hundred samples. Keep the raw report and binary/model identities when comparing changes. Performance work follows this correctness baseline and must report regressions as well as improvements.
