#!/usr/bin/env python3
"""Compare the frozen pre-cache driver with the source-pinned cached driver."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import signal
import statistics
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "docs/evidence/v0.3-symbol-cache"
BUILD = ROOT / "target/symbol-cache"
BASE = ROOT / "docs/evidence/v0.3-benchmarks/build/manifest.json"
HELPER = ROOT / "scripts/reference/benchmark_v03.py"


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n")


def sources():
    paths = [ROOT / "Cargo.toml", ROOT / "Cargo.lock", ROOT / "experiments/rust/benchmark_v03.rs", HELPER]
    paths += list((ROOT / "crates").rglob("*.rs")) + list((ROOT / "crates").rglob("Cargo.toml"))
    return {str(p.relative_to(ROOT)): sha(p) for p in sorted(set(paths))}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", action="store_true")
    parser.add_argument("--native", action="store_true")
    args = parser.parse_args()
    BUILD.mkdir(parents=True, exist_ok=True)
    baseline = json.loads(BASE.read_text())
    before = ROOT / baseline["binary"]["path"]
    assert sha(before) == baseline["binary"]["sha256"], "Pre-cache executable changed"
    for path, entry in baseline["files"].items():
        assert sha(ROOT / path) == entry["sha256"], f"Benchmark helper changed: {path}"
    frozen = json.loads((BASE.parent / baseline["library"]["build_manifest"]).read_text())
    changed = [path for path, digest in frozen["source_hashes"].items() if sha(ROOT / path) != digest]
    assert changed == ["crates/corsairs-abi/src/native/loader.rs"], changed
    current = sources()
    after = BUILD / "driver"
    rlib = BUILD / "cargo/release/libcorsairs.rlib"
    manifest_path = BUILD / "build-manifest.json"
    if args.build:
        commands = [
            ["cargo", "build", "--offline", "-p", "corsairs", "--release", "--lib", "--target-dir", str(BUILD / "cargo")],
            ["rustc", "--edition=2024", "-Dwarnings", "-O", "experiments/rust/benchmark_v03.rs", "--extern", f"corsairs={rlib}",
             "-L", f"dependency={rlib.parent / 'deps'}", "-o", str(after)],
        ]
        for command in commands:
            subprocess.run(command, cwd=ROOT, check=True, timeout=120)
        assert sources() == current
        manifest = dict(source_hashes=current, source_changes_from_baseline=changed, commands=commands,
            baseline_manifest_sha256=sha(BASE), before=dict(path=str(before), sha256=sha(before)),
            after=dict(path=str(after), sha256=sha(after)), library_sha256=sha(rlib),
            compiler=subprocess.check_output(["rustc", "-Vv"], text=True))
        save(manifest_path, manifest)
        save(DEST / "build-manifest.json", manifest)
        (DEST / "loader.rs").write_bytes((ROOT / changed[0]).read_bytes())
    else:
        manifest = json.loads(manifest_path.read_text())
        assert manifest["source_hashes"] == current
        assert sha(after) == manifest["after"]["sha256"] and sha(rlib) == manifest["library_sha256"]
    if not args.native:
        print(json.dumps(dict(prepared=True, native_executed=False)))
        return 0
    temporary = Path("/private/tmp/corsairs-v03-symbol-cache-pairs")
    temporary.mkdir(exist_ok=False)
    report = dict(passed=False, started_utc=datetime.now(timezone.utc).isoformat(),
        build_manifest_sha256=sha(manifest_path), controller_sha256=sha(__file__),
        protocol="Same phase driver and data; only loader.rs library source changes. Three alternating fresh-process pairs per device;10 warmups/100 samples per phase. Every output checked after every iteration. No concurrent GPU runs or cache purge.", pairs=[])
    try:
        for backend in ["cpu", "gpu-preferred"]:
            case = ROOT / f"docs/evidence/v0.3-benchmarks/cases/feedforward-{backend}.json"
            for pair in range(1, 4):
                row = dict(backend=backend, pair=pair, order=["before", "after"] if pair % 2 else ["after", "before"], arms={})
                report["pairs"].append(row)
                for arm in row["order"]:
                    output = temporary / f"{backend}-{pair}-{arm}.json"
                    command = json.loads(subprocess.check_output([sys.executable, "-B", str(HELPER), "--rust-argv",
                        "--case", str(case), "--rust-driver", str(before if arm == "before" else after), "--output", str(output)], cwd=ROOT, text=True))
                    p = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, start_new_session=True)
                    try:
                        out, err = p.communicate(timeout=20)
                    except subprocess.TimeoutExpired:
                        os.killpg(p.pid, signal.SIGKILL)
                        p.communicate()
                        raise RuntimeError(f"Timed out: {backend} {pair} {arm}")
                    row["arms"][arm] = dict(command=command, exit_status=p.returncode, stdout=out, stderr=err)
                    assert p.returncode == 0, err
                    value = json.loads(output.read_text())
                    assert value["passed"] and all(x["every_iteration_exact"] for x in value["phases"])
                    row["arms"][arm]["measurements"] = value
                    save(DEST / "checks.json", report)
                print(f"{backend} pair {pair}: exact before and after", flush=True)
        assert sources() == current
        report["summary"] = {}
        for backend in ["cpu", "gpu-preferred"]:
            group = {}
            for phase in report["pairs"][0]["arms"]["before"]["measurements"]["phases"]:
                name = phase["phase"]
                group[name] = {arm: statistics.median(
                    next(p["median_ns"] for p in row["arms"][arm]["measurements"]["phases"] if p["phase"] == name)
                    for row in report["pairs"] if row["backend"] == backend) for arm in ["before", "after"]}
            report["summary"][backend] = group
        report["passed"] = True
    except Exception as error:
        report["error"] = str(error)
    save(DEST / "checks.json", report)
    print(json.dumps(dict(passed=report["passed"], report=str(DEST / "checks.json"))), flush=True)
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
