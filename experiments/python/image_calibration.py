#!/usr/bin/env python3
"""Extract the image-I/O call conventions from ImageReference.swift's emitted IR.

Usage: python3 -B experiments/python/image_calibration.py OUT.json
(run after experiments/python/image_oracle.py has written target/image/image.ll)

For every SDK symbol an image binding would call, records the compiler-declared
swiftcc/C signature, the @inline(never) wrapper call site that passes it
arguments, and whether the symbol is exported by the SDK .tbd it belongs to.
"""
from pathlib import Path
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
IR = ROOT / "target" / "image" / "image.ll"
SDK = Path(subprocess.run(["xcrun", "--show-sdk-path"], capture_output=True, text=True, check=True).stdout.strip())
TBDS = {"CoreAIRuntime": SDK / "System/Library/SubFrameworks/CoreAIRuntime.framework/CoreAIRuntime.tbd",
        "CoreVideo": SDK / "System/Library/Frameworks/CoreVideo.framework/CoreVideo.tbd"}

SYMBOLS = {
    # Descriptor exposure: enum case tag and ImageDescriptor getters.
    "image_case_tag": "$s13CoreAIRuntime14InferenceValueV10DescriptorO5imageyAeA05ImageE0VcAEmFWC",
    "image_descriptor_metadata": "$s13CoreAIRuntime15ImageDescriptorVMa",
    "image_width": "$s13CoreAIRuntime15ImageDescriptorV5widthSivg",
    "image_height": "$s13CoreAIRuntime15ImageDescriptorV6heightSivg",
    "image_pixel_format": "$s13CoreAIRuntime15ImageDescriptorV15pixelFormatTypes6UInt32Vvg",
    # Pixel-buffer wrappers.
    "mutable_metadata": "$s9CoreVideo20CVMutablePixelBufferVMa",
    "mutable_init_unsafe_buffer": "$s9CoreVideo20CVMutablePixelBufferV06unsafeE0ACSo11CVBufferRefan_tcfC",
    "mutable_with_unsafe_buffer": "$s9CoreVideo20CVMutablePixelBufferV010withUnsafeE0yxxSo11CVBufferRefaKYTXEKRi_zlF",
    "read_only_metadata": "$s9CoreVideo21CVReadOnlyPixelBufferCMa",
    "read_only_init_unsafe_buffer": "$s9CoreVideo21CVReadOnlyPixelBufferC06unsafeF0ACSo11CVBufferRefan_tcfc",
    "read_only_from_mutable": "$s9CoreVideo21CVReadOnlyPixelBufferCyAcA09CVMutableeF0Vcfc",
    "read_only_with_unsafe_buffer": "$s9CoreVideo21CVReadOnlyPixelBufferC010withUnsafeF0yxxSo11CVBufferRefaKYTXEKRi_zlF",
    # Conformances passed as witness tables to the generic inserts.
    "mutable_view_representable": "$s9CoreVideo20CVMutablePixelBufferV0A9AIRuntime14InferenceValueV17ViewRepresentableADWP",
    "mutable_mutable_view_representable": "$s9CoreVideo20CVMutablePixelBufferV0A9AIRuntime14InferenceValueV24MutableViewRepresentableADWP",
    "read_only_view_representable": "$s9CoreVideo21CVReadOnlyPixelBufferC0A9AIRuntime14InferenceValueV17ViewRepresentableADWP",
    # Inputs / MutableViews generic inserts and value readback.
    "inputs_insert_view_representable": "$s13CoreAIRuntime17InferenceFunctionV6InputsV6insert_3foryx_SStAA0C5ValueV17ViewRepresentableRzRi_zlF",
    "mutable_views_insert_representable": "$s13CoreAIRuntime17InferenceFunctionV12MutableViewsV6insert_3foryxz_SStAA0C5ValueV0E17ViewRepresentableRzRi_zlF",
    "value_kind": "$s13CoreAIRuntime14InferenceValueV4kindAC4KindOvg",
    "kind_image_case_tag": "$s13CoreAIRuntime14InferenceValueV4KindO5imageyA2EmFWC",
    "value_pixel_buffer": "$s13CoreAIRuntime14InferenceValueV11pixelBuffer0A5Video014CVMutablePixelF0VSgvg",
    "value_from_pixel_buffer": "$s13CoreAIRuntime14InferenceValueVyAC0A5Video20CVMutablePixelBufferVcfC",
    # Stream (encode) path.
    "async_value_from_read_only": "$s13CoreAIRuntime17InferenceFunctionV10AsyncValueCyAE0A5Video21CVReadOnlyPixelBufferCcfc",
    "async_mutable_value_from_mutable": "$s13CoreAIRuntime17InferenceFunctionV17AsyncMutableValueVyAE0A5Video20CVMutablePixelBufferVcfC",
    "async_value_pixel_buffer": "$s13CoreAIRuntime17InferenceFunctionV10AsyncValueC11pixelBuffer0A5Video015CVReadOnlyPixelH0CSgvg",
    # CoreVideo C API.
    **{name: name for name in ["CVPixelBufferCreate", "CVPixelBufferLockBaseAddress", "CVPixelBufferUnlockBaseAddress",
                                "CVPixelBufferGetBaseAddress", "CVPixelBufferGetBytesPerRow", "CVPixelBufferGetWidth",
                                "CVPixelBufferGetHeight", "CVPixelBufferGetPixelFormatType", "CVPixelBufferIsPlanar",
                                "CVPixelBufferGetIOSurface", "CVPixelBufferGetDataSize"]},
}

