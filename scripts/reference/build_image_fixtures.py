#!/usr/bin/env python3
"""Author v0.5 image fixtures with the pinned b3 package; never execute a model.

Writes fixtures/parity-v05/images: one asset per case, tight input and expected
payloads, and suite.json. Image payloads are CoreVideo memory order with tight
rows (RGB24: R,G,B; ARGB32: A,R,G,B; BGRA32: B,G,R,A). Input bytes use the
deterministic pattern of experiments/swift/ImageReference.swift, so the Swift
oracle and b3 see the same pixels. Expected bytes are the analytic result
(conversions copy bytes; invert is 255 - x); goldens are frozen separately by
freeze_image_goldens.py from reference runs.

    python3.12 -I -B scripts/reference/build_image_fixtures.py
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
from coreai.authoring.constraints import ContainerType, ImageConstraints
from coreai._compiler._mlir_libs._coreaiIR._bindings.mlir.dialects.coreai import FourCC

DIRECTORY = ROOT / "fixtures/parity-v05/images"
FORMATS = {"RGB24": (24, 3), "ARGB32": (32, 4), "BGRA32": (0x42475241, 4)}
PLANAR = ("YpCbCr8420Planar", 0x79343230)
BACKENDS = ["cpu", "gpu-preferred", "neural-engine-preferred"]
CASES, NEGATIVES = [], []


def pattern(width, height, channels):
    """ImageReference.swift `pattern` for plane 0; never 0 or 255."""
    return bytes(1 + (y * 37 + x * 11 + c * 3) % 253
                 for y in range(height) for x in range(width) for c in range(channels))


def payload(case, label, data):
    path = DIRECTORY / case / f"{label}.bin"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    return {"file": str(path.relative_to(DIRECTORY)), "sha256": hashlib.sha256(data).hexdigest()}


def image_value(case, label, fourcc, width, height, data):
    os_type, bpp = FORMATS[fourcc]
    assert len(data) == width * height * bpp
    return {"image": {"format": fourcc, "os_type": os_type, "width": width, "height": height,
                      **payload(case, label, data)}}


def tensor_value(case, label, shape, data):
    return {"tensor": {"dtype": "uint8", "shape": list(shape), **payload(case, label, data)}}


def image_type(fourcc, height, width, name, constraints=None):
    return Annotated[a.Value, a.ImageType(getattr(FourCC, fourcc), height, width, name=name,
                                          constraints=constraints)]


def tensor_type(shape, name):
    return Annotated[a.Value, a.TensorType(list(shape), a.uint8, name=name)]


def author(name, annotations, operation):
    # b3 reads parameter names from the function, so single-input operations
    # (lambdas that capture defaults) are wrapped in a function of x alone.
    if list(annotations) == ["x", "return"]:
        def body(x):
            return operation(x)
    else:
        body = operation
    module = a.Module.create()
    with module:
        body.__annotations__ = annotations
        a.graph(body, provided_name="main")
    module.verify()
    directory = DIRECTORY / name
    directory.mkdir(parents=True, exist_ok=True)
    (directory / "graph.mlir").write_text(module.as_string() + "\n")
    a.AIProgram(module).save_asset(directory / "model.aimodel")
    print(f"Built {name}", flush=True)
    return f"{name}/model.aimodel"


def case(name, annotations, body, inputs, outputs, *, comparison="exact", notes=()):
    CASES.append({"name": name, "model": author(name, annotations, body), "function": "main",
                  "inputs": inputs, "outputs": outputs, "comparison": comparison, "notes": list(notes)})


def packed_cases(fourcc):
    _, bpp = FORMATS[fourcc]
    for height, width, suffix in [(2, 4, ""), (3, 5, "_3x5")]:
        shape = [height, width, bpp]
        pixels = pattern(width, height, bpp)
        result = a.ImageType(getattr(FourCC, fourcc), height, width, name="y")
        name = f"{fourcc}_to_tensor{suffix}"
        case(name, {"x": image_type(fourcc, height, width, "x"), "return": tensor_type(shape, "y")},
             lambda x: a.image_to_tensor(x),
             {"x": image_value(name, "x", fourcc, width, height, pixels)},
             {"y": tensor_value(name, "expected-y", shape, pixels)})
        name = f"{fourcc}_identity{suffix}"
        case(name, {"x": image_type(fourcc, height, width, "x"), "return": image_type(fourcc, height, width, "y")},
             lambda x, result=result: a.tensor_to_image(result, a.image_to_tensor(x)),
             {"x": image_value(name, "x", fourcc, width, height, pixels)},
             {"y": image_value(name, "expected-y", fourcc, width, height, pixels)})
        if suffix:
            continue
        name = f"{fourcc}_from_tensor"
        case(name, {"x": tensor_type(shape, "x"), "return": image_type(fourcc, height, width, "y")},
             lambda x, result=result: a.tensor_to_image(result, x),
             {"x": tensor_value(name, "x", shape, pixels)},
             {"y": image_value(name, "expected-y", fourcc, width, height, pixels)})
        constraints = ImageConstraints(backing=ContainerType.CVPixelBuffer, row_alignments_per_plane=[64])
        name = f"{fourcc}_aligned_to_tensor"
        case(name, {"x": image_type(fourcc, height, width, "x", constraints), "return": tensor_type(shape, "y")},
             lambda x: a.image_to_tensor(x),
             {"x": image_value(name, "x", fourcc, width, height, pixels)},
             {"y": tensor_value(name, "expected-y", shape, pixels)},
             notes=["CVPixelBuffer constraint with 64-byte row alignment"])
        name = f"{fourcc}_invert"
        case(name, {"x": image_type(fourcc, height, width, "x"), "return": image_type(fourcc, height, width, "y")},
             lambda x, result=result, shape=shape: a.tensor_to_image(
                 result, a.sub(np.full(shape, 255, dtype=np.uint8), a.image_to_tensor(x))),
             {"x": image_value(name, "x", fourcc, width, height, pixels)},
             {"y": image_value(name, "expected-y", fourcc, width, height, bytes(255 - b for b in pixels))},
             comparison="reviewed-backend-digest",
             notes=["uint8 255 - x; Neural Engine preference returns all 255 (backend arithmetic, "
                    "reproduced by a tensor-only control in docs/evidence/v0.5/image-swift-oracle.json)"])


for fourcc in FORMATS:
    packed_cases(fourcc)

# Tensor and image values in one signature, crossing kinds both ways.
pixels, tensor_bytes = pattern(4, 2, 4), bytes(reversed(pattern(4, 2, 4)))
case("mixed_bgra32",
     {"x": image_type("BGRA32", 2, 4, "x"), "t": tensor_type([2, 4, 4], "t"),
      "return": tuple[image_type("BGRA32", 2, 4, "y"), tensor_type([2, 4, 4], "z")]},
     lambda x, t: (a.tensor_to_image(a.ImageType(FourCC.BGRA32, 2, 4, name="y"), t), a.image_to_tensor(x)),
     {"x": image_value("mixed_bgra32", "x", "BGRA32", 4, 2, pixels),
      "t": tensor_value("mixed_bgra32", "t", [2, 4, 4], tensor_bytes)},
     {"y": image_value("mixed_bgra32", "expected-y", "BGRA32", 4, 2, tensor_bytes),
      "z": tensor_value("mixed_bgra32", "expected-z", [2, 4, 4], pixels)},
     notes=["two inputs and two outputs; the Swift oracle handles only one of each, so b3 freezes it"])

# Planar 4:2:0 traps Core AI (ImageUtils.swift:91). Corsairs must load the
# function, report the raw OSType, and reject every run before dispatch.
height, width = 2, 4
planar = author(f"{PLANAR[0]}_to_tensor", {
    "x": image_type(PLANAR[0], height, width, "x"),
    "return": tensor_type([height * width + 2 * (height // 2) * (width // 2)], "y")},
    lambda x: a.image_to_tensor(x))
NEGATIVES.append({"name": "planar_420_run", "model": planar, "never_execute": True,
                  "descriptor": {"x": {"os_type": PLANAR[1], "width": width, "height": height}},
                  "images": {"x": {"format": "BGRA32", "width": 4, "height": 2}},
                  "expected_error": "Unsupported"})
NEGATIVES.append({"name": "planar_420_run_without_images", "model": planar, "never_execute": True,
                  "images": {}, "expected_error": "Unsupported"})
# Request errors on a packed model, all rejected before dispatch.
identity_model = "BGRA32_identity/model.aimodel"
for name, images, error in [
    ("wrong_format", {"x": {"format": "ARGB32", "width": 4, "height": 2}}, "DescriptorMismatch"),
    ("wrong_size", {"x": {"format": "BGRA32", "width": 6, "height": 2}}, "DescriptorMismatch"),
    ("transposed_size", {"x": {"format": "BGRA32", "width": 2, "height": 4}}, "DescriptorMismatch"),
    ("missing_image", {}, "MissingTensor"),
    ("unexpected_image", {"x": {"format": "BGRA32", "width": 4, "height": 2},
                          "extra": {"format": "BGRA32", "width": 4, "height": 2}}, "UnexpectedTensor"),
]:
    NEGATIVES.append({"name": name, "model": identity_model, "images": images, "expected_error": error})

write_json(DIRECTORY / "suite.json", {
    "schema": 1, "reference": identity(), "native_executed": False, "backends": BACKENDS,
    "pattern": "1 + (y * 37 + x * 11 + c * 3) % 253, tight rows, CoreVideo memory order",
    "formats": {name: {"os_type": os_type, "bytes_per_pixel": bpp} for name, (os_type, bpp) in FORMATS.items()},
    "cases": CASES, "negatives": NEGATIVES})
print(f"{len(CASES)} cases and {len(NEGATIVES)} negatives in {DIRECTORY}")
