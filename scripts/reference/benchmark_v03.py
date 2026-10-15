#!/usr/bin/env python3
"""Warm stateless phase benchmarks, or emit Rust argv without native imports.

Preparation and --rust-argv modes never import Core AI or launch benchmarks.
All native execution must be coordinated by the caller on the quiet host.
"""
import argparse
import asyncio
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import statistics
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
PHASES = ["upload_inputs", "download_inputs", "owned_run", "native_run", "native_run_download"]
RUST_PHASES = ["worker_flush", *PHASES, "metal_encode", "metal_encode_download"]


def digest(path):
    value = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for chunk in iter(lambda: stream.read(8 << 20), b""):
            value.update(chunk)
    return value.hexdigest()


def write(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, allow_nan=False) + "\n")


def specs(case, key):
    value = case[key]
    if isinstance(value, dict):
        return [dict(spec, name=name) for name, spec in value.items()]
    return value


def load_case(path):
    path = Path(path).resolve()
    case = json.loads(path.read_text())
    case["model"] = str((path.parent / case["model"]).resolve())
    for group in ["inputs", "outputs"]:
        case[group] = specs(case, group)
        if not case[group] or len({s["name"] for s in case[group]}) != len(case[group]):
            raise ValueError(f"Empty/duplicate {group}")
        for spec in case[group]:
            spec["file"] = str((path.parent / spec["file"]).resolve())
    if case.get("state"):
        raise ValueError("Stateless benchmark cases only")
    return case


def prepare(args):
    fixtures = ROOT / "fixtures/parity-v01"
    suite = json.loads((fixtures / "suite.json").read_text())
    original = next(c for c in suite["cases"] if c["name"] == args.prepare_suite_case)
    if original.get("state"):
        raise ValueError("Stateless benchmark cases only")
    backend = args.backend or "cpu"
    golden = next(c for c in json.loads((fixtures / "backend-goldens.json").read_text())["cases"]
                  if c["case"] == original["name"] and c["backend"] == backend)
    case = {"schema": 1, "name": original["name"], "model": str(fixtures / original["model"]),
            "function": original["function"], "compute": backend, "expect_frequent_reshapes": None,
            "warmup": 10, "samples": 100, "inputs": [], "outputs": [],
            "source_suite_sha256": digest(fixtures / "suite.json"),
            "backend_goldens_sha256": digest(fixtures / "backend-goldens.json")}
    for group, source in [("inputs", original["inputs"]), ("outputs", golden["steps"][0]["outputs"])]:
        for name, spec in source.items():
            spec = dict(spec, name=name, file=str(fixtures / spec["file"]))
            if digest(spec["file"]) != spec["sha256"]:
                raise ValueError("Pinned fixture bytes changed")
            case[group].append(spec)
    write(args.case, case)
    print(json.dumps({"prepared": str(Path(args.case).resolve()), "native_executed": False}))


def configuration(args, case):
    backend = args.backend or case.get("compute", "cpu")
    warmup = args.warmup if args.warmup is not None else case.get("warmup", 10)
    samples = args.samples if args.samples is not None else case.get("samples", 100)
    if not 0 <= warmup <= 1_000_000 or not 1 <= samples <= 1_000_000:
        raise ValueError("Invalid warmup/sample count")
    phases = args.phases.split(",") if args.phases else None
    if phases and (not phases or any(p not in RUST_PHASES for p in phases)):
        raise ValueError("Unknown phase")
    return backend, warmup, samples, phases


def output_path(args, case, language):
    return Path(args.output) if args.output else Path(args.output_dir) / f"{case['name']}-{language}.json"


