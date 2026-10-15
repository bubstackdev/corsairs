# Published Python reference tooling

Use CPython 3.12. These tools prepare and execute differential references; the Rust runtime has no Python dependency.

Acquire the exact published wheel without a global installation:

```sh
python3.12 -I -B scripts/reference/acquire.py
```

If local DNS cannot resolve `files.pythonhosted.org`, `--cdn-address ADDRESS` supplies an explicit CDN address while preserving HTTPS certificate validation and the pinned SHA-256 check. The retained PyPI metadata supplies the expected digest. The wheel/extraction destination is `.local/reference/`.

The reference dependency versions are NumPy 2.3.5, ml-dtypes 0.6.0, Pillow 12.3.0, typing-extensions 4.16.0, yuvio 1.6, and psutil 7.2.2. Install them only into a reference virtual environment if needed. Scripts prefer those installed versions and otherwise discover matching existing uv cache entries. They never install dependencies or modify the global Python environment themselves.

Prepare fixtures and enumerate the actual public b3 API:

```sh
python3.12 -I -B scripts/reference/build_fixtures.py
python3.12 -I -B scripts/reference/verify_fixtures.py
python3.12 -I -B scripts/reference/inventory.py
```

Once retained safe Rust reports exist, inventory generation automatically validates `docs/evidence/v0.1/checks-debug.json` and `checks-release.json` together with the adjacent build manifest. Explicit report locations can be supplied repeatedly with `--rust-report PATH`. The inventory labels only the bounded v0.1 subset as tested and records the exact report/source/binary identities; all graph authoring remains deferred.

Building regenerates asset metadata timestamps and bytecode source locations; do not rebuild during native execution or after freezing a reviewed baseline without regenerating/reviewing the dependent hashes and observations.

Run the native reference grid where CoreAI can access its specialization cache and device services:

```sh
python3.12 -I -B scripts/reference/run_suite.py
```

Each invocation is isolated in a child process. Native traps/timeouts remain failed observations. The full grid includes 32 positive configurations and 16 negative cases. Outputs, metadata, state changes, errors, backend preferences, elapsed times, and return codes are retained. The shell sandbox currently returns `AIModelCacheError` during specialization; that is an environment failure and cannot count as a successful reference comparison.

Filter a probe without replacing the complete report:

```sh
python3.12 -I -B scripts/reference/run_suite.py --case float_edges --backend gpu-preferred
```

After a reviewed native run, freeze exact Python outputs separately from the mathematical expectations:

```sh
python3.12 -I -B scripts/reference/freeze_goldens.py
python3.12 -I -B scripts/reference/inventory.py
```

The freeze script rejects execution failures and unreviewed mathematical mismatches. Its only reviewed difference is bound to the exact observed GPU-preferred float-edge output digest. This preserves strict Rust-to-Python comparison. See the fixture [backend observations](../../fixtures/parity-v01/BACKEND-SEMANTICS.md).

The safe Rust API differential/stress driver is separate:

```sh
python3 scripts/check_v01.py
python3 scripts/check_v01.py --native --no-build
```

It builds debug/release clients with unsafe code forbidden, compares all 32 positive and 16 typed negative configurations per profile, and exercises 10,000 stateless and 10,000 stateful calls per backend/profile. Each backend/profile also runs 100 model/function load/drop cycles and abandons 100 futures each for inference, model loading, and function loading. Abandoned work owns its resources until completion. `--no-build` verifies current source, compiler, fixture, rlib, and driver hashes against the separate build manifest. Quick native smoke counts can use `--cycles 10 --loads 2 --dropped 3`.

Compare the same warm host round-trip boundary with the published Python runtime:

```sh
python3.12 -I -B scripts/reference/benchmark.py --rust-cli target/release/corsairs
```

This records CPU-only and GPU-preferred feedforward samples, with ten warmup calls and one hundred measured calls each. Both sides include host input cloning, native tensor creation, submission/completion, and copying outputs/state to owned host bytes. Model/function loading and correctness checks are outside the per-call timings. Output bytes and metadata must match frozen Python goldens before a timing comparison is accepted. Raw samples and model/CLI identities remain recorded; no speedup threshold or general workload claim follows from this tiny fixture.