text = IR.read_text()
lines = text.splitlines()
tbd = {name: path.read_text() for name, path in TBDS.items()}


def declaration(symbol):
    quoted = f'@"{symbol}"' if symbol.startswith("$") else f"@{symbol}("
    for line in lines:
        if line.startswith("declare") and quoted in line:
            return re.sub(r" local_unnamed_addr #\d+$", "", line)
    # Data symbols (case tags, witness tables) are referenced, not declared as functions.
    for line in lines:
        if line.startswith(f'@"{symbol}"') or line.startswith(f"@{symbol} "):
            return line
    return None


def call_sites(symbol):
    quoted = f'@"{symbol}"' if symbol.startswith("$") else f"@{symbol}("
    sites, current = [], None
    for line in lines:
        if line.startswith("define"):
            match = re.search(r'@"(\$s5image[^"]+)"', line)
            current = match.group(1) if match else None
        if current and quoted in line and not line.startswith(("declare", "define")):
            sites.append({"wrapper": current, "ir": line.strip()})
    return sites[:2]


rows = {}
for role, symbol in SYMBOLS.items():
    exported = {name: (f"'_{symbol}'" in body or f"_{symbol}," in body or f"_{symbol} " in body
                       or f"_{symbol}\n" in body or f"_{symbol}'" in body)
                for name, body in tbd.items()}
    rows[role] = {"symbol": symbol, "declaration": declaration(symbol), "call_sites": call_sites(symbol),
                  "exported_by": [name for name, present in exported.items() if present]}
imports = subprocess.run(["dyld_info", "-imports", "/System/Library/SubFrameworks/CoreAIRuntime.framework/Versions/A/CoreAIRuntime"],
                         capture_output=True, text=True).stdout
video_imports = sorted({line.split()[0] for line in imports.splitlines()
                        if "(from CoreVideo)" in line or "(from IOSurface)" in line})
missing = [role for role, row in rows.items() if not row["declaration"] and not row["call_sites"]]
unexported = [role for role, row in rows.items() if not row["exported_by"]]
Path(sys.argv[1]).write_text(json.dumps({
    "schema": 1, "ir": str(IR.relative_to(ROOT)), "sdk": str(SDK),
    "swiftc": subprocess.run(["xcrun", "swiftc", "--version"], capture_output=True, text=True).stdout.strip(),
    "symbols": rows, "missing_from_ir": missing, "not_exported": unexported,
    "core_ai_runtime_corevideo_iosurface_imports": video_imports}, indent=1) + "\n")
print(f"{len(rows)} symbols; missing from IR: {missing}; not exported: {unexported}")
