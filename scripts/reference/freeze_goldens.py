#!/usr/bin/env python3
"""Freeze completed native Python outputs independently from math expectations."""
import hashlib
import json
from pathlib import Path
import shutil
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import FIXTURES, WHEEL_SHA256, write_json
from execution import execution_error

# Explicitly reviewed difference, bound to the observed bytes. This records
# reference backend behavior without changing the independent math expectation
# or loosening the Rust-versus-Python exact-byte comparison.
REVIEWED = {("gpu-preferred", "float_edges"):
            "21d5209e8fc24ba7377db28f1433405693130086705058bd606a601e530f43d7",
            # Identical bytes to GPU preference: subnormal flush and NaN canonicalization.
            ("neural-engine-preferred", "float_edges"):
            "21d5209e8fc24ba7377db28f1433405693130086705058bd606a601e530f43d7"}
# v0.4 scalar types: Neural Engine integer saturation and int16 rounding.
REVIEWED.update({
    ("neural-engine-preferred", "int8_wrap"): "08cfe95a5f91d92225cf1d5a8a4ebd9b47a58cb5793acf013cd84a5364de68b9",
    ("neural-engine-preferred", "uint8_wrap"): "68c859c8c0cb7820e0ba460746cee510e2541c362af6c51db05ec678b66b37cd",
    ("neural-engine-preferred", "int16_transpose"): "4f3fd117b811641de216b8e692a44ec1201040da1016f9e7374266a2ab6d4136",
})
# Valid requests Core AI itself rejects; Rust must surface the same native error.
REVIEWED_ERRORS = {
    ("cpu", "int16_empty"): "(loc: unknown, error: inferenceFailed(-1))",
    ("cpu", "uint16_empty"): "(loc: unknown, error: inferenceFailed(-1))",
}
SCALAR_FIXTURES = FIXTURES.parent / "parity-v04" / "scalar-types"
SCALAR_BACKENDS = ("cpu", "gpu-preferred", "neural-engine-preferred")
# Backends frozen separately so the original CPU/GPU grid stays immutable.
SUPPLEMENTARY = ("neural-engine-preferred",)
RULES = ["Never replace mathematical expected files with backend observations.",
         "Rust comparisons use the identical pinned model/input/backend and exact frozen Python bytes.",
         "Backend preference does not prove which delegate executed an individual operation.",
         "Native traps, timeouts or unsupported failures cannot become successful goldens."]


def load_report(fixtures, name):
    """Validate a completed report and pin its first observed bytes."""
    source = fixtures / f"{name}.json"
    report = json.loads(source.read_text())
    if not report["complete"] or report["reference"]["wheel_sha256"] != WHEEL_SHA256:
        raise RuntimeError("Only a completed pinned reference run can produce goldens")
    # Validate every process before creating snapshots or writing golden bytes.
    for observed in report["results"]:
        if problem := execution_error(observed):
            raise RuntimeError(f"Invalid native reference {observed.get('backend')}/{observed.get('case')}: {problem}")
    original = fixtures / f"{name}.initial.json"
    if not original.exists():
        shutil.copyfile(source, original)
    elif original.read_bytes() != source.read_bytes():
        raise RuntimeError("Original reference observations changed; review before replacing frozen goldens")
    return report, original


def freeze_rows(report, fixtures):
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
                    payload = (fixtures / tensor["file"]).read_bytes()
                    actual = hashlib.sha256(payload).hexdigest()
                    if actual != tensor["sha256"]:
                        raise RuntimeError(f"Reference bytes changed: {tensor['file']}")
                    destination = fixtures / "goldens" / backend / name / f"step{step_number}-{group}-{tensor_name}.bin"
                    destination.parent.mkdir(parents=True, exist_ok=True)
                    destination.write_bytes(payload)
                    frozen[group][tensor_name] = {"file": str(destination.relative_to(fixtures)),
                        "dtype": tensor["dtype"], "shape": tensor["shape"], "strides": tensor["strides"], "sha256": actual}
            row["steps"].append(frozen)
        rows.append(row)
    return rows, negative_rows


def negative_summary(negative_rows):
    return [{"backend": row["backend"], "case": row["case"], "negative_case": row["negative_case"],
             "python_error_type": row["error_type"], "python_error": row["error"]} for row in negative_rows]


def freeze(fixtures=FIXTURES):
    report, original = load_report(fixtures, "python-results")
    rows, negative_rows = freeze_rows(report, fixtures)
    if len(rows) != 32 or len(negative_rows) != 16:
        raise RuntimeError(f"Incomplete reference grid: {len(rows)} positives, {len(negative_rows)} negatives")
    write_json(fixtures / "backend-goldens.json", {
        "schema": 1, "reference": report["reference"], "native_execution_successes": len(rows),
        "negative_reference_errors": len(negative_rows), "cases": rows,
        "negative_cases": negative_summary(negative_rows),
        "source_observations": "python-results.initial.json",
        "source_observations_sha256": hashlib.sha256(original.read_bytes()).hexdigest(),
        "python_to_math_mismatches": [{"backend": "gpu-preferred", "case": "float_edges",
            "input_f32_bits": ["00000000", "80000000", "7f800000", "ff800000", "7fc12345", "00000001"],
            "cpu_and_math_output_f32_bits": ["00000000", "80000000", "7f800000", "ff800000", "7fc12345", "00000002"],
            "gpu_preferred_output_f32_bits": ["00000000", "80000000", "7f800000", "ff800000", "7fc00000", "00000000"],
            "interpretation": "Observed subnormal flush and NaN payload canonicalization in GPU-preferred configuration; exact delegate unproven."}],
        "rules": RULES})
    print(f"Frozen {len(rows)} native reference cases; retained 1 Python-to-math mismatch; {len(negative_rows)} expected negative errors")


