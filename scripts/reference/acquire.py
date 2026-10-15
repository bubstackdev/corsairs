#!/usr/bin/env python3
"""Download and verify the pinned published wheel without installing globally."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import zipfile

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import FIXTURES, REFERENCE, WHEEL_NAME, WHEEL_SHA256, write_json

URL = "https://files.pythonhosted.org/packages/40/af/4a807a56030a2fe3cf18a83dae6a5871fcb89f9831e1e9e32b0ac30832db/" + WHEEL_NAME
wheel = REFERENCE / "wheels" / WHEEL_NAME
wheel.parent.mkdir(parents=True, exist_ok=True)
if not wheel.exists():
    # An explicit --resolve can work around local DNS failures while keeping TLS
    # certificate verification and the published SHA256 verification intact.
    args = ["curl", "-fL", "--max-time", "60"]
    if "--cdn-address" in sys.argv:
        address = sys.argv[sys.argv.index("--cdn-address") + 1]
        args += ["--resolve", f"files.pythonhosted.org:443:{address}"]
    subprocess.run(args + [URL, "-o", str(wheel)], check=True)
actual = hashlib.sha256(wheel.read_bytes()).hexdigest()
if actual != WHEEL_SHA256:
    raise RuntimeError(f"Wheel SHA256 mismatch: {actual}")
with zipfile.ZipFile(wheel) as archive:
    archive.extractall(REFERENCE / "coreai-b3")
write_json(FIXTURES / "reference-lock.json", {
    "distribution": "coreai-core",
    "version": "1.0.0b3",
    "filename": WHEEL_NAME,
    "url": URL,
    "size": wheel.stat().st_size,
    "sha256": actual,
    "digest_source": "https://pypi.org/pypi/coreai-core/1.0.0b3/json",
    "license": "BSD-3-Clause",
})
print(f"Verified {wheel}: {actual}")
