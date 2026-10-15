#!/usr/bin/env python3
"""Rebuild descriptive summaries from the retained v0.3 benchmark reports."""
import hashlib
import json
from pathlib import Path
import statistics

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "docs/evidence/v0.3-benchmarks"


def main():
    result = {"units": "milliseconds", "statistic": "Range and median of per-process medians; no confidence intervals",
              "groups": {}, "source_reports": {}}
    for key, pairs, phase in [
        ("feedforward-cpu", [1, 2, 3], "owned_run"),
        ("feedforward-gpu-preferred", [1, 2, 3], "owned_run"),
        ("h3-functional-19333", [3, 4], "native_run_download"),
        ("krea-first-segment", [1, 2], "native_run_download"),
    ]:
        group = {"phase": phase, "pairs": pairs, "arms": {}}
        for language in ["rust", "python"]:
            values, p95s = [], []
            for pair in pairs:
                path = BASE / f"runs/{key}/pair-{pair:02}.json"
                report = json.loads(path.read_text())
                assert report["passed"]
                value = next(p for p in report[language]["phases"] if p["phase"] == phase)
                assert value["every_iteration_exact"]
                values.append(value["median_ns"] / 1e6)
                p95s.append(value["p95_ns"] / 1e6)
                relative = str(path.relative_to(ROOT))
                result["source_reports"][relative] = hashlib.sha256(path.read_bytes()).hexdigest()
            group["arms"][language] = dict(process_medians=values, median_of_medians=statistics.median(values),
                median_range=[min(values), max(values)], process_p95s=p95s)
        result["groups"][key] = group
    result["exclusions"] = [
        "H3 pair1: initial single-phase run without cooldown, retained separately",
        "H3 pair2: exploratory fixed-order phase sweep with drift, retained separately",
        "Single-language Metal runs: no public Python equivalent",
        "Sampled Rust profiling loop: instrumented diagnostic",
        "Published external results: unmatched models/hardware/precision/schedules",
    ]
    path = BASE / "summary.json"
    path.write_text(json.dumps(result, indent=2) + "\n")
    print(path)


if __name__ == "__main__":
    main()
