#!/usr/bin/env python3
"""Author v0.4 scalar-type fixtures with the pinned b3 package; never execute a model.

Writes fixtures/parity-v04/scalar-types/suite.json in run_suite.py's format, so
the existing reference runner, freezer and Rust parity drivers apply unchanged.
"""
from pathlib import Path
import hashlib
import sys
from typing import Annotated

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import ROOT, initialize, identity, write_json
initialize()
import numpy as np
import coreai.authoring as a

DIRECTORY = ROOT / "fixtures/parity-v04/scalar-types"
INTEGERS = {"int8": np.int8, "int16": np.int16, "uint8": np.uint8,
            "uint16": np.uint16, "uint32": np.uint32, "uint64": np.uint64}
CASES = []


def tensor(name, label, value):
    # ascontiguousarray would promote rank-0 values to shape [1].
    value = np.array(value, order="C", copy=True)
    path = DIRECTORY / name / f"{label}.bin"
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = value.astype(value.dtype.newbyteorder("<"), copy=False).tobytes(order="C")
    path.write_bytes(payload)
    return {"file": str(path.relative_to(DIRECTORY)), "shape": list(value.shape),
            "dtype": value.dtype.name, "strides": [s // value.itemsize for s in value.strides],
            "sha256": hashlib.sha256(payload).hexdigest()}


def case(name, x, expected, operation, *, notes=()):
    module = a.Module.create()
    with module:
        def body(x):
            return operation(x)
        body.__annotations__ = {
            "x": Annotated[a.Value, a.TensorType(list(x.shape), getattr(a, x.dtype.name))],
            "return": Annotated[a.Value, a.TensorType(list(expected.shape), getattr(a, x.dtype.name), name="y")],
        }
        a.graph(body, provided_name="main")
    module.verify()
    directory = DIRECTORY / name
    directory.mkdir(parents=True, exist_ok=True)
    (directory / "graph.mlir").write_text(module.as_string() + "\n")
    a.AIProgram(module).save_asset(directory / "model.aimodel")
    CASES.append({"name": name, "category": "scalar-types", "model": f"{name}/model.aimodel",
                  "function": "main", "inputs": {"x": tensor(name, "x", x)},
                  "outputs": {"y": tensor(name, "expected-y", expected)}, "comparison": "exact",
                  "notes": list(notes), "state": {}})
    print(f"Built {name}", flush=True)


def double(x):
    return a.add(x, x)


def transpose(x):
    return a.transpose(x, np.asarray([1, 0], dtype=np.uint32))


for name, dtype in INTEGERS.items():
    info = np.iinfo(dtype)
    signed = info.min < 0
    small = np.array([1, -2, 0, 17, 50, -25] if signed else [1, 2, 0, 17, 50, 25], dtype=dtype).reshape(2, 3)
    case(f"{name}_double", small, small + small, double)
    case(f"{name}_scalar", np.array(7, dtype=dtype), np.array(14, dtype=dtype), double)
    case(f"{name}_empty", np.zeros((0, 3), dtype=dtype), np.zeros((0, 3), dtype=dtype), double)
    extremes = np.array([info.min, info.max, 0, 1, info.max - 1, info.min + 1 if signed else 2],
                        dtype=dtype).reshape(2, 3)
    case(f"{name}_transpose", extremes, extremes.T, transpose,
         notes=["Storage identity of each type's extremes through a stride-changing layout."])
    with np.errstate(over="ignore"):
        wrapped = extremes + extremes
    case(f"{name}_wrap", extremes, wrapped, double,
         notes=["Math expectation is two's-complement wrapping; backends may saturate instead."])

x = np.array([1, -2, 0, 0.5, 1e300, -0.25], dtype=np.float64).reshape(2, 3)
case("float64_double", x, x + x, double)
case("float64_scalar", np.array(3.5), np.array(7.0), double)
case("float64_empty", np.zeros((0, 3)), np.zeros((0, 3)), double)
extremes = np.array([np.finfo(np.float64).max, -np.finfo(np.float64).max, 5e-324,
                     -0.0, np.inf, np.finfo(np.float64).tiny]).reshape(2, 3)
case("float64_transpose", extremes, extremes.T, transpose,
     notes=["Storage identity of float64 extremes, including the minimum subnormal."])
edges = np.array([0x0, 0x8000000000000000, 0x7ff0000000000000, 0xfff0000000000000,
                  0x7ff8000000012345, 0x1], dtype=np.uint64).view(np.float64).reshape(2, 3)
with np.errstate(invalid="ignore"):
    case("float64_edges", edges, edges + edges, double,
         notes=["Signed zeros, infinities, a NaN payload and the minimum subnormal under x + x."])

write_json(DIRECTORY / "suite.json", {
    "schema": 1, "reference": identity(), "native_executed": False, "cases": CASES, "negative_cases": [],
    "sha256": {str(path.relative_to(DIRECTORY)): hashlib.sha256(path.read_bytes()).hexdigest()
               for path in sorted(DIRECTORY.rglob("*")) if path.is_file()
               and path.name not in {"suite.json", "backend-goldens.json"}
               and not path.name.startswith("python-results") and "results" not in path.parts
               and "goldens" not in path.parts},
    "limitations": ["Prepared models and expected bytes do not establish native execution.",
                    "Expected bytes are NumPy arithmetic; backend observations are frozen separately."]})
print(f"{len(CASES)} cases in {DIRECTORY}")
