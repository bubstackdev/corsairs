#!/usr/bin/env python3
"""Run fixtures/parity-v05/images through a reference and record exact outputs.

--source swift: compiles experiments/swift/ImageReference.swift and runs it on
  every single-input, single-output case (it cannot express mixed_bgra32).
  Each case's recorded bytes come from the path Corsairs uses: a memory-backed
  input in a CVMutablePixelBuffer and a memory-backed output view
  (`run_output_view_memory`), or `run_memory` for tensor outputs. Every other
  completed oracle variant must agree, and is recorded by digest.
  Run with python3 -B.
--source b3: runs every case b3 can feed through the pinned coreai-core 1.0.0b3
  runtime, one child process per case and backend. b3 converts PIL inputs to
  32BGRA with R and B swapped and decodes every 32-bit output as BGRA, so only
  BGRA32 and tensor inputs are comparable; outputs are un-swizzled back to
  CoreVideo memory order (RGB24 outputs are unchanged). Run with python3.12 -I -B.

Planar negatives are never executed. Writes results/SOURCE.json under the
fixture directory and scratch files under target/images-reference.
"""
from pathlib import Path
import argparse
import asyncio
import hashlib
import json
import os
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import ROOT, write_json

FIXTURES = ROOT / "fixtures/parity-v05/images"
BUILD = ROOT / "target/images-reference"
BACKENDS = {"cpu": "cpu_only", "gpu-preferred": "gpu", "neural-engine-preferred": "neural_engine"}
BGRA = 0x42475241


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def single_io(case):
    return len(case["inputs"]) == 1 and len(case["outputs"]) == 1


def swift(suite):
    BUILD.mkdir(parents=True, exist_ok=True)
    oracle = BUILD / "image-oracle"
    compiled = subprocess.run(["xcrun", "swiftc", "-parse-as-library", "-O", "-module-cache-path",
                               str(BUILD / "module-cache"), str(ROOT / "experiments/swift/ImageReference.swift"),
                               "-o", str(oracle)], capture_output=True, text=True)
    if compiled.returncode:
        sys.exit(compiled.stderr)
    models = BUILD / "models"
    models.mkdir(exist_ok=True)
    cases = [c for c in suite["cases"] if single_io(c)]
    for case in cases:
        link = models / case["name"]
        if not link.exists():
            link.symlink_to(FIXTURES / case["name"])
    (models / "models.json").write_text(json.dumps({"models": [{"name": c["name"], "authored": True} for c in cases]}))
    run = subprocess.run([str(oracle), str(models)], capture_output=True, text=True, timeout=3600)
    if run.returncode:
        sys.exit(f"oracle failed ({run.returncode}): {run.stderr[-3000:]}")
    oracle_rows = {row["model"]: row for row in json.loads(run.stdout)["models"]}
    results = {}
    for backend, oracle_backend in BACKENDS.items():
        table = results[backend] = {}
        for case in cases:
            (input_name, input_spec), (output_name, output_spec) = *case["inputs"].items(), *case["outputs"].items()
            rows = oracle_rows[case["name"]]["backends"][oracle_backend]
            selected = "run_output_view_memory" if "image" in output_spec else "run_memory"
            row = rows[selected]
            if row.get("outcome") != "completed":
                sys.exit(f"{case['name']} {backend} {selected}: {row}")
            data = bytes(row["actual"])
            variants = {name: sha256(bytes(r["actual"])) for name, r in sorted(rows.items())
                        if isinstance(r, dict) and r.get("outcome") == "completed" and "wrong" not in name}
            rejected = {name: r.get("description") for name, r in sorted(rows.items())
                        if isinstance(r, dict) and "wrong" in name}
            table[case["name"]] = {output_name: {
                "hex": data.hex(), "sha256": sha256(data), "variant": selected,
                "variants_agree": len(set(variants.values())) == 1, "variants": variants,
                "rejected_variants": rejected}}
            print(f"swift {backend} {case['name']}: {len(variants)} variants, agree={len(set(variants.values())) == 1}",
                  flush=True)
    return {"source": "swift-oracle", "oracle": "experiments/swift/ImageReference.swift",
            "oracle_sha256": sha256((ROOT / "experiments/swift/ImageReference.swift").read_bytes()),
            "swiftc": subprocess.run(["xcrun", "swiftc", "--version"], capture_output=True, text=True).stdout,
            "device_architecture": json.loads(run.stdout)["device_architecture"], "results": results}


