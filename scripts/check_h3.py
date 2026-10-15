#!/usr/bin/env python3
"""Prepare bounded BF16 H3 acceptance from read-only local Swift lab fixtures.

No weights are copied and native execution is opt-in. Coordinate every native
run with the shared runner; the checker never opens a REA session.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import math
from pathlib import Path
import struct
import sys

import check_krea as runner

ROOT = runner.ROOT
BUILD = ROOT / "target/h3-check"
CARGO_TARGET = BUILD / "cargo"
RLIB = CARGO_TARGET / "release/libcorsairs.rlib"
SNAPSHOT = "42ed227ee7df40d41602854ae760620d6eb651fe"
# Reuse the tested deadline/live-capture helper in this process only. Its report
# destination is redirected to H3; no Krea source, binary or report is changed.
runner.BUILD = BUILD
sha, save = runner.sha, runner.save


def fixture(root, value):
    result = dict(value)
    path = (root / value["file"]).resolve(strict=True)
    width = {"bfloat16": 2, "float32": 4, "int64": 8}[value["dtype"]]
    if path.stat().st_size != math.prod(value["shape"]) * width or sha(path) != value["sha256"]:
        raise RuntimeError(f"Fixture bytes/extent differ: {path}")
    result["path"] = str(path)
    result["bytes"] = path.stat().st_size
    if value["dtype"] == "int64":
        if any(not -(2**31) <= v[0] < 2**31 for v in struct.iter_unpack("<q", path.read_bytes())):
            raise RuntimeError("Swift's int64-to-int32 tag coercion is not exact")
        result["runtime_dtype"] = "int32"
    return result


def inspect_inputs(args, report):
    root = args.h3_root.resolve(strict=True)
    records = {name: root / f"records/{name}.json" for name in [
        "block-oracle-128", "block-gpu-128", "schedule-inputs", "schedule-cache-parity",
        "block-oracle-19350", "backbone-tables", "backbone-export", "segments-25-export", "backbone-streaming"]}
    data = {name: json.loads(path.read_text()) for name, path in records.items()}
    oracle, gpu = data["block-oracle-128"], data["block-gpu-128"]
    if oracle["snapshot"] != SNAPSHOT or oracle["rows"] != 128 or oracle["block"] != 0:
        raise RuntimeError("Unexpected H3 block oracle identity")
    if gpu["sourceTensorSHA256"] != oracle["sourceTensorSHA256"] or not gpu["liveCachedByteIdentical"]:
        raise RuntimeError("Swift block record differs from the source-weight oracle")
    output_hashes = {row["outputSHA256"] for row in gpu["samples"]}
    if len(output_hashes) != 1 or gpu["crossBackendRelativeL2LimitPredefined"] != 0.02:
        raise RuntimeError("Swift block exactness/tolerance contract differs")
    output_hash = next(iter(output_hashes))
    block_inputs = [fixture(root, row) for row in oracle["inputs"]]
    cpu = fixture(root, oracle["reference"])
    cpu_table = fixture(root, oracle["cachedTemb"])
    gpu_files = {}
    for name, expected in [("gpu-live.raw", output_hash), ("gpu-cached.raw", output_hash), ("gpu-modulations.raw", gpu["cacheSHA256"])]:
        path = root / "forge/fixtures/block-128" / name
        if sha(path) != expected:
            raise RuntimeError(f"Saved Swift bytes differ: {path}")
        gpu_files[name] = {"path": str(path), "sha256": expected, "bytes": path.stat().st_size}
    schedule = data["schedule-inputs"]["items"]
    samples = data["schedule-cache-parity"]["samples"]
    if len(schedule) != 50 or len(samples) != 50 or [row["step"] for row in samples] != list(range(50)):
        raise RuntimeError("The 50-pair base schedule is incomplete")
    if any(not row["byteIdentical"] or row["liveSHA256"] != row["cachedSHA256"] for row in samples):
        raise RuntimeError("Saved schedule live/cache bytes differ")
    schedule_inputs = []
    for index, row in enumerate(schedule):
        if row["step"] != index:
            raise RuntimeError("Schedule inputs are not ordered")
        value = row["tensor"]
        schedule_inputs.append(fixture(root, value) if args.mode == "schedule50" else {**value, "path": str(root / value["file"])})
    backbone_oracle = data["block-oracle-19350"]
    backbone_inputs = [{**row, "path": str(root / row["file"])} for row in backbone_oracle["inputs"] if row["name"] != "temb"]
    tables = data["backbone-tables"]
    if tables["sourceExportRecordSHA256"] != sha(records["backbone-export"]):
        raise RuntimeError("Backbone modulation cache source identity differs")
    if tables["tembSHA256"] != next(row["sha256"] for row in backbone_oracle["inputs"] if row["name"] == "temb"):
        raise RuntimeError("Backbone cache uses a different timestep pair")
    if len(tables["files"]) != 50 or [row["block"] for row in tables["files"]] != list(range(50)):
        raise RuntimeError("Backbone tables are incomplete")
    segments = data["segments-25-export"]
    if not segments["completed"] or [(row["firstBlock"], row["endBlockExclusive"]) for row in segments["segments"]] != [(0, 25), (25, 50)]:
        raise RuntimeError("Backbone segment boundaries differ")
    backbone_reference = root / "forge/fixtures/backbone-streaming.raw"
    backbone_hash = data["backbone-streaming"]["finalSHA256"]
    if args.mode.startswith("backbone"):
        backbone_inputs = [fixture(root, row) for row in backbone_oracle["inputs"] if row["name"] != "temb"]
        for row in tables["files"]:
            fixture(root, {"name": f"table{row['block']}", **row})
        if sha(backbone_reference) != backbone_hash:
            raise RuntimeError("Saved full-backbone Swift reference bytes differ")
    segment_rows = segments["segments"]
    if args.mode == "backbone-stage0":
        segment_rows = segment_rows[:1]
    elif args.mode == "backbone-stage1":
        segment_rows = segment_rows[1:]
    selected = [(row["asset"], "segment") for row in segment_rows] if args.mode.startswith("backbone") else [
        (f"forge/assets/block-{arm}-128.aimodel", "modulation" if arm == "modulation" else "block") for arm in ["live", "cached", "modulation"]]
    assets = []
    for relative, function in selected:
        path = (root / relative).resolve(strict=True)
        source = path / "main.mlirb"
        expected = (path / "main.hash").read_bytes().hex()
        print(f"Verifying external H3 source: {relative} ({source.stat().st_size / 1e9:.2f} GB)", flush=True)
        if sha(source) != expected:
            raise RuntimeError(f"H3 asset source digest differs: {source}")
        assets.append({"path": str(path), "function": function, "source_sha256": expected,
            "source_bytes": source.stat().st_size, "full_source_hash_verified": True,
            "metadata": json.loads((path / "metadata.json").read_text()),
            "compute": "gpu-preferred", "expect_frequent_reshapes": True})
    result = {"h3_root": str(root), "snapshot": SNAPSHOT,
        "records_sha256": {str(path): sha(path) for path in records.values()},
        "source_files_sha256": {str(root / name): sha(root / name) for name in [
            "Tests/Block.swift", "Tests/Schedule.swift", "Tests/Segments.swift", "forge/qualify_block.py", "forge/export_segments.py"]},
        "assets": assets, "block_inputs": block_inputs, "cpu_reference": cpu, "cpu_modulations": cpu_table,
        "swift_files": gpu_files, "swift_output_sha256": output_hash, "swift_modulation_sha256": gpu["cacheSHA256"],
        "schedule_inputs": schedule_inputs, "schedule_samples": samples, "backbone_inputs": backbone_inputs,
        "backbone_tables": tables["files"], "backbone_segments": segments["segments"],
        "backbone_asset_identities": [{"path": str(root / row["asset"]),
            "source_sha256": (root / row["asset"] / "main.hash").read_bytes().hex()} for row in segments["segments"]],
        "backbone_reference": {"path": str(backbone_reference), "sha256": backbone_hash},
        "scope": "Synthetic hidden states, real unchanged BF16/F32 block weights. No packing, conditioning prefix, heads, sampler, audio/video decoder or generation.",
        "resource_budget": {"concurrent_native_jobs": 1, "block128_historical_peak_rss_bytes": gpu["peakRSSBytes"],
            "backbone_policy": "One owned-output stage at a time with transitive drain before the next acquisition; no resident-fit or OS page-eviction guarantee.",
            "source_payload_note": "Derived .aimodel streams are fully hashed for the selected gate. The original 144 GB checkpoint cache is not rehashed; source-tensor provenance comes from the retained lab records."}}
    report["external"] = result
    return result


def generate_data(external):
    q = json.dumps
    root = Path(external["h3_root"])
    lines = ["// Generated paths and exact reference identities only; no weights copied.", f"const H3_ROOT: &str = {q(str(root))};"]
    for key, arm in [("LIVE_ASSET", "live"), ("CACHED_ASSET", "cached"), ("MODULATION_ASSET", "modulation")]:
        lines.append(f"const {key}: &str = {q(str(root / f'forge/assets/block-{arm}-128.aimodel'))};")
    dtypes = {"bfloat16": "BFloat16", "float32": "Float32", "int64": "Int32"}
    def specs(name, values):
        lines.append(f"const {name}: &[InputSpec] = &[")
        for value in values:
            lines.append(f"InputSpec {{ name: {q(value['name'])}, dtype: DType::{dtypes[value['dtype']]}, shape: &{q(value['shape'])}, path: {q(value['path'])}, narrow_i64: {str(value['dtype'] == 'int64').lower()} }},")
        lines.append("];")
    specs("BLOCK_INPUTS", external["block_inputs"])
    specs("SCHEDULE_INPUTS", external["schedule_inputs"])
    specs("BACKBONE_INPUTS", external["backbone_inputs"])
    for name, value in [("GPU_OUTPUT_HASH", external["swift_output_sha256"]), ("GPU_TABLE_HASH", external["swift_modulation_sha256"]), ("BACKBONE_OUTPUT_HASH", external["backbone_reference"]["sha256"])]:
        lines.append(f"const {name}: &str = {q(value)};")
    for name, values in [("SCHEDULE_OUTPUT_HASHES", [row["liveSHA256"] for row in external["schedule_samples"]]),
                         ("SCHEDULE_TABLE_HASHES", [row["tableSHA256"] for row in external["schedule_samples"]]),
                         ("BACKBONE_ASSETS", [str(root / row["asset"]) for row in external["backbone_segments"]]),
                         ("BACKBONE_TABLE_PATHS", [str(root / row["file"]) for row in external["backbone_tables"]])]:
        lines.append(f"const {name}: &[&str] = &{q(values)};")
    (BUILD / "data.rs").write_text("\n".join(lines) + "\n")


def source_hashes():
    paths = [ROOT / name for name in ["Cargo.toml", "Cargo.lock", "scripts/check_h3.py", "scripts/check_krea.py", "experiments/rust/h3_driver.rs"]]
    paths += [BUILD / "data.rs"] + list((ROOT / "crates").rglob("*.rs")) + list((ROOT / "crates").rglob("Cargo.toml"))
    return {str(path.relative_to(ROOT)): sha(path) for path in sorted(set(paths))}


def prepare(args, report):
    external = inspect_inputs(args, report)
    generate_data(external)
    sources = source_hashes()
    if args.inventory_only:
        report["inventory_only"] = True
        return None
    binary = BUILD / "driver"
    manifest_path = BUILD / "build-manifest.json"
    if args.no_build:
        manifest = json.loads(manifest_path.read_text())
        if manifest["source_hashes"] != sources or manifest["binary_sha256"] != sha(binary) or manifest["rlib_sha256"] != sha(RLIB):
            raise RuntimeError("--no-build rejected changed H3 sources/binary/library")
    else:
        runner.command([runner.tool("cargo"), "build", "--offline", "-p", "corsairs", "--release", "--lib", "--target-dir", CARGO_TARGET], report)
        rustc = runner.tool("rustc")
        runner.command([rustc, "--edition=2024", "-Dwarnings", "-O", ROOT / "experiments/rust/h3_driver.rs",
            "--extern", f"corsairs={RLIB}", "-L", f"dependency={CARGO_TARGET / 'release/deps'}", "-o", binary], report,
            env={"CORSAIRS_H3_DATA": str(BUILD / "data.rs"), "CORSAIRS_H3_WORKSPACE": str(ROOT)})
        if source_hashes() != sources:
            raise RuntimeError("H3 sources changed during the build")
        manifest = {"source_hashes": sources, "binary_sha256": sha(binary), "rlib_sha256": sha(RLIB),
                    "cargo_target_directory": str(CARGO_TARGET), "cargo_features": [],
                    "compiler": runner.command([rustc, "--version"], report).stdout.strip()}
        save(manifest_path, manifest)
    report["build"] = manifest
    report["build_manifest_sha256"] = sha(manifest_path)
    if args.resume:
        checkpoint = json.loads(args.resume.read_text())
        if checkpoint["build_manifest_sha256"] != report["build_manifest_sha256"] or checkpoint["records_sha256"] != external["records_sha256"] or checkpoint["backbone_asset_identities"] != external["backbone_asset_identities"]:
            raise RuntimeError("Backbone checkpoint source/build/reference identities differ")
        if sha(checkpoint["file"]) != checkpoint["sha256"] or checkpoint["shape"] != [1, 19350, 5376] or checkpoint["dtype"] != "bfloat16":
            raise RuntimeError("Backbone checkpoint bytes or metadata differ")
        report["resume_checkpoint"] = {"manifest": str(args.resume.resolve()), "manifest_sha256": sha(args.resume), **checkpoint}
    report["prepared"] = True
    return binary


def cpu_metrics(reference, candidate):
    a, b = Path(reference).read_bytes(), Path(candidate).read_bytes()
    if len(a) != len(b):
        raise RuntimeError("CPU/BF16 output extents differ")
    error = norm = dot = other_norm = maximum = 0.0
    finite = True
    for (x,), (y,) in zip(struct.iter_unpack("<H", a), struct.iter_unpack("<H", b)):
        x = struct.unpack("<f", struct.pack("<I", x << 16))[0]
        y = struct.unpack("<f", struct.pack("<I", y << 16))[0]
        finite = finite and math.isfinite(x) and math.isfinite(y)
        error += (x-y)**2; norm += x*x; dot += x*y; other_norm += y*y; maximum = max(maximum, abs(x-y))
    return {"finite": finite, "relative_l2": math.sqrt(error / max(norm, 1e-30)) if finite else None,
        "max_abs": maximum if finite else None, "cosine": dot / math.sqrt(max(norm * other_norm, 1e-30)) if finite else None,
        "predefined_relative_l2_limit": 0.02, "passed": finite and math.sqrt(error / max(norm, 1e-30)) <= 0.02,
        "scope": "Separate cross-backend CPU comparison. Exact saved Swift bytes remain the required primary gate."}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--h3-root", type=Path, default=Path.home() / "Code/atelier/lab/minimax-h3-lab")
    parser.add_argument("--mode", choices=["block128", "schedule50", "backbone", "backbone-stage0", "backbone-stage1"], default="block128")
    parser.add_argument("--resume", type=Path, help="Verified stage0 checkpoint.json, required only for backbone-stage1")
    parser.add_argument("--native", action="store_true")
    parser.add_argument("--no-build", action="store_true")
    parser.add_argument("--inventory-only", action="store_true")
    parser.add_argument("--timeout", type=int, default=1200)
    parser.add_argument("--output", type=Path, default=Path("/private/tmp/corsairs-h3-block128"))
    args = parser.parse_args()
    if args.timeout < 1 or (args.native and args.inventory_only):
        parser.error("Positive timeout required; inventory-only cannot run native")
    if (args.mode == "backbone-stage1") != bool(args.resume):
        parser.error("--resume is required only for backbone-stage1")
    output = args.output.resolve()
    if output == ROOT or ROOT in output.parents or output == args.h3_root.resolve() or args.h3_root.resolve() in output.parents:
        parser.error("Outputs must be outside Corsairs and the read-only H3 tree")
    BUILD.mkdir(parents=True, exist_ok=True)
    report = {"kind": "corsairs-h3-bf16-acceptance", "mode": args.mode, "native_requested": args.native,
        "large_output_directory": str(output), "created_at": datetime.now(timezone.utc).isoformat(), "commands": [], "passed": False,
        "scope": "Owned safe Rust tensors, original BF16/F32 assets, exact saved Swift/Core AI hashes. Separate 2% CPU metric only for the original 128-row block. No full H3 generation."}
    try:
        binary = prepare(args, report)
        report["native_validated"] = False
        if args.native:
            output.mkdir(parents=True, exist_ok=True)
            argv = [binary, output, args.mode]
            if args.resume:
                argv.append(report["resume_checkpoint"]["file"])
            completed = runner.native_command(argv, report, output, args.timeout)
            events = [json.loads(line) for line in completed.stdout.splitlines() if line.startswith("{")]
            if not events or events[-1].get("event") != "complete" or not events[-1].get("passed") or events[-1].get("mode") != args.mode:
                raise RuntimeError("H3 native driver did not finish the selected gate")
            expected = {"block128": 3, "schedule50": 150, "backbone": 1, "backbone-stage0": 1, "backbone-stage1": 1}[args.mode]
            files = [row for row in events if "file" in row]
            if len(files) != expected or any(not row.get("passed") or sha(row["file"]) != row["sha256"] for row in files):
                raise RuntimeError("Exact saved Swift BF16 output gate failed")
            report["native_events"] = events
            if args.mode == "backbone-stage0":
                if files[0]["event"] != "backbone_checkpoint" or files[0]["exact_swift_comparison"]:
                    raise RuntimeError("Stage0 must emit an explicitly partial backbone checkpoint")
                checkpoint = {key: files[0][key] for key in ["file", "sha256", "shape", "dtype", "bytes"]}
                checkpoint.update({"build_manifest_sha256": report["build_manifest_sha256"],
                    "records_sha256": report["external"]["records_sha256"],
                    "backbone_asset_identities": report["external"]["backbone_asset_identities"],
                    "scope": "Partial blocks 0..25 checkpoint, not a saved Swift comparison. Blocks 25..50 and the final exact hash complete the gate."})
                save(output / "checkpoint.json", checkpoint)
                report["exact_swift_validated"] = False
                report["acceptance_complete"] = False
            else:
                if any(row["sha256"] != row["swift_sha256"] for row in files):
                    raise RuntimeError("Exact saved Swift BF16 output gate failed")
                report["exact_swift_validated"] = True
                report["acceptance_complete"] = True
            if args.mode == "block128":
                report["cross_backend_cpu"] = {name: cpu_metrics(report["external"]["cpu_reference"]["path"], output / f"{name}.bf16") for name in ["live", "cached"]}
                if not all(row["passed"] for row in report["cross_backend_cpu"].values()):
                    raise RuntimeError("Separate CPU tolerance comparison failed after exact Swift validation")
            report["native_validated"] = True
        report["passed"] = True
        save(BUILD / "checks.json", report)
        if args.native:
            save(output / "checks.json", report)
        print(json.dumps({"prepared": report.get("prepared", False), "inventory_only": args.inventory_only,
            "native_validated": report["native_validated"], "report": str(BUILD / "checks.json")}), flush=True)
        return 0
    except Exception as exc:
        report["error"] = str(exc);save(BUILD / "checks.json", report)
        print(str(exc), file=sys.stderr, flush=True)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