def freeze_supplement(backend, fixtures=FIXTURES):
    """Freeze one additional backend into backend-goldens-BACKEND.json."""
    if backend not in SUPPLEMENTARY:
        raise RuntimeError(f"Not a supplementary backend: {backend}")
    # Reject a mixed report before load_report can pin it as the original.
    source = json.loads((fixtures / f"python-results-{backend}.json").read_text())
    if any(row.get("backend") != backend for row in source["results"]):
        raise RuntimeError(f"Supplementary report mixes backends other than {backend}")
    report, original = load_report(fixtures, f"python-results-{backend}")
    rows, negative_rows = freeze_rows(report, fixtures)
    if len(rows) != 16 or len(negative_rows) != 8:
        raise RuntimeError(f"Incomplete {backend} grid: {len(rows)} positives, {len(negative_rows)} negatives")
    mismatches = [row["case"] for row in rows if row["reference_to_math"] == "mismatch"]
    write_json(fixtures / f"backend-goldens-{backend}.json", {
        "schema": 1, "backend": backend, "reference": report["reference"],
        "native_execution_successes": len(rows), "negative_reference_errors": len(negative_rows),
        "cases": rows, "negative_cases": negative_summary(negative_rows),
        "source_observations": original.name,
        "source_observations_sha256": hashlib.sha256(original.read_bytes()).hexdigest(),
        "python_to_math_mismatches": mismatches, "rules": RULES})
    print(f"Frozen {len(rows)} {backend} cases; retained {len(mismatches)} reviewed Python-to-math mismatch; "
          f"{len(negative_rows)} expected negative errors")


def freeze_scalar_types(fixtures=SCALAR_FIXTURES):
    """Freeze a three-backend v0.4 grid (scalar-types or float8) in its directory."""
    suite = json.loads((fixtures / "suite.json").read_text())
    names = {case["name"] for case in suite["cases"]}
    reviewed_errors = {key for key in REVIEWED_ERRORS if key[1] in names}
    report, original = load_report(fixtures, "python-results")
    errors = [row for row in report["results"] if row["status"] == "error"]
    for row in errors:
        if REVIEWED_ERRORS.get((row["backend"], row["case"])) != row.get("error") or row.get("failure_stage") != "inference":
            raise RuntimeError(f"Unreviewed native error: {row['backend']}/{row['case']}: {row.get('error')}")
    report = {**report, "results": [row for row in report["results"] if row["status"] != "error"]}
    rows, negative_rows = freeze_rows(report, fixtures)
    expected = len(suite["cases"]) * len(SCALAR_BACKENDS)
    if len(rows) + len(errors) != expected or negative_rows or len(errors) != len(reviewed_errors):
        raise RuntimeError(f"Incomplete scalar grid: {len(rows)} positives, {len(errors)} reviewed errors of {expected}")
    if {row["backend"] for row in rows} != set(SCALAR_BACKENDS):
        raise RuntimeError("Scalar grid must cover every backend")
    write_json(fixtures / "backend-goldens.json", {
        "schema": 1, "reference": report["reference"], "native_execution_successes": len(rows),
        "negative_reference_errors": 0, "cases": rows, "negative_cases": [],
        "native_errors": [{"backend": row["backend"], "case": row["case"], "python_error_type": row["error_type"],
                           "python_error": row["error"]} for row in errors],
        "source_observations": original.name,
        "source_observations_sha256": hashlib.sha256(original.read_bytes()).hexdigest(),
        "python_to_math_mismatches": [{"backend": row["backend"], "case": row["case"]}
                                      for row in rows if row["reference_to_math"] == "mismatch"],
        "rules": RULES})
    print(f"Frozen {len(rows)} {fixtures.name} configurations; {len(errors)} reviewed native errors")


if __name__ == "__main__":
    if sys.argv[1:] == ["--scalar-types"]:
        freeze_scalar_types()
    elif sys.argv[1:] == ["--float8"]:
        freeze_scalar_types(SCALAR_FIXTURES.parent / "float8")
    elif len(sys.argv) == 3 and sys.argv[1] == "--backend":
        freeze_supplement(sys.argv[2])
    elif len(sys.argv) == 1:
        freeze()
    else:
        raise SystemExit("usage: freeze_goldens.py [--backend BACKEND | --scalar-types | --float8]")
