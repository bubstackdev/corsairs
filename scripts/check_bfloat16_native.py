#!/usr/bin/env python3
"""Build BF16 public-API probes or check already captured native results.

This script never executes a native probe. The root-coordinated native runner
must run the retained Swift and Rust commands, then invoke the check subcommand.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "fixtures/parity-v02/bfloat16"


def digest(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def load(path): return json.loads(Path(path).read_text())
def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n")


def spec(name, value):
    return "Spec{" + f"name:{json.dumps(name)},shape:&{value['shape']!r},file:{json.dumps(value['file'])}" + "}"


def specs(values): return "&[" + ",".join(spec(name, value) for name, value in values.items()) + "]"


def build(args):
    fixtures = load(FIXTURES / "manifest.json")
    directory = ROOT / "target/bfloat16-native"
    directory.mkdir(parents=True, exist_ok=True)
    table = directory / "cases.rs"
    cases = []
    for case in fixtures["cases"]:
        steps = ["Step{" + f"inputs:{specs(step['inputs'])},outputs:{specs(step['outputs'])},states:{specs(step.get('state_after',{}))}" + "}" for step in case["steps"]]
        cases.append("Case{" + f"name:{json.dumps(case['name'])},model:{json.dumps(case['model'])},dynamic:{str(case['name']=='dynamic').lower()},initial_state:{specs(case.get('state',{}))},steps:&[{','.join(steps)}]" + "}")
    table.write_text("const CASES:&[Case]=&[" + ",\n".join(cases) + "];\n")
    profiles = [args.profile] if args.profile else ["debug", "release"]
    commands, binaries = [], []
    for profile in profiles:
        command = ["cargo", "build", "--offline", "-p", "corsairs", "--lib"]
        if profile == "release": command.append("--release")
        env = os.environ.copy()
        env["CORSAIRS_BF16_CASES"] = str(table)
        binary = directory / f"bfloat16-{profile}"
        rust = ["rustc", "--edition=2024", str(ROOT / "experiments/rust/bfloat16_parity.rs"),
                "--extern", f"corsairs={ROOT}/target/{profile}/libcorsairs.rlib", "-L",
                f"dependency={ROOT}/target/{profile}/deps", "-o", str(binary)]
        if profile == "release": rust += ["-C", "opt-level=3"]
        for cmd in [command, rust]:
            result = subprocess.run(cmd, cwd=ROOT, env=env, text=True, capture_output=True)
            commands.append({"command": cmd, "exit_code": result.returncode, "stdout": result.stdout, "stderr": result.stderr})
            if result.returncode: raise RuntimeError(result.stderr)
        binaries.append(binary)
    files = sorted((ROOT / "crates/corsairs-abi/src").rglob("*.rs")) + [
        ROOT / "experiments/rust/bfloat16_parity.rs", Path(__file__), table,
        ROOT / "scripts/reference/build_bfloat16_fixtures.py", FIXTURES / "manifest.json"] + binaries
    report = {"native_executed": False, "commands": commands,
              "case_table_environment": {"CORSAIRS_BF16_CASES": str(table)},
              "files_sha256": {str(path.relative_to(ROOT)): digest(path) for path in files},
              "native_commands": [[str(binary.relative_to(ROOT)), str(FIXTURES.relative_to(ROOT)),
                                   str((directory / (binary.name + "-output")).relative_to(ROOT))] for binary in binaries]}
    write(directory / "build.json", report)
    write(args.evidence_dir / "rust-build.json", report)
    print(json.dumps({"native_commands": report["native_commands"], "build": str(args.evidence_dir / "rust-build.json")}))


def check(args):
    fixtures = load(FIXTURES / "manifest.json")
    for name, expected in fixtures["sha256"].items():
        if digest(FIXTURES / name) != expected: raise AssertionError(f"Fixture changed: {name}")
    swift = load(args.swift / "swift-results.json")
    if not swift["passed"] or swift["all_encodings"] != 65536 or not swift["bfloat16_distinct_from_float16"]:
        raise AssertionError("Swift native oracle did not pass")
    observation = load(args.observation)
    native = observation["normalized_result"]
    process = native["process"]
    if process["exit_status"] != 0 or native["coverage"]["status"] != "complete" or not process["stdout"]["complete"]:
        raise AssertionError("Incomplete/failed native observation")
    lines = [json.loads(line) for line in process["stdout"]["text"].splitlines() if line.startswith("{")]
    complete = [line for line in lines if line.get("event") == "complete"]
    if len(complete) != 1 or not complete[0]["passed"] or complete[0]["configurations"] != 46:
        raise AssertionError("Missing complete 46-configuration result")
    raw = [line for line in lines if line.get("event") == "bf16_raw"]
    if len(raw) != 1 or raw[0]["encodings"] != 65536 or not all(raw[0][name] for name in ["native_exact", "metal_exact", "clone_drop"]):
        raise AssertionError("Raw all-encoding result missing")
    all_bits = (FIXTURES / "all-encodings.bin").read_bytes()
    for path in [args.swift / "all-encodings.bin", args.rust / "native-all-encodings.bin", args.rust / "metal-all-encodings.bin"]:
        if path.read_bytes() != all_bits: raise AssertionError(f"All-encoding raw mismatch: {path}")
    expected = {}
    swift_records = {(r["backend"], r["case"], r["step"]): r for r in swift["records"]}
    for backend in ["cpu", "gpu-preferred"]:
        for case in fixtures["cases"]:
            modes = ["owned", "native", "metal-auto"] + ([] if case["name"] == "dynamic" else ["metal-bound"])
            for index, step in enumerate(case["steps"]):
                reference = swift_records[(backend, case["name"], index)]
                for mode in modes:
                    label = f"{backend}-{mode}-{case['name']}-{index}"
                    for kind, values in [("output", step["outputs"]), ("state", step.get("state_after", {}))]:
                        for name, value in values.items():
                            swift_file = f"{backend}-{case['name']}-{index}-{'y' if kind == 'output' else 'state'}.bin"
                            expected[(label, kind, name)] = (value, args.swift / swift_file, reference, mode)
    values = [line for line in lines if line.get("event") == "bf16_value"]
    if len(values) != len(expected): raise AssertionError(f"Expected {len(expected)} records, received {len(values)}")
    checked, seen = [], set()
    for value in values:
        key = (value["label"], value["kind"], value["name"])
        if key in seen: raise AssertionError(f"Duplicate record {key}")
        seen.add(key)
        fixture, reference_path, reference, mode = expected[key]
        payload = (args.rust / value["file"]).read_bytes()
        if payload != reference_path.read_bytes() or payload != (FIXTURES / fixture["file"]).read_bytes():
            raise AssertionError(f"Rust differs from Swift/finite arithmetic fixture: {key}")
        if value["dtype"] != "bfloat16" or value["shape"] != fixture["shape"] or not value["exact"]:
            raise AssertionError(f"Rust metadata differs: {key}")
        if mode == "native" and value["kind"] == "output" and value["native_strides"] != reference["strides"]:
            raise AssertionError(f"Native output strides differ from Swift: {key}")
        checked.append({**value, "sha256": hashlib.sha256(payload).hexdigest(),
                        "swift_file": str(reference_path), "swift_exact": True})
    if seen != set(expected): raise AssertionError("Missing configuration values")
    report = {"passed": True, "configuration_count": 46, "checked_value_count": len(checked),
              "all_native_raw_encodings": 65536, "all_metal_raw_encodings": 65536,
              "fixture_manifest_sha256": digest(FIXTURES / "manifest.json"),
              "native_observation": str(args.observation), "native_observation_sha256": digest(args.observation),
              "swift_report": str(args.swift / "swift-results.json"), "swift_report_sha256": digest(args.swift / "swift-results.json"),
              "completion": complete[0], "values": checked,
              "limitations": ["Exact finite fixtures and raw all-encoding storage; NaN arithmetic is not specified.",
                              "Same-host Swift/native stride equality is fixture-specific.",
                              "Successful abandoned-job completion does not by itself measure native store counts."]}
    write(args.report, report)
    print(json.dumps({"passed": True, "configurations": 46, "values": len(checked), "report": str(args.report)}))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="action", required=True)
    compile_parser = subparsers.add_parser("build")
    compile_parser.add_argument("--evidence-dir", type=Path, default=ROOT / "docs/evidence/v0.2-bfloat16")
    compile_parser.add_argument("--profile", choices=["debug", "release"])
    check_parser = subparsers.add_parser("check")
    check_parser.add_argument("--swift", required=True, type=Path)
    check_parser.add_argument("--rust", required=True, type=Path)
    check_parser.add_argument("--observation", required=True, type=Path)
    check_parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    (build if args.action == "build" else check)(args)


if __name__ == "__main__": main()
