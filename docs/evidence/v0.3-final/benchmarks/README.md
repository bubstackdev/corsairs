# Final tiny same-asset regression pairs

The test-only [controller](../../../../scripts/benchmark_final_v03.py) leaves the historical benchmark controller and reports unchanged. [build.json](build.json) is the authoritative unexecuted preparation receipt: it binds the final qualification manifest, complete current production source set, frozen benchmark/library, reference helpers, case/model/fixture bytes, CPython binary and verified dependency RECORD payloads. [controller-checks.json](controller-checks.json) records metadata-only validation; CoreAI was not imported. Earlier `build-*preflight*.json` files are unexecuted preparation snapshots retained during controller review.

Root-coordinated execution only:

```sh
/Users/zakkeown/.local/bin/python3.12 -I -B scripts/benchmark_final_v03.py --native --deadline 60
```

This runs one CPU pair in Rust→Python order and one GPU-preferred pair in Python→Rust order. Each arm measures `owned_run` and `native_run_download`, with ten warmups and 100 retained samples. Loading, exact output validation and result cleanup stay outside the selected timing intervals. Both frozen helpers compare every output byte with the same pinned golden. The controller requires the same model/input/output identities and validates sample counts/statistics.

Children run serially in separate process groups. An expired arm is killed as a group and its direct child reaped; failure/partial stdout and stderr remain evidence. No cache purge or fixed-clock claim is made. Preparation, environment verification and hashes occur outside native timing windows. Caller coordination supplies the quiet host.

Reports will be created here as `feedforward-cpu.json`, `feedforward-gpu-preferred.json` and `checks.json`; raw arm reports/logs go under `/private/tmp/corsairs-v03-final-benchmarks`. Existing result paths are rejected. Source/environment changes after preparation are rejected. Optional Python H3 timing is omitted because the separate final H3 qualification already records current Rust timings.

These are **one descriptive pair per setting**, not repeated-pair statistics, a render benchmark or a general Rust/Python speed claim. Within-arm medians/P95 describe only the retained samples.
