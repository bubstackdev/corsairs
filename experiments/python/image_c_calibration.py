#!/usr/bin/env python3
"""Record the C lowering of every CoreVideo call the image binding makes.

Usage: python3 -B experiments/python/image_c_calibration.py OUT.json

Compiles experiments/c/CoreVideoReference.c to LLVM IR, extracts each callee's
declaration, and checks that CoreVideo.tbd exports it. Writes only OUT.json and
target/images-reference/.
"""
from pathlib import Path
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / "target/images-reference"
SYMBOLS = ["CVPixelBufferCreate", "CVPixelBufferLockBaseAddress", "CVPixelBufferUnlockBaseAddress",
           "CVPixelBufferGetBaseAddress", "CVPixelBufferGetBytesPerRow", "CVPixelBufferGetWidth",
           "CVPixelBufferGetHeight", "CVPixelBufferGetPixelFormatType", "CVPixelBufferIsPlanar",
           "CVPixelBufferGetDataSize", "CVPixelBufferRetain", "CVPixelBufferRelease"]


def main():
    BUILD.mkdir(parents=True, exist_ok=True)
    ir = BUILD / "corevideo.ll"
    subprocess.run(["xcrun", "clang", "-O1", "-S", "-emit-llvm", str(ROOT / "experiments/c/CoreVideoReference.c"),
                    "-o", str(ir)], check=True)
    text = ir.read_text()
    sdk = subprocess.run(["xcrun", "--show-sdk-path"], capture_output=True, text=True, check=True).stdout.strip()
    tbd = (Path(sdk) / "System/Library/Frameworks/CoreVideo.framework/CoreVideo.tbd").read_text()
    rows = {}
    for symbol in SYMBOLS:
        declaration = next((line for line in text.splitlines()
                            if line.startswith("declare") and f"@{symbol}(" in line), None)
        calls = [line.strip() for line in text.splitlines() if f"@{symbol}(" in line and "call" in line]
        rows[symbol] = {"declaration": declaration, "call_sites": calls,
                        "exported_by_corevideo_tbd": re.search(rf"'?_{symbol}'?[,\s\]]", tbd) is not None}
    read_only = re.search(r"define[^\n]*@read_only\(\)[^{]*\{\s*(?:entry:\s*)?ret i64 (\d+)", text)
    record = {"schema": 1, "ir": str(ir.relative_to(ROOT)), "sdk": sdk,
              "clang": subprocess.run(["xcrun", "clang", "--version"], capture_output=True, text=True).stdout,
              "symbols": rows, "kCVPixelBufferLock_ReadOnly": int(read_only.group(1)) if read_only else None,
              "missing": [s for s, r in rows.items() if not r["declaration"]],
              "not_exported": [s for s, r in rows.items() if not r["exported_by_corevideo_tbd"]]}
    Path(sys.argv[1]).write_text(json.dumps(record, indent=1) + "\n")
    print(json.dumps({"missing": record["missing"], "not_exported": record["not_exported"],
                      "read_only": record["kCVPixelBufferLock_ReadOnly"]}))
    if record["missing"] or record["not_exported"] or record["kCVPixelBufferLock_ReadOnly"] != 1:
        sys.exit(1)


main()
