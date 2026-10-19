#!/usr/bin/env python3.12
"""Run authored image models through the pinned b3 runtime (OS Core AI), per backend.

Usage: python3.12 -I -B experiments/python/image_b3_run.py MODELS_DIR OUT.json

b3 accepts PIL images as inputs and returns PIL images for image outputs. Each
(model, backend, PIL mode) runs in its own child so a trap is recorded as an
exit status rather than ending the collection. Input bytes follow the same
deterministic pattern as ImageReference.swift.
"""
from pathlib import Path
import asyncio
import json
import os
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "reference"))
from environment import initialize, identity  # noqa: E402
from execution import select_os_framework  # noqa: E402

BACKENDS = ["cpu", "gpu-preferred", "neural-engine-preferred"]
MODES = {"RGB": 3, "RGBA": 4, "L": 1}


def hexify(value):
    """Render byte lists (keys bytes/actual/input_bytes) as hex for compact evidence."""
    if isinstance(value, dict):
        return {k: (bytes(v).hex() if k in ("bytes", "actual", "input_bytes") and isinstance(v, list)
                    else hexify(v)) for k, v in value.items()}
    if isinstance(value, list):
        return [hexify(v) for v in value]
    return value


def pattern(width, height, channels):
    return bytes(1 + (y * 37 + x * 11 + c * 3) % 253
                 for y in range(height) for x in range(width) for c in range(channels))


async def child(models, name, backend, mode):
    initialize()
    import numpy as np
    from PIL import Image
    from coreai.runtime import AIModel, ComputeUnitKind, NDArray, SpecializationOptions, _use_os_coreai
    entry = next(m for m in json.loads((models / "models.json").read_text())["models"] if m["name"] == name)
    options = (SpecializationOptions.cpu_only() if backend == "cpu"
               else SpecializationOptions.from_preferred_compute_unit_kind(
                   ComputeUnitKind.neural_engine() if backend == "neural-engine-preferred" else ComputeUnitKind.gpu()))
    row = {"model": name, "backend": backend, "mode": mode, "os_backed": _use_os_coreai}
    try:
        model = await AIModel.load(str(models / entry["model"]), options)
        function = model.load_function("main")
        row["descriptor"] = str(function.desc)
        spec = entry["inputs"]["x"]
        if "image" in spec:
            width, height = spec["image"]["width"], spec["image"]["height"]
            value = Image.frombytes(mode, (width, height), pattern(width, height, MODES[mode]))
        else:
            shape = spec["tensor"]
            value = NDArray(np.frombuffer(pattern(shape[1], shape[0], shape[2]) if len(shape) == 3
                                          else bytes(range(1, 1 + shape[0])), dtype=np.uint8).reshape(shape).copy())
        outputs = await function({"x": value})
        y = outputs["y"]
        if isinstance(y, Image.Image):
            row["output"] = {"kind": "PIL.Image", "mode": y.mode, "size": list(y.size), "bytes": list(y.tobytes())}
        else:
            array = y.numpy()
            row["output"] = {"kind": "NDArray", "shape": list(array.shape), "dtype": str(array.dtype),
                             "bytes": list(array.tobytes())}
        row["input_bytes"] = list(value.tobytes()) if isinstance(value, Image.Image) else None
        row["outcome"] = "completed"
    except Exception as error:  # Reference observations, not assertions.
        row.update({"outcome": "threw", "error_type": type(error).__name__, "error": str(error)})
    print(json.dumps(row))


def main():
    if sys.argv[1] == "--child":
        return asyncio.run(child(Path(sys.argv[2]), sys.argv[3], sys.argv[4], sys.argv[5]))
    models, out = Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve()
    environment = dict(os.environ)
    select_os_framework(environment)
    rows = []
    for entry in json.loads((models / "models.json").read_text())["models"]:
        if not entry["authored"]:
            continue
        modes = list(MODES) if "image" in entry["inputs"]["x"] else ["tensor"]
        for backend in BACKENDS:
            for mode in modes:
                command = [sys.executable, "-I", "-B", __file__, "--child", str(models), entry["name"], backend, mode]
                completed = subprocess.run(command, capture_output=True, text=True, env=environment, timeout=300)
                lines = completed.stdout.strip().splitlines()
                row = json.loads(lines[-1]) if completed.returncode == 0 and lines else {
                    "model": entry["name"], "backend": backend, "mode": mode, "outcome": "process_failed",
                    "stderr_tail": completed.stderr.strip().splitlines()[-3:]}
                row["returncode"] = completed.returncode
                rows.append(row)
                print(f"{entry['name']} {backend} {mode}: {row['outcome']} {row.get('error', '')[:120]}", flush=True)
    initialize()
    out.write_text(json.dumps(hexify({"schema": 1, "reference": identity(), "runs": rows}), indent=1) + "\n")
    print(f"wrote {out}")


main()
