#!/usr/bin/env python3
"""Compile ImageReference.swift, run it over authored image models, and summarize.

Usage: python3 -B experiments/python/image_oracle.py MODELS_DIR OUT.json

Cases that trap the process (planar 4:2:0 image inputs, ImageUtils.swift:91)
are first confirmed to trap in their own process, then skipped in the full run
so every other case is still recorded. Writes only OUT.json and target/image/.
"""
from pathlib import Path
import json
import os
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / "target" / "image"
MODELS, OUT = Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve()
ORACLE = BUILD / "image-oracle"
PLANAR_INPUTS = ["to_tensor", "identity", "invert", "aligned_to_tensor", "to_tensor_16x16"]
TRAPPING = [f"YpCbCr8420Planar_{model}:{case}" for model in PLANAR_INPUTS
            for case in ["run_io_surface", "run_memory", "run_mutable_input", "encode"]
            + (["run_output_view", "run_output_view_memory", "encode_output_view", "encode_output_view_memory"]
               if model in ("identity", "invert") else [])]
CASES = ["run_io_surface", "run_memory", "run_mutable_input", "run_output_view", "run_output_view_memory",
         "encode", "encode_output_view", "encode_output_view_memory", "run_wrong_format", "run_wrong_size"]
SOAK_MODEL, SOAK_ITERATIONS = "BGRA32_identity", int(os.environ.get("IMAGE_ORACLE_SOAK", "5000"))


def hexify(value):
    """Render byte lists (keys bytes/actual/input_bytes) as hex for compact evidence."""
    if isinstance(value, dict):
        return {k: (bytes(v).hex() if k in ("bytes", "actual", "input_bytes") and isinstance(v, list)
                    else hexify(v)) for k, v in value.items()}
    if isinstance(value, list):
        return [hexify(v) for v in value]
    return value


def run(command, **kwargs):
    result = subprocess.run([str(c) for c in command], capture_output=True, text=True, **kwargs)
    return {"command": [str(c) for c in command], "returncode": result.returncode,
            "stdout": result.stdout, "stderr": result.stderr}


BUILD.mkdir(parents=True, exist_ok=True)
cache = BUILD / "module-cache"
compile_ir = run(["xcrun", "swiftc", "-parse-as-library", "-O", "-module-cache-path", cache, "-emit-ir",
                  ROOT / "experiments/swift/ImageReference.swift", "-o", BUILD / "image.ll"])
compile_exe = run(["xcrun", "swiftc", "-parse-as-library", "-O", "-module-cache-path", cache,
                   ROOT / "experiments/swift/ImageReference.swift", "-o", ORACLE])
if compile_ir["returncode"] or compile_exe["returncode"]:
    sys.exit(compile_ir["stderr"] + compile_exe["stderr"])

# Each trapping case alone, per backend, in a fresh process: the trap is the
# observation. Encode runs only on accelerated preferences.
traps = []
for entry in TRAPPING:
    model, case = entry.split(":")
    others = [f"{model}:{c}" for c in CASES if c != case]
    for backend in ["cpu_only", "gpu", "neural_engine"]:
        if case.startswith("encode") and backend == "cpu_only":
            continue
        env = {**os.environ, "IMAGE_ORACLE_SKIP": ",".join(others), "IMAGE_ORACLE_TRACE": "1",
               "IMAGE_ORACLE_BACKENDS": backend}
        result = run([ORACLE, MODELS, model], env=env)
        traps.append({"model": model, "case": case, "backend": backend, "returncode": result["returncode"],
                      "stderr_tail": result["stderr"].strip().splitlines()[-3:]})
        print(f"{entry} {backend}: exit {result['returncode']}", flush=True)

full = run([ORACLE, MODELS], env={**os.environ, "IMAGE_ORACLE_SKIP": ",".join(TRAPPING)})
if full["returncode"]:
    sys.exit(f"full oracle run failed: {full['returncode']} {full['stderr'][-2000:]}")
oracle = json.loads(full["stdout"])
soak = run([ORACLE, MODELS, SOAK_MODEL], env={**os.environ, "IMAGE_ORACLE_SOAK": str(SOAK_ITERATIONS)})
if soak["returncode"]:
    sys.exit(f"soak failed: {soak['returncode']} {soak['stderr'][-2000:]}")
sw_vers = run(["/usr/bin/sw_vers"])["stdout"]
swiftc = run(["xcrun", "swiftc", "--version"])["stderr"] or run(["xcrun", "swiftc", "--version"])["stdout"]
OUT.write_text(json.dumps(hexify({"schema": 1, "sw_vers": sw_vers, "swiftc": swiftc,
                                  "models_manifest": json.loads((MODELS / "models.json").read_text()),
                                  "trapping_cases": traps, "oracle": oracle,
                                  "soak": json.loads(soak["stdout"])}), indent=1, sort_keys=True) + "\n")
print(f"wrote {OUT}")
