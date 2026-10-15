"""Prepare one deterministic CoreAI fixture with cached Apple authoring tools.

Offline preparation only; Corsairs' application runtime never invokes Python.
Run: /Users/zakkeown/.local/bin/python3.12 -I -B build_fixture.py
"""

import hashlib
import importlib.metadata
import json
from pathlib import Path
import platform
import struct
import subprocess
import sys
from typing import Annotated

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
from coreai.authoring import AIProgram, Module, TensorSpec
from coreai._compiler.dialects import coreai
from coreai._compiler.ir import Value

HERE = Path(__file__).resolve().parent
MODEL = HERE / "double_f32_2x3.aimodel"

module = Module.create()
with module:
    @coreai.graph(provided_name="main")
    def main(
        x: Annotated[Value, TensorSpec([2, 3], np.float32, name="x")],
    ) -> Annotated[Value, TensorSpec([2, 3], np.float32, name="y")]:
        return coreai.add(x, x)

module.verify()
(HERE / "double_f32_2x3.mlir").write_text(module.as_string() + "\n")
print(module.as_string(), flush=True)
asset = AIProgram(module).save_asset(MODEL)
print(f"Saved {MODEL}", flush=True)

inputs = [1.0, -2.0, 0.0, 0.5, 100.0, -0.25]
expected = [2.0, -4.0, 0.0, 1.0, 200.0, -0.5]
(HERE / "input.f32le").write_bytes(struct.pack("<6f", *inputs))
(HERE / "expected.f32le").write_bytes(struct.pack("<6f", *expected))
file_digests = {
    str(path.relative_to(HERE)): hashlib.sha256(path.read_bytes()).hexdigest()
    for path in sorted(HERE.rglob("*"))
    if path.is_file() and path.name != "manifest.json"
}
manifest = {
    "model": str(MODEL),
    "function": "main",
    "input_name": "x",
    "output_name": "y",
    "shape": [2, 3],
    "dtype": "float32",
    "inputs": inputs,
    "expected_outputs": expected,
    "expected_basis": "Exact binary32 arithmetic for x + x; no rounding for these values",
    "python_reference_execution": "not yet run",
    "python": sys.version,
    "python_executable": sys.executable,
    "platform": platform.platform(),
    "os_build": subprocess.check_output(["/usr/bin/sw_vers", "-buildVersion"], text=True).strip(),
    "packages": {
        name: importlib.metadata.version(name)
        for name in ["coreai-core", "numpy", "ml-dtypes", "typing-extensions", "pillow", "yuvio", "psutil"]
    },
    "package_roots": PACKAGE_ROOTS,
    "cached_artifact_sha256": {
        relative: hashlib.sha256((Path(PACKAGE_ROOTS[0]) / relative).read_bytes()).hexdigest()
        for relative in [
            "coreai_core-1.0.0b2.dist-info/METADATA",
            "coreai_core-1.0.0b2.dist-info/RECORD",
            "coreai/runtime/_coreai_runtime_os.cpython-312-darwin.so",
            "coreai/runtime/_coreai_runtime.cpython-312-darwin.so",
            "coreai/_compiler/_mlir_libs/_mlir.cpython-312-darwin.so",
        ]
    },
    "sha256": file_digests,
    "limits": [
        "Prepared with cached coreai-core 1.0.0b2, not published parity baseline 1.0.0b3",
        "Original wheel archive hash unavailable; exact cached native library and asset hashes retained",
        "Asset metadata embeds creation time, so repeated builds need not have identical bytes",
    ],
}
(HERE / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
print(json.dumps(manifest, indent=2), flush=True)
