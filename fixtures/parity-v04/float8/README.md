# v0.4 float8 fixtures

Ten single-function assets for `float8_e4m3fn` and `float8_e5m2`, authored by
`build_scalar_fixtures.py --set float8` with pinned `coreai-core 1.0.0b3`.
Expected bytes are ml_dtypes arithmetic. `python-results.initial.json` is the
immutable first reference run on CPU-only, GPU-preferred and Neural
Engine-preferred options, and `backend-goldens.json` is frozen by
`freeze_goldens.py --float8`. All 30 configurations matched exactly. See
[scalar types](../../../docs/scalar-types.md#float8).

```sh
python3.12 -I -B scripts/reference/build_scalar_fixtures.py --set float8
CORSAIRS_REFERENCE_FIXTURES=$PWD/fixtures/parity-v04/float8 \
  python3.12 -I -B scripts/reference/run_suite.py --backends cpu gpu-preferred neural-engine-preferred
python3.12 -I -B scripts/reference/freeze_goldens.py --float8
```
