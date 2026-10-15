# Benchmarks

The [v0.3 matched Python measurements](v0.3-benchmarks.md) cover full-size H3,
Krea, small-call phases, published benchmark context and the symbol-lookup
overhead profile. Large-graph calls have similar latency; tiny Rust calls retain
about 1 ms of avoidable overhead. The historical results below remain unchanged.

The v0.1 safe Rust path had higher round-trip latency than the published Python bindings in the recorded tiny feedforward workload below. The v0.2 Krea pairs recorded lower native-carry generation intervals in each pair, with high variance and mixed RSS results. Separate preparation pairs recorded shorter batch-loading intervals with higher child RSS. These measurements establish no general performance guarantee.

## v0.1 tiny feedforward workload

Rust and Python produced exactly matching output bytes and metadata.

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

## v0.2 Krea owned/native pairs

Three alternating pairs compare the owned host-copy path with retained native carries using the same fixed 768×1344 Krea fixture and one pinned release build. Every render matched all three first-segment carries, eight latent steps, final latent, and decoded pixels. An [independent verification](evidence/v0.2-krea/paired/payload-verification.json) rehashed all 78 saved payloads against the original Swift records. The [aggregate](evidence/v0.2-krea/paired/aggregate.json), [pair 1](evidence/v0.2-krea/paired/pair-01-benchmark.json), [pair 2](evidence/v0.2-krea/paired/pair-02-benchmark.json), and [pair 3](evidence/v0.2-krea/paired/pair-03-benchmark.json) retain the raw observations and links to all six render-report snapshots.

Generation intervals, in seconds:

| Pair | Execution order | Owned | Native carries | Owned minus native |
| --- | --- | ---: | ---: | ---: |
| 1 | Owned, native | 39.611 | 36.089 | 3.522 |
| 2 | Native, owned | 31.368 | 25.893 | 5.476 |
| 3 | Owned, native | 42.467 | 28.350 | 14.117 |
| Arm median | | 39.611 | 28.350 | |

Native intervals were lower in every observed pair. The paired differences vary substantially, and owned/native ranges overlap: 31.368–42.467 seconds owned and 25.893–36.089 seconds native. These six instrumented renders do not establish general latency, sustained throughput, or the cause of the timing differences.

Descriptive medians across the three renders per arm:

| Recorded interval, seconds | Owned | Native carries |
| --- | ---: | ---: |
| Denoiser preparation | 19.840 | 22.307 |
| Sum of 32 segment calls | 38.196 | 27.202 |
| Sum of eight complete steps | 38.710 | 27.624 |
| Owned decoder call | 0.529 | 0.526 |
| Whole Rust child | 56.409 | 48.252 |

Each arm ran one generation in a fresh Rust process under its own fresh Python checker. Both used serial denoiser preparation, GPU-preferred compute, explicit frequent reshapes for the four denoisers, and the original decoder with that hint disabled. The saved text/noise/rope inputs exclude text encoding and tokenization. There was no warmup render or cache purge. Full model source hashes were streamed before each arm, outside native child timing, while SDK/OS caches remained available. The [build manifest](evidence/v0.2-krea/paired/build.json) SHA-256 is `cb583a415b07d7dde831872f244980dc344d5f9d352502feb2bba48cd3ccd2f6`; all six runs use identical source, driver, and library identities. The [host record](evidence/v0.2-krea/paired/host.json) identifies an Apple M5 Max with 64 GiB RAM and OS build 26A434.

Generation timing begins after denoiser loading and includes first-carry checkpoint readbacks, hashes, disk writes, CPU float32 Euler, decoder loading, and decoding. Segment call timers cover submission through completion: owned calls construct native tensors and copy returned outputs, while explicit native uploads/downloads occur outside native call timers. Complete step intervals include that surrounding work. The decoder call interval excludes its separate model load and the subsequent output hash/write. Whole-child and whole-checker intervals have broader boundaries and are retained separately in the reports.

Process RSS results were mixed:

| Pair | Owned child RSS high-water, GiB | Native child RSS high-water, GiB |
| --- | ---: | ---: |
| 1 | 12.78 | 10.82 |
| 2 | 14.82 | 14.81 |
| 3 | 10.76 | 14.83 |

There is no consistent RSS reduction. These counters use Darwin `resource.getrusage(RUSAGE_CHILDREN).ru_maxrss`, in bytes, within each fresh checker; its preparation helpers also contribute to that maximum. Before/after high-water marks must not be subtracted, and RSS must not be added to separate Metal allocation accounting.

