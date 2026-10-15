# Warm public-API phase measurements

`benchmark_v03.rs` forbids unsafe code and is compiled directly against the
frozen default-feature release library under `target/large-check/cargo`.
[The build manifest](manifest.json) pins the executable, library, source
snapshots and shared JSON case files. No package installation is required.
Build preparation and Rust-argv generation execute no Core AI operations.
All native launches are coordinated separately on the quiet host.

## Boundaries

Each phase has its own warmups and retains every measured nanosecond sample.
Input/expected files and model source hashes are read before model loading.
Model and function loading are observed separately, without cache purging.
Calls are sequential, with no batching or pipelining.

| Phase | Rust measured interval | Public Python b3 measured interval |
| --- | --- | --- |
| `worker_flush` | Submit an ordered worker marker and wait | Unavailable |
| `upload_inputs` | Clone owned inputs, allocate/upload each native tensor and wait | Clone host arrays and construct each NDArray |
| `download_inputs` | Download every persistent native input into owned host tensors | `numpy()` and `tobytes()` for every persistent input |
| `owned_run` | Clone owned input map/bytes, submit/await, return all owned output bytes | Clone host inputs, construct NDArrays, submit/await, `numpy()` and `tobytes()` for all outputs |
| `native_run` | Clone handle map, submit/await retained native outputs | Copy handle dictionary and submit/await retained NDArrays |
| `native_run_download` | Retained run plus download of every output | Retained call plus `numpy()`/`tobytes()` of every output |
| `metal_encode` | Clone persistent binding maps, encode into reused preallocated buffers, await public fence/readiness | Unavailable |
| `metal_encode_download` | Same encoded call plus host download of every output | Unavailable |

Retained/native and Metal inputs are prepared once outside sample windows.
Metal output buffers are also allocated once and reused within each phase.
Every iteration compares the full result bytes, dtype, shape and name set with
the fixed expected output, after stopping the timer. Phases without host output
readback perform diagnostic downloads **outside** their measured interval.
Results are then dropped; Rust waits on a transitive drain, while Python drops
references and yields once to its event loop. Python exposes no public worker
drain. This per-iteration correctness/cleanup protocol adds untimed host work
and spacing; it is not an uninstrumented streaming-throughput measurement.

`native_run` measures the public await-return boundary without adding a separate
GPU fence. It must not be described as a separately established device-complete
latency. Metal phases explicitly include the current public fence/readiness
contract. Differences between named phases are observations across complete API
boundaries, not an additive cost attribution proof.

Median averages the two central observations for even sample counts. P95 is the
nearest-rank observation at `ceil(0.95 * count)`. Every raw sample is retained.
Small fixture cases default to ten warmups/100 samples; the H3 cases request
three warmups/ten samples. The caller can override either and can select phases.

Both languages use the same case's compute preference and omit the reshape
override. Public b3 has no reshape-hint setter, so Python rejects an explicit
override. H3 application acceptance uses an explicit true hint separately.
All H3 cases use the existing raw BF16/F32 assets; the functional case supplies
ten original BF16 weight inputs. No float16 substitution is performed. Cases
remain stateless; stateful benchmark semantics are deliberately unspecified.

## Commands

Generate the exact Rust command as a JSON argv list. This only reads metadata
and prints arguments; it does not import Core AI or launch either executable:

```sh
python3 -B scripts/reference/benchmark_v03.py \
  --case docs/evidence/v0.3-benchmarks/cases/feedforward-gpu-preferred.json \
  --rust-argv --output-dir /private/tmp/corsairs-bench/pair01
```

Launch that argv through the coordinated native runner. For the Python arm,
launch the pinned CPython 3.12 executable through the same native mechanism:

```text
/Users/zakkeown/.local/bin/python3.12 -I -B \
  /Users/zakkeown/Code/aether/lab/corsairs/scripts/reference/benchmark_v03.py \
  --case /Users/zakkeown/Code/aether/lab/corsairs/docs/evidence/v0.3-benchmarks/cases/feedforward-gpu-preferred.json \
  --output-dir /private/tmp/corsairs-bench/pair01
```

Use a fresh process and output directory for each arm. Alternate Rust/Python
order over multiple pairs. Record that order and the actual system/cache state;
the script never purges SDK/OS/filesystem caches. `--phases` accepts a comma list,
such as `owned_run,native_run,native_run_download`, to compare only common
boundaries. Omit it for all phases supported by that language. Python records
unavailable requested worker/Metal phases explicitly. `--output` can select one
specific report path. `--warmup` and `--samples` override case defaults.

The additional shared cases are `double_float32-{cpu,gpu-preferred}`,
`feedforward-cpu`, `h3-cached-128`, `h3-cached-19350` and
`h3-functional-19350`, under the sibling `cases` directory. H3 cases use the
root-prepared checked int64-to-int32 tags and retain original-source hashes.
GPU-preferred is a specialization policy, not a proof that every operator uses
the GPU. Exact expected output verification remains mandatory for both arms.
