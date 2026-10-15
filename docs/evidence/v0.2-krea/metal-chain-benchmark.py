#!/usr/bin/env python3
"""Prepare three alternating fresh-process owned/native Krea fixture pairs.

Native execution is opt-in and must be coordinated with the shared native
runner. This uses saved text, never runs the encoder, and never opens REA.
"""
import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import shutil
import signal
import statistics
import subprocess
import sys
import time

import check_krea as acceptance

ROOT = acceptance.ROOT
BUILD = acceptance.BUILD


def summarize(report):
    if not report.get("passed") or not report.get("native_validated"):
        raise RuntimeError("A benchmark arm failed its exact correctness gate")
    events = report["native_events"]
    segments = [row for row in events if row.get("event") == "segment"]
    steps = [row for row in events if row.get("event") == "step_complete"]
    payloads = [row for row in events if "file" in row]
    if len(segments) != 32 or len(steps) != 8 or len(payloads) != 13:
        raise RuntimeError("A benchmark arm did not complete the full saved-text fixture")
    if any(not row.get("passed") for row in payloads):
        raise RuntimeError("A benchmark arm has a mismatched output")
    for row in payloads:
        if acceptance.sha(row["file"]) != row["expected_sha256"]:
            raise RuntimeError("A benchmark payload changed after the acceptance check")

    def only(event):
        rows = [row for row in events if row.get("event") == event]
        if len(rows) != 1:
            raise RuntimeError(f"Expected one {event} timing")
        return rows[0]

    return {
        "generation_seconds": only("complete")["seconds"],
        "denoiser_prepare_seconds": only("denoisers_ready")["seconds"],
        "segment_calls_seconds": sum(row["seconds"] for row in segments),
        "steps_seconds": sum(row["seconds"] for row in steps),
        "decoder_call_seconds": only("decoder_call")["seconds"],
        "decode_phase_seconds": only("decode_complete")["seconds"],
        "native_child_seconds": report["commands"][-1]["elapsed_seconds"],
        "child_max_rss_bytes": report["process_memory"]["native_after_max_rss_bytes"],
        "process_memory": report["process_memory"],
        "segment_calls": segments,
        "steps": steps,
        "model_loads": [row for row in events if row.get("event") in ["loaded", "function_loaded", "batch_load"]],
        "batch_load_events": [row for row in events if row.get("event") == "batch_load_event"],
        "payload_hashes": {Path(row["file"]).name: row["sha256"] for row in payloads},
    }


