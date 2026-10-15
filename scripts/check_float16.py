#!/usr/bin/env python3
"""Differential binary32/binary16 conversion check against pinned NumPy.

Development tooling only. Imports NumPy but never imports or executes Core AI.
All full corpus/output vectors are retained beneath target/float16-conversion;
the small evidence report includes their hashes and deterministic replay inputs.
Run with CPython 3.12 and NumPy 2.3.5 (an existing matching uv cache is supported).
"""
import argparse
from datetime import datetime, timezone
import gzip
import hashlib
import importlib.metadata
import json
from pathlib import Path
import random
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
NUMPY_VERSION = "2.3.5"
DEFAULT_SEED = 0xC075A1


def numpy_reference():
    if sys.version_info[:2] != (3, 12):
        raise RuntimeError("Use CPython 3.12 with the pinned NumPy 2.3.5 reference")
    try:
        installed = importlib.metadata.version("numpy")
    except importlib.metadata.PackageNotFoundError:
        installed = None
    if installed != NUMPY_VERSION:
        cache = Path.home() / ".cache/uv/archive-v0"
        candidates = sorted(cache.glob(f"*/numpy-{NUMPY_VERSION}.dist-info"))
        for info in candidates:
            wheel = (info / "WHEEL").read_text()
            if "cp312-cp312-macosx" in wheel and ("arm64" in wheel or "universal2" in wheel):
                sys.path.insert(0, str(info.parent))
                break
        else:
            raise RuntimeError("NumPy 2.3.5 is required; no matching installed package or existing CPython 3.12 cache found")
    import numpy as np
    if np.__version__ != NUMPY_VERSION:
        raise RuntimeError(f"Expected NumPy {NUMPY_VERSION}, imported {np.__version__}")
    return np


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def corpus(np, seed, random_count):
    # Every positive finite binary16, widened exactly to binary32. Negative
    # counterparts use sign-bit insertion, avoiding arithmetic on NaN payloads.
    halves = np.arange(0x7c00, dtype="<u2")
    singles = halves.view("<f2").astype("<f4").view("<u4")
    representables = np.concatenate((singles, singles | np.uint32(0x80000000)))
    neighbors = np.concatenate((singles[1:] - np.uint32(1), singles + np.uint32(1)))
    neighbors = np.concatenate((neighbors, neighbors | np.uint32(0x80000000)))
    # All adjacent finite binary16 rounding midpoints are exactly representable
    # in binary32. Include both sides at one binary32 ULP, for both signs.
    values = halves.view("<f2").astype("<f8")
    midpoints = ((values[:-1] + values[1:]) * 0.5).astype("<f4").view("<u4")
    ties = np.concatenate((midpoints - np.uint32(1), midpoints, midpoints + np.uint32(1)))
    ties = np.concatenate((ties, ties | np.uint32(0x80000000)))
    # Maximum-finite to infinity midpoint (65520) and its binary32 neighbors;
    # explicit infinities, exponent extremes, zero/subnormal boundaries and NaNs.
    special = [
        0, 1, 2, 0x007ffffe, 0x007fffff, 0x00800000, 0x00800001,
        0x32ffffff, 0x33000000, 0x33000001, 0x337fffff, 0x33800000,
        0x387fffff, 0x38800000, 0x38800001, 0x477fe000,
        0x477fefff, 0x477ff000, 0x477ff001, 0x47800000,
        0x7f7fffff, 0x7f800000, 0x7f800001, 0x7fc00000, 0x7fffffff,
    ]
    exponent_grid = [(exponent << 23) | fraction for exponent in range(256)
                     for fraction in [0, 1, 0xfff, 0x1000, 0x1001, 0x1fff, 0x2000,
                                      0x3fffff, 0x400000, 0x7fefff, 0x7ff000, 0x7ffffe, 0x7fffff]]
    special = np.array(special + exponent_grid, dtype="<u4")
    special = np.concatenate((special, special | np.uint32(0x80000000)))
    rng = random.Random(seed)
    randoms = np.fromiter((rng.getrandbits(32) for _ in range(random_count)), dtype="<u4", count=random_count)
    families = {"exact_half_values": int(representables.size),
                "half_neighbors": int(neighbors.size), "all_half_midpoint_neighborhoods": int(ties.size),
                "exponent_and_explicit_boundaries": int(special.size), "seeded_uniform_u32": random_count}
    bits = np.unique(np.concatenate((representables, neighbors, ties, special, randoms))).astype("<u4")
    return bits, families


