#!/usr/bin/env python3
"""Record Swift/Rust call lowering without executing the declared functions."""

import json
import os
from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "target/experiments/calibration"


def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    commands = [
        (["rustc", "--crate-type=lib", "--emit=llvm-ir", "-O", "experiments/rust/call_lowering.rs", "-o", str(OUTPUT / "rust.ll")], {"RUSTC_BOOTSTRAP": "1"}),
        (["xcrun", "swiftc", "-O", "-parse-as-library", "-module-cache-path", str(OUTPUT / "swift-cache"), "-emit-ir", "experiments/swift/ConventionReference.swift", "-o", str(OUTPUT / "swift.ll")], {}),
    ]
    records = []
    for command, extra in commands:
        result = subprocess.run(command, cwd=ROOT, env={**os.environ, **extra}, text=True, capture_output=True, timeout=120)
        records.append({"command": command, "environment_overrides": extra, "exit_code": result.returncode, "stdout": result.stdout, "stderr": result.stderr})
        if result.returncode:
            (OUTPUT / "results.json").write_text(json.dumps({"status": "failed", "commands": records}, indent=2) + "\n")
            raise SystemExit(result.stderr)
    rust = [line for line in (OUTPUT / "rust.ll").read_text().splitlines() if line.startswith("declare swiftcc")]
    swift = [line for line in (OUTPUT / "swift.ll").read_text().splitlines() if line.startswith("define ") and any(s in line for s in ["aggregate3", "compute", "throwing", "asyncExample"])]
    mismatch = any("@aggregate3(ptr" in line and "sret(" in line for line in rust) and any("{ i64, i64, i64 }" in line and "aggregate3" in line for line in swift)
    (OUTPUT / "results.json").write_text(json.dumps({"status": "observed", "commands": records, "rust_declarations": rust, "swift_definitions": swift, "aggregate_mismatch_reproduced": mismatch}, indent=2) + "\n")
    if not mismatch:
        raise SystemExit("ABI classification changed; inspect calibration/results.json before relying on prior conclusions")
    print("PASS: Known aggregate mismatch reproduced; no diagnostic function executed.")


if __name__ == "__main__":
    main()
