# Rust inference overhead: source audit

Read-only audit on 2026-10-15; no model/native benchmark was launched. [manifest.json](manifest.json) pins 17 inspected files and the compiled, unexecuted lookup probe. Every inspected library source present in the frozen library manifest matches it. The two Python wrapper files and native extension match the b3 wheel's RECORD. [call-counts.json](call-counts.json) contains the expanded symbol ledger.

The retained [tiny benchmark](../tiny-baseline/roundtrips.json) reports Python/Rust medians of **65.875/1078.333 µs CPU** and **453.541/1479.958 µs GPU-preferred**. Source inspection identifies repeated work; it does **not** attribute those gaps to any one operation. Parent-reported first H3 retained-plus-download timings instead favor Rust, so the toy ratio is not a general runtime ratio.

## Confirmed repeated work

`native/loader.rs:39` calls `dlsym` for every `Library::symbol`; there is no symbol cache. `NativeSession::call`, `pair`, `metadata`, `optional` and `release` all reach that resolver (`native/owned.rs:307–355`, `native/mod.rs:81`). Nominal metadata is requested synchronously and its VWT/layout re-read and validated each time. Swift may internally cache metadata; this audit does not claim repeated metadata construction.

For **one F32 rank-2 input, one F32 rank-2 output, no state/output bindings**, the successful owned path has these explicit lookup counts:

| Work | `dlsym` calls |
|---|---:|
| Allocate/build/upload input tensor | 13 |
| Construct Inputs and insert input RawView | 5 |
| Construct two empty MutableViews containers | 3 |
| Outputs metadata | 1 |
| Swift task support and async entry descriptor | 10 |
| Output projection metadata, remove and NDArray projection | 6 |
| Read shape/strides/dtype/bytes | 20 |
| Check remaining output count | 1 |
| **Total** | **59** |

This includes **11 nominal and 3 generic metadata accessor calls**, plus **4 enum-case symbol lookups**. Classification at `native/owned.rs:613` reads the native tag, then resolves case symbols until matching: F16/BF16/F32/I32/I64/Bool require 1/2/3/4/5/6 lookups. Shape and stride extraction each resolve count/subscript APIs; `integers` resolves the subscript again for every dimension. The input shape's modify/resume pointers are already reused within its loop.

The same path makes **14 `NativeValue::allocate` calls**, each using `alloc_zeroed`; additional Swift/Rust collections, native tensor storage and task allocations are separate. Owned input cloning and upload copy payloads; output readback zero-initializes a Rust byte vector before copying into it. Validation is repeated at facade/native/construction boundaries. Bool additionally scans payload bytes; F32 validation is shape/length work.

Retained `run_native` avoids input tensor reconstruction, but still rebuilds view containers, creates a task and queries output metadata: **43 lookups** for the same signature. A subsequent handle download performs **20 more** and a separate worker request; it re-queries shape, strides and dtype rather than using the record's existing metadata (`native/owned/handles.rs:62,129,178`). These are path-specific manual counts, excluding framework-internal work and error branches.

## Scheduling and Python boundary

Each public request allocates an Arc/Mutex result and boxed closure, updates the submission registry and sends through MPSC (`worker.rs:294`). `Task::wait` installs a waker and may park/unpark the caller (`worker.rs:26`); this is a possible scheduler cost, not a measured delay. Native inference separately creates a genuine Swift task, allocates an Arc completion state and joins through a mutex/condvar. Task identity/TLS checks and completion bookkeeping remain in the production path (`native/async_task.rs:135–219`, `async_task/pending.rs:102,162`). There are five explicit current-task getter calls per successful native call. The native condvar only waits if completion is still pending; Inline scheduling does not necessarily suspend.

The shipped Python facade instead unwraps existing NDArray handles, builds argument dictionaries, awaits its native extension and wraps returned handles (`_inference_function.py:24,87–108`). Its F32 `numpy()` path requests DLPack; the benchmark's subsequent `tobytes()` performs the owned output copy (`_ndarray.py:125`). The extension's internal lookup, allocation and executor costs were **not** reconstructed here. Do not infer that Python has no Swift task or synchronization overhead.

Model/function loading, descriptor inspection, `sw_vers`, framework opening and Text's constructor/release resolution occur outside warm run calls. Text's function pointers are already cached. The executor image pin is protected by OnceLock. ErrorSupport loading/reflection is an error-path cost, not part of these successful rounds.

## Small next measurements

1. Run the compiled lookup-only probe after GPU timings: `target/benchmark-overhead/dlsym-owned-run 100000`. It makes 5.9 million timed lookups, verifies address stability, reports total/per-lookup/per-59-lookup-batch nanoseconds and measures a separate cached-pointer control. It never calls a resolved symbol. Initial loading/resolution, warmup and closing are excluded. Its source is [dlsym_owned_run.c](../../../../experiments/c/dlsym_owned_run.c); the binary hash/build command are pinned in the manifest. No cost result exists yet.
2. Sample a long **tiny CPU** loop in the existing frozen Rust harness. Inspect the `corsairs-coreai` worker for dyld lookup stacks, tensor/view allocation and Swift task machinery; distinguish its blocked native join from the caller's parked `Task::wait`. The existing `worker_flush`, upload, download, owned and retained phases separate broad costs without changing production.
3. If lookup cost is material, test session-owned cached symbol addresses, copied complete metadata and verified enum tags in a separate change. Preserve image ownership, per-session confinement and actual completion/error cleanup. Re-measure the same boundaries before changing pooling, task reuse or synchronization. Source counts alone do not justify weakening those contracts.
