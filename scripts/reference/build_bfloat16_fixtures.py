#!/usr/bin/env python3
"""Author small BF16 fixtures with the pinned b3 package; never execute a model."""
from pathlib import Path
import hashlib
import struct
import sys
from typing import Annotated

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import ROOT, initialize, identity, write_json
initialize()
import numpy as np
import ml_dtypes
import coreai.authoring as a

directory = ROOT / "fixtures/parity-v02/bfloat16"
directory.mkdir(parents=True, exist_ok=True)
dtype = ml_dtypes.bfloat16
cases = []


def tensor(path, value):
    value = np.asarray(value, dtype=dtype)
    payload = value.view(np.uint16).astype("<u2").tobytes(order="C")
    (directory / path).write_bytes(payload)
    return {"file": path, "shape": list(value.shape), "dtype": "bfloat16",
            "sha256": hashlib.sha256(payload).hexdigest()}


def save_model(name, module):
    case_directory = directory / name
    case_directory.mkdir(exist_ok=True)
    module.verify()
    (case_directory / "graph.mlir").write_text(module.as_string() + "\n")
    a.AIProgram(module).save_asset(case_directory / "model.aimodel")
    return f"{name}/model.aimodel"


for name, shape, values in [
    ("double", [2, 3], [1, -2, 0, .5, 100, -.25]),
    ("scalar", [], [3.5]),
    ("empty", [0, 3], []),
    ("dynamic", [-1, 3], None),
]:
    module = a.Module.create()
    with module:
        def body(x):
            return a.add(x, x)
        body.__annotations__ = {
            "x": Annotated[a.Value, a.TensorType(shape, a.bfloat16)],
            "return": Annotated[a.Value, a.TensorType(shape, a.bfloat16, name="y")],
        }
        a.graph(body, provided_name="main")
    model = save_model(name, module)
    steps = []
    for index, concrete in enumerate(([1, 3], [4, 3], [2, 3], [1, 3]) if values is None else [shape]):
        x = (np.arange(np.prod(concrete), dtype=np.float32) - np.float32(2.5)).astype(dtype).reshape(concrete) if values is None else np.asarray(values, dtype=dtype).reshape(concrete)
        expected = (x.astype(np.float32) + x.astype(np.float32)).astype(dtype)
        steps.append({"inputs": {"x": tensor(f"{name}/{index}-x.bin", x)},
                      "outputs": {"y": tensor(f"{name}/{index}-expected-y.bin", expected)}})
    cases.append({"name": name, "model": model, "function": "main", "steps": steps})

# A stride-sensitive result exercises checked packing rather than assuming the
# native output is contiguous. The native oracle records the actual strides.
module = a.Module.create()
with module:
    def transpose_body(x):
        return a.transpose(x, np.asarray([1, 0], dtype=np.uint32))
    transpose_body.__annotations__ = {
        "x": Annotated[a.Value, a.TensorType([2, 3], a.bfloat16)],
        "return": Annotated[a.Value, a.TensorType([3, 2], a.bfloat16, name="y")],
    }
    a.graph(transpose_body, provided_name="main")
model = save_model("transpose", module)
x = np.asarray([1, -2, 0, .5, 100, -.25], dtype=dtype).reshape(2, 3)
cases.append({"name": "transpose", "model": model, "function": "main", "steps": [{
    "inputs": {"x": tensor("transpose/0-x.bin", x)},
    "outputs": {"y": tensor("transpose/0-expected-y.bin", x.T)}}]})

# The public b3 decorator does not author handle I/O. This matches the retained
# v0.1 state fixture's explicit private authoring seam; invocation stays public.
from coreai.authoring.graph_builder import GraphOp
from coreai._compiler.dialects import _coreai_ops_gen as raw
module = a.Module.create()
with module:
    ty = a.TensorType([2, 3], a.bfloat16)._to_mlir()
    handle = a.HandleType(a.TensorType([2, 3], a.bfloat16))._to_mlir()
    token_type = a.TokenType()._to_mlir()
    graph = GraphOp("main", [ty, handle], [ty, token_type], input_names=["x", "accumulator"], result_names=["y", "accumulator"])
    with graph.block:
        x_arg, state_arg = graph.arguments
        token = raw.create_token()
        previous, token = raw.read_handle(state_arg, token)
        token = raw.write_handle(state_arg, raw.add(previous, x_arg), token)
        result, token = raw.read_handle(state_arg, token)
        raw.output([result, token])
model = save_model("accumulator", module)
initial = np.zeros((2, 3), dtype=dtype)
state = initial.copy()
steps = []
for index, x in enumerate([np.ones((2, 3), dtype=dtype), np.full((2, 3), 2, dtype=dtype), np.arange(6, dtype=np.float32).astype(dtype).reshape(2, 3)]):
    state = (state.astype(np.float32) + x.astype(np.float32)).astype(dtype)
    steps.append({"inputs": {"x": tensor(f"accumulator/{index}-x.bin", x)},
                  "outputs": {"y": tensor(f"accumulator/{index}-expected-y.bin", state)},
                  "state_after": {"accumulator": tensor(f"accumulator/{index}-expected-state.bin", state)}})
cases.append({"name": "accumulator", "model": model, "function": "main", "steps": steps,
              "state": {"accumulator": tensor("accumulator/initial-state.bin", initial)}})

all_bits = b"".join(struct.pack("<H", bits) for bits in range(65536))
(directory / "all-encodings.bin").write_bytes(all_bits)
write_json(directory / "manifest.json", {
    "schema": 1, "reference": identity(), "native_executed": False,
    "dtype": "bfloat16", "comparison": "Exact bytes; arithmetic uses finite exactly representable values.",
    "all_encodings": {"file": "all-encodings.bin", "shape": [65536], "count": 65536,
                      "sha256": hashlib.sha256(all_bits).hexdigest(),
                      "purpose": "Raw storage identity only; never NaN arithmetic."},
    "cases": cases,
    "sha256": {str(path.relative_to(directory)): hashlib.sha256(path.read_bytes()).hexdigest()
               for path in sorted(directory.rglob("*")) if path.is_file() and path.name != "manifest.json"},
    "limitations": ["Prepared model/expected bytes do not establish native execution.",
                    "State authoring uses b3 private GraphOp/handle operations, as in v0.1."]})
print(directory)
