#!/usr/bin/env python3
"""Fresh-process NDArray input diagnostics using the actual owned stream."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "docs/evidence/v0.3-release-preparation/rgb345-isolation"
TEMP = Path("/private/tmp/corsairs-v03-rgb345-migration")


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    TEMP.mkdir(exist_ok=False)
    manifest = json.loads((DEST / "migration-build-manifest.json").read_text())
    for entry in [manifest["source"], manifest["binary"]]:
        assert sha(ROOT / entry["path"]) == entry["sha256"]
    binary = ROOT / manifest["binary"]["path"]
    asset = ROOT / "fixtures/parity-v03/large-tensors/h3-rgb345/model.aimodel"
    report = dict(started_utc=datetime.now(timezone.utc).isoformat(),
        build_manifest_sha256=sha(DEST / "migration-build-manifest.json"),
        controller_sha256=sha(__file__), modes={})
    for mode in ["ndarray-auto", "ndarray-chain"]:
        command = [str(binary), str(asset), "345,1344,768,3", mode, str(TEMP / f"{mode}.json")]
        with (TEMP / f"{mode}.stdout").open("w") as out, (TEMP / f"{mode}.stderr").open("w") as err:
            process = subprocess.Popen(command, cwd=ROOT, stdout=out, stderr=err)
            timed_out = False
            try:
                status = process.wait(timeout=90)
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
        (DEST / "migration-checks.json").write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(dict(mode=mode, exit_status=status, timed_out=timed_out,
            passed=result.get("report", {}).get("passed", False))), flush=True)
    print(json.dumps(dict(diagnostics_complete=True, report=str(DEST / "migration-checks.json"))), flush=True)


if __name__ == "__main__":
    main()
