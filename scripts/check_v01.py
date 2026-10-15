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
DTYPES = {"float16": "Float16", "float32": "Float32", "int32": "Int32", "int64": "Int64", "bool": "Bool"}


def quoted(value):
    # Fixture labels and paths are ASCII; JSON string literals are valid Rust.
    return json.dumps(value, ensure_ascii=True)


def specs(values, *, order=None):
    rendered = []
    for name in order or values:
        value = values[name]
        shape = ",".join(str(n) for n in value["shape"])
        strides = ",".join(str(n) for n in value.get("strides", []))
        rendered.append("Spec { name: %s, dtype: DType::%s, shape: &[%s], strides: &[%s], file: %s }" %
                        (quoted(name), DTYPES[value["dtype"]], shape, strides, quoted(value["file"])))
    return "&[" + ",\n".join(rendered) + "]"


def prepare_data():
    suite = json.loads((FIXTURES / "suite.json").read_text())
    goldens = json.loads((FIXTURES / "backend-goldens.json").read_text())
    expected_wheel = "8db70074eb049b0a86bd263e137ea173f3298f7f1b60ec1a7f7c592f4c26c4a9"
    if goldens["reference"]["wheel_sha256"] != expected_wheel:
        raise RuntimeError("Unexpected reference wheel")
    initial = FIXTURES / goldens["source_observations"]
    if hashlib.sha256(initial.read_bytes()).hexdigest() != goldens["source_observations_sha256"]:
        raise RuntimeError("Original native reference observations changed")
    for path, digest in suite["sha256"].items():
        if hashlib.sha256((FIXTURES / path).read_bytes()).hexdigest() != digest:
            raise RuntimeError(f"Fixture bytes changed: {path}")
    by_name = {case["name"]: case for case in suite["cases"]}
    rendered = []
    tensor_count = 0
    for golden in goldens["cases"]:
        case = by_name[golden["case"]]
        original_steps = case.get("steps", [{"inputs": case["inputs"]}])
        if len(original_steps) != len(golden["steps"]):
            raise RuntimeError("Fixture/golden step counts differ")
        steps = []
        for original, expected in zip(original_steps, golden["steps"]):
            for group in expected.values():
                for tensor in group.values():
                    if hashlib.sha256((FIXTURES / tensor["file"]).read_bytes()).hexdigest() != tensor["sha256"]:
                        raise RuntimeError(f"Frozen backend output changed: {tensor['file']}")
                    tensor_count += 1
            steps.append("Step { inputs: %s, outputs: %s, states: %s }" %
                         (specs(original["inputs"], order=golden["descriptor"]["inputs"]),
                          specs(expected["outputs"], order=golden["descriptor"]["outputs"]), specs(expected["state_after"])))
        rendered.append("Case { name: %s, backend: %s, compute: Compute::%s, model: %s, inputs: %s, initial_state: %s, steps: &[%s] }" %
                        (quoted(case["name"]), quoted(golden["backend"]), "CpuOnly" if golden["backend"] == "cpu" else "GpuPreferred",
                         quoted(case["model"]), specs(case["inputs"], order=golden["descriptor"]["inputs"]),
                         specs(case.get("state", {}), order=golden["descriptor"]["state"]), ",\n".join(steps)))
    if len(rendered) != 32 or len(goldens["negative_cases"]) != 16:
        raise RuntimeError("Reference grid must contain 32 positive and 16 negative configurations")
    generated = OUTPUT / "cases.rs"
    generated.parent.mkdir(parents=True, exist_ok=True)
    generated.write_text("// Generated from pinned fixtures and native Python backend goldens.\nconst CASES: &[Case] = &[\n" + ",\n".join(rendered) + "\n];\n")
    return {"cases": 32, "negative_cases": 16, "golden_tensors": tensor_count,
            "generated_sha256": hashlib.sha256(generated.read_bytes()).hexdigest(),
            "suite_sha256": hashlib.sha256((FIXTURES / "suite.json").read_bytes()).hexdigest(),
            "goldens_sha256": hashlib.sha256((FIXTURES / "backend-goldens.json").read_bytes()).hexdigest()}


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
                print(f"{profile}: native public-API parity (32 positive +16 negative configurations)", flush=True)
                observation = execute([binary, FIXTURES, "parity"], report, native=True)
                events = observation["events"]
                if len([row for row in events if row["event"] == "parity" and row["passed"]]) != 32:
                    raise RuntimeError("Driver did not validate all 32 positive configurations")
                if len([row for row in events if row["event"] == "negative" and row["passed"]]) != 16:
                    raise RuntimeError("Driver did not validate all 16 typed negative configurations")
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
