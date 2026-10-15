#!/usr/bin/env python3
"""Bounded diagnostic runs; results are excluded from inference timing tables."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "docs/evidence/v0.3-benchmarks/overhead-audit"
TEMP = Path("/private/tmp/corsairs-v03-overhead-profile")


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    TEMP.mkdir(exist_ok=False)
    manifest = json.loads((DEST / "manifest.json").read_text())
    probe = manifest["lookup_probe"]
    for entry in [probe["source"], probe["binary"]]:
        assert sha(ROOT / entry["path"]) == entry["sha256"]
    report = {"purpose": "Diagnostic only; not an uninstrumented latency comparison",
              "controller_sha256": sha(__file__), "lookups": []}
    for n in range(3):
        command = [str(ROOT / probe["binary"]["path"]), "10000"]
        started = time.monotonic()
        p = subprocess.run(command, capture_output=True, text=True, timeout=40, check=True)
        report["lookups"].append(dict(command=command, seconds=time.monotonic()-started,
                                     result=json.loads(p.stdout), stderr=p.stderr))
        print(f"Lookup probe {n+1}/3 complete", flush=True)
    command = [sys.executable, "-B", "scripts/reference/benchmark_v03.py", "--rust-argv",
               "--case", "docs/evidence/v0.3-benchmarks/cases/feedforward-cpu.json",
               "--output-dir", str(TEMP), "--phases", "owned_run", "--samples", "6000", "--warmup", "30"]
    argv = json.loads(subprocess.check_output(command, cwd=ROOT, text=True))
    with (TEMP / "rust.stdout").open("w") as out, (TEMP / "rust.stderr").open("w") as err:
        p = subprocess.Popen(argv, cwd=ROOT, stdout=out, stderr=err)
        try:
            time.sleep(0.5)
            sample_command = ["/usr/bin/sample", str(p.pid), "3", "1", "-file", str(TEMP / "sample.txt")]
            sample = subprocess.run(sample_command, capture_output=True, text=True, timeout=12)
            status = p.wait(timeout=20)
        finally:
            if p.poll() is None:
                p.kill()
                p.wait()
    report["profile"] = dict(command=argv, binary_sha256=sha(argv[0]), exit_status=status,
        sample_command=sample_command, sample_exit_status=sample.returncode,
        sample_stdout=sample.stdout, sample_stderr=sample.stderr,
        stderr=(TEMP / "rust.stderr").read_text(),
        validation=json.loads((TEMP / "feedforward-rust.json").read_text()))
    report["passed"] = status == 0 and sample.returncode == 0 and report["profile"]["validation"]["passed"]
    (DEST / "measurements.json").write_text(json.dumps(report, indent=2)+"\n")
    (DEST / "sample.txt").write_bytes((TEMP / "sample.txt").read_bytes())
    print(json.dumps({"passed": report["passed"], "report": str(DEST / "measurements.json")}), flush=True)
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
