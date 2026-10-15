#!/usr/bin/env python3
"""Build deterministic assets and independent NumPy expected byte sequences."""
from pathlib import Path
import hashlib
import sys
from typing import Annotated

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import FIXTURES, initialize, identity, write_json
initialize()
import numpy as np
import coreai.authoring as a

CASES = []


def tensor_file(directory, label, value):
    value = np.asarray(value)
    path = directory / f"{label}.bin"
    payload = value.astype(value.dtype.newbyteorder("<"), copy=False).tobytes(order="C")
    path.write_bytes(payload)
    return {"file": str(path.relative_to(FIXTURES)), "shape": list(value.shape),
            "dtype": value.dtype.name, "strides": [s // value.itemsize for s in value.strides],
            "sha256": hashlib.sha256(payload).hexdigest()}


def add_case(name, category, inputs, expected, operation, *, policy="exact", state=None, notes=None):
    directory = FIXTURES / name
    directory.mkdir(parents=True, exist_ok=True)
    module = a.Module.create()
    with module:
        # The pinned public decorator inspects a concrete function signature.
        if len(inputs) == 1:
            def body(x):
                return operation(x)
            body.__annotations__ = {"x": Annotated[a.Value, a.TensorType(inputs["x"].shape, inputs["x"].dtype.type)]}
        else:
            def body(x, addend):
                return operation(x, addend)
            body.__annotations__ = {
                key: Annotated[a.Value, a.TensorType(value.shape, value.dtype.type)]
                for key, value in inputs.items()
            }
        body.__annotations__["return"] = Annotated[a.Value, a.TensorType(expected.shape, expected.dtype.type, name="y")]
        a.graph(body, provided_name="main")
    module.verify()
    (directory / "graph.mlir").write_text(module.as_string() + "\n")
    model = directory / "model.aimodel"
    a.AIProgram(module).save_asset(model)
    CASES.append({"name": name, "category": category, "model": str(model.relative_to(FIXTURES)),
                  "function": "main", "inputs": {key: tensor_file(directory, key, value) for key, value in inputs.items()},
                  "outputs": {"y": tensor_file(directory, "expected-y", expected)}, "comparison": policy,
                  "notes": notes or [], "state": state or {}})
    print(f"Built {name}", flush=True)


base = [1, -2, 0, 0.5, 100, -0.25]
for dtype in [np.float16, np.float32, np.int32, np.int64]:
    x = np.array(base if np.issubdtype(dtype, np.floating) else [1, -2, 0, 17, 100, -25], dtype=dtype).reshape(2, 3)
    add_case(f"double_{np.dtype(dtype).name}", "arithmetic", {"x": x}, x + x, lambda x: a.add(x, x))
x = np.array([[True, False, True], [False, False, True]], dtype=np.bool_)
add_case("not_bool", "arithmetic", {"x": x}, np.logical_not(x), a.not_)
x = np.array([[1, -2, 3], [0, 5, -1]], dtype=np.float32)
w = np.array([[1, 2], [3, -1], [2, 0]], dtype=np.float32)
add_case("matmul", "matmul", {"x": x}, x @ w, lambda x: a.batch_matmul(x, w))
add_case("reduce_sum", "reduction", {"x": x}, np.sum(x, axis=1, dtype=np.float32, keepdims=True),
         lambda x: a.reduce_sum(x, np.array([1], dtype=np.int32)))
indices = np.array([[2, 0], [1, 2]], dtype=np.int32)
add_case("gather", "indexing", {"x": x}, np.take_along_axis(x, indices, axis=1),
         lambda x: a.gather_along_axis(x, indices, np.array(1, dtype=np.int32)))
add_case("reshape", "shape", {"x": x}, x.reshape(3, 2),
         lambda x: a.reshape(x, np.array([3, 2], dtype=np.int32)))
w1 = np.array([[1, -1, 2, 0], [0, 2, 1, -1], [-1, 0, 1, 1]], dtype=np.float32)
b1 = np.array([1, -2, 0, 3], dtype=np.float32)
w2 = np.array([[1, 2], [-1, 0], [2, -1], [0, 1]], dtype=np.float32)
add_case("feedforward", "feedforward", {"x": x}, np.maximum(x @ w1 + b1, 0) @ w2,
         lambda x: a.batch_matmul(a.relu(a.broadcasting_add(a.batch_matmul(x, w1), b1)), w2))
add_case("named_add", "named-inputs", {"x": x, "addend": x + 1}, x + x + 1, a.add)
edge = np.array([0, 0x80000000, 0x7f800000, 0xff800000, 0x7fc12345, 1], dtype=np.uint32).view(np.float32).reshape(2, 3)
with np.errstate(invalid="ignore"):
    add_case("float_edges", "edge-values", {"x": edge}, edge + edge, lambda x: a.add(x, x), policy="ieee-special",
             notes=["NaN payload equality is not required; NaN class, infinities, signed zero and finite results are checked separately."])
wide = np.array([2**53 + 1, -(2**53 + 1), 0, 2**62 - 1, -2**62, -7], dtype=np.int64).reshape(2, 3)
add_case("int64_edges", "edge-values", {"x": wide}, wide + wide, lambda x: a.add(x, x))
scalar = np.array(3.5, dtype=np.float32)
add_case("scalar", "boundary-shape", {"x": scalar}, scalar + scalar, lambda x: a.add(x, x))
empty = np.empty((0, 3), dtype=np.float32)
add_case("empty", "boundary-shape", {"x": empty}, empty + empty, lambda x: a.add(x, x),
         notes=["Boundary probe: reference rejection is retained as an unsupported shape outcome, not success."])

# State handle authoring is an explicit private seam: b3's public decorator only
# accepts TensorType/ImageType annotations and exports no handle I/O operations.
from coreai.authoring.graph_builder import GraphOp
from coreai._compiler.dialects import _coreai_ops_gen as raw
directory = FIXTURES / "accumulator"
directory.mkdir(parents=True, exist_ok=True)
module = a.Module.create()
with module:
    ty = a.TensorType([2, 3], a.float32)._to_mlir()
    handle = a.HandleType(a.TensorType([2, 3], a.float32))._to_mlir()
    token_type = a.TokenType()._to_mlir()
    graph = GraphOp("main", [ty, handle], [ty, token_type], input_names=["x", "accumulator"], result_names=["y", "accumulator"])
    with graph.block:
        x_arg, state_arg = graph.arguments
        token = raw.create_token()
        previous, token = raw.read_handle(state_arg, token)
        updated = raw.add(previous, x_arg)
        token = raw.write_handle(state_arg, updated, token)
        result, token = raw.read_handle(state_arg, token)
        raw.output([result, token])
module.verify()
(directory / "graph.mlir").write_text(module.as_string() + "\n")
a.AIProgram(module).save_asset(directory / "model.aimodel")
initial = np.zeros((2, 3), dtype=np.float32)
running = initial.copy()
steps = []
for step, values in enumerate([np.ones((2, 3), dtype=np.float32), np.full((2, 3), 2, dtype=np.float32), np.arange(6, dtype=np.float32).reshape(2, 3)]):
    running = running + values
    steps.append({"inputs": {"x": tensor_file(directory, f"step{step}-x", values)},
                  "outputs": {"y": tensor_file(directory, f"step{step}-expected-y", running)},
                  "state_after": {"accumulator": tensor_file(directory, f"step{step}-expected-state", running)}})
CASES.append({"name": "accumulator", "category": "named-state", "model": "accumulator/model.aimodel", "function": "main",
              "inputs": steps[0]["inputs"], "outputs": steps[0]["outputs"], "comparison": "exact",
              "state": {"accumulator": tensor_file(directory, "initial-state", initial)}, "steps": steps,
              "notes": ["State fixture uses b3 private raw GraphOp/read_handle/write_handle/create_token authoring; runtime invocation uses published API."]})

digests = {str(path.relative_to(FIXTURES)): hashlib.sha256(path.read_bytes()).hexdigest()
           for path in sorted(FIXTURES.rglob("*")) if path.is_file() and (path.suffix in [".mlir", ".bin"] or ".aimodel" in str(path))}
write_json(FIXTURES / "suite.json", {"schema": 1, "reference": identity(), "cases": CASES, "sha256": digests,
    "negative_cases": ["missing_asset", "missing_function", "missing_input", "unknown_input", "wrong_shape", "wrong_dtype", "missing_state", "wrong_state_shape"],
    "limitations": ["CPU-only and GPU-preferred are preferences; actual delegated backend must be recorded separately.",
                    "Prepared models and NumPy expectations are not Rust parity evidence until native reference and Rust differential runs pass."]})
print(f"Built {len(CASES)} fixtures into {FIXTURES}", flush=True)
