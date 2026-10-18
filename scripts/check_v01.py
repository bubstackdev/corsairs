#!/usr/bin/env python3
"""Build and exercise Corsairs v0.1 exclusively through the safe public API."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "fixtures" / "parity-v01"
OUTPUT = ROOT / "target" / "v01-check"
# (directory relative to FIXTURES, goldens file): the original frozen CPU/GPU
# grid, the separately frozen Neural Engine grid, and the v0.4 scalar and float8 types.
GOLDEN_SETS = ((".", "backend-goldens.json"), (".", "backend-goldens-neural-engine-preferred.json"),
               ("../parity-v04/scalar-types", "backend-goldens.json"), ("../parity-v04/float8", "backend-goldens.json"))
COMPUTE = {"cpu": "CpuOnly", "gpu-preferred": "GpuPreferred", "neural-engine-preferred": "NeuralEnginePreferred"}
DTYPES = {"float16": "Float16", "float32": "Float32", "float64": "Float64", "int8": "Int8", "int16": "Int16",
          "int32": "Int32", "int64": "Int64", "uint8": "UInt8", "uint16": "UInt16", "uint32": "UInt32",
          "uint64": "UInt64", "bool": "Bool", "float8_e4m3fn": "Float8E4M3Fn", "float8_e5m2": "Float8E5M2",
          # b3's spelling, kept verbatim in frozen observations.
          "float8e4m3fn": "Float8E4M3Fn", "float8e5m2": "Float8E5M2"}


def quoted(value):
    # Fixture labels and paths are ASCII; JSON string literals are valid Rust.
    return json.dumps(value, ensure_ascii=True)


def relative(prefix, path):
    """A set-relative fixture path, expressed relative to FIXTURES for drivers."""
    return path if prefix == "." else f"{prefix}/{path}"


def specs(values, prefix, *, order=None):
    rendered = []
    for name in order or values:
        value = values[name]
        shape = ",".join(str(n) for n in value["shape"])
        strides = ",".join(str(n) for n in value.get("strides", []))
        rendered.append("Spec { name: %s, dtype: DType::%s, shape: &[%s], strides: &[%s], file: %s }" %
                        (quoted(name), DTYPES[value["dtype"]], shape, strides, quoted(relative(prefix, value["file"]))))
    return "&[" + ",\n".join(rendered) + "]"


def prepare_data():
    expected_wheel = "8db70074eb049b0a86bd263e137ea173f3298f7f1b60ec1a7f7c592f4c26c4a9"
    rendered, negatives, backends, identities = [], [], [], {}
    tensor_count = 0
    for prefix, name in GOLDEN_SETS:
        directory = FIXTURES / prefix
        suite = json.loads((directory / "suite.json").read_text())
        goldens = json.loads((directory / name).read_text())
        if goldens["reference"]["wheel_sha256"] != expected_wheel:
            raise RuntimeError("Unexpected reference wheel")
        initial = directory / goldens["source_observations"]
        if hashlib.sha256(initial.read_bytes()).hexdigest() != goldens["source_observations_sha256"]:
            raise RuntimeError("Original native reference observations changed")
        for path, digest in suite["sha256"].items():
            if hashlib.sha256((directory / path).read_bytes()).hexdigest() != digest:
                raise RuntimeError(f"Fixture bytes changed: {relative(prefix, path)}")
        set_backends = list(dict.fromkeys(golden["backend"] for golden in goldens["cases"]))
        # Every (case, backend) is either a frozen success or a reviewed native error.
        if (len(goldens["cases"]) + len(goldens.get("native_errors", [])) != len(suite["cases"]) * len(set_backends)
                or len(goldens["negative_cases"]) != len(suite["negative_cases"]) * len(set_backends)):
            raise RuntimeError(f"Incomplete reference grid: {relative(prefix, name)}")
        backends += [backend for backend in set_backends if backend not in backends]
        negatives += goldens["negative_cases"]
        identities[relative(prefix, name)] = hashlib.sha256((directory / name).read_bytes()).hexdigest()
        identities[relative(prefix, "suite.json")] = hashlib.sha256((directory / "suite.json").read_bytes()).hexdigest()
        by_name = {case["name"]: case for case in suite["cases"]}
        for golden in goldens["cases"]:
            case = by_name[golden["case"]]
            original_steps = case.get("steps", [{"inputs": case["inputs"]}])
            if len(original_steps) != len(golden["steps"]):
                raise RuntimeError("Fixture/golden step counts differ")
            steps = []
            for original, expected in zip(original_steps, golden["steps"]):
                for group in expected.values():
                    for tensor in group.values():
                        if hashlib.sha256((directory / tensor["file"]).read_bytes()).hexdigest() != tensor["sha256"]:
                            raise RuntimeError(f"Frozen backend output changed: {relative(prefix, tensor['file'])}")
                        tensor_count += 1
                steps.append("Step { inputs: %s, outputs: %s, states: %s }" %
                             (specs(original["inputs"], prefix, order=golden["descriptor"]["inputs"]),
                              specs(expected["outputs"], prefix, order=golden["descriptor"]["outputs"]),
                              specs(expected["state_after"], prefix)))
            rendered.append("Case { name: %s, backend: %s, compute: Compute::%s, model: %s, inputs: %s, initial_state: %s, steps: &[%s] }" %
                            (quoted(case["name"]), quoted(golden["backend"]), COMPUTE[golden["backend"]],
                             quoted(relative(prefix, case["model"])), specs(case["inputs"], prefix, order=golden["descriptor"]["inputs"]),
                             specs(case.get("state", {}), prefix, order=golden["descriptor"]["state"]), ",\n".join(steps)))
    generated = OUTPUT / "cases.rs"
    generated.parent.mkdir(parents=True, exist_ok=True)
    generated.write_text("// Generated from pinned fixtures and native Python backend goldens.\nconst CASES: &[Case] = &[\n" + ",\n".join(rendered) + "\n];\n"
                         "#[allow(dead_code, reason = \"shared by drivers that do not all iterate backends\")]\n"
                         "const BACKENDS: &[(&str, Compute)] = &[" + ", ".join(f"({quoted(name)}, Compute::{COMPUTE[name]})" for name in backends) + "];\n")
    return {"cases": len(rendered), "negative_cases": len(negatives), "backends": backends, "golden_tensors": tensor_count,
            "generated_sha256": hashlib.sha256(generated.read_bytes()).hexdigest(), "inputs_sha256": identities}


def tool(name):
    found = shutil.which(name)
    if found:
        return found
    candidate = Path.home() / ".cargo" / "bin" / name
    if candidate.is_file():
        return str(candidate)
    raise RuntimeError(f"Required tool is unavailable: {name}")


def execute(command, report, *, env=None, timeout=300, native=False):
    started = time.monotonic()
    completed = subprocess.run([str(arg) for arg in command], cwd=ROOT,
                               env={**os.environ, **(env or {})}, capture_output=True, text=True, timeout=timeout)
    observation = {"command": [str(arg) for arg in command], "returncode": completed.returncode,
                   "elapsed_seconds": time.monotonic() - started, "stdout": completed.stdout, "stderr": completed.stderr}
    if native:
        events = []
        for line in completed.stdout.splitlines():
            try:
                events.append(json.loads(line))
            except json.JSONDecodeError:
                pass
        observation["events"] = events
        observation["native_complete"] = bool(events and events[-1].get("event") == "complete" and events[-1].get("passed"))
    report["commands"].append(observation)
    save(report)
    if completed.returncode != 0:
        raise RuntimeError(f"Command failed ({completed.returncode}): {' '.join(map(str, command))}\n{completed.stdout[-6000:]}\n{completed.stderr[-3000:]}")
    if native and not observation["native_complete"]:
        raise RuntimeError("Native driver did not report successful completion")
    return observation


def save(report):
    (OUTPUT / "checks.json").write_text(json.dumps(report, indent=2) + "\n")


def source_hashes():
    paths = {ROOT / "Cargo.toml", ROOT / "Cargo.lock", ROOT / "experiments/rust/v01_driver.rs",
             ROOT / "scripts/check_v01.py", OUTPUT / "cases.rs"}
    paths.update((ROOT / "crates").rglob("*.rs"))
    paths.update((ROOT / "crates").rglob("Cargo.toml"))
    if (ROOT / ".cargo").exists():
        paths.update(path for path in (ROOT / ".cargo").rglob("*") if path.is_file())
    return {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in sorted(paths) if path.is_file()}


def binary_hashes(profile):
    paths = [OUTPUT / f"driver-{profile}", ROOT / "target" / profile / "libcorsairs.rlib"]
    return {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", action="store_true", help="Run parity and lifecycle probes in a native environment")
    parser.add_argument("--profiles", nargs="+", choices=["debug", "release"], default=["debug", "release"])
    parser.add_argument("--cycles", type=int, default=10000)
    parser.add_argument("--loads", type=int, default=100)
    parser.add_argument("--dropped", type=int, default=100)
    parser.add_argument("--skip-stress", action="store_true")
    parser.add_argument("--no-build", action="store_true", help="Verify exact source and binary identities against build-manifest.json, then reuse drivers")
    args = parser.parse_args()
    if min(args.cycles, args.loads, args.dropped) < 1:
        parser.error("stress counts must be positive")
    OUTPUT.mkdir(parents=True, exist_ok=True)
    report = {"started_at": datetime.now(timezone.utc).isoformat(), "platform": platform.platform(),
              "native_requested": args.native, "public_api_only": True, "driver_forbids_unsafe": True,
              "profiles": args.profiles, "stress": {"stateless_and_stateful_each": args.cycles, "load_drop": args.loads,
                  "dropped_each_kind": args.dropped, "per_backend_per_profile": True}, "commands": [], "passed": False}
    try:
        report["fixtures"] = prepare_data()
        sources = source_hashes()
        report["source_hashes"] = sources
        report["source_identity_sha256"] = hashlib.sha256(json.dumps(sources, sort_keys=True).encode()).hexdigest()
        manifest_path = OUTPUT / "build-manifest.json"
        cargo, rustc = tool("cargo"), tool("rustc")
        report["compiler"] = subprocess.check_output([rustc, "--version"], text=True).strip()
        if args.no_build:
            if not manifest_path.is_file():
                raise RuntimeError("--no-build requires a prior successful build-manifest.json")
            manifest = json.loads(manifest_path.read_text())
            if manifest["source_hashes"] != sources:
                changed = sorted(name for name in set(sources) | set(manifest["source_hashes"])
                                 if sources.get(name) != manifest["source_hashes"].get(name))
                raise RuntimeError(f"--no-build rejected changed source: {changed}; rebuild drivers")
            if manifest["fixtures"] != report["fixtures"]:
                raise RuntimeError("--no-build rejected changed fixture/golden identities")
            if manifest["compiler"] != report["compiler"]:
                raise RuntimeError("--no-build rejected changed Rust compiler")
            for profile in args.profiles:
                if manifest.get("binaries", {}).get(profile) != binary_hashes(profile):
                    raise RuntimeError(f"--no-build rejected changed or unrecorded {profile} binaries")
        else:
            manifest = {"source_hashes": sources, "source_identity_sha256": report["source_identity_sha256"],
                        "fixtures": report["fixtures"], "compiler": report["compiler"], "binaries": {}}
            for profile in args.profiles:
                command = [cargo, "build", "--offline", "-p", "corsairs", "--lib"]
                if profile == "release":
                    command.append("--release")
                execute(command, report)
                execute([rustc, "--edition=2024", "-Dwarnings", "-C", f"opt-level={3 if profile == 'release' else 0}",
                         ROOT / "experiments/rust/v01_driver.rs", "--extern", f"corsairs={ROOT / 'target' / profile / 'libcorsairs.rlib'}",
                         "-L", f"dependency={ROOT / 'target' / profile / 'deps'}", "-o", OUTPUT / f"driver-{profile}"], report,
                        env={"CORSAIRS_V01_CASES": str(OUTPUT / "cases.rs")})
                manifest["binaries"][profile] = binary_hashes(profile)
            if source_hashes() != sources:
                raise RuntimeError("Sources changed during the build; rerun to bind binaries to a stable source snapshot")
            manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
        report["build_manifest_sha256"] = hashlib.sha256(manifest_path.read_bytes()).hexdigest()
        for profile in args.profiles:
            binary = OUTPUT / f"driver-{profile}"
            if not binary.is_file():
                raise RuntimeError(f"Driver missing: {binary}")
            report.setdefault("driver_sha256", {})[profile] = hashlib.sha256(binary.read_bytes()).hexdigest()
            if args.native:
                grid = report["fixtures"]
                print(f"{profile}: native public-API parity ({grid['cases']} positive +{grid['negative_cases']} negative configurations)", flush=True)
                observation = execute([binary, FIXTURES, "parity"], report, native=True)
                events = observation["events"]
                if len([row for row in events if row["event"] == "parity" and row["passed"]]) != grid["cases"]:
                    raise RuntimeError(f"Driver did not validate all {grid['cases']} positive configurations")
                if len([row for row in events if row["event"] == "negative" and row["passed"]]) != grid["negative_cases"]:
                    raise RuntimeError(f"Driver did not validate all {grid['negative_cases']} typed negative configurations")
                if not args.skip_stress:
                    print(f"{profile}: {args.cycles} stateless +{args.cycles} stateful per backend; lifecycle probes", flush=True)
                    execute([binary, FIXTURES, "stress", args.cycles, args.loads, args.dropped], report, native=True, timeout=600)
        report["passed"] = True
        report["native_validated"] = args.native
        save(report)
        print(json.dumps({"passed": True, "native_validated": args.native, "profiles": args.profiles,
                          "report": str(OUTPUT / "checks.json")}), flush=True)
        return 0
    except Exception as error:
        report["error"] = str(error)
        save(report)
        print(str(error), file=sys.stderr, flush=True)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
