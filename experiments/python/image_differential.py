#!/usr/bin/env python3
"""Compare the Swift image oracle with the b3 runtime wherever their inputs coincide.

Usage: python3 -B experiments/python/image_differential.py SWIFT.json B3.json OUT.json

b3 converts every PIL input to a 32BGRA pixel buffer (swapping R and B) and
decodes 32-bit outputs as BGRA into PIL RGBA. Both programs generate the same
byte pattern, so for channel-wise models:

- b3 BGRA32 input (PIL RGBA) holds swap_rb(Swift input) in buffer memory;
  tensor outputs equal swap_rb(Swift tensor), image outputs decode back to the
  Swift buffer bytes.
- tensor inputs are identical; image outputs decode as swap_rb(Swift buffer)
  for 32-bit formats and unchanged for RGB24.
"""
from pathlib import Path
import json
import sys

swift = json.loads(Path(sys.argv[1]).read_text())["oracle"]
b3 = json.loads(Path(sys.argv[2]).read_text())["runs"]
BACKENDS = {"cpu": "cpu_only", "gpu-preferred": "gpu", "neural-engine-preferred": "neural_engine"}


def swap_rb(data):
    out = bytearray(data)
    for i in range(0, len(out) - 3, 4):
        out[i], out[i + 2] = out[i + 2], out[i]
    return bytes(out)


models = {m["model"]: m for m in swift["models"]}
rows = []
for run in b3:
    name, backend = run["model"], BACKENDS[run["backend"]]
    if run["mode"] not in ("RGBA", "tensor") or name.startswith("YpCbCr"):
        continue
    swift_case = models[name]["backends"][backend].get("run_io_surface", {})
    row = {"model": name, "backend": run["backend"], "b3_outcome": run["outcome"],
           "swift_outcome": swift_case.get("outcome")}
    if run["outcome"] == "completed" and swift_case.get("outcome") == "completed":
        actual = bytes.fromhex(run["output"]["bytes"])
        reference = bytes.fromhex(swift_case["actual"])
        fourcc = name.split("_")[0]
        if run["mode"] == "RGBA":            # BGRA32 image input via PIL
            expected = reference if run["output"]["kind"] == "PIL.Image" else swap_rb(reference)
            rule = "image output decodes to Swift bytes" if run["output"]["kind"] == "PIL.Image" else "swap_rb(Swift tensor)"
        elif run["output"]["kind"] == "PIL.Image":
            expected = reference if fourcc == "RGB24" else swap_rb(reference)
            rule = "RGB24 unchanged" if fourcc == "RGB24" else "b3 decodes 32-bit output as BGRA: swap_rb(Swift buffer)"
        else:
            expected, rule = reference, "identical tensor bytes"
        row.update({"rule": rule, "agree": actual == expected})
    elif run["outcome"] == "threw" and swift_case.get("outcome") == "threw":
        row["agree"] = True
    elif run["outcome"] == "threw" and name.split("_")[0] in ("RGB24", "ARGB32") and run["mode"] == "RGBA":
        row.update({"agree": None, "rule": "b3 always supplies 32BGRA; not comparable", "b3_error": run.get("error")})
    else:
        row["agree"] = False
    rows.append(row)

compared = [r for r in rows if r["agree"] is not None]
summary = {"compared": len(compared), "agree": sum(r["agree"] for r in compared),
           "not_comparable": len(rows) - len(compared)}
Path(sys.argv[3]).write_text(json.dumps({"schema": 1, "summary": summary, "rows": rows}, indent=1) + "\n")
print(summary)
for r in rows:
    if r["agree"] is False:
        print("DISAGREE", r)
