#!/usr/bin/env python3
"""Independent float8 (E4M3FN, E5M2) conversion check against pinned ml_dtypes.

No Core AI import or model execution. Widening covers all 256 encodings of each
type. Narrowing covers every representable value, every rounding midpoint and
its binary32 neighbors, overflow boundaries, specials and seeded random bits.
Non-NaN results must match bit for bit; NaN results must be the canonical NaN
of the input's sign, which is also what ml_dtypes produces for these types.
"""
import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import random

from check_bfloat16 import reference
from check_float16 import ROOT, retain, run, sha256, tool

TYPES = {"e4m3fn": ("float8_e4m3fn", 0x7f), "e5m2": ("float8_e5m2", 0x7e)}


def corpus(np, ml, seed, random_count):
    parts = []
    for name, _ in TYPES.values():
        values = np.arange(256, dtype=np.uint8).view(getattr(ml, name)).astype("<f4")
        finite = np.unique(np.abs(values[np.isfinite(values)]))
        mid = (finite[:-1].astype(np.float64) + finite[1:]) / 2
        edge = np.array([finite[-1] * 1.0, finite[-1] * 1.0625, finite[-1] * 1.125, finite[-1] * 2, 65536, 1e9],
                        dtype=np.float64)
        for group in [finite.astype(np.float64), mid, edge]:
            exact = group.astype("<f4")
            parts += [exact, np.nextafter(exact, np.float32(np.inf)), np.nextafter(exact, np.float32(0))]
    specials = np.array([0x0, 0x80000000, 0x7f800000, 0xff800000, 0x7fc00000, 0xffc00000, 0x7f800001,
                         0x7fa00000, 0xffffffff, 0x00000001, 0x007fffff, 0x7f7fffff], dtype="<u4").view("<f4")
    rng = random.Random(seed)
    randoms = np.fromiter((rng.getrandbits(32) for _ in range(random_count)), dtype="<u4", count=random_count).view("<f4")
    bits = np.concatenate([np.concatenate(parts), -np.concatenate(parts), specials, randoms]).view("<u4")
    return np.unique(bits).astype("<u4")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--seed", type=lambda value: int(value, 0), default=0xF8F8)
    parser.add_argument("--random-count", type=int, default=1_000_000)
    parser.add_argument("--output", type=Path, default=ROOT / "target/float8-conversion")
    parser.add_argument("--report", type=Path, default=ROOT / "docs/evidence/v0.4/float8-conversion.json")
    args = parser.parse_args()
    np, ml = reference()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    bits = corpus(np, ml, args.seed, args.random_count)
    floats = bits.view("<f4")
    nan_input = np.isnan(floats)
    report = {"schema": 1, "passed": False, "generated_utc": datetime.now(timezone.utc).isoformat(),
              "native_coreai_executed": False, "seed": args.seed, "random_count": args.random_count,
              "unique_vectors": int(bits.size), "nan_vectors": int(nan_input.sum()),
              "reference": {"numpy": np.__version__, "ml_dtypes": ml.__version__},
              "source_sha256": {name: sha256((ROOT / name).read_bytes()) for name in [
                  "experiments/rust/float8_conversion.rs", "scripts/check_float8.py", "crates/corsairs-abi/src/dtype.rs"]},
              "inputs": retain(output, "inputs.f32le", bits.tobytes()), "profiles": {}, "commands": []}
    with np.errstate(over="ignore", invalid="ignore"):
        expected = {key: floats.astype(getattr(ml, name)).view(np.uint8) for key, (name, _) in TYPES.items()}
        widened = {key: np.arange(256, dtype=np.uint8).view(getattr(ml, name)).astype("<f4").view("<u4")
                   for key, (name, _) in TYPES.items()}
    for profile in ["debug", "release"]:
        command = [tool("cargo"), "build", "--offline", "-p", "corsairs", "--lib", "--message-format=json"]
        if profile == "release": command.append("--release")
        events = run(command, report["commands"])
        libraries = [Path(f) for line in events.splitlines() if line.startswith("{") for e in [json.loads(line)]
                     if e.get("reason") == "compiler-artifact" and e.get("target", {}).get("name") == "corsairs"
                     for f in e.get("filenames", []) if f.endswith(".rlib")]
        if len(libraries) != 1: raise RuntimeError("Expected one library artifact")
        executable = output / f"float8-{profile}"
        command = [tool("rustc"), "--edition=2024", "-Dwarnings", ROOT / "experiments/rust/float8_conversion.rs",
                   "--extern", f"corsairs={libraries[0]}", "-L", f"dependency={libraries[0].parent}", "-o", executable]
        if profile == "release": command += ["-C", "opt-level=3"]
        run(command, report["commands"])
        directory = output / profile
        directory.mkdir(exist_ok=True)
        summary = json.loads(run([executable, output / "inputs.f32le", directory], report["commands"]))
        if summary["converted"] != bits.size: raise AssertionError("Incomplete conversion")
        result = {}
        for key, (_, nan) in TYPES.items():
            actual = np.fromfile(directory / f"{key}-narrow.u8", dtype=np.uint8)
            wide = np.fromfile(directory / f"{key}-widen.f32le", dtype="<u4")
            sign = ((bits >> 24) & 0x80).astype(np.uint8)
            bad_narrow = (~nan_input) & (actual != expected[key])
            bad_nan = nan_input & ((actual != (sign | nan)) | (expected[key] != (sign | nan)))
            reference_wide = widened[key]
            nan_wide = (reference_wide & 0x7fffffff) > 0x7f800000
            bad_wide = (~nan_wide) & (wide != reference_wide)
            bad_wide_nan = nan_wide & (((wide & 0x7fffffff) <= 0x7f800000) | ((wide >> 31) != (reference_wide >> 31)))
            mismatch = np.flatnonzero(bad_narrow | bad_nan)
            result[key] = {"narrow_mismatches": int(bad_narrow.sum()), "nan_mismatches": int(bad_nan.sum()),
                           "widen_mismatches": int(bad_wide.sum()), "widen_nan_mismatches": int(bad_wide_nan.sum()),
                           "first_mismatches": [{"input": f"0x{int(bits[i]):08x}", "rust": f"0x{int(actual[i]):02x}",
                                                 "reference": f"0x{int(expected[key][i]):02x}"} for i in mismatch[:20]],
                           "narrow_vector": retain(output, f"{profile}-{key}-narrow.u8", actual.tobytes())}
        report["profiles"][profile] = result
    report["passed"] = all(not any(v for k, v in r.items() if k.endswith("mismatches") and k != "first_mismatches")
                           and not r["first_mismatches"]
                           for profile in report["profiles"].values() for r in profile.values())
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"passed": report["passed"], "unique_vectors": report["unique_vectors"],
                      "nan_vectors": report["nan_vectors"], "report": str(args.report),
                      "summary": {p: {k: {m: v[m] for m in v if m.endswith("mismatches") and m != "first_mismatches"}
                                      for k, v in r.items()} for p, r in report["profiles"].items()}}))
    if not report["passed"]: raise SystemExit(1)


if __name__ == "__main__": main()
