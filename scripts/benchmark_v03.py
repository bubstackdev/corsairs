#!/usr/bin/env python3
"""Run one alternating Rust/Python pair with bounded, isolated children."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "scripts/reference/benchmark_v03.py"
EVIDENCE = ROOT / "docs/evidence/v0.3-benchmarks"

def sha(path):
    h = hashlib.sha256()
    with Path(path).open("rb") as f:
        for chunk in iter(lambda: f.read(8 << 20), b""):
            h.update(chunk)
    return h.hexdigest()

def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n")

def host_state():
    result = {"utc": datetime.now(timezone.utc).isoformat()}
    for name, command in [("thermal", ["/usr/bin/pmset", "-g", "therm"]),
                          ("virtual_memory", ["/usr/bin/vm_stat"])]:
        p = subprocess.run(command, capture_output=True, text=True, timeout=5)
        result[name] = dict(status=p.returncode, stdout=p.stdout, stderr=p.stderr)
    return result

def child(command, name, output, deadline):
    started = time.monotonic()
    with (output / f"{name}.stdout").open("w") as out, (output / f"{name}.stderr").open("w") as err:
        p = subprocess.Popen(command, cwd=ROOT, stdout=out, stderr=err, start_new_session=True)
        try:
            status = p.wait(timeout=deadline)
            timed_out = False
        except subprocess.TimeoutExpired:
            os.killpg(p.pid, signal.SIGKILL)
            status = p.wait()
            timed_out = True
    return dict(command=command, pid=p.pid, exit_status=status, timed_out=timed_out,
        seconds=time.monotonic() - started, stdout=(output / f"{name}.stdout").read_text(),
        stderr=(output / f"{name}.stderr").read_text())

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--case", type=Path, required=True)
    parser.add_argument("--pair", type=int, default=1)
    parser.add_argument("--deadline", type=int, default=120)
    parser.add_argument("--phases")
    parser.add_argument("--cooldown", type=int, default=0)
    parser.add_argument("--languages", choices=["both", "rust", "python"], default="both")
    parser.add_argument("--warmup", type=int)
    parser.add_argument("--samples", type=int)
    args = parser.parse_args()
    if args.pair < 1 or not 1 <= args.deadline <= 130:
        parser.error("Positive pair and 1..130 second per-arm deadline required")
    if not 0 <= args.cooldown <= 30:
        parser.error("Cooldown must be 0..30 seconds")
    case_path = args.case.resolve()
    case = json.loads(case_path.read_text())
    key = case_path.stem
    output = Path(f"/private/tmp/corsairs-v03-benchmarks/{key}/pair-{args.pair:02}")
    if output.exists():
        raise RuntimeError(f"Use a fresh pair number; output already exists: {output}")
    output.mkdir(parents=True)
    build_path = EVIDENCE / "build/manifest.json"
    build = json.loads(build_path.read_text())
    for entry in [build["binary"], build["library"]]:
        if sha(ROOT / entry["path"]) != entry["sha256"]:
            raise RuntimeError(f"Benchmark binary changed: {entry['path']}")
    for path, entry in build["files"].items():
        if sha(ROOT / path) != entry["sha256"]:
            raise RuntimeError(f"Benchmark source changed: {path}")
    # Full driver/library identity plus every original library source pin.
    frozen = json.loads((ROOT / "target/large-check/build-manifest.json").read_text())
    for path, digest in frozen["source_hashes"].items():
        if sha(ROOT / path) != digest:
            raise RuntimeError(f"Frozen source changed: {path}")
    spec = [sys.executable, "-B", str(REFERENCE), "--case", str(case_path), "--output-dir", str(output)]
    if args.phases:
        spec += ["--phases", args.phases]
    for name in ["warmup", "samples"]:
        if getattr(args, name) is not None:
            spec += [f"--{name}", str(getattr(args, name))]
    rust = json.loads(subprocess.check_output([*spec, "--rust-argv"], cwd=ROOT, text=True))
    python = [sys.executable, "-I", *spec[1:]]
    report = dict(passed=False, case=case, case_file_sha256=sha(case_path), pair=args.pair,
        order=["rust", "python"] if args.pair % 2 else ["python", "rust"],
        started_utc=datetime.now(timezone.utc).isoformat(), output=str(output),
        build_manifest_sha256=sha(build_path), controller_sha256=sha(__file__),
        binaries={str(ROOT / "target/benchmark-v03"): sha(ROOT / "target/benchmark-v03"),
            str(ROOT / "target/large-check/cargo/release/libcorsairs.rlib"): sha(ROOT / "target/large-check/cargo/release/libcorsairs.rlib")},
        cooldown_seconds=args.cooldown,
        quiet_window="User reserved GPU after completing/stopping Aether work. No benchmark GPU concurrency or cache purge. Recorded cooldown is experimental spacing, not fixed clocks or controlled ambient temperature.",
        processes={})
    if args.languages != "both":
        report["order"] = [args.languages]
    destination = EVIDENCE / f"runs/{key}/pair-{args.pair:02}.json"
    try:
        for language in report["order"]:
            save(output / "progress.json", dict(case=key, pair=args.pair, language=language))
            print(f"{key} pair {args.pair}: {language}", flush=True)
            if args.cooldown:
                time.sleep(args.cooldown)
            before = host_state()
            observation = child(rust if language == "rust" else python, language, output, args.deadline)
            observation["host_before"] = before
            observation["host_after"] = host_state()
            report["processes"][language] = observation
            if observation["exit_status"] or observation["timed_out"]:
                raise RuntimeError(f"{language} failed: {observation['stderr'][-2000:]}")
            value = json.loads((output / f"{case['name']}-{language}.json").read_text())
            if not value["passed"] or not all(p["every_iteration_exact"] for p in value["phases"]):
                raise RuntimeError(f"{language} validation incomplete")
            report[language] = value
        if args.languages == "both":
            if report["rust"]["model_main_mlirb_sha256"] != report["python"]["model_main_mlirb_sha256"]:
                raise RuntimeError("Different model source bytes")
            for group, rust_group in [("inputs", "inputs"), ("outputs", "expected_outputs")]:
                identities = lambda specs: {s["name"]: (s["dtype"], s["shape"], s["sha256"]) for s in specs}
                if identities(report["rust"][rust_group]) != identities(report["python"]["case"][group]):
                    raise RuntimeError(f"Different {group} bytes or metadata")
        report["passed"] = True
    except Exception as e:
        report["error"] = str(e)
    save(destination, report)
    print(json.dumps(dict(passed=report["passed"], report=str(destination))), flush=True)
    return 0 if report["passed"] else 1

if __name__ == "__main__":
    raise SystemExit(main())