def rust_argv(args, case):
    backend, warmup, samples, phases = configuration(args, case)
    reshape = case.get("expect_frequent_reshapes")
    command = [str(Path(args.rust_driver).resolve()), "--model", case["model"],
               "--function", case.get("function", "main"), "--backend", backend,
               "--reshape", "default" if reshape is None else str(reshape).lower(),
               "--warmup", str(warmup), "--samples", str(samples),
               "--output", str(output_path(args, case, "rust").resolve())]
    if phases:
        command += ["--phases", ",".join(phases)]
    for group, flag in [("inputs", "--input"), ("outputs", "--expected")]:
        for spec in case[group]:
            command += [flag, spec["name"], spec["dtype"],
                        ",".join(map(str, spec["shape"])) or "scalar", spec["file"]]
    print(json.dumps(command))


async def benchmark(args, case):
    backend, warmup, samples, requested = configuration(args, case)
    if case.get("expect_frequent_reshapes") is not None:
        raise ValueError("Public b3 has no reshape-hint setter; use identical omitted hints for pairs")
    # This branch alone imports the pinned native bindings. Explicitly require
    # Apple's OS implementation rather than the wheel's alternate backing.
    os.environ["USE_OS_COREAI"] = "1"
    os.environ.pop("USE_LOCAL_COREAI", None)
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from environment import initialize, identity
    initialize()
    import numpy as np
    import ml_dtypes
    from coreai.runtime import AIModel, ComputeUnitKind, NDArray, SpecializationOptions, _use_os_coreai
    if not _use_os_coreai:
        raise RuntimeError("Reference must use OS Core AI")
    phases = [p for p in (requested or PHASES) if p in PHASES]
    if not phases:
        raise ValueError("No requested phases are available in public Python b3")
    report = {"schema": 1, "language": "python-b3", "reference": identity(),
              "os_backed": bool(_use_os_coreai), "platform": platform.platform(),
              "case": case, "case_file_sha256": digest(args.case), "backend": backend,
              "expect_frequent_reshapes": None, "phases": [], "passed": False,
              "unavailable_phases": [p for p in (requested or []) if p not in PHASES],
              "timing_clock": "time.perf_counter_ns",
              "cleanup": "exact validation/diagnostic readback, result decref and asyncio.sleep(0) outside every interval; Python has no public worker drain",
              "limits": "Sequential warm stateless calls; persistent native inputs prepared outside timing; no public Python Metal equivalent; no cache purge or performance threshold"}
    destination = output_path(args, case, "python")
    try:
        inputs, expected, input_bytes = {}, {}, {}
        for group in ["inputs", "outputs"]:
            for spec in case[group]:
                raw = Path(spec["file"]).read_bytes()
                actual = hashlib.sha256(raw).hexdigest()
                if spec.get("sha256") and actual != spec["sha256"]:
                    raise ValueError(f"Fixture hash changed: {spec['name']}")
                spec["sha256"] = actual
                if group == "inputs":
                    dt = ml_dtypes.bfloat16 if spec["dtype"] == "bfloat16" else np.dtype(spec["dtype"]).newbyteorder("<")
                    inputs[spec["name"]] = np.frombuffer(raw, dtype=dt).reshape(spec["shape"])
                    input_bytes[spec["name"]] = raw
                else:
                    expected[spec["name"]] = raw
        report["model_main_mlirb_sha256"] = digest(Path(case["model"]) / "main.mlirb")
        options = SpecializationOptions.cpu_only() if backend == "cpu" else SpecializationOptions.from_preferred_compute_unit_kind(ComputeUnitKind.gpu())
        report["allowed_compute_units"] = [str(v) for v in options.allowed_compute_unit_kinds]
        report["preferred_compute_unit"] = str(options.preferred_compute_unit_kind)
        begin = time.perf_counter_ns()
        model = await AIModel.load(Path(case["model"]), options)
        report["model_load_ns"] = time.perf_counter_ns() - begin
        begin = time.perf_counter_ns()
        function = model.load_function(case.get("function", "main"))
        report["function_load_ns"] = time.perf_counter_ns() - begin
        if function is None or list(function.desc.state_names):
            raise ValueError("Missing function or stateful signature")
        persistent = {name: NDArray(value.copy(order="C")) for name, value in inputs.items()}

        def payloads(values):
            return {name: value.numpy().tobytes(order="C") for name, value in values.items()}

        def check(values, wanted, group):
            if set(values) != set(wanted):
                raise ValueError("Output name set differs")
            for spec in case[group]:
                value = values[spec["name"]]
                if list(value.shape) != spec["shape"] or value.dtype != spec["dtype"]:
                    raise ValueError("Output dtype/shape differs")

        for phase in phases:
            durations = []
            for iteration in range(warmup + samples):
                begin = time.perf_counter_ns()
                if phase == "upload_inputs":
                    result = {name: NDArray(value.copy(order="C")) for name, value in inputs.items()}
                elif phase == "download_inputs":
                    result = payloads(persistent)
                elif phase == "owned_run":
                    native_inputs = {name: NDArray(value.copy(order="C")) for name, value in inputs.items()}
                    outputs = await function(inputs=native_inputs, state={})
                    result = outputs, payloads(outputs)
                    del native_inputs
                elif phase == "native_run":
                    result = await function(inputs=persistent.copy(), state={})
                else:
                    outputs = await function(inputs=persistent.copy(), state={})
                    result = outputs, payloads(outputs)
                elapsed = time.perf_counter_ns() - begin
                if phase == "upload_inputs":
                    check(result, input_bytes, "inputs")
                    actual, wanted = payloads(result), input_bytes
                elif phase == "download_inputs":
                    actual, wanted = result, input_bytes
                elif phase == "native_run":
                    check(result, expected, "outputs")
                    actual, wanted = payloads(result), expected
                else:
                    check(result[0], expected, "outputs")
                    actual, wanted = result[1], expected
                if actual != wanted:
                    raise ValueError(f"Exact output mismatch in {phase}")
                del result, actual
                if phase in ["owned_run", "native_run_download"]:
                    del outputs
                await asyncio.sleep(0)
                if iteration >= warmup:
                    durations.append(elapsed)
            ordered = sorted(durations)
            report["phases"].append({"phase": phase, "warmup": warmup, "samples": samples,
                "median_ns": statistics.median(durations), "p95_ns": ordered[math.ceil(samples * .95) - 1],
                "min_ns": ordered[0], "max_ns": ordered[-1], "samples_ns": durations,
                "every_iteration_exact": True,
                "boundary": {"upload_inputs": "copy host inputs, construct retained NDArray storage",
                    "download_inputs": "numpy views and tobytes copies for every persistent native input",
                    "owned_run": "clone host inputs, construct NDArray storage, submit/await, numpy+tobytes every output",
                    "native_run": "copy handle dictionary, submit/await retained output; no host download in timing",
                    "native_run_download": "copy handle dictionary, submit/await retained output, numpy+tobytes every output"}[phase]})
            write(destination, report)
        report["passed"] = True
        write(destination, report)
        print(json.dumps({"passed": True, "report": str(destination.resolve())}))
    except Exception as error:
        report["error"] = f"{type(error).__name__}: {error}"
        write(destination, report)
        raise


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--case", required=True)
    parser.add_argument("--prepare-suite-case", choices=["feedforward", "double_float32"])
    parser.add_argument("--backend", choices=["cpu", "gpu-preferred"])
    parser.add_argument("--warmup", type=int)
    parser.add_argument("--samples", type=int)
    parser.add_argument("--phases", help="Comma-separated phase names; omit for all supported phases")
    parser.add_argument("--output")
    parser.add_argument("--output-dir", default="target/benchmark-v03-results")
    parser.add_argument("--rust-driver", default="target/benchmark-v03")
    parser.add_argument("--rust-argv", action="store_true", help="Print JSON argv only; no native imports/launch")
    args = parser.parse_args()
    if args.prepare_suite_case:
        prepare(args)
    else:
        case = load_case(args.case)
        if args.rust_argv:
            rust_argv(args, case)
        else:
            asyncio.run(benchmark(args, case))


if __name__ == "__main__":
    main()
