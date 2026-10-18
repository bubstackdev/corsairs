#!/usr/bin/env python3
"""Run the pinned Python differential reference, isolating each native invocation.

Use a native execution environment; the shell sandbox cannot access CoreAI's
specialization cache/device services. Native traps remain failed observations.
"""
import argparse
import asyncio
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time
import traceback

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import FIXTURES, initialize, identity, write_json
from execution import execution_error, select_os_framework


def read_spec(spec):
    payload = (FIXTURES / spec["file"]).read_bytes()
    if hashlib.sha256(payload).hexdigest() != spec["sha256"]:
        raise RuntimeError(f"Fixture digest changed: {spec['file']}")
    return np.frombuffer(payload, dtype=np.dtype(spec["dtype"]).newbyteorder("<")).reshape(spec["shape"]).copy()


# b3 spells these dtypes without NumPy/ml_dtypes' underscore. Observations keep
# b3's name; metadata comparison accepts exactly these aliases and nothing else.
NATIVE_DTYPE_ALIASES = {"float8e4m3fn": "float8_e4m3fn", "float8e5m2": "float8_e5m2"}


def snapshot(tensor, expected, path, policy):
    array = tensor.numpy()
    payload = array.astype(array.dtype.newbyteorder("<"), copy=False).tobytes(order="C")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(payload)
    wanted = read_spec(expected)
    metadata_match = (list(tensor.shape) == expected["shape"]
                      and NATIVE_DTYPE_ALIASES.get(tensor.dtype, tensor.dtype) == expected["dtype"])
    exact = payload == (FIXTURES / expected["file"]).read_bytes()
    if policy == "ieee-special":
        same_values = np.all((array == wanted) | (np.isnan(array) & np.isnan(wanted)))
        zero_mask = (array == 0) & (wanted == 0)
        zero_signs = np.array_equal(np.signbit(array[zero_mask]), np.signbit(wanted[zero_mask]))
        numeric_match = bool(same_values and zero_signs)
    else:
        numeric_match = exact
    return {"dtype": tensor.dtype, "shape": list(tensor.shape), "strides": list(tensor.strides),
            "file": str(path.relative_to(FIXTURES)), "sha256": hashlib.sha256(payload).hexdigest(),
            "exact_bytes": exact, "comparison": policy, "passed": bool(metadata_match and numeric_match),
            "values": [str(value) for value in array.reshape(-1).tolist()]}


async def run_child(case, backend, negative):
    select_os_framework(os.environ)
    from coreai.runtime import AIModel, ComputeUnitKind, NDArray, SpecializationOptions, _use_os_coreai
    directory = FIXTURES / "results" / backend / case["name"]
    if negative:
        directory = directory / negative
    directory.mkdir(parents=True, exist_ok=True)
    result = {"case": case["name"], "backend": backend, "negative_case": negative,
              "os_backed": _use_os_coreai, "status": "running"}
    stage = "reference_backing"
    try:
        if _use_os_coreai is not True:
            raise RuntimeError("Reference must use OS Core AI")
        stage = "options"
        options = (SpecializationOptions.cpu_only() if backend == "cpu"
                   else SpecializationOptions.from_preferred_compute_unit_kind(
                       ComputeUnitKind.neural_engine() if backend == "neural-engine-preferred"
                       else ComputeUnitKind.gpu()))
        result["allowed_compute_units"] = [str(kind) for kind in options.allowed_compute_unit_kinds]
        result["preferred_compute_unit"] = str(options.preferred_compute_unit_kind)
        model_path = FIXTURES / case["model"]
        if negative == "missing_asset":
            model_path = FIXTURES / "does-not-exist.aimodel"
        stage = "model_load"
        model = await AIModel.load(model_path, options)
        stage = "function_load"
        function = model.load_function("does-not-exist" if negative == "missing_function" else case["function"])
        stage = "descriptor"
        desc = function.desc
        result["descriptor"] = {"name": desc.name, "inputs": list(desc.input_names),
                                "outputs": list(desc.output_names), "state": list(desc.state_names)}
        steps = case.get("steps", [{"inputs": case["inputs"], "outputs": case["outputs"]}])
        states = {name: NDArray(read_spec(spec)) for name, spec in case.get("state", {}).items()}
        if negative == "missing_state":
            states = {}
        if negative == "wrong_state_shape":
            states = {"accumulator": NDArray(np.ones((3, 2), dtype=np.float32))}
        observations = []
        for step_number, step in enumerate(steps):
            stage = "input_creation"
            inputs = {name: NDArray(read_spec(spec)) for name, spec in step["inputs"].items()}
            if negative == "missing_input":
                inputs = {}
            elif negative == "unknown_input":
                inputs = {"unknown": inputs["x"]}
            elif negative == "wrong_shape":
                inputs = {"x": NDArray(np.ones((3, 2), dtype=np.float32))}
            elif negative == "wrong_dtype":
                inputs = {"x": NDArray(np.ones((2, 3), dtype=np.int32))}
            stage = "inference"
            outputs = await function(inputs=inputs, state=states)
            stage = "output_readback"
            observed = {"outputs": {}, "state_after": {}}
            for name, expected in step["outputs"].items():
                observed["outputs"][name] = snapshot(outputs[name], expected,
                    directory / f"step{step_number}-{name}.bin", case["comparison"])
            for name, expected in step.get("state_after", {}).items():
                observed["state_after"][name] = snapshot(states[name], expected,
                    directory / f"step{step_number}-state-{name}.bin", case["comparison"])
            observations.append(observed)
        result["steps"] = observations
        matches = all(value["passed"] for step in observations for group in step.values() for value in group.values())
        result["status"] = "unexpected_success" if negative else ("passed" if matches else "mismatch")
    except Exception as exc:
        expected_stage = {"missing_asset": "model_load", "missing_function": "function_load"}.get(negative, "inference")
        result["status"] = "expected_error" if negative and stage == expected_stage else "error"
        result["failure_stage"] = stage
        result["error_type"] = type(exc).__name__
        result["error"] = str(exc)
        result["traceback"] = traceback.format_exc()
    write_json(directory / "observation.json", result)
    print(json.dumps(result, allow_nan=False), flush=True)
    return 0 if result["status"] in ["passed", "expected_error"] else 1


