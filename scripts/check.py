#!/usr/bin/env python3
"""Reproduce compiler and native parity experiments; development tooling only."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import struct
import sys
from datetime import datetime, timezone


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "target" / "experiments" / "check"
RECORDS = []


def run(command, *, extra_env=None, expected=0):
    result = subprocess.run(
        [str(x) for x in command], cwd=ROOT,
        env={**os.environ, **(extra_env or {})},
        text=True, capture_output=True, timeout=180,
    )
    RECORDS.append({
        "command": [str(x) for x in command],
        "environment_overrides": extra_env or {},
        "exit_code": result.returncode,
        "stdout": result.stdout, "stderr": result.stderr,
    })
    if expected is not None and result.returncode != expected:
        raise RuntimeError(
            f"command exited {result.returncode}: {' '.join(map(str, command))}\n"
            f"{result.stdout}{result.stderr}"
        )
    return result


def swift(source, output, *options):
    return run([
        "xcrun", "swiftc", "-O", "-module-cache-path", OUTPUT / "swift-cache",
        *options, ROOT / "experiments" / "swift" / source, "-o", OUTPUT / output,
    ])


def check(native, cycles):
    fixture = ROOT / "fixtures/double_f32_2x3"
    manifest = json.loads((fixture / "manifest.json").read_text())
    for relative, expected_hash in manifest["sha256"].items():
        if hashlib.sha256((fixture / relative).read_bytes()).hexdigest() != expected_hash:
            raise AssertionError(f"fixture identity changed: {relative}")
    run([sys.executable, "scripts/calibrate.py"])
    run(["cargo", "fmt", "--all", "--", "--check"])
    run(["cargo", "clippy", "--offline", "--workspace", "--all-targets", "--", "-D", "warnings"])
    run(["cargo", "test", "--offline", "--workspace"])
    run(["cargo", "build", "--offline", "--workspace"])
    run(["cargo", "build", "--offline", "--workspace", "--release"])
    swift("MetadataReference.swift", "metadata-reference")
    swift("TensorReference.swift", "tensor-reference.ll", "-parse-as-library", "-emit-ir")
    swift("BufferReference.swift", "buffer-reference.ll", "-parse-as-library", "-emit-ir")
    swift("ErrorReference.swift", "error-reference.ll", "-parse-as-library", "-emit-ir")
    swift("ErrorReference.swift", "error-reference.sil", "-parse-as-library", "-emit-sil")
    swift("TaskReference.swift", "task-reference.ll", "-parse-as-library", "-emit-ir")
    swift("TaskReference.swift", "task-reference.s", "-parse-as-library", "-emit-assembly")
    swift("TaskRunReference.swift", "task-reference", "-parse-as-library")
    run(["xcrun", "clang", "-O2", ROOT / "experiments/c/SuspensionReference.c", "-o", OUTPUT / "suspension-reference"])
    suspension_reference = run([OUTPUT / "suspension-reference"]).stdout
    if "ok=1 entries=1 resumes=1 identity_matches=2 completion_tls_clear=1 caller_tls_clear=1" not in suspension_reference:
        raise AssertionError("independent compiler-generated suspension oracle did not finish")
    swift("LoadReference.swift", "load-reference.ll", "-parse-as-library", "-emit-ir")
    swift("LoadReference.swift", "load-reference.sil", "-parse-as-library", "-emit-sil")
    swift("LoadRunReference.swift", "load-reference", "-parse-as-library")
    swift("SuspensionReference.swift", "suspension-reference.ll", "-parse-as-library", "-emit-ir")
    swift("InferenceReference.swift", "inference-reference.ll", "-parse-as-library", "-emit-ir")
    swift("InferenceReference.swift", "inference-reference.sil", "-parse-as-library", "-emit-sil")
    swift("InferenceRunReference.swift", "inference-reference", "-parse-as-library")
    missing_asset = OUTPUT / "intentionally-absent.aimodel"
    if missing_asset.exists():
        raise AssertionError("negative model fixture path must be absent")
    expected_model_error = json.loads(run([OUTPUT / "load-reference", missing_asset, "cpuOnly"], expected=1).stdout)
    if expected_model_error["loaded"]:
        raise AssertionError("absent model unexpectedly loaded in Swift")
    expected_task = json.loads(run([OUTPUT / "task-reference"]).stdout)
    if not expected_task["completed"] or not expected_task["body_has_current_task"]:
        raise AssertionError("Swift task oracle did not complete inside a task")
    swift("ErrorRunReference.swift", "error-reference", "-parse-as-library")
    expected_error = json.loads(run([OUTPUT / "error-reference"]).stdout)
    if not expected_error.get("caught"):
        raise AssertionError("empty bookmark must throw in Swift reference")
    # Keep unoptimized generic accessor signatures: optimized calls can inline.
    run([
        "xcrun", "swiftc", "-Onone", "-module-cache-path", OUTPUT / "swift-cache",
        "-parse-as-library", "-emit-ir", ROOT / "experiments/swift/TensorReference.swift",
        "-o", OUTPUT / "tensor-reference-onone.ll",
    ])
    expected = json.loads(run([OUTPUT / "metadata-reference"]).stdout)
    for profile in ["debug", "release"]:
        actual = json.loads(run([ROOT / f"target/{profile}/corsairs-lab", "metadata"]).stdout)
        comparable = [{k: row[k] for k in ["name", "size", "stride", "alignment"]} for row in actual]
        if comparable != expected:
            raise AssertionError(f"{profile} metadata disagrees with Swift: {comparable} != {expected}")
        for command in ["tensor", "buffer", "bookmark-error", "task", "suspend"]:
            bad = run([ROOT / f"target/{profile}/corsairs-lab", command, "0"], expected=None)
            if bad.returncode != 1 or "cycles" not in bad.stderr:
                raise AssertionError(f"invalid {command} count was not rejected before native allocation")
        for command in ["model", "infer"]:
            bad = run([ROOT / f"target/{profile}/corsairs-lab", command, missing_asset, "0"], expected=None)
            if bad.returncode != 1 or "cycles" not in bad.stderr:
                raise AssertionError(f"invalid {command} count was not rejected")
        errors = json.loads(run([ROOT / f"target/{profile}/corsairs-lab", "bookmark-error", str(cycles)]).stdout)
        if not errors["attempts"] == errors["caught"] == errors["released"] == cycles:
            raise AssertionError("native error lifetime loop did not finish")
        if errors["error_type"] != expected_error["error_type"]:
            raise AssertionError("native error type disagrees with Swift")
        task = json.loads(run([ROOT / f"target/{profile}/corsairs-lab", "task", str(cycles)]).stdout)
        if not task["cycles"] == task["bodies_executed"] == task["task_identity_matches"] == task["tls_restored"] == cycles:
            raise AssertionError("native nonsuspending task lifecycle did not finish")
        suspended = json.loads(run([ROOT / f"target/{profile}/corsairs-lab", "suspend", str(cycles)]).stdout)
        if not suspended["cycles"] == suspended["resumes"] == suspended["native_completions"] == suspended["tls_restored"] == cycles or suspended["task_identity_matches"] != 2 * cycles:
            raise AssertionError("native suspending task lifecycle did not finish")
        # Thread migration is observed, not promised by Task.yield's contract.
        if suspended["resumed_on_other_thread"] > cycles:
            raise AssertionError("invalid native thread migration count")
        model_error = json.loads(run([ROOT / f"target/{profile}/corsairs-lab", "model", missing_asset, str(cycles)]).stdout)
        if not model_error["caught"] == model_error["errors_released"] == model_error["native_completions"] == cycles or model_error["loaded"] != 0:
            raise AssertionError("asynchronous model errors were not owned/released")
        if model_error["error_type"] != expected_model_error["error_type"]:
            raise AssertionError("asynchronous model error type disagrees with Swift")
    if native:
        asset = ROOT / "fixtures/double_f32_2x3/double_f32_2x3.aimodel"
        expected_model = json.loads(run([OUTPUT / "load-reference", asset, "cpuOnly"]).stdout)
        for profile in ["debug", "release"]:
            actual = json.loads(run([ROOT / f"target/{profile}/corsairs-lab", "model", asset, str(cycles)]).stdout)
            if actual["function_names"] != expected_model["function_names"] or not actual["loaded"] == actual["destroyed"] == actual["native_completions"] == cycles or actual["caught"] != 0:
                raise AssertionError("native model loading disagrees with Swift")
        expected_inference = json.loads(run([OUTPUT / "inference-reference", asset]).stdout)
        python_reference = json.loads((fixture / "python-reference.json").read_text())
        if not expected_inference["exact_bytes_match"] or not python_reference["exact_bytes_match"]:
            raise AssertionError("reference inference does not match expected bytes")
        for profile in ["debug", "release"]:
            actual = json.loads(run([ROOT / f"target/{profile}/corsairs-lab", "infer", asset, str(cycles)]).stdout)
            for key in ["output_shape", "output_strides", "is_float32", "output_count", "remaining_outputs", "exact_bytes_match"]:
                if actual[key] != expected_inference[key]:
                    raise AssertionError(f"native inference disagrees with Swift: {key}")
            if actual["completed"] != cycles:
                raise AssertionError("inference cycles did not complete")
            output_bytes = struct.pack("<6I", *actual["output_bits"])
            if output_bytes != (fixture / "expected.f32le").read_bytes() or hashlib.sha256(output_bytes).hexdigest() != python_reference["actual_sha256"]:
                raise AssertionError("native inference output disagrees with published Python API")
            if actual["output_shape"] != python_reference["output_shape"] or actual["output_strides"] != python_reference["output_strides"] or python_reference["output_dtype"] != "float32":
                raise AssertionError("native inference metadata disagrees with Python")
        swift("TensorRunReference.swift", "tensor-reference")
        reference = run([OUTPUT / "tensor-reference"], expected=None)
        if reference.returncode:
            raise RuntimeError(
                f"Swift tensor oracle failed with status {reference.returncode}. "
                "The native environment is unavailable; Rust parity is not established by this run."
            )
        expected_tensor = json.loads(reference.stdout)
        for profile in ["debug", "release"]:
            result = json.loads(run([ROOT / f"target/{profile}/corsairs-lab", "tensor", str(cycles)]).stdout)
            if result["shape"] != expected_tensor["shape"] or not expected_tensor["is_float32"]:
                raise AssertionError("native tensor result disagrees with Swift")
            if not result["initialized"] == result["destroyed"] == cycles:
                raise AssertionError("native tensor lifetime loop did not finish")
        swift("BufferRunReference.swift", "buffer-reference", "-parse-as-library", ROOT / "experiments/swift/BufferReference.swift")
        expected_buffer = json.loads(run([OUTPUT / "buffer-reference"]).stdout)
        for profile in ["debug", "release"]:
            actual = json.loads(run([ROOT / f"target/{profile}/corsairs-lab", "buffer", str(cycles)]).stdout)
            if actual["content_bits"] != expected_buffer["content_bits"] or actual["shape"] != expected_buffer["shape"]:
                raise AssertionError("float32 buffer bits disagree with Swift")
            if not actual["initialized"] == actual["destroyed"] == cycles:
                raise AssertionError("native buffer lifetime loop did not finish")
    return {"metadata_matches_swift": True, "error_type_matches_swift": True, "error_cycles": cycles, "task_lifecycle_checked": True, "task_cycles": cycles, "suspension_checked": True, "async_model_error_checked": True, "model_loading_checked": native, "inference_matches_swift_and_recorded_python": native, "tensor_checked": native, "buffer_checked": native, "cycles": cycles if native else None}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", action="store_true", help="also execute tensor oracles; needs native framework access")
    parser.add_argument("--cycles", type=int, default=1000)
    args = parser.parse_args()
    if not 1 <= args.cycles <= 1_000_000:
        parser.error("--cycles must be between 1 and 1000000")
    OUTPUT.mkdir(parents=True, exist_ok=True)
    report = {"timestamp": datetime.now(timezone.utc).isoformat(), "status": "running"}
    try:
        for command in [["sw_vers"], ["rustc", "-Vv"], ["xcrun", "swiftc", "--version"], ["xcrun", "--show-sdk-path"]]:
            run(command)
        report["results"] = check(args.native, args.cycles)
        report["status"] = "passed"
        print("PASS: Rust checks, metadata, and native error type/lifetimes match independent Swift oracles.")
        if args.native:
            print(f"PASS: Tensor construction, shape, dtype, and {args.cycles} destruction cycles in debug and release.")
            print("PASS: Three float32 bit-pattern round trips per tensor match Swift exactly.")
    except (RuntimeError, AssertionError, ValueError, subprocess.TimeoutExpired, OSError) as error:
        report["status"] = "failed"
        report["error"] = str(error)
        print(str(error), file=sys.stderr)
    finally:
        report["commands"] = RECORDS
        report["source_sha256"] = {
            str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
            for base in [ROOT / "crates", ROOT / "experiments", ROOT / "scripts", ROOT / "fixtures"]
            for p in sorted(base.rglob("*")) if p.is_file() and "__pycache__" not in p.parts
        }
        (OUTPUT / "results.json").write_text(json.dumps(report, indent=2) + "\n")
        print(f"Evidence: {OUTPUT / 'results.json'}")
    return 0 if report["status"] == "passed" else 1


if __name__ == "__main__":
    raise SystemExit(main())
