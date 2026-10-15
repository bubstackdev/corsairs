#!/usr/bin/env python3
"""Run fresh, bounded Swift allocation probes serially on an owned Metal queue."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "docs/evidence/v0.3-release-preparation/rgb345-isolation"
TEMP = Path("/private/tmp/corsairs-v03-rgb345-isolation")


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    TEMP.mkdir(exist_ok=False)
    source = ROOT / "experiments/swift/LargeOutputIsolation.swift"
    binary = ROOT / "target/rgb345-isolation/probe"
    asset = ROOT / "fixtures/parity-v03/large-tensors/h3-rgb345/model.aimodel"
    report = dict(started_utc=datetime.now(timezone.utc).isoformat(),
        source_sha256=sha(source), binary_sha256=sha(binary), controller_sha256=sha(__file__),
        model_sha256={str(p.relative_to(asset)): sha(p) for p in asset.rglob("*") if p.is_file()},
        scope="Independent Swift x+x diagnostics; failed modes are not qualification", modes={})
    DEST.mkdir(parents=True, exist_ok=True)
    for mode in ["auto", "bound", "bound-chain"]:
        command = [str(binary), str(asset), "345,1344,768,3", mode, str(TEMP / f"{mode}.json")]
        with (TEMP / f"{mode}.stdout").open("w") as out, (TEMP / f"{mode}.stderr").open("w") as err:
            process = subprocess.Popen(command, cwd=ROOT, stdout=out, stderr=err)
            timed_out = False
            try:
                status = process.wait(timeout=70)
            except subprocess.TimeoutExpired:
                process.kill()
                status = process.wait()
                timed_out = True
        result = dict(command=command, exit_status=status, timed_out=timed_out,
            stdout=(TEMP / f"{mode}.stdout").read_text(), stderr=(TEMP / f"{mode}.stderr").read_text())
        path = TEMP / f"{mode}.json"
        if path.exists():
            result["report"] = json.loads(path.read_text())
        report["modes"][mode] = result
        (DEST / "checks.json").write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(dict(mode=mode, exit_status=status, timed_out=timed_out,
            passed=result.get("report", {}).get("passed", False))), flush=True)
    assert sha(source) == report["source_sha256"] and sha(binary) == report["binary_sha256"]
    # Completing all diagnostics is not the same as every mode qualifying.
    print(json.dumps(dict(diagnostics_complete=True, report=str(DEST / "checks.json"))), flush=True)


if __name__ == "__main__":
    main()