def suite_main(args):
    suite = json.loads((FIXTURES / "suite.json").read_text())
    cases = suite["cases"]
    if args.case:
        cases = [case for case in cases if case["name"] == args.case]
    if not cases:
        raise RuntimeError("No matching fixture")
    if args.child:
        return asyncio.run(run_child(cases[0], args.backend, args.negative))
    report_path = Path(args.report) if args.report else FIXTURES / (f"python-results-{args.case}-{args.backend or 'both'}.json" if args.case else "python-results.json")
    results = []
    backends = getattr(args, "backends", None) or ([args.backend] if args.backend else ["cpu", "gpu-preferred"])
    invocations = [(case, backend, None) for backend in backends for case in cases]
    if not args.case:
        selected = {case["name"]: case for case in cases}
        invocations += [(selected["accumulator"] if "state" in negative else selected["double_float32"], backend, negative)
                        for backend in backends for negative in suite["negative_cases"]]
    for case, backend, negative in invocations:
        command = [sys.executable, "-I", "-B", str(Path(__file__).resolve()), "--child", "--case", case["name"], "--backend", backend]
        if negative:
            command += ["--negative", negative]
        started = time.monotonic()
        try:
            environment = os.environ.copy()
            select_os_framework(environment)
            completed = subprocess.run(command, capture_output=True, text=True, timeout=args.timeout,
                                       env=environment)
            try:
                observation = json.loads(completed.stdout.strip().splitlines()[-1])
                if not isinstance(observation, dict):
                    raise ValueError("Child observation must be a JSON object")
            except (ValueError, IndexError):
                observation = {"status": "native_failure", "stdout": completed.stdout[-6000:], "stderr": completed.stderr[-6000:]}
            observation["returncode"] = completed.returncode
            if problem := execution_error(observation):
                observation["reported_status"] = observation.get("status")
                observation.update({"status": "native_failure", "validation_error": problem,
                                    "stdout": completed.stdout[-6000:], "stderr": completed.stderr[-6000:]})
        except subprocess.TimeoutExpired as exc:
            observation = {"status": "timeout", "timeout_seconds": args.timeout}
        observation.update({"case": case["name"], "backend": backend, "negative_case": negative,
                            "elapsed_seconds": time.monotonic() - started})
        results.append(observation)
        write_json(report_path, {"reference": identity(), "results": results, "complete": False})
        print(f"{backend} {case['name']} {negative or 'valid'}: {observation['status']}", flush=True)
    report = {"reference": identity(), "results": results, "complete": True,
              "passed": all(row["status"] in ["passed", "expected_error"]
                            and execution_error(row) is None for row in results)}
    write_json(report_path, report)
    print(json.dumps({"complete": True, "invocations": len(results), "passed": report["passed"]}), flush=True)
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--child", action="store_true")
    parser.add_argument("--case")
    parser.add_argument("--backend", choices=["cpu", "gpu-preferred", "neural-engine-preferred"])
    parser.add_argument("--backends", nargs="+", choices=["cpu", "gpu-preferred", "neural-engine-preferred"],
                        help="run several backends into one report")
    parser.add_argument("--negative")
    parser.add_argument("--timeout", type=int, default=120)
    parser.add_argument("--report", help="Optional report destination; defaults preserve full-suite reports for filtered runs")
    args = parser.parse_args()
    initialize()
    import numpy as np
    raise SystemExit(suite_main(args))
