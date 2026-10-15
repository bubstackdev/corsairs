#!/usr/bin/env python3
"""Author tiny x+x assets with large tensor signatures, without weight payloads."""
import hashlib
import sys
from pathlib import Path
from typing import Annotated

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import ROOT, initialize, identity, write_json
initialize()
import numpy as np
import ml_dtypes
import coreai.authoring as a

directory = ROOT / "fixtures/parity-v03/large-tensors"
cases = [
    ("h3-hidden", "bfloat16", [1, 102816, 5376]),
    ("h3-rgb124", "float32", [124, 1344, 768, 3]),
    ("h3-rgb345", "float32", [345, 1344, 768, 3]),
    ("limit-f32", "float32", [1 << 30]),
]
records = []
for name, dtype, shape in cases:
    target = directory / name
    target.mkdir(parents=True, exist_ok=True)
    module = a.Module.create()
    scalar = ml_dtypes.bfloat16 if dtype == "bfloat16" else np.float32
    with module:
        def body(x):
            return a.add(x, x)
        body.__annotations__ = {
            "x": Annotated[a.Value, a.TensorType(shape, scalar)],
            "return": Annotated[a.Value, a.TensorType(shape, scalar, name="y")],
        }
        a.graph(body, provided_name="main")
    module.verify()
    (target / "graph.mlir").write_text(module.as_string() + "\n")
    a.AIProgram(module).save_asset(target / "model.aimodel")
    size = int(np.prod(shape)) * (2 if dtype == "bfloat16" else 4)
    records.append({"name": name, "dtype": dtype, "shape": shape, "bytes": size,
                    "asset": name + "/model.aimodel"})
write_json(directory / "manifest.json", {
    "schema": 1, "reference": identity(), "cases": records,
    "native_executed": False,
    "scope": "Mechanical tensor capacity and x+x arithmetic only; no H3 attention, decoder, temporal chunking or generation equivalence.",
    "pattern_version": 2,
    "pattern": "1 MiB blocks; seed=1+(block_index%251); eight finite nonzero scalars [seed,-seed,1,-1,2,-2,64,-64] repeated. Powers of two preserve exact BF16/F32 values. Offset-varying blocks detect wrap at 1/2/4 GiB. The initial signed-zero CPU observation is retained separately.",
    "sha256": {str(p.relative_to(directory)): hashlib.sha256(p.read_bytes()).hexdigest()
               for p in sorted(directory.rglob("*")) if p.is_file() and p.name != "manifest.json"},
})
print(directory)
