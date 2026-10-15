#!/usr/bin/env python3
"""Verify pinned asset/input bytes and authoring save/load round trips."""
import hashlib
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import FIXTURES, initialize, write_json
initialize()
from coreai.authoring import AIModelAsset

suite = json.loads((FIXTURES / "suite.json").read_text())
for name, digest in suite["sha256"].items():
    actual = hashlib.sha256((FIXTURES / name).read_bytes()).hexdigest()
    if actual != digest:
        raise RuntimeError(f"Fixture bytes changed: {name}")
rows = []
for case in suite["cases"]:
    path = FIXTURES / case["model"]
    valid = AIModelAsset.is_valid(path)
    asset = AIModelAsset.load(path)
    program = asset.program
    summary = asset.summary(include_statistics=False)
    if not valid or "@main" not in str(program):
        raise RuntimeError(f"Asset round trip failed: {case['name']}")
    expected_hash = hashlib.sha256((path / "main.mlirb").read_bytes()).digest()
    if (path / "main.hash").read_bytes() != expected_hash:
        raise RuntimeError(f"Apple bytecode integrity digest differs: {case['name']}")
    rows.append({"case": case["name"], "asset_valid": valid,
                 "source_reload_has_main": "@main" in str(program), "summary": str(summary),
                 "apple_bytecode_digest_match": True})
write_json(FIXTURES / "preparation-checks.json", {"passed": True, "fixture_count": len(rows), "cases": rows})
print(f"Verified hashes and authoring round trips for {len(rows)} fixtures")