The [first native observation](evidence/v0.2-krea-pair-01-native.json), [second observation](evidence/v0.2-krea-pair-02-native.json), and [third observation](evidence/v0.2-krea-pair-03-native.json) launched the Python wrappers at an entry breakpoint; Rust children ran without requested breakpoints. Measurements were sequential on one host with alternating pair order. Thermal state, background system load, and cache residency were not controlled or sampled. Three pairs give no confidence interval or machine/OS matrix, and these results do not measure the Metal path or a full prompt-encoding render.

Prepare one common build, then use [`benchmark_krea.py`](../scripts/benchmark_krea.py) with `--native --no-build --pairs 1` and offsets `0`, `1`, and `2`, choosing a separate empty output directory for each observation window. Keep the source/build identity fixed across all three reports. Native execution must be coordinated so these renders run sequentially without another benchmark GPU workload.

## v0.2 Serial/batch preparation pairs

Three alternating pairs compare serial loading with the final same-runtime model/function batches for the four fixed Krea denoisers. The [aggregate](evidence/v0.2-krea/load-paired/aggregate.json), [pair 1](evidence/v0.2-krea/load-paired/pair-01-benchmark.json), [pair 2](evidence/v0.2-krea/load-paired/pair-02-benchmark.json), and [pair 3](evidence/v0.2-krea/load-paired/pair-03-benchmark.json) retain all six load-only reports. Independent [phase verification](evidence/v0.2-krea/load-paired/verification.json) reconstructs peak four overlapping invocation lifetimes in both model initialization and function materialization for every batch arm: four entries, four returns, and zero active after each join. All runs use the same [46-file build](evidence/v0.2-krea/load-paired/build.json), manifest `e96a58096a87d2cc454446eb5ddb276a7daf767a31c77d1bfdf42e64a77cd2d2`.

| Pair | Execution order | Serial preparation, s | Batch preparation, s |
| --- | --- | ---: | ---: |
| 1 | Serial, batch | 1.741641 | 0.757413 |
| 2 | Batch, serial | 1.778410 | 0.753073 |
| 3 | Serial, batch | 1.759193 | 0.755380 |
| Arm median | | 1.759193 | 0.755380 |

The observed preparation median was 1.759 seconds serial and 0.755 seconds batch. Batch loading also raised the child RSS high-water mark in every pair. Values below use decimal GB (`10^9` bytes); exact counters remain in the raw reports.

| Pair | Serial child RSS high-water, GB | Batch child RSS high-water, GB |
| --- | ---: | ---: |
| 1 | 15.912 | 24.270 |
| 2 | 15.912 | 24.288 |
| 3 | 15.912 | 24.273 |
| Arm median | 15.912 | 24.273 |

The median counters differ by 8,361,508,864 bytes: 8.36 GB (7.79 GiB) higher for batch loading. This is a measured latency/memory tradeoff for these cache-retaining preparation runs. RSS is Darwin's cumulative `RUSAGE_CHILDREN` high-water mark within each fresh checker, including its preparation helpers. It is not a Metal allocation measurement, and must not be subtracted from a prior high-water counter or added to separate Metal accounting.

Each arm prepares four models and their segment functions, checks signatures, then releases and flushes them. Primary timing starts after `Runtime` initialization and ends when all four functions are ready; release/flush and whole-child/checker times are separate. These runs perform no inference, encoder call, or decoder call and save no tensor outputs. The [full eight-step batch correctness gate](evidence/v0.2-krea/eight-step-parallel-functions.json) separately validates all 13 Swift payload hashes with this build.

Full source byte streams were verified before each arm, and SDK/OS/filesystem caches were retained without a purge. These are not cold-start measurements. The [first](evidence/v0.2-load-pair-01-native.json), [second](evidence/v0.2-load-pair-02-native.json), and [third](evidence/v0.2-load-pair-03-native.json) observation windows launched Python wrappers before timing; native Rust children had no requested breakpoints. Order alternated across three pairs on the same host. System load, thermal state, and cache residency were not controlled or sampled. Invocation overlap does not establish concurrent backend compilation or GPU execution, and these preparation measurements do not establish full-render latency or a general startup guarantee.

Reproduce with `benchmark_krea.py --native --no-build --comparison load-policy --pairs 1`, offsets `0`, `1`, and `2`, and separate empty output directories, keeping one prepared build fixed throughout.
