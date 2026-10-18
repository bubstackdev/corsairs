#!/usr/bin/env python3
"""Freeze fixtures/parity-v05/images/backend-goldens.json from reference runs.

Combines results/swift-oracle.json (primary; every single-input case) and
results/b3.json (BGRA32 and tensor inputs). Where both ran a case they must
agree byte for byte. A golden that differs from the analytic expected bytes is
accepted only if this file reviews that exact (backend, case, output) digest.
Once written, backend-goldens.json is immutable: rerunning with different
results fails instead of overwriting. Stdlib only; run with python3 -B.
"""
from pathlib import Path
import hashlib
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
FIXTURES = ROOT / "fixtures/parity-v05/images"
GOLDENS = FIXTURES / "backend-goldens.json"


def sha256(data):
    return hashlib.sha256(data).hexdigest()


# Neural Engine preference computes uint8 255 - x as 255 for every element.
# The tensor-only control in docs/evidence/v0.5/image-swift-oracle.json does the
# same, so this is backend arithmetic, not image I/O. b3 and the Swift oracle
# agree on the BGRA32 digest; RGB24/ARGB32 rest on the Swift oracle alone.
INVERT_REASON = ("Neural Engine preference returns 255 for uint8 255 - x; reproduced without images "
                 "by the tensor-only uint8_invert_tensor control (docs/image-io.md)")
REVIEWED = {
    ("neural-engine-preferred", "RGB24_invert", "y"): (sha256(b"\xff" * 24), INVERT_REASON),
    ("neural-engine-preferred", "ARGB32_invert", "y"): (sha256(b"\xff" * 32), INVERT_REASON),
    ("neural-engine-preferred", "BGRA32_invert", "y"): (sha256(b"\xff" * 32), INVERT_REASON),
}


def pattern(width, height, channels):
    return bytes(1 + (y * 37 + x * 11 + c * 3) % 253
                 for y in range(height) for x in range(width) for c in range(channels))


def main():
    suite_bytes = (FIXTURES / "suite.json").read_bytes()
    suite = json.loads(suite_bytes)
    sources = {"swift-oracle": FIXTURES / "results/swift-oracle.json", "b3": FIXTURES / "results/b3.json"}
    runs = {name: json.loads(path.read_text()) for name, path in sources.items()}
    failures, used_reviews = [], set()
    for name, run in runs.items():
        if run["suite_sha256"] != sha256(suite_bytes):
            failures.append(f"{name} ran a different suite.json")
    for case in suite["cases"]:
        for name, spec in case["inputs"].items():
            value = spec.get("image") or spec["tensor"]
            data = (FIXTURES / value["file"]).read_bytes()
            if sha256(data) != value["sha256"]:
                failures.append(f"{case['name']} input {name} digest")
            # The Swift oracle generates its own inputs; they must be these bytes.
            if len(case["inputs"]) == 1:
                width, height = (value["width"], value["height"]) if "image" in spec else value["shape"][1::-1]
                channels = len(data) // (width * height)
                if data != pattern(width, height, channels):
                    failures.append(f"{case['name']} input {name} is not the oracle pattern")
    backends = {}
    for backend in suite["backends"]:
        table = backends[backend] = {}
        for case in suite["cases"]:
            entry = table[case["name"]] = {}
            for output, spec in case["outputs"].items():
                value = spec.get("image") or spec["tensor"]
                expected = (FIXTURES / value["file"]).read_bytes()
                found = {}
                for source, run in runs.items():
                    row = run["results"].get(backend, {}).get(case["name"], {}).get(output)
                    if row is None:
                        continue
                    if source == "swift-oracle" and not row["variants_agree"]:
                        failures.append(f"{backend} {case['name']}: oracle variants disagree")
                    found[source] = bytes.fromhex(row["hex"])
                if not found:
                    failures.append(f"{backend} {case['name']} {output}: no reference ran it")
                    continue
                if len(set(found.values())) != 1:
                    failures.append(f"{backend} {case['name']} {output}: references disagree "
                                    f"{ {k: sha256(v) for k, v in found.items()} }")
                    continue
                data = next(iter(found.values()))
                golden = {"sha256": sha256(data), "hex": data.hex(), "sources": sorted(found),
                          "matches_expected": data == expected}
                key = (backend, case["name"], output)
                if data != expected:
                    review = REVIEWED.get(key)
                    if review is None or review[0] != golden["sha256"]:
                        failures.append(f"{backend} {case['name']} {output}: unreviewed digest {golden['sha256']}")
                        continue
                    golden["reviewed"] = review[1]
                    used_reviews.add(key)
                entry[output] = golden
    for key in set(REVIEWED) - used_reviews:
        failures.append(f"stale review {key}")
    if failures:
        sys.exit("\n".join(failures))
    record = {"schema": 1, "suite_sha256": sha256(suite_bytes),
              "sources": {name: sha256(path.read_bytes()) for name, path in sources.items()},
              "reviewed": [{"backend": b, "case": c, "output": o, "sha256": REVIEWED[(b, c, o)][0],
                            "reason": REVIEWED[(b, c, o)][1]} for b, c, o in sorted(REVIEWED)],
              "backends": backends}
    text = json.dumps(record, indent=1, sort_keys=True) + "\n"
    if GOLDENS.exists():
        if GOLDENS.read_text() != text:
            sys.exit(f"{GOLDENS} is frozen and differs from these results; refusing to overwrite")
        print(f"{GOLDENS} unchanged")
        return
    GOLDENS.write_text(text)
    counts = {b: sum(len(v) for v in t.values()) for b, t in backends.items()}
    both = sum(len(g["sources"]) == 2 for t in backends.values() for v in t.values() for g in v.values())
    print(f"froze {counts} outputs ({both} confirmed by both references, {len(REVIEWED)} reviewed) to {GOLDENS}")


if __name__ == "__main__":
    main()
