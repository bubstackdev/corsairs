#!/usr/bin/env python3
"""Independent BF16 numerical conversion check against pinned ml_dtypes.

No Core AI import or model execution. The retained corpus includes all BF16
representables, all finite rounding-midpoint neighborhoods, and seeded f32 bits.
NaN numerical conversion is checked by class/sign separately from payload policy.
"""
import argparse
from datetime import datetime, timezone
import importlib.metadata
import json
from pathlib import Path
import random
import sys

from check_float16 import ROOT, numpy_reference, retain, run, sha256, tool


def reference():
    np = numpy_reference()
    try:
        version = importlib.metadata.version("ml_dtypes")
    except importlib.metadata.PackageNotFoundError:
        version = None
    if version != "0.6.0":
        matches = sorted((Path.home() / ".cache/uv/archive-v0").glob("*/ml_dtypes-0.6.0.dist-info"))
        for info in matches:
            if "cp312-cp312-macosx" in (info / "WHEEL").read_text():
                sys.path.insert(0, str(info.parent))
                break
        else:
            raise RuntimeError("Pinned cached ml_dtypes 0.6.0 is required")
    import ml_dtypes
    if ml_dtypes.__version__ != "0.6.0":
        raise RuntimeError("Unexpected ml_dtypes version")
    return np, ml_dtypes


