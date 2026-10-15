#!/usr/bin/env python3
"""Measure the same owned-host round-trip boundary as `corsairs bench`.

Preparation/imports/model/function loading and correctness checks are outside the
warm per-call samples. Host input cloning, native tensor construction, inference
submission/completion, and output/state copies are included.
"""
import argparse
import asyncio
import hashlib
import json
from pathlib import Path
import platform
import subprocess
import sys
import time

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import FIXTURES, initialize, identity, write_json
initialize()
import numpy as np
from coreai.runtime import AIModel, ComputeUnitKind, NDArray, SpecializationOptions, _use_os_coreai


def host_tensor(spec):
    payload = (FIXTURES / spec["file"]).read_bytes()
    if hashlib.sha256(payload).hexdigest() != spec["sha256"]:
        raise RuntimeError(f"Fixture bytes changed: {spec['file']}")
    return np.frombuffer(payload, dtype=np.dtype(spec["dtype"]).newbyteorder("<")).reshape(spec["shape"]).copy()


async def measure(case, golden, backend, warmup, samples):
    options = (SpecializationOptions.cpu_only() if backend == "cpu"
               else SpecializationOptions.from_preferred_compute_unit_kind(ComputeUnitKind.gpu()))
    inputs = {name: host_tensor(spec) for name, spec in case["inputs"].items()}
    initial_states = {name: host_tensor(spec) for name, spec in case.get("state", {}).items()}
    expected = {name: (FIXTURES / spec["file"]).read_bytes()
                for name, spec in golden["steps"][0]["outputs"].items()}
    started = time.perf_counter_ns()
    model = await AIModel.load(FIXTURES / case["model"], options)
    load_us = (time.perf_counter_ns() - started) / 1000
    function = model.load_function(case["function"])
    states = {name: NDArray(value) for name, value in initial_states.items()}
    durations = []
    last_outputs = None
    last_state_payloads = None
    for iteration in range(warmup + samples):
        started = time.perf_counter_ns()
        # Match Rust TensorMap.clone followed by native allocation/copy.
        native_inputs = {name: NDArray(value.copy(order="C")) for name, value in inputs.items()}
        outputs = await function(inputs=native_inputs, state=states)
        output_payloads = {name: value.numpy().tobytes(order="C") for name, value in outputs.items()}
        state_payloads = {name: value.numpy().tobytes(order="C") for name, value in states.items()}
        elapsed = (time.perf_counter_ns() - started) / 1000
        if iteration >= warmup:
            durations.append(elapsed)
        # Correctness remains mandatory; verification itself is outside samples.
        if output_payloads != expected:
            raise RuntimeError(f"Benchmark output differs from pinned Python golden: {backend}")
        for name, spec in golden["steps"][0]["outputs"].items():
            if list(outputs[name].shape) != spec["shape"] or outputs[name].dtype != spec["dtype"]:
                raise RuntimeError("Benchmark output metadata mismatch")
        last_outputs, last_state_payloads = output_payloads, state_payloads
    ordered = sorted(durations)
    return {"compute": backend, "case": case["name"], "load_us": load_us, "warmup": warmup,
            "iterations": samples, "median_us": ordered[len(ordered) // 2],
            "p95_us": ordered[((len(ordered) - 1) * 95) // 100], "samples_us": durations,
            "boundary": "clone host inputs, allocate native tensors, submit, await, copy outputs/state to host",
            "output_sha256": {name: hashlib.sha256(payload).hexdigest() for name, payload in last_outputs.items()},
            "state_sha256": {name: hashlib.sha256(payload).hexdigest() for name, payload in last_state_payloads.items()},
            "allowed_compute_units": [str(kind) for kind in options.allowed_compute_unit_kinds],
            "preferred_compute_unit": str(options.preferred_compute_unit_kind), "os_backed": _use_os_coreai}


async def main(args):
    suite = json.loads((FIXTURES / "suite.json").read_text())
    goldens = json.loads((FIXTURES / "backend-goldens.json").read_text())
    case = next(row for row in suite["cases"] if row["name"] == "feedforward")
    backends = [args.backend] if args.backend else ["cpu", "gpu-preferred"]
    report = {"reference": identity(), "platform": platform.platform(), "case": "feedforward",
              "model_sha256": hashlib.sha256((FIXTURES / case["model"] / "main.mlirb").read_bytes()).hexdigest(),
              "method": "Sequential warm host round trips; model/function loading outside per-call samples; no speedup threshold.",
              "results": [], "complete": False}
    output = Path(args.output) if args.output else FIXTURES / "python-benchmark.json"
    try:
        for backend in backends:
            golden = next(row for row in goldens["cases"] if row["case"] == "feedforward" and row["backend"] == backend)
            result = await measure(case, golden, backend, args.warmup, args.samples)
            if args.rust_cli:
                spec = case["inputs"]["x"]
                command = [str(Path(args.rust_cli).resolve()), "bench", str(FIXTURES / case["model"]),
                           "--input", "x", spec["dtype"], ",".join(map(str, spec["shape"])), str(FIXTURES / spec["file"]),
                           "--compute", backend, "--warmup", str(args.warmup), "--repeat", str(args.samples)]
                completed = subprocess.run(command, capture_output=True, text=True, timeout=180)
                if completed.returncode != 0:
                    raise RuntimeError(f"Rust benchmark failed: {completed.stdout}\n{completed.stderr}")
                rust = json.loads(completed.stdout)
                actual_outputs = {row["name"]: bytes.fromhex(row["hex"]) for row in rust["outputs"]}
                expected_outputs = {name: (FIXTURES / spec["file"]).read_bytes()
                                    for name, spec in golden["steps"][0]["outputs"].items()}
                if actual_outputs != expected_outputs or rust["states"]:
                    raise RuntimeError(f"Rust benchmark output/state differs from pinned reference: {backend}")
                for row in rust["outputs"]:
                    expected_spec = golden["steps"][0]["outputs"][row["name"]]
                    if any(row[field] != expected_spec[field] for field in ["dtype", "shape", "strides"]):
                        raise RuntimeError(f"Rust benchmark metadata differs from pinned reference: {backend}")
                result["rust_cli"] = {"command": command, "result": rust}
                result["rust_python_exact_match"] = True
                result["python_over_rust_median"] = result["median_us"] / rust["median_us"]
                result["rust_cli_sha256"] = hashlib.sha256(Path(args.rust_cli).read_bytes()).hexdigest()
            report["results"].append(result)
            write_json(output, report)
            print(json.dumps({"compute": backend, "python_median_us": result["median_us"],
                              "python_p95_us": result["p95_us"], "iterations": args.samples,
                              "python_over_rust_median": result.get("python_over_rust_median")}), flush=True)
        report["complete"] = True
        write_json(output, report)
        return 0
    except Exception as error:
        report["error"] = str(error)
        write_json(output, report)
        raise


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--backend", choices=["cpu", "gpu-preferred"])
    parser.add_argument("--warmup", type=int, default=10)
    parser.add_argument("--samples", type=int, default=100)
    parser.add_argument("--rust-cli", help="Optional Rust CLI for same-host sequential comparison")
    parser.add_argument("--output")
    args = parser.parse_args()
    if args.warmup < 0 or args.samples < 1:
        parser.error("warmup must be nonnegative and samples positive")
    raise SystemExit(asyncio.run(main(args)))
