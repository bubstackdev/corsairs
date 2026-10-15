# Read-only Aether H3 performance audit

The retained attempt does not establish completed-render latency or show that Corsairs overhead caused the slowdown. It was stopped after **22 of 50 steps**, before either decoder. The source does establish substantial synchronization amplification: **52 encoded calls and 161 completion-fence helper calls per step**, alongside a large source-precision workload.

No native target, GPU workload, profiler, Python package import, or benchmark was launched for this audit. [Structured evidence](audit.json) records identities, source-derived counts, hypotheses, and limits. All writes are confined to this evidence directory.

## What ran

The [initial report](production-report.json) requests **960×544, 124 frames at 24 fps**, about 5.167 seconds of media, with 49 text rows and no supplied conditioning/noise. Its `passed: false` is the initial placeholder; SIGTERM prevented the final report update. This is an incomplete attempt, not evidence of a numerical failure. The [stop record](production-stop.json) retains the user-requested termination and REA evidence ID `ev_23fac2f37c4aa754a14bb148d3a6df624a1e6235d2793282eea8c24da2f4d636`.

The [journal](production-events.jsonl) contains 50 completed conditioner layers, 50 modulation groups, 50 weight groups, and 22 completed steps (last index21). There are no decoder events. From the [sample's](production-sample.txt) launch time to the retained kill invocation, the derived wall interval is **1,596.533 seconds**. That includes all startup, 22 completed steps, and any interrupted step; it is not a per-step measurement or final-render estimate. The journal contains no phase timestamps, and the final `elapsed_seconds` write occurs only after the pipeline returns. Sources: [journal callback](</Users/zakkeown/Code/aether/lab/aether-prototype/examples/h3_generate.rs:85>), [final timing](</Users/zakkeown/Code/aether/lab/aether-prototype/examples/h3_generate.rs:210>).

The [frozen manifest](frozen-manifest.json) matches all **66 current and retained source files**. Its binary hash `ec135d7a62662f0b7cbdb10e0bd8ab9e855b2a449551b14cc9cb36f869122e50` also matches `target/release/examples/h3_generate`. The [bundle](frozen-bundle.json) describes this exact profile. There is no evidence here of an accidental debug executable.

## Execution and copies

All models use `GpuPreferred` with explicit `expect_frequent_reshapes=true`. GPU preference does not prove that every backend operation ran on the GPU. Body weights/hidden state use BF16; authoritative video/audio latents and scheduler updates use float32, and rotary tables use float32. Internal kernel accumulation precision is not established. Sources: [load options](</Users/zakkeown/Code/aether/lab/aether-prototype/src/h3/assets.rs:19>), [float32 scheduler boundary](</Users/zakkeown/Code/aether/lab/aether-prototype/src/h3/pipeline.rs:507>).

| Phase | Source-derived work and residency |
| --- | --- |
| Initial integrity | 108 unique asset bytecode streams, totaling 88,279,632,094 bytes by filesystem length, are hashed before first use. This audit checked metadata/source identities, not those large streams again. |
| Conditioner | Embedding plus 50 layers use 51 owned `Function.run` calls, loading/dropping each stage and draining; hidden/cos/sin cross owned host boundaries. |
| Time/modulation preparation | 50 owned time-embedding calls and **2,500 owned modulation calls**; 50 projector models load once each. Cached host modulation tables occupy 958,003,200 logical bytes. |
| Body parameters | 500 raw BF16 tensors, **38,536,268,800 bytes**, are read, hashed, and uploaded once into persistent Metal storage. They are retained across steps. |
| Each denoising step | Two latent writes, prepare encode, 50 table uploads/body encodes, head inputs/encode, two velocity readbacks, CPU float32 update, and step hashes. |
| Hidden boundaries | 19,333 joint rows; two persistent BF16 `[1,19333,5376]` buffers, 207,868,416 bytes each, alternate across blocks. No owned host hidden-state round-trip occurs per block. |
| Model retention | Prepare and heads remain loaded. The body switches from cardinality1 at step0 to cardinality2 at step1, then remains loaded; it is not reloaded per block or every step. |
| Decoders, if reached | One owned audio call, then seven overlapping owned 22-frame video-window calls. Neither decoder ran in this attempt. |

Sources: [integrity loop](</Users/zakkeown/Code/aether/lab/aether-prototype/src/h3/assets.rs:175>), [parameter read/hash](</Users/zakkeown/Code/aether/lab/aether-prototype/src/h3/assets.rs:59>), [conditioner](</Users/zakkeown/Code/aether/lab/aether-prototype/src/h3/pipeline.rs:137>), [modulation preparation](</Users/zakkeown/Code/aether/lab/aether-prototype/src/h3/pipeline.rs:336>), [persistent uploads](</Users/zakkeown/Code/aether/lab/aether-prototype/src/h3/pipeline.rs:389>), [body retention and execution](</Users/zakkeown/Code/aether/lab/aether-prototype/src/h3/pipeline.rs:420>), [decoder windows](</Users/zakkeown/Code/aether/lab/aether-prototype/src/h3/pipeline.rs:586>).

## Binding boundaries that could amplify overhead

Each `metal_encode` performs a [preflight fence](</Users/zakkeown/Code/aether/lab/corsairs/crates/corsairs-abi/src/native/owned/metal.rs:751>) and [completion fence](</Users/zakkeown/Code/aether/lab/corsairs/crates/corsairs-abi/src/native/owned/metal.rs:858>), then awaits output readiness. The [fence helper](</Users/zakkeown/Code/aether/lab/corsairs/crates/corsairs-abi/src/native/owned/metal.rs:270>) awaits Core AI stream completion and commits/waits an empty Metal command buffer. Uploads/writes/readbacks also fence.

For a successful source step, this yields **161 fence-helper calls**:104 from52 encodes,50 table uploads,2 latent writes,3 other uploads, and2 readbacks. There are53 output-readiness getters. Thus the full planned50-step loop implies8,050 helpers and10,700 native async child calls from these fences/getters. These are control-flow counts, not measured timing or an assertion that all barriers are unnecessary. The safe API currently completes each encode before publishing its result.

The worker uses a [serialized request queue](</Users/zakkeown/Code/aether/lab/corsairs/crates/corsairs-abi/src/worker.rs:173>); native calls allocate Swift task contexts and [wait on a condition variable](</Users/zakkeown/Code/aether/lab/corsairs/crates/corsairs-abi/src/native/async_task/pending.rs:102>). No fixed polling sleep was found. Per-call dictionary/view/metadata construction and [repeated `dlsym` calls](</Users/zakkeown/Code/aether/lab/corsairs/crates/corsairs-abi/src/native/loader.rs:39>) add CPU work; its duration is unmeasured.

The retained approximately1.6-second CPU sample catches the Corsairs worker in native fence/condition-variable waiting for1,598 of1,621 samples and output-readiness waiting for14 more. Its reported physical footprint is44.3G, peak44.4G. This supports investigating completion/backend waiting. It does not distinguish GPU arithmetic, backend submission, redundant synchronization, memory pressure, or external GPU contention, and it cannot attribute the entire attempt.

## Comparison with published Python and remaining gaps

The pinned `coreai-core 1.0.0b3` [Python wrapper](</Users/zakkeown/Code/aether/lab/corsairs/.local/reference/coreai-b3/coreai/runtime/_inference_function.py:87>) passes existing native NDArray objects into one awaited compiled binding call and wraps returned native arrays. Its [NumPy conversion](</Users/zakkeown/Code/aether/lab/corsairs/.local/reference/coreai-b3/coreai/runtime/_ndarray.py:114>) can return shared contiguous views. Corsairs' owned path reconstructs native arrays and copies outputs; Aether uses that path for preparation and decoding, while its body already uses retained Metal storage. The compiled Python extension's scheduling/fences are opaque to this source audit. Runtime backend selection must also match; [wheel/development defaults and environment overrides differ](</Users/zakkeown/Code/aether/lab/corsairs/.local/reference/coreai-b3/coreai/runtime/__init__.py:44>).

There is no matched Python/Swift production-render timing, stage timestamp series, GPU timeline, memory-pressure record, or quiet-host baseline here. Startup hashing/loading, owned modulation traffic, per-block completion overhead, and the large50×50 source-precision body workload are plausible contributors; their shares remain unknown. Before an authorized rerun, collect phase/call timings and compare identical assets, precision, options and backend. Any batched-completion experiment must retain native lifetimes and throwing readiness; this audit changes none of those contracts.

## Closest retained functional-body fixtures

The [component input inventory](functional-benchmark-inputs.json) supplies exact paths, shapes, hashes, checked tag conversion and production schemas without copying weights. Both lab cases expose10 source-precision weight tensors as inputs, totaling770,725,376 bytes. They use entrypoint `block`, GPU preference, and the true reshape hint.

| Existing Swift comparison | Rows | Non-warmup samples per arm | Functional median, s | Other arm median, s |
| --- | ---: | ---: | ---: | ---: |
| [Synthetic functional/cached](reference-functional-gpu-19350.json) | 19,350 | 6 | 0.588506 | Cached0.578030 |
| [Actual-layout first block functional/live](reference-packed-first-gpu-19333.json) | 19,333 | 6 | 0.559660 | Live0.572624 |

Those historical intervals include `run`, output readiness and a full207/208MB raw output copy, ending before hashing/comparison; model loading, input/weight allocation and modulation generation are excluded. See [the original timing boundary](</Users/zakkeown/Code/atelier/lab/minimax-h3-lab/Tests/Block.swift:220>). They do not show a large functional-versus-constant penalty in these isolated NDArray calls, but they do not measure Aether's complete weight residency or its Metal path.

The19,333-row packet uses `packed-block-text-first.json` inputs, `packed-text-first-functional.aimodel`, and **GPU** `gpu-modulations.raw` (`ae84a1b6…`); its CPU modulation file has different bytes and is unsuitable for the exact Swift gate. Expected output is `8a54a3add9162492963b1d864ec4406a492a40ef003c99f55c541f0c474c9a38`. All15 inputs total993,712,404 runtime bytes, including weights. The19,350-row packet's exact output is `f02ea0a551bac61416825e2d070fb13bd9cc5160794cbda6966f301c98ebe92a`.

Production `body-1.aimodel/main` has the same first-step input shapes as the19,333-row lab packet; `body-2.aimodel/main` changes the modulation table from BF16 `[6,3,5376]` to `[6,6,5376]`. These production assets have different bytecode identities, so lab output equality must be verified rather than assumed. No actual later-step hidden/table payload was saved by the stopped production run. Retained NDArray/handle inputs plus matched full readback provide a fair Python/Rust call boundary; cloning all770.7MB of weights per owned call would measure host traffic absent from Aether's body path. A separate Swift Metal arm is needed to isolate the production Metal completion policy.
