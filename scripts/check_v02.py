#!/usr/bin/env python3
"""Pin and run dynamic-shape, native-storage parity, and handle-lifetime gates."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import sys
import time

import check_v01

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "target" / "v02-check"
DRIVERS = ("dynamic_shapes", "native_handles", "native_parity", "metal_parity")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def sources():
    paths = {ROOT / "Cargo.toml", ROOT / "Cargo.lock", Path(__file__).resolve(),
             ROOT / "scripts/check_v01.py", check_v01.OUTPUT / "cases.rs"}
    paths.update((ROOT / "crates").rglob("*.rs"))
    paths.update((ROOT / "crates").rglob("Cargo.toml"))
    paths.update(ROOT / "experiments/rust" / (name + ".rs") for name in DRIVERS)
    paths.update(path for path in (ROOT / "fixtures/parity-v02").rglob("*") if path.is_file())
    return {str(path.relative_to(ROOT)): sha(path) for path in sorted(paths)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", action="store_true")
    parser.add_argument("--no-build", action="store_true")
    parser.add_argument("--profiles", nargs="+", choices=["debug", "release"], default=["debug", "release"])
    args = parser.parse_args()
    OUTPUT.mkdir(parents=True, exist_ok=True)
    report = {"started_at": datetime.now(timezone.utc).isoformat(), "platform": platform.platform(),
              "native_requested": args.native, "native_validated": False, "passed": False,
              "public_api_only": True, "drivers_forbid_unsafe": True, "commands": []}

    def save():
        (OUTPUT / "checks.json").write_text(json.dumps(report, indent=2) + "\n")

    def execute(command, *, env=None, native=False):
        started = time.monotonic()
        run = subprocess.run(list(map(str, command)), cwd=ROOT, env={**os.environ, **(env or {})},
                             capture_output=True, text=True, timeout=300)
        row = {"command": list(map(str, command)), "returncode": run.returncode,
               "elapsed_seconds": time.monotonic() - started, "stdout": run.stdout, "stderr": run.stderr}
        report["commands"].append(row)
        save()
        if run.returncode:
            raise RuntimeError(f"Command failed: {command}\n{run.stdout[-6000:]}\n{run.stderr[-3000:]}")
        if native:
            events = [json.loads(line) for line in run.stdout.splitlines() if line.startswith("{")]
            row["events"] = events
            if not events or events[-1].get("event") != "complete" or not events[-1].get("passed"):
                raise RuntimeError("Native driver did not complete")
            if "native_parity" in str(command[0]) and sum(e.get("event") == "native_parity" and e.get("passed") for e in events) != report["fixtures"]["cases"]:
                raise RuntimeError("Native parity grid incomplete")
            if "metal_parity" in str(command[0]) and sum(e.get("event") == "metal_parity" and e.get("passed") for e in events) != 2 * report["fixtures"]["cases"]:
                raise RuntimeError("Metal parity grid incomplete")
            save()

    try:
        report["fixtures"] = check_v01.prepare_data()
        source_hashes = sources()
        report["source_hashes"] = source_hashes
        report["source_identity_sha256"] = hashlib.sha256(json.dumps(source_hashes, sort_keys=True).encode()).hexdigest()
        rustc, cargo = check_v01.tool("rustc"), check_v01.tool("cargo")
        report["compiler"] = subprocess.check_output([rustc, "--version"], text=True).strip()
        manifest_path = OUTPUT / "build-manifest.json"
        if args.no_build:
            manifest = json.loads(manifest_path.read_text())
            if manifest["source_hashes"] != source_hashes or manifest["compiler"] != report["compiler"] or manifest["fixtures"] != report["fixtures"]:
                raise RuntimeError("Sources, compiler, or fixtures changed; rebuild first")
        else:
            manifest = {key: report[key] for key in ("source_hashes", "source_identity_sha256", "compiler", "fixtures")}
            manifest["binaries"] = {}
        for profile in args.profiles:
            binaries = [OUTPUT / (name + "-" + profile) for name in DRIVERS]
            rlib = ROOT / "target" / profile / "libcorsairs.rlib"
            if args.no_build:
                expected = manifest["binaries"][profile]
                if expected != {str(p.relative_to(ROOT)): sha(p) for p in [*binaries, rlib]}:
                    raise RuntimeError(f"{profile} binaries changed; rebuild first")
            else:
                execute([cargo, "build", "--offline", "-p", "corsairs", "--lib", *(["--release"] if profile == "release" else [])])
                for name, binary in zip(DRIVERS, binaries):
                    execute([rustc, "--edition=2024", "-Dwarnings", "-C", "opt-level=" + ("3" if profile == "release" else "0"),
                             ROOT / "experiments/rust" / (name + ".rs"), "--extern", f"corsairs={rlib}",
                             "-L", "dependency=" + str(ROOT / "target" / profile / "deps"), "-o", binary],
                            env={"CORSAIRS_V01_CASES": str(check_v01.OUTPUT / "cases.rs")})
                manifest["binaries"][profile] = {str(p.relative_to(ROOT)): sha(p) for p in [*binaries, rlib]}
            if sources() != source_hashes:
                raise RuntimeError("Sources changed during validation; rebuild first")
            if args.native:
                fixture = ROOT / "fixtures/parity-v01"
                execute([binaries[0], ROOT / "fixtures/parity-v02/dynamic-double"], native=True)
                execute([binaries[1], fixture / "double_float32/model.aimodel", fixture / "accumulator/model.aimodel"], native=True)
                execute([binaries[2], fixture], native=True)
                execute([binaries[3], fixture], native=True)
        if not args.no_build:
            manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
        report["build_manifest_sha256"] = sha(manifest_path)
        report.update(passed=True, native_validated=args.native)
        save()
        print(json.dumps({"passed": True, "native_validated": args.native, "report": str(OUTPUT / "checks.json")}))
        return 0
    except Exception as error:
        report["error"] = str(error)
        save()
        print(error, file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
