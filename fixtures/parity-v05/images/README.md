# v0.5 image fixtures

Twenty-two single-function assets with packed `24RGB`, `32ARGB` and `32BGRA`
image values, plus a planar 4:2:0 asset that is never executed. All were
authored by `build_image_fixtures.py` with pinned `coreai-core 1.0.0b3`.
Payloads are tight rows in CoreVideo memory order; `expected-*.bin` are the
analytic results. `suite.json` also lists seven negative requests.

`results/swift-oracle.json` (experiments/swift/ImageReference.swift, every
single-input case) and `results/b3.json` (BGRA32 and tensor inputs only) are
the reference runs on CPU-only, GPU-preferred and Neural Engine-preferred
options. `backend-goldens.json` is frozen from them by
`freeze_image_goldens.py`, which refuses to overwrite it. 27 goldens are
confirmed by both references. The only goldens that differ from the expected
bytes are the reviewed Neural Engine `invert` digests (every byte 255). See
[image I/O](../../../docs/image-io.md).

```sh
python3.12 -I -B scripts/reference/build_image_fixtures.py
python3 -B scripts/reference/run_image_suite.py --source swift
python3.12 -I -B scripts/reference/run_image_suite.py --source b3
python3 -B scripts/reference/freeze_image_goldens.py
python3 -B scripts/check_images.py
```
