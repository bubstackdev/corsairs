# Published Python benchmark context

Research date: 2026-10-15. No models were executed for this research. Machine-readable measurements, source revisions, downloaded-source SHA-256 hashes, unknown fields and the 24 search queries are retained in [evidence.json](evidence.json).

No matched published **CoreAI b3 H3 or Krea benchmark on M5 Max 64 GB** was found within this search. This is a bounded finding, not proof that none exists. The closest original reports are:

| Original publisher | Published measurement | Relevance |
|---|---|---|
| [Ultralytics](https://github.com/ultralytics/ultralytics/blob/46f7dd3edaa04ca02d4cf12b33c57de1e9d34c4e/docs/en/integrations/coreai.md) | YOLO26n FP16, size 640, M4 16 GB: Python CoreAI b3 **16.8 ms CPU / 2.8 ms ANE-preferred**, including preprocessing and postprocessing. | Exact package version; different workload, hardware and compute preference. |
| [skymars13](https://github.com/skymars13/minimax-h3-mlx-64gb/blob/b788e667c62f63c358c705b6490295b9b62597a3/README.md) | H3 on **M5 Max 64 GB**, Python/MLX: 10-second 544×960 video, 6-bit DiT; **31.3 min at 15 steps**, **10.5 min with 4-step Turbo LoRA**. | Matching SoC/memory, but different runtime, precision and schedule. The wall-clock stage boundary is unspecified. |
| [00cyre](https://huggingface.co/00cyre/Krea-2-Turbo-Distill4-mflux-q8/blob/0cf3660684591954465013c4302c768b365f886d/README.md) | Krea q8 distilled checkpoint, Python/mflux, M5 Pro 48 GiB: **29.05 s**, 4 steps, 832×1216. | Generation context; different hardware, weights and sampler. Load is reported separately. |
| [john-rocky](https://github.com/john-rocky/coreai-model-zoo/blob/e680060e50ec9e33584f0e1ba15d9c4f243fab4d/knowledge/apple-models-bench.md) | Official Apple CLIP export, Python CoreAI, M4 Max 128 GB: FP16 **6.31 ms GPU / 3.68 ms ANE-preferred**. | Original community measurements, not Apple results; binding version unspecified. |

The inspected [Apple recipe catalog](https://github.com/apple/coreai-models/blob/90cc644367f27338c1ed512b9c4b68eb513d4317/models/README.md), top-level README and FLUX.2 README did not provide a qualifying H3/Krea timing table. Apple's retained [benchmark source](https://github.com/apple/coreai-models/blob/90cc644367f27338c1ed512b9c4b68eb513d4317/swift/Sources/Tools/benchmark/BenchmarkMain.swift) implements a Swift LLM benchmark, rather than published Python diffusion results. Official H3/Krea model cards and the b3 PyPI page were also checked.

These reports do not establish a Corsairs/Python speed ratio or explain Aether's latency. A defensible comparison needs the same local artifact, input bytes, precision, compute settings, schedule and output-readiness boundary. Separate loading/specialization, conditioning, denoising, decoding and output transfer; identify warmup and report repeated trials. Full-video wall time and a model-block timer measure different work.
