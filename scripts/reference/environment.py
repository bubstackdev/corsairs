"""Pinned Python reference imports; never used by the Rust production runtime."""
from pathlib import Path
import hashlib
import importlib.metadata
import importlib.util
import json
import os
import sys

ROOT = Path(__file__).resolve().parents[2]
# Children inherit the override, so one runner serves several fixture suites.
FIXTURES = Path(os.environ.get("CORSAIRS_REFERENCE_FIXTURES", ROOT / "fixtures" / "parity-v01")).resolve()
WHEEL_NAME = "coreai_core-1.0.0b3-cp312-cp312-macosx_26_0_arm64.whl"
WHEEL_SHA256 = "8db70074eb049b0a86bd263e137ea173f3298f7f1b60ec1a7f7c592f4c26c4a9"
REFERENCE = ROOT / ".local" / "reference"
DEPENDENCIES = {"numpy": "2.3.5", "ml_dtypes": "0.6.0", "typing_extensions": "4.16.0",
                "pillow": "12.3.0", "yuvio": "1.6", "psutil": "7.2.2"}
PACKAGE_ROOTS = [REFERENCE / "coreai-b3"]


def dependency_roots():
    """Prefer installed pinned dependencies, otherwise read existing uv caches."""
    roots = []
    for distribution, version in DEPENDENCIES.items():
        try:
            if importlib.metadata.version(distribution) == version:
                continue
        except importlib.metadata.PackageNotFoundError:
            pass
        cache = Path.home() / ".cache" / "uv" / "archive-v0"
        matches = sorted(cache.glob(f"*/{distribution}-{version}.dist-info"))
        for info in matches:
            wheel = (info / "WHEEL").read_text()
            if any(tag in wheel for tag in ["cp312", "abi3", "py3-none-any", "py2.py3-none-any"]):
                roots.append(info.parent)
                break
        else:
            raise RuntimeError(f"Install reference-only dependency {distribution}=={version} in a CPython 3.12 virtual environment")
    return roots


def initialize():
    if sys.version_info[:2] != (3, 12):
        raise RuntimeError("The pinned reference wheel requires CPython 3.12")
    wheel = REFERENCE / "wheels" / WHEEL_NAME
    if not wheel.exists() or hashlib.sha256(wheel.read_bytes()).hexdigest() != WHEEL_SHA256:
        raise RuntimeError("Run scripts/reference/acquire.py before the reference suite")
    if len(PACKAGE_ROOTS) == 1:
        PACKAGE_ROOTS.extend(dependency_roots())
    sys.path[:0] = [str(path) for path in PACKAGE_ROOTS]
    if importlib.metadata.version("coreai-core") != "1.0.0b3":
        raise RuntimeError("Reference distribution is not coreai-core 1.0.0b3")


def identity():
    return {
        "coreai_core": "1.0.0b3",
        "wheel_filename": WHEEL_NAME,
        "wheel_sha256": WHEEL_SHA256,
        "python": sys.version,
        "executable": sys.executable,
        "dependencies": {
            name: importlib.metadata.version(name)
            for name in ["numpy", "ml-dtypes", "pillow", "typing-extensions", "yuvio", "psutil"]
        },
        "package_roots": [str(path) for path in PACKAGE_ROOTS],
    }


def write_json(path, obj):
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    Path(path).write_text(json.dumps(obj, indent=2, allow_nan=False) + "\n")