def corpus(np, seed, random_count):
    positive = np.arange(0x7f80, dtype="<u4") << np.uint32(16)
    exact = np.arange(65536, dtype="<u4") << np.uint32(16)
    neighbors = np.concatenate((positive[1:] - np.uint32(1), positive + np.uint32(1)))
    # Same exponent range as f32: arithmetic on integer encodings gives exact
    # f32 rounding midpoints even at the zero/subnormal and finite/Inf bounds.
    mid = positive + np.uint32(0x8000)
    ties = np.concatenate((mid - np.uint32(1), mid, mid + np.uint32(1)))
    boundaries = np.array([(exponent << 23) | fraction for exponent in range(256)
                           for fraction in [0, 1, 0x7fff, 0x8000, 0x8001, 0xffff,
                                            0x10000, 0x3fffff, 0x400000, 0x7f7fff,
                                            0x7f8000, 0x7ffffe, 0x7fffff]], dtype="<u4")
    structured = np.concatenate((neighbors, ties, boundaries))
    structured = np.concatenate((exact, structured, structured | np.uint32(0x80000000)))
    rng = random.Random(seed)
    randoms = np.fromiter((rng.getrandbits(32) for _ in range(random_count)), dtype="<u4", count=random_count)
    return np.unique(np.concatenate((structured, randoms))).astype("<u4")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--seed", type=lambda value: int(value, 0), default=0xBF1602)
    parser.add_argument("--random-count", type=int, default=1_000_000)
    parser.add_argument("--output", type=Path, default=ROOT / "target/bfloat16-conversion")
    parser.add_argument("--report", type=Path, default=ROOT / "docs/evidence/v0.2-bfloat16-conversion.json")
    args = parser.parse_args()
    if args.random_count < 1:
        parser.error("--random-count must be positive")
    np, ml = reference()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    bits = corpus(np, args.seed, args.random_count)
    nan = (bits & np.uint32(0x7fffffff)) > np.uint32(0x7f800000)
    with np.errstate(over="ignore", under="ignore", invalid="ignore"):
        expected = bits.view("<f4").astype(ml.bfloat16).view("<u2")
        widened = expected.view(ml.bfloat16).astype("<f4").view("<u4")
    extension = Path(ml._ml_dtypes_ext.__file__)
    report = {"schema": 1, "passed": False, "generated_utc": datetime.now(timezone.utc).isoformat(),
              "native_coreai_executed": False, "seed": args.seed, "random_count": args.random_count,
              "rng": "CPython random.Random(seed).getrandbits(32)", "unique_vectors": int(bits.size),
              "finite_or_inf_vectors": int(np.count_nonzero(~nan)), "nan_vectors": int(np.count_nonzero(nan)),
              "reference": {"numpy": np.__version__, "ml_dtypes": ml.__version__,
                            "python": sys.version, "executable": sys.executable,
                            "extension": str(extension), "extension_sha256": sha256(extension.read_bytes())},
              "source_sha256": {name: sha256((ROOT / name).read_bytes()) for name in [
                  "experiments/rust/bfloat16_conversion.rs", "scripts/check_bfloat16.py",
                  "scripts/check_float16.py", "crates/corsairs-abi/src/dtype.rs"]},
              "nan_policy": "Numerical reference may quiet/canonicalize NaNs. Strict equality excludes NaNs; Rust must preserve NaN class/sign and its documented high-payload/signaling policy. Raw native storage tests require all bits unchanged.",
              "vectors": {"inputs": retain(output, "inputs.f32le", bits.tobytes()),
                          "ml_dtypes_narrow": retain(output, "reference.bf16le", expected.tobytes()),
                          "ml_dtypes_wide": retain(output, "reference-widened.f32le", widened.tobytes())},
              "profiles": {}, "commands": []}
    for profile in ["debug", "release"]:
        command = [tool("cargo"), "build", "--offline", "-p", "corsairs", "--lib", "--message-format=json"]
        if profile == "release": command.append("--release")
        events = run(command, report["commands"])
        libraries = [Path(filename) for line in events.splitlines() if line.startswith("{")
                     for event in [json.loads(line)] if event.get("reason") == "compiler-artifact"
                     and event.get("target", {}).get("name") == "corsairs"
                     for filename in event.get("filenames", []) if filename.endswith(".rlib")]
        if len(libraries) != 1: raise RuntimeError("Expected one library artifact")
        executable = output / f"bfloat16-{profile}"
        command = [tool("rustc"), "--edition=2024", ROOT / "experiments/rust/bfloat16_conversion.rs",
                   "--extern", f"corsairs={libraries[0]}", "-L", f"dependency={libraries[0].parent}", "-o", executable]
        if profile == "release": command += ["-C", "opt-level=3"]
        run(command, report["commands"])
        narrow_path, wide_path = output / f"rust-{profile}.bf16le", output / f"rust-{profile}-widened.f32le"
        summary = json.loads(run([executable, output / "inputs.f32le", narrow_path, wide_path], report["commands"]))
        if summary["converted"] != bits.size: raise AssertionError("Incomplete conversion")
        actual, wide = np.fromfile(narrow_path, dtype="<u2"), np.fromfile(wide_path, dtype="<u4")
        if actual.size != bits.size or wide.size != bits.size: raise AssertionError("Output extent")
        bad_narrow, bad_wide = (~nan) & (actual != expected), (~nan) & (wide != widened)
        bad_class = nan & (((actual & 0x7f80) != 0x7f80) | ((actual & 0x7f) == 0))
        bad_sign = nan & ((actual >> 15) != (bits >> 31))
        # Separately audit the documented payload policy without requiring the
        # reference implementation to share it. No float arithmetic is used.
        upper = (bits >> 16).astype("<u2")
        wanted_nan = upper | ((upper & 0x7f) == 0).astype("<u2")
        bad_payload = nan & (actual != wanted_nan)
        mismatch = np.flatnonzero(bad_narrow | bad_wide | bad_class | bad_sign | bad_payload)
        report["profiles"][profile] = {
            "finite_or_inf_narrow_mismatches": int(np.count_nonzero(bad_narrow)),
            "finite_or_inf_widened_mismatches": int(np.count_nonzero(bad_wide)),
            "nan_class_mismatches": int(np.count_nonzero(bad_class)),
            "nan_sign_mismatches": int(np.count_nonzero(bad_sign)),
            "documented_nan_payload_mismatches": int(np.count_nonzero(bad_payload)),
            "nan_payload_differences_from_reference": int(np.count_nonzero(nan & (actual != expected))),
            "first_mismatches": [{"input": f"0x{int(bits[i]):08x}", "rust": f"0x{int(actual[i]):04x}",
                                  "reference": f"0x{int(expected[i]):04x}"} for i in mismatch[:20]],
            "narrow_vector": retain(output, f"rust-{profile}.bf16le", narrow_path.read_bytes()),
            "wide_vector": retain(output, f"rust-{profile}-widened.f32le", wide_path.read_bytes())}
    report["passed"] = all(not result["first_mismatches"] for result in report["profiles"].values())
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"passed": report["passed"], "unique_vectors": report["unique_vectors"],
                      "finite_or_inf_vectors": report["finite_or_inf_vectors"], "nan_vectors": report["nan_vectors"],
                      "report": str(args.report)}, sort_keys=True))
    if not report["passed"]: raise SystemExit(1)


if __name__ == "__main__": main()
