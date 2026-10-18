# v0.4 scalar-type fixtures

35 single-function assets authored by
[`build_scalar_fixtures.py`](../../../scripts/reference/build_scalar_fixtures.py)
with pinned `coreai-core 1.0.0b3`. `suite.json` uses `run_suite.py`'s format,
`python-results.initial.json` is the immutable first reference run on CPU-only,
GPU-preferred and Neural Engine-preferred options, and `backend-goldens.json` is
frozen by `freeze_goldens.py --scalar-types`. See
[scalar types](../../../docs/scalar-types.md) for the five reviewed backend
outcomes.

```sh
python3.12 -I -B scripts/reference/build_scalar_fixtures.py
CORSAIRS_REFERENCE_FIXTURES=$PWD/fixtures/parity-v04/scalar-types \
  python3.12 -I -B scripts/reference/run_suite.py --backends cpu gpu-preferred neural-engine-preferred
python3.12 -I -B scripts/reference/freeze_goldens.py --scalar-types
```
