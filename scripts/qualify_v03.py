#!/usr/bin/env python3
"""Freeze final release probes or run one bounded serial native gate.

No registry access. Native execution is opt-in and requires the permitted runner.
Historical checkers retain their original behavior; receipts are copied here.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / "target/qualify-v03"
EVIDENCE = ROOT / "docs/evidence/v0.3-final"

def sha(path):
    h = hashlib.sha256()
    with Path(path).open("rb") as f:
        for block in iter(lambda: f.read(8 << 20), b""): h.update(block)
    return h.hexdigest()

def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n")

def pins():
    paths = [ROOT / "Cargo.toml", ROOT / "Cargo.lock", Path(__file__)]
    paths += list((ROOT / "crates").rglob("*.rs")) + list((ROOT / "crates").rglob("Cargo.toml"))
    return {str(p.relative_to(ROOT)): sha(p) for p in sorted(paths)}

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--prepare", action="store_true")
    p.add_argument("--native", choices=["core", "lifecycle", "bf16-debug", "bf16-release", "stress-debug", "stress-release", "raw-storage", "h3"])
    a = p.parse_args()
    if a.prepare == bool(a.native): p.error("Choose prepare or one native gate")
    BUILD.mkdir(parents=True, exist_ok=True)
    report = {"passed": False, "started_utc": datetime.now(timezone.utc).isoformat(), "commands": []}
    destination = EVIDENCE / ((a.native or "preparation") + ".json")

    def run(command, timeout=250, env=None):
        command = list(map(str, command))
        child = subprocess.Popen(command, cwd=ROOT, env={**os.environ, **(env or {})},
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, start_new_session=True)
        try:
            out, err = child.communicate(timeout=timeout)
            expired = False
        except subprocess.TimeoutExpired:
            os.killpg(child.pid, signal.SIGKILL)
            out, err = child.communicate()
            expired = True
        row = {"command": command, "status": child.returncode, "timed_out": expired, "stdout": out, "stderr": err}
        report["commands"].append(row); save(destination, report)
        if child.returncode or expired: raise RuntimeError(f"Gate command failed: {command}: {err[-2000:]}")
        return out

    try:
        freeze = BUILD / "manifest.json"
        if a.prepare:
            before = pins()
            run(["cargo", "fmt", "--all", "--check"])
            run(["cargo", "clippy", "--offline", "-p", "corsairs", "--all-targets", "--no-default-features", "--", "-D", "warnings"])
            run(["cargo", "clippy", "--offline", "--workspace", "--all-targets", "--all-features", "--", "-D", "warnings"])
            run(["cargo", "test", "--offline", "-p", "corsairs", "--lib", "--no-default-features"])
            run(["cargo", "test", "--offline", "--workspace", "--all-features", "--doc"])
            run(["cargo", "doc", "--offline", "--workspace", "--all-features", "--no-deps"], env={"RUSTDOCFLAGS": "-Dwarnings"})
            output = run(["cargo", "test", "--offline", "--workspace", "--all-features", "--no-run", "--message-format=json"])
            tests = [json.loads(line) for line in output.splitlines() if line.startswith("{")]
            binaries = [v["executable"] for v in tests if v.get("reason") == "compiler-artifact" and v.get("executable")]
            run([sys.executable, "-B", "scripts/check_v01.py"])
            run([sys.executable, "-B", "scripts/check_v02.py"])
            run([sys.executable, "-B", "scripts/check_bfloat16_native.py", "build", "--evidence-dir", EVIDENCE / "bf16"])
            run([sys.executable, "-B", "scripts/check_large_tensors.py", "--build", "--evidence-subdir", "release"])
            rlib = ROOT / "target/large-check/cargo/release/libcorsairs.rlib"
            for source, name in [("experiments/rust/benchmark_v03.rs", "benchmark"), ("docs/evidence/v0.3-large-tensors/raw-storage/driver.rs", "raw-storage")]:
                run(["rustc", "--edition=2024", "-Dwarnings", "-C", "opt-level=3", source, "--extern", f"corsairs={rlib}", "-L", f"dependency={rlib.parent / 'deps'}", "-o", BUILD / name])
            binaries += [str(BUILD / "benchmark"), str(BUILD / "raw-storage")]
            if pins() != before: raise RuntimeError("Sources changed while preparing")
            manifest = {"sources": before, "binaries": {s: sha(s) for s in binaries}}
            save(freeze, manifest); save(EVIDENCE / "manifest.json", manifest)
        else:
            manifest = json.loads(freeze.read_text())
            if pins() != manifest["sources"] or any(sha(path) != digest for path, digest in manifest["binaries"].items()):
                raise RuntimeError("Final source/binary freeze changed")
            report["manifest_sha256"] = sha(freeze)
            if a.native == "core":
                run([sys.executable, "-B", "scripts/check_v02.py", "--native", "--no-build"])
                save(EVIDENCE / "core-checks.json", json.loads((ROOT / "target/v02-check/checks.json").read_text()))
                save(EVIDENCE / "core-build.json", json.loads((ROOT / "target/v02-check/build-manifest.json").read_text()))
            elif a.native == "lifecycle":
                for binary in manifest["binaries"]:
                    if "/deps/" in binary:
                        run([binary, "--include-ignored", "--test-threads=1"], env={"CORSAIRS_TEST_MODEL": str(ROOT / "fixtures/parity-v01/double_float32/model.aimodel")})
            elif a.native.startswith("bf16-"):
                profile = a.native.removeprefix("bf16-")
                run([ROOT / f"target/bfloat16-native/bfloat16-{profile}", ROOT / "fixtures/parity-v02/bfloat16", BUILD / f"bf16-{profile}"])
            elif a.native.startswith("stress-"):
                profile = a.native.removeprefix("stress-")
                run([sys.executable, "-B", "scripts/check_v01.py", "--native", "--no-build", "--profiles", profile, "--cycles", "10000", "--loads", "100", "--dropped", "100"])
                save(EVIDENCE / f"{a.native}-checks.json", json.loads((ROOT / "target/v01-check/checks.json").read_text()))
            elif a.native == "raw-storage": run([BUILD / "raw-storage"])
            elif a.native == "h3":
                command = json.loads(run([sys.executable, "-B", "scripts/reference/benchmark_v03.py", "--case", "docs/evidence/v0.3-benchmarks/cases/h3-functional-19333.json", "--rust-driver", BUILD / "benchmark", "--warmup", "1", "--samples", "3", "--phases", "native_run_download,metal_encode_download", "--output-dir", BUILD / "h3", "--rust-argv"]))
                run(command)
                values = json.loads((BUILD / "h3/h3-functional-19333-rust.json").read_text())
                if not values["passed"] or not all(v["every_iteration_exact"] for v in values["phases"]): raise RuntimeError("H3 exactness incomplete")
                report["h3"] = values
        report["passed"] = True
    except Exception as error:
        report["error"] = str(error)
    save(destination, report)
    print(json.dumps({"passed": report["passed"], "report": str(destination)}), flush=True)
    return 0 if report["passed"] else 1

if __name__ == "__main__": raise SystemExit(main())
