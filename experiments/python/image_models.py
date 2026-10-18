#!/usr/bin/env python3.12
"""Author tiny image-signature models with the pinned b3 package (research only).

Usage: python3.12 -I -B experiments/python/image_models.py OUT_DIR

For each FourCC the b3 authoring API accepts, writes OUT_DIR/NAME/model.aimodel
and graph.mlir, plus OUT_DIR/models.json describing every signature:

- NAME_to_tensor:   image x -> image_to_tensor -> uint8 tensor y
- NAME_from_tensor: uint8 tensor x -> tensor_to_image -> image y
- NAME_identity:    image x -> tensor -> image y
- NAME_invert:      image x -> 255 - tensor -> image y (forces real compute)
- NAME_aligned_to_tensor: as to_tensor, with explicit CVPixelBuffer image
  constraints (64-byte row alignment per plane)
- uint8_invert_tensor: tensor-only 255 - x control for the invert models

Sizes are HEIGHT x WIDTH = 2 x 4, plus an odd 3 x 5 to_tensor case per packed
format and a 16 x 16 to_tensor case for the planar format. Nothing here executes a model.
"""
from pathlib import Path
import json
import sys
from typing import Annotated

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "reference"))
from environment import initialize, identity  # noqa: E402
initialize()
import numpy as np  # noqa: E402
import coreai.authoring as a  # noqa: E402
from coreai.authoring.constraints import ContainerType, ImageConstraints  # noqa: E402
from coreai._compiler._mlir_libs._coreaiIR._bindings.mlir.dialects.coreai import FourCC, FourCCAttr  # noqa: E402

OUT = Path(sys.argv[1]).resolve()
FORMATS = {"RGB24": 1, "ARGB32": 1, "BGRA32": 1, "YpCbCr8420Planar": 3}
MODELS = []


def tensor_shape(fourcc, height, width):
    # Matches the ImageToTensorOp documentation; checked by the verifier below.
    return {"RGB24": [height, width, 3], "ARGB32": [height, width, 4], "BGRA32": [height, width, 4],
            "YpCbCr8420Planar": [height * width + 2 * (height // 2) * (width // 2)]}[fourcc]


def image(fourcc, height, width, name, constraints=None):
    return Annotated[a.Value, a.ImageType(getattr(FourCC, fourcc), height, width, name=name,
                                          constraints=constraints)]


def tensor(shape, name=None):
    return Annotated[a.Value, a.TensorType(shape, a.uint8, name=name)]


def build(name, annotations, operation, signature):
    module = a.Module.create()
    try:
        with module:
            def body(x):
                return operation(x)
            body.__annotations__ = annotations
            a.graph(body, provided_name="main")
        module.verify()
        directory = OUT / name
        directory.mkdir(parents=True, exist_ok=True)
        (directory / "graph.mlir").write_text(module.as_string() + "\n")
        a.AIProgram(module).save_asset(directory / "model.aimodel")
        MODELS.append({"name": name, "model": f"{name}/model.aimodel", "authored": True, **signature,
                       "graph": module.as_string()})
        print(f"built {name}", flush=True)
    except Exception as error:  # Record authoring rejections as evidence.
        MODELS.append({"name": name, "authored": False, "error_type": type(error).__name__,
                       "error": str(error), **signature})
        print(f"rejected {name}: {type(error).__name__}: {error}", flush=True)


for fourcc, planes in FORMATS.items():
    for height, width in [(2, 4)] + ([(3, 5)] if planes == 1 else [(16, 16)]):
        suffix = "" if (height, width) == (2, 4) else f"_{height}x{width}"
        shape = tensor_shape(fourcc, height, width)
        img = {"fourcc": fourcc, "height": height, "width": width}
        build(f"{fourcc}_to_tensor{suffix}", {"x": image(fourcc, height, width, "x"), "return": tensor(shape, "y")},
              a.image_to_tensor, {"inputs": {"x": {"image": img}}, "outputs": {"y": {"tensor": shape}}})
        if suffix:
            continue
        result = a.ImageType(getattr(FourCC, fourcc), height, width, name="y")
        build(f"{fourcc}_from_tensor", {"x": tensor(shape), "return": image(fourcc, height, width, "y")},
              lambda x, result=result: a.tensor_to_image(result, x),
              {"inputs": {"x": {"tensor": shape}}, "outputs": {"y": {"image": img}}})
        build(f"{fourcc}_identity", {"x": image(fourcc, height, width, "x"), "return": image(fourcc, height, width, "y")},
              lambda x, result=result: a.tensor_to_image(result, a.image_to_tensor(x)),
              {"inputs": {"x": {"image": img}}, "outputs": {"y": {"image": img}}})
        build(f"{fourcc}_invert", {"x": image(fourcc, height, width, "x"), "return": image(fourcc, height, width, "y")},
              lambda x, result=result: a.tensor_to_image(
                  result, a.sub(np.full(shape, 255, dtype=np.uint8), a.image_to_tensor(x))),
              {"inputs": {"x": {"image": img}}, "outputs": {"y": {"image": img}}})
        constraints = ImageConstraints(backing=ContainerType.CVPixelBuffer, row_alignments_per_plane=[64] * planes)
        build(f"{fourcc}_aligned_to_tensor",
              {"x": image(fourcc, height, width, "x", constraints), "return": tensor(shape, "y")},
              a.image_to_tensor, {"inputs": {"x": {"image": {**img, "row_alignment": 64}}},
                                  "outputs": {"y": {"tensor": shape}}})

# Tensor-only control: the same 255 - x on uint8 without any image value, to
# separate backend integer arithmetic from image conversion.
build("uint8_invert_tensor", {"x": tensor([2, 4, 4]), "return": tensor([2, 4, 4], "y")},
      lambda x: a.sub(np.full([2, 4, 4], 255, dtype=np.uint8), x),
      {"inputs": {"x": {"tensor": [2, 4, 4]}}, "outputs": {"y": {"tensor": [2, 4, 4]}}})



def fourcc_probe():
    """Map every FourCC enum case to its raw OSType; try raw values outside it."""
    rows = []
    for name in [m for m in dir(FourCC) if not m.startswith("_")]:
        module = a.Module.create()
        with module:
            attr = FourCCAttr(FourCCAttr.get_enum(enum_value=getattr(FourCC, name)))
            row = {"enum": name, "raw_value": attr.raw_value, "attr": str(attr)}
        # Unknown is accepted by the verifier with a flat height*width tensor.
        if name == "Unknown":
            module = a.Module.create()
            try:
                with module:
                    def body(x):
                        return a.image_to_tensor(x)
                    body.__annotations__ = {"x": image(name, 2, 4, "x"), "return": tensor([8], "y")}
                    a.graph(body, provided_name="main")
                module.verify()
                row["verified_to_tensor"] = module.as_string()
            except Exception as error:
                row["verify_error"] = f"{type(error).__name__}: {error}"
        rows.append(row)
    for raw in [0x4C303038, 0x52476641]:  # 'L008' OneComponent8, 'RGfA' 64RGBAHalf
        module = a.Module.create()
        try:
            with module:
                rows.append({"raw": hex(raw), "attr": str(FourCCAttr(FourCCAttr.get_raw(raw_value=raw)))})
        except Exception as error:
            rows.append({"raw": hex(raw), "error": f"{type(error).__name__}: {error}"})
    return rows


(OUT / "models.json").write_text(json.dumps({"reference": identity(), "fourcc": fourcc_probe(),
                                             "models": MODELS}, indent=2) + "\n")
print(f"{sum(m['authored'] for m in MODELS)} of {len(MODELS)} models authored in {OUT}")