async def child(case_name, backend):
    from environment import initialize
    initialize()
    import numpy as np
    from PIL import Image
    from coreai.runtime import AIModel, ComputeUnitKind, NDArray, SpecializationOptions, _use_os_coreai
    suite = json.loads((FIXTURES / "suite.json").read_text())
    case = next(c for c in suite["cases"] if c["name"] == case_name)
    options = (SpecializationOptions.cpu_only() if backend == "cpu"
               else SpecializationOptions.from_preferred_compute_unit_kind(
                   ComputeUnitKind.neural_engine() if backend == "neural-engine-preferred" else ComputeUnitKind.gpu()))
    row = {"case": case_name, "backend": backend, "os_backed": _use_os_coreai, "outputs": {}}
    model = await AIModel.load(str(FIXTURES / case["model"]), options)
    function = model.load_function(case["function"])
    row["descriptor"] = str(function.desc)
    feeds = {}
    for name, spec in case["inputs"].items():
        value = spec.get("image") or spec["tensor"]
        data = (FIXTURES / value["file"]).read_bytes()
        if "tensor" in spec:
            feeds[name] = NDArray(np.frombuffer(data, dtype=np.uint8).reshape(value["shape"]).copy())
        else:
            # PIL RGBA (R,G,B,A) that b3 converts to exactly these B,G,R,A bytes.
            pixels = np.frombuffer(data, dtype=np.uint8).reshape(value["height"], value["width"], 4)
            feeds[name] = Image.fromarray(pixels[:, :, [2, 1, 0, 3]].copy(), "RGBA")
    outputs = await function(feeds)
    for name, spec in case["outputs"].items():
        value = outputs[name]
        if isinstance(value, Image.Image):
            pixels = np.asarray(value)
            if value.mode == "RGBA":
                rule, data = "PIL RGBA decoded as BGRA; swap R and B", pixels[:, :, [2, 1, 0, 3]].tobytes()
            elif value.mode == "RGB":
                rule, data = "PIL RGB unchanged", pixels.tobytes()
            else:
                raise RuntimeError(f"unexpected PIL mode {value.mode}")
        else:
            rule, data = "NDArray bytes", value.numpy().tobytes()
        row["outputs"][name] = {"hex": data.hex(), "sha256": sha256(data), "rule": rule}
    print(json.dumps(row))


def b3(suite):
    from execution import select_os_framework
    from environment import initialize, identity
    environment = dict(os.environ)
    select_os_framework(environment)
    results, skipped = {}, []
    for backend in BACKENDS:
        table = results[backend] = {}
        for case in suite["cases"]:
            images = [v["image"] for v in case["inputs"].values() if "image" in v]
            if any(i["os_type"] != BGRA for i in images):
                skipped.append({"case": case["name"], "backend": backend,
                                "reason": "b3 always supplies 32BGRA; not comparable"})
                continue
            completed = subprocess.run([sys.executable, "-I", "-B", __file__, "--child", case["name"], backend],
                                       capture_output=True, text=True, env=environment, timeout=600)
            lines = completed.stdout.strip().splitlines()
            if completed.returncode or not lines:
                sys.exit(f"b3 {case['name']} {backend} failed ({completed.returncode}): {completed.stderr[-3000:]}")
            row = json.loads(lines[-1])
            if row["os_backed"] is not True:
                sys.exit("b3 must use OS Core AI")
            table[case["name"]] = row["outputs"]
            print(f"b3 {backend} {case['name']}: completed", flush=True)
    initialize()
    return {"source": "b3", "reference": identity(), "results": results, "not_comparable": skipped}


def main():
    if sys.argv[1:2] == ["--child"]:
        return asyncio.run(child(sys.argv[2], sys.argv[3]))
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", choices=["swift", "b3"], required=True)
    args = parser.parse_args()
    suite = json.loads((FIXTURES / "suite.json").read_text())
    record = swift(suite) if args.source == "swift" else b3(suite)
    sw_vers = subprocess.run(["/usr/bin/sw_vers"], capture_output=True, text=True).stdout
    write_json(FIXTURES / "results" / f"{'swift-oracle' if args.source == 'swift' else 'b3'}.json",
               {"schema": 1, "sw_vers": sw_vers, "suite_sha256": sha256((FIXTURES / "suite.json").read_bytes()),
                **record})


if __name__ == "__main__":
    main()