def run(command, commands):
    completed = subprocess.run([str(arg) for arg in command], cwd=ROOT, capture_output=True, text=True, timeout=180)
    commands.append({"command": [str(arg) for arg in command], "returncode": completed.returncode,
                     "stdout": completed.stdout, "stderr": completed.stderr})
    if completed.returncode:
        raise RuntimeError(f"Command failed: {command}\n{completed.stdout}\n{completed.stderr}")
    return completed.stdout


def tool(name):
    found = shutil.which(name)
    if found:
        return found
    candidate = Path.home() / ".cargo/bin" / name
    if candidate.is_file():
        return candidate
    raise RuntimeError(f"Missing tool {name}")


def retain(output, name, data):
    raw = output / name
    raw.write_bytes(data)
    compressed = output / f"{name}.gz"
    compressed.write_bytes(gzip.compress(data, compresslevel=9, mtime=0))
    return {"file": str(raw.relative_to(ROOT)) if raw.is_relative_to(ROOT) else str(raw),
            "bytes": len(data), "sha256": sha256(data),
            "gzip_file": str(compressed.relative_to(ROOT)) if compressed.is_relative_to(ROOT) else str(compressed),
            "gzip_sha256": sha256(compressed.read_bytes())}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--seed", type=lambda text: int(text, 0), default=DEFAULT_SEED)
    parser.add_argument("--random-count", type=int, default=1_000_000)
    parser.add_argument("--output", type=Path, default=ROOT / "target/float16-conversion")
    parser.add_argument("--report", type=Path, default=ROOT / "docs/evidence/v0.1-float16-conversion.json")
    args = parser.parse_args()
    if args.random_count < 1:
        parser.error("--random-count must be positive")
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    np = numpy_reference()
    bits, families = corpus(np, args.seed, args.random_count)
    mask_nan = (bits & np.uint32(0x7fffffff)) > np.uint32(0x7f800000)
    with np.errstate(over="ignore", invalid="ignore", under="ignore"):
        expected_half = bits.view("<f4").astype("<f2").view("<u2")
        expected_wide = expected_half.view("<f2").astype("<f4").view("<u4")
    vectors = {
        "inputs_f32le": retain(output, "inputs.f32le", bits.tobytes()),
        "numpy_f16le": retain(output, "numpy.f16le", expected_half.tobytes()),
        "numpy_widened_f32le": retain(output, "numpy-widened.f32le", expected_wide.tobytes()),
    }
    extension = Path(np._core._multiarray_umath.__file__)
    report = {"schema": 1, "passed": False, "generated_utc": datetime.now(timezone.utc).isoformat(),
              "python": sys.version, "python_executable": sys.executable,
              "reference": {"name": "numpy", "version": np.__version__, "module": str(np.__file__),
                            "conversion_extension": str(extension), "extension_sha256": sha256(extension.read_bytes())},
              "seed": args.seed, "rng": "CPython random.Random(seed).getrandbits(32)",
              "families_before_deduplication": families, "unique_vectors": int(bits.size),
              "strict_finite_or_infinity_vectors": int(np.count_nonzero(~mask_nan)),
              "nan_vectors": int(np.count_nonzero(mask_nan)),
              "nan_policy": "NaN payloads excluded from NumPy equality; Rust conversion must preserve NaN class and sign",
              "source_sha256": {name: sha256((ROOT / name).read_bytes()) for name in [
                  "experiments/rust/float16_conversion.rs", "crates/corsairs-abi/src/dtype.rs", "scripts/check_float16.py"]},
              "vectors": vectors, "profiles": {}, "commands": []}
    for profile in ["debug", "release"]:
        command = [tool("cargo"), "build", "--offline", "-p", "corsairs", "--message-format=json"]
        if profile == "release":
            command.append("--release")
        stdout = run(command, report["commands"])
        libraries = [Path(filename) for line in stdout.splitlines() if line.startswith("{")
                     for event in [json.loads(line)] if event.get("reason") == "compiler-artifact"
                     and event.get("target", {}).get("name") == "corsairs"
                     for filename in event.get("filenames", []) if filename.endswith(".rlib")]
        if len(libraries) != 1:
            raise RuntimeError("Could not identify one Corsairs library artifact")
        executable = output / f"float16-{profile}"
        command = [tool("rustc"), "--edition=2024", ROOT / "experiments/rust/float16_conversion.rs",
                   "--extern", f"corsairs={libraries[0]}", "-L", f"dependency={libraries[0].parent}", "-o", executable]
        if profile == "release":
            command += ["-C", "opt-level=3"]
        run(command, report["commands"])
        half_path, wide_path = output / f"rust-{profile}.f16le", output / f"rust-{profile}-widened.f32le"
        summary = json.loads(run([executable, output / "inputs.f32le", half_path, wide_path], report["commands"]))
        if summary["converted"] != bits.size:
            raise AssertionError("Rust driver did not process the full corpus")
        half = np.fromfile(half_path, dtype="<u2")
        wide = np.fromfile(wide_path, dtype="<u4")
        if half.size != bits.size or wide.size != bits.size:
            raise AssertionError("Rust output length differs from corpus")
        mismatch_half = (~mask_nan) & (half != expected_half)
        mismatch_wide = (~mask_nan) & (wide != expected_wide)
        nan_bad_class = mask_nan & (((half & 0x7c00) != 0x7c00) | ((half & 0x03ff) == 0))
        nan_bad_sign = mask_nan & ((half >> 15) != (bits >> 31))
        mismatches = np.flatnonzero(mismatch_half | mismatch_wide | nan_bad_class | nan_bad_sign)
        report["profiles"][profile] = {
            "finite_or_infinity_half_mismatches": int(np.count_nonzero(mismatch_half)),
            "finite_or_infinity_widened_mismatches": int(np.count_nonzero(mismatch_wide)),
            "nan_class_mismatches": int(np.count_nonzero(nan_bad_class)),
            "nan_sign_mismatches": int(np.count_nonzero(nan_bad_sign)),
            "first_mismatches": [{"input_f32_bits": f"0x{int(bits[i]):08x}",
                                  "rust_f16_bits": f"0x{int(half[i]):04x}", "numpy_f16_bits": f"0x{int(expected_half[i]):04x}",
                                  "rust_widened_f32_bits": f"0x{int(wide[i]):08x}", "numpy_widened_f32_bits": f"0x{int(expected_wide[i]):08x}"}
                                 for i in mismatches[:20]],
            "half_vector": retain(output, f"rust-{profile}.f16le", half_path.read_bytes()),
            "widened_vector": retain(output, f"rust-{profile}-widened.f32le", wide_path.read_bytes()),
        }
    report["passed"] = all(not values["first_mismatches"] for values in report["profiles"].values())
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2, allow_nan=False) + "\n")
    print(json.dumps({"passed": report["passed"], "unique_vectors": report["unique_vectors"],
                      "strict_finite_or_infinity_vectors": report["strict_finite_or_infinity_vectors"],
                      "nan_vectors": report["nan_vectors"], "report": str(args.report)}, sort_keys=True))
    if not report["passed"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
