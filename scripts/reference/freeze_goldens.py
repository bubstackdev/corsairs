#!/usr/bin/env python3
"""Freeze completed native Python outputs independently from math expectations."""
import hashlib
import json
from pathlib import Path
import shutil
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import FIXTURES, WHEEL_SHA256, write_json

source = FIXTURES / "python-results.json"
report = json.loads(source.read_text())
if not report["complete"] or report["reference"]["wheel_sha256"] != WHEEL_SHA256:
    raise RuntimeError("Only a completed pinned reference run can produce goldens")
original = FIXTURES / "python-results.initial.json"
if not original.exists():
    shutil.copyfile(source, original)
elif original.read_bytes() != source.read_bytes():
    raise RuntimeError("Original reference observations changed; review before replacing frozen goldens")

# Explicitly reviewed difference, bound to the observed bytes. This records
# reference backend behavior without changing the independent math expectation
# or loosening the Rust-versus-Python exact-byte comparison.
REVIEWED = {("gpu-preferred", "float_edges"):
            "21d5209e8fc24ba7377db28f1433405693130086705058bd606a601e530f43d7"}
rows = []
negative_rows = []
for observed in report["results"]:
    backend, name = observed["backend"], observed["case"]
    if observed["negative_case"]:
        if observed["status"] != "expected_error":
            raise RuntimeError(f"Negative reference precondition failed: {observed}")
        negative_rows.append(observed)
        continue
    if observed["status"] not in ["passed", "mismatch"]:
        raise RuntimeError(f"Native reference did not execute successfully: {backend}/{name}")
    if observed["status"] == "mismatch":
        actual = observed["steps"][0]["outputs"]["y"]["sha256"]
        if REVIEWED.get((backend, name)) != actual:
            raise RuntimeError(f"Unreviewed Python-to-math mismatch: {backend}/{name}: {actual}")
    row = {"case": name, "backend": backend, "descriptor": observed["descriptor"],
           "reference_to_math": observed["status"], "native_reference_execution": "completed",
           "rust_to_python_comparison": "exact bytes, dtype, shape, strides and state after every step",
           "steps": []}
    for step_number, step in enumerate(observed["steps"]):
        frozen = {}
        for group, tensors in step.items():
            frozen[group] = {}
            for tensor_name, tensor in tensors.items():
                payload = (FIXTURES / tensor["file"]).read_bytes()
                actual = hashlib.sha256(payload).hexdigest()
                if actual != tensor["sha256"]:
                    raise RuntimeError(f"Reference bytes changed: {tensor['file']}")
                destination = FIXTURES / "goldens" / backend / name / f"step{step_number}-{group}-{tensor_name}.bin"
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_bytes(payload)
                frozen[group][tensor_name] = {"file": str(destination.relative_to(FIXTURES)),
                    "dtype": tensor["dtype"], "shape": tensor["shape"], "strides": tensor["strides"], "sha256": actual}
        row["steps"].append(frozen)
    rows.append(row)
if len(rows) != 32 or len(negative_rows) != 16:
    raise RuntimeError(f"Incomplete reference grid: {len(rows)} positives, {len(negative_rows)} negatives")
write_json(FIXTURES / "backend-goldens.json", {
    "schema": 1, "reference": report["reference"], "native_execution_successes": len(rows),
    "negative_reference_errors": len(negative_rows), "cases": rows,
    "negative_cases": [{"backend": row["backend"], "case": row["case"],
        "negative_case": row["negative_case"], "python_error_type": row["error_type"],
        "python_error": row["error"]} for row in negative_rows],
    "source_observations": "python-results.initial.json",
    "source_observations_sha256": hashlib.sha256(original.read_bytes()).hexdigest(),
    "python_to_math_mismatches": [{"backend": "gpu-preferred", "case": "float_edges",
        "input_f32_bits": ["00000000", "80000000", "7f800000", "ff800000", "7fc12345", "00000001"],
        "cpu_and_math_output_f32_bits": ["00000000", "80000000", "7f800000", "ff800000", "7fc12345", "00000002"],
        "gpu_preferred_output_f32_bits": ["00000000", "80000000", "7f800000", "ff800000", "7fc00000", "00000000"],
        "interpretation": "Observed subnormal flush and NaN payload canonicalization in GPU-preferred configuration; exact delegate unproven."}],
    "rules": ["Never replace mathematical expected files with backend observations.",
              "Rust comparisons use the identical pinned model/input/backend and exact frozen Python bytes.",
              "Backend preference does not prove which delegate executed an individual operation.",
              "Native traps, timeouts or unsupported failures cannot become successful goldens."]})
print(f"Frozen {len(rows)} native reference cases; retained 1 Python-to-math mismatch; {len(negative_rows)} expected negative errors")
