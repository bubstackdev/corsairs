"""Execute prepared fixture using the exact cached published Python API."""
import asyncio
import hashlib
import json
from pathlib import Path
import sys

PACKAGE_ROOTS = [
    "/Users/zakkeown/.cache/uv/archive-v0/LBs_td0hqU20OP4_",
    "/Users/zakkeown/.cache/uv/archive-v0/DhD_Ey_vrIsX1X33",
    "/Users/zakkeown/.cache/uv/archive-v0/EGNgvXto1myrK9QG",
    "/Users/zakkeown/.cache/uv/archive-v0/qIlLwKwPLBB3seBO",
    "/Users/zakkeown/.cache/uv/archive-v0/Z3Unk8ytqsnf75ew",
    "/Users/zakkeown/.cache/uv/archive-v0/xmyuyphpTmMgbH8w",
    "/Users/zakkeown/.cache/uv/archive-v0/6nwX0VHcZt1XHq5g",
]
sys.path[:0] = PACKAGE_ROOTS

import numpy as np
from coreai.runtime import AIModel, NDArray, SpecializationOptions, _use_os_coreai

HERE = Path(__file__).resolve().parent

async def main():
    print(f"OS-backed extension: {_use_os_coreai}", flush=True)
    model = await AIModel.load(HERE / "double_f32_2x3.aimodel", SpecializationOptions.cpu_only())
    print(f"Functions: {model.function_names}", flush=True)
    function = model.load_function("main")
    print(f"Descriptor: {function.desc}", flush=True)
    input_values = np.frombuffer((HERE / "input.f32le").read_bytes(), dtype=np.float32).reshape(2, 3).copy()
    input_tensor = NDArray(input_values)
    outputs = await function(inputs={"x": input_tensor})
    assert list(outputs) == ["y"], outputs
    output = outputs["y"]
    values = output.numpy()
    actual = values.astype("<f4", copy=False).tobytes(order="C")
    expected = (HERE / "expected.f32le").read_bytes()
    result = {
        "model_functions": model.function_names,
        "os_backed": _use_os_coreai,
        "specialization": "cpu_only",
        "input_shape": list(input_tensor.shape),
        "input_dtype": input_tensor.dtype,
        "output_shape": list(output.shape),
        "output_dtype": output.dtype,
        "output_strides": list(output.strides),
        "values": values.tolist(),
        "actual_sha256": hashlib.sha256(actual).hexdigest(),
        "expected_sha256": hashlib.sha256(expected).hexdigest(),
        "exact_bytes_match": actual == expected,
    }
    (HERE / "python-reference.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2), flush=True)
    assert list(output.shape) == [2, 3]
    assert output.dtype == "float32"
    assert actual == expected

asyncio.run(main())