def comparisons(runs):
    metrics = ["generation_seconds", "denoiser_prepare_seconds", "segment_calls_seconds", "steps_seconds",
               "decoder_call_seconds", "decode_phase_seconds", "native_child_seconds", "child_max_rss_bytes"]
    paired = []
    for pair in sorted({row["pair"] for row in runs}):
        members = {row["arm"]: row["measurements"] for row in runs if row["pair"] == pair}
        if len(members) != 2:
            continue
        paired.append({"pair": pair, "differences_owned_minus_native": {
            key: members["owned"][key] - members["native"][key] for key in metrics
        }, "generation_owned_over_native": members["owned"]["generation_seconds"] / members["native"]["generation_seconds"]})
    medians = {arm: {key: statistics.median(row["measurements"][key] for row in runs if row["arm"] == arm)
                     for key in metrics} for arm in ["owned", "native"] if any(row["arm"] == arm for row in runs)}
    return {"paired_observations": paired, "arm_medians": medians,
            "interpretation": "Descriptive measurements from three pairs on one host, with instrumented correctness checks and retained caches; no confidence interval, cold-start claim, or general speedup claim."}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", action="store_true", help="Run six sequential native children; coordinate with the parent first")
    parser.add_argument("--no-build", action="store_true")
    parser.add_argument("--pairs", type=int, default=3)
    parser.add_argument("--parallel-loads", action="store_true")
    parser.add_argument("--timeout", type=int, default=1200, help="Deadline for each native child, in seconds")
    parser.add_argument("--krea-root", type=Path, default=Path.home() / "Code/atelier/lab/krea-lab")
    parser.add_argument("--fixtures", type=Path)
    parser.add_argument("--output", type=Path, default=Path("/private/tmp/corsairs-krea-paired"))
    args = parser.parse_args()
    if args.pairs < 1 or args.timeout < 1:
        parser.error("--pairs and --timeout must be positive")
    output = args.output.resolve()
    if output == ROOT or ROOT in output.parents or output == args.krea_root.resolve() or args.krea_root.resolve() in output.parents:
        parser.error("Benchmark results must be outside Corsairs and the read-only Krea tree")
    if output.exists() and any(output.iterdir()):
        parser.error("Use an empty output directory to preserve earlier evidence")
    output.mkdir(parents=True, exist_ok=True)
    report_path = output / "benchmark.json"
    report = {"kind": "corsairs-krea-paired-owned-native", "created_at": datetime.now(timezone.utc).isoformat(),
        "native_requested": args.native, "native_validated": False, "passed": False, "pairs_requested": args.pairs,
        "load_policy": "parallel" if args.parallel_loads else "serial", "runs": [],
        "methodology": "Saved text/noise/rope, eight Euler steps and owned decoder, one generation per fresh native process. Pair order alternates owned/native then native/owned. Same pinned driver/library/source bytes for every arm. No encoder, warm-up render, cache purge or concurrent GPU job. Full model source hashes are streamed before every arm, outside native child timing; SDK/OS caches are retained.",
        "timing_scope": "Generation timing starts after denoiser preparation and includes hashes, disk writes, first-carry checkpoints, CPU Euler and decoder loading. Call/step/decode phase timings have explicit event boundaries. Whole child timing includes model preparation; whole checker timing also includes source verification and Swift schedule preparation.",
        "rss_scope": "Every arm runs a fresh Python checker, so its cumulative RUSAGE_CHILDREN peak is separate from other arms. Each peak still includes that checker's preparation helpers. Retain before/after counters; do not subtract high-water marks or add RSS to Metal accounting.",
        "launcher_scope": "When launched via REA at the Python entry point, native Rust children have no requested breakpoints. Launch/observation overhead remains outside the driver phase timers.",
    }
    checker = ROOT / "scripts/check_krea.py"
    common = [sys.executable, "-B", str(checker), "--krea-root", str(args.krea_root), "--timeout", str(args.timeout)]
    if args.fixtures:
        common += ["--fixtures", str(args.fixtures)]
    if args.parallel_loads:
        common.append("--parallel-loads")

    def run_checker(argv, directory):
        directory.mkdir(parents=True, exist_ok=True)
        started = time.monotonic()
        with (directory / "wrapper.stdout.log").open("w") as stdout, (directory / "wrapper.stderr.log").open("w") as stderr:
            process = subprocess.Popen(argv, cwd=ROOT, stdout=stdout, stderr=stderr, start_new_session=True)
            try:
                returncode = process.wait(timeout=args.timeout + 600)
            except subprocess.TimeoutExpired:
                # The checker normally enforces its own native deadline first.
                # Its outer watchdog must also terminate descendants if hung.
                os.killpg(process.pid, signal.SIGKILL)
                process.wait(timeout=30)
                raise RuntimeError(f"Checker watchdog expired; partial logs retained in {directory}")
        elapsed = time.monotonic() - started
        snapshot = directory / "checks.json"
        shutil.copyfile(BUILD / "checks.json", snapshot)
        if returncode:
            raise RuntimeError(f"Checker failed ({returncode}); see {directory}")
        return json.loads(snapshot.read_text()), snapshot, elapsed

    try:
        prepare_args = common + ["--mode", "native-chain", "--output", str(output / "preparation")]
        if args.no_build:
            prepare_args.append("--no-build")
        prepared, _, _ = run_checker(prepare_args, output / "preparation")
        if not prepared.get("prepared") or prepared.get("native_validated"):
            raise RuntimeError("Preparation did not produce an unexecuted pinned build")
        manifest = json.loads((BUILD / "build-manifest.json").read_text())
        manifest_sha = acceptance.sha(BUILD / "build-manifest.json")
        shutil.copyfile(BUILD / "build-manifest.json", output / "build.json")
        report.update({"prepared": True, "build_manifest_sha256": manifest_sha, "build": manifest,
                       "benchmark_script_sha256": acceptance.sha(Path(__file__)),
                       "external": prepared["external"]})
        acceptance.save(report_path, report)
        if args.native:
            payload_hashes = None
            for pair in range(1, args.pairs + 1):
                arms = ["owned", "native"] if pair % 2 else ["native", "owned"]
                for arm in arms:
                    mode = "eight-step" if arm == "owned" else "native-chain"
                    directory = output / f"pair{pair:02d}-{arm}"
                    print(json.dumps({"event": "run_start", "pair": pair, "arm": arm, "directory": str(directory)}), flush=True)
                    checked, snapshot, elapsed = run_checker(common + ["--native", "--no-build", "--mode", mode, "--output", str(directory)], directory)
                    if checked["build_manifest_sha256"] != manifest_sha or checked["build"] != manifest:
                        raise RuntimeError("Benchmark arms used different source/build identities")
                    if acceptance.sha(BUILD / "driver") != manifest["binary_sha256"]:
                        raise RuntimeError("Driver binary changed during paired measurements")
                    measurement = summarize(checked)
                    if payload_hashes is not None and measurement["payload_hashes"] != payload_hashes:
                        raise RuntimeError("Paired arms produced different payload bytes")
                    payload_hashes = measurement["payload_hashes"]
                    row = {"pair": pair, "arm": arm, "mode": mode, "checker_report": str(snapshot),
                           "checker_report_sha256": acceptance.sha(snapshot), "whole_checker_seconds": elapsed,
                           "measurements": measurement}
                    report["runs"].append(row)
                    report["comparison"] = comparisons(report["runs"])
                    acceptance.save(report_path, report)
                    print(json.dumps({"event": "run_complete", "pair": pair, "arm": arm,
                        "generation_seconds": measurement["generation_seconds"],
                        "child_max_rss_bytes": measurement["child_max_rss_bytes"]}), flush=True)
            report["native_validated"] = True
        report["passed"] = True
        acceptance.save(report_path, report)
        print(json.dumps({"prepared": True, "native_validated": report["native_validated"], "report": str(report_path)}), flush=True)
        return 0
    except Exception as exc:
        report["error"] = str(exc)
        acceptance.save(report_path, report)
        print(str(exc), file=sys.stderr, flush=True)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
