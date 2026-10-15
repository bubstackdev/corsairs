#!/usr/bin/env python3
"""Pin and qualify large mechanical tensor signatures against independent Swift.

Each native invocation runs one case/compute/profile, with Swift then Rust in
separate processes. No multi-gigabyte fixtures or output payloads are retained.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import resource
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / "target/large-check"
FIXTURES = ROOT / "fixtures/parity-v03/large-tensors"

def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n")

def sources():
    paths = [ROOT / n for n in ["Cargo.toml", "Cargo.lock", "scripts/check_large_tensors.py",
        "scripts/reference/build_large_fixtures.py", "experiments/rust/large_tensors.rs", "experiments/swift/LargeTensorReference.swift"]]
    paths += list((ROOT / "crates").rglob("*.rs")) + list((ROOT / "crates").rglob("Cargo.toml"))
    paths += [p for p in FIXTURES.rglob("*") if p.is_file()]
    return {str(p.relative_to(ROOT)): sha(p) for p in sorted(set(paths))}

def command(args):
    run = subprocess.run(list(map(str, args)), cwd=ROOT, capture_output=True, text=True, timeout=120)
    if run.returncode:
        raise RuntimeError(run.stderr + run.stdout)
    return {"command": list(map(str, args)), "exit_status": run.returncode, "stdout": run.stdout, "stderr": run.stderr}

def native(args, label, output, timeout):
    stdout, stderr = output / (label + ".stdout"), output / (label + ".stderr")
    started = time.monotonic()
    with stdout.open("w") as out, stderr.open("w") as err:
        process = subprocess.Popen(list(map(str, args)), cwd=ROOT, stdout=out, stderr=err)
        try:
            status = process.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            process.kill(); status = process.wait()
            timed_out = True
        else:
            timed_out = False
    observation = {"command": list(map(str, args)), "exit_status": status,
        "elapsed_seconds": time.monotonic() - started, "timed_out": timed_out,
        "stdout": stdout.read_text(), "stderr": stderr.read_text()}
    save(output / (label + "-process.json"), observation)
    return observation

def require_success(observation, label):
    if observation["exit_status"] or observation["timed_out"]:
        raise RuntimeError(f"{label} failed ({observation['exit_status']}, timeout={observation['timed_out']}): {observation['stderr'][-3000:]}")

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", action="store_true")
    parser.add_argument("--native", action="store_true")
    parser.add_argument("--case", choices=["h3-hidden", "h3-rgb124", "h3-rgb345", "limit-f32"], default="h3-hidden")
    parser.add_argument("--compute", choices=["cpu", "gpu-preferred"], default="gpu-preferred")
    parser.add_argument("--profile", choices=["debug", "release"], default="release")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    BUILD.mkdir(parents=True, exist_ok=True)
    manifest_path = BUILD / "build-manifest.json"
    fixture = json.loads((FIXTURES / "manifest.json").read_text())
    for path, digest in fixture["sha256"].items():
        if sha(FIXTURES / path) != digest:
            raise RuntimeError(f"Fixture identity differs: {path}")
    source_hashes = sources()
    if args.build:
        commands = []
        swift = BUILD / "swift-oracle"
        commands.append(command(["swiftc", "-parse-as-library", "-O", "-module-cache-path", BUILD / "module-cache",
            ROOT / "experiments/swift/LargeTensorReference.swift", "-o", swift]))
        binaries = {str(swift.relative_to(ROOT)): sha(swift)}
        for profile in ["debug", "release"]:
            commands.append(command(["cargo", "build", "--offline", "-p", "corsairs", "--lib", "--target-dir", BUILD / "cargo",
                *(["--release"] if profile == "release" else [])]))
            rlib = BUILD / "cargo" / profile / "libcorsairs.rlib"
            driver = BUILD / ("driver-" + profile)
            commands.append(command(["rustc", "--edition=2024", "-Dwarnings", "-C", "opt-level=" + ("3" if profile == "release" else "0"),
                ROOT / "experiments/rust/large_tensors.rs", "--extern", f"corsairs={rlib}",
                "-L", f"dependency={rlib.parent / 'deps'}", "-o", driver]))
            binaries.update({str(p.relative_to(ROOT)): sha(p) for p in [rlib, driver]})
        if sources() != source_hashes: raise RuntimeError("Sources changed during the build")
        manifest = {"source_hashes": source_hashes, "binaries": binaries, "commands": commands,
            "rustc": command(["rustc", "-Vv"])["stdout"], "swiftc": command(["swiftc", "--version"])["stdout"],
            "os": command(["sw_vers"])["stdout"], "native_executed": False}
        save(manifest_path, manifest)
        save(ROOT / "docs/evidence/v0.3-large-tensors/build-manifest.json", manifest)
    else:
        manifest = json.loads(manifest_path.read_text())
        if manifest["source_hashes"] != source_hashes or any(sha(ROOT / p) != h for p, h in manifest["binaries"].items()):
            raise RuntimeError("Sources or binaries changed; rebuild first")
    if not args.native:
        print(json.dumps({"prepared": True, "native_executed": False, "build_manifest": str(manifest_path)}))
        return
    case = next(c for c in fixture["cases"] if c["name"] == args.case)
    output = (args.output or Path(f"/private/tmp/corsairs-large-{args.case}-{args.compute}-{args.profile}")).resolve()
    if output == ROOT or ROOT in output.parents: raise RuntimeError("Native outputs must be outside source tree")
    output.mkdir(parents=True, exist_ok=True)
    report = {"passed": False, "case": case, "compute": args.compute, "profile": args.profile,
        "created_utc": datetime.now(timezone.utc).isoformat(), "build_manifest_sha256": sha(manifest_path),
        "concurrent_native_processes": 1,
        "concurrency_scope": "This checker's child processes only; other host workloads are uncontrolled unless separately recorded.",
        "swift_readback": "Immediate full byte snapshot before block comparison/hash",
        "scope": fixture["scope"]}
    save(output / "checks.json", report)
    try:
        shape = ",".join(map(str, case["shape"]))
        asset = FIXTURES / case["asset"]
        print(f"Swift {args.case} {args.compute}: {case['bytes']} bytes", flush=True)
        oracle_path = output / "swift.json"
        oracle_process = native([BUILD / "swift-oracle", asset, case["dtype"], shape, args.compute, args.case, oracle_path], "swift", output, 120)
        report["swift_process"] = oracle_process
        require_success(oracle_process, "swift")
        oracle = json.loads(oracle_path.read_text())
        report["swift"] = oracle
        if not oracle["passed"] or oracle["bytes"] != case["bytes"] or oracle["shape"] != case["shape"]:
            raise RuntimeError("Independent Swift oracle did not establish capacity")
        print(f"Rust {args.case} {args.compute} {args.profile}: owned/native/Metal", flush=True)
        rust = native([BUILD / ("driver-" + args.profile), asset, case["dtype"], shape, args.compute], "rust", output, 160)
        report["rust_process"] = rust
        require_success(rust, "rust")
        events = [json.loads(line) for line in rust["stdout"].splitlines() if line.startswith("{")]
        values = [e for e in events if e.get("event") == "value"]
        if len(values) != 7 or not events[-1].get("passed") or events[-1].get("event") != "complete":
            raise RuntimeError("Native Rust path coverage incomplete")
        hashes = {1: oracle["input_sha256"], 2: oracle["double_sha256"], 4: oracle["chain_sha256"]}
        for value in values:
            if not value["passed"] or value["bytes"] != case["bytes"] or value["sha256"] != hashes[value["factor"]]:
                raise RuntimeError(f"Rust differs from independent Swift: {value['label']}")
        report.update(passed=True, swift=oracle, swift_process=oracle_process, rust_process=rust,
            values=values, native_validated=True,
            child_max_rss_bytes=resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,
            rss_scope="Darwin cumulative completed-child maximum for this fresh checker, including both independent Swift and Rust processes. Not a per-Rust peak, Metal allocation counter or repeated-residency guarantee.")
    except Exception as error:
        report["error"] = str(error)
    save(output / "checks.json", report)
    destination = ROOT / f"docs/evidence/v0.3-large-tensors/immediate-snapshot/{args.case}-{args.compute}-{args.profile}.json"
    save(destination, report)
    print(json.dumps({"passed": report["passed"], "report": str(destination)}), flush=True)
    if not report["passed"]: raise SystemExit(1)

if __name__ == "__main__": main()
