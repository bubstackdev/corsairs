#!/usr/bin/env python3
"""Prepare/run Krea's fixed-fixture eight-step acceptance through safe Corsairs.

External model/fixture trees are read-only. Large results are written outside
the Corsairs tree. Native execution is opt-in and must be coordinated with the
single shared native runner; this script never launches a REA session.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import resource
import shutil
import struct
import subprocess
import sys
import threading
import time

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / "target" / "krea-check"


def sha(path):
    digest = hashlib.sha256()
    with Path(path).open("rb") as source:
        for chunk in iter(lambda: source.read(8 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n")


def command(args, report, *, env=None):
    completed = subprocess.run(list(map(str, args)), cwd=ROOT, capture_output=True, text=True,
                               env={**os.environ, **(env or {})}, timeout=300)
    report["commands"].append({"argv": list(map(str, args)), "returncode": completed.returncode,
                               "stdout": completed.stdout, "stderr": completed.stderr})
    if completed.returncode:
        raise RuntimeError(f"Command failed: {args}\n{completed.stdout}\n{completed.stderr}")
    return completed


def native_command(args, report, output, timeout):
    """Stream native stdout while keeping a hard deadline outside reader threads."""
    events_path = output / "events.jsonl"
    stderr_path = output / "native.stderr.log"
    rss_before = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
    process = subprocess.Popen(list(map(str, args)), cwd=ROOT, text=True, bufsize=1,
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    report["native_process"] = {"pid": process.pid, "timeout_seconds": timeout,
        "events_file": str(events_path), "stderr_file": str(stderr_path),
        "started_at": datetime.now(timezone.utc).isoformat()}
    save(BUILD / "checks.json", report)
    captured = {"stdout": [], "stderr": []}
    failures = []

    def read_stream(stream, target, field, echo):
        try:
            with target.open("w", buffering=1) as saved:
                for line in stream:
                    captured[field].append(line)
                    saved.write(line)
                    saved.flush()
                    if echo:
                        print(line, end="", flush=True)
        except Exception as exc:
            failures.append(f"{field} capture failed: {exc}")

    readers = [
        threading.Thread(target=read_stream, args=(process.stdout, events_path, "stdout", True), daemon=True),
        threading.Thread(target=read_stream, args=(process.stderr, stderr_path, "stderr", False), daemon=True),
    ]
    for reader in readers:
        reader.start()
    started = time.monotonic()
    timed_out = False
    try:
        process.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        timed_out = True
        process.kill()
        process.wait(timeout=30)
    finally:
        for reader, stream in zip(readers, [process.stdout, process.stderr]):
            reader.join(timeout=10)
            if reader.is_alive():
                failures.append("capture pipe remained open after native process exit")
            else:
                stream.close()
    stdout, stderr = "".join(captured["stdout"]), "".join(captured["stderr"])
    rss_after = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
    rss_unit_bytes = 1 if sys.platform == "darwin" else 1024 if sys.platform.startswith("linux") else None
    report["process_memory"] = {
        "source": "resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss",
        "platform": sys.platform,
        "native_before_raw": rss_before,
        "native_after_raw": rss_after,
        "raw_unit": "bytes" if sys.platform == "darwin" else "KiB" if rss_unit_bytes else "platform-dependent",
        "native_before_max_rss_bytes": int(rss_before * rss_unit_bytes) if rss_unit_bytes else None,
        "native_after_max_rss_bytes": int(rss_after * rss_unit_bytes) if rss_unit_bytes else None,
        "new_child_high_water": rss_after > rss_before,
        "scope": "Maximum RSS across completed children of this checker, including preparation helpers; not a per-process sample or an additive before/after delta. Darwin ru_maxrss is bytes. This does not separately measure Metal allocations; overlapping accounting must not be summed.",
    }
    report["commands"].append({"argv": list(map(str, args)), "returncode": process.returncode,
        "stdout": stdout, "stderr": stderr, "timed_out": timed_out,
        "elapsed_seconds": time.monotonic() - started,
        "events_file": str(events_path), "stderr_file": str(stderr_path)})
    save(BUILD / "checks.json", report)
    if timed_out:
        raise RuntimeError(f"Native Krea driver exceeded {timeout} seconds; partial events retained in {events_path}")
    if failures:
        raise RuntimeError("; ".join(failures))
    if process.returncode:
        raise RuntimeError(f"Native driver exited {process.returncode}; partial events retained in {events_path}\n{stderr}")
    return subprocess.CompletedProcess(args, process.returncode, stdout, stderr)


def tool(name):
    found = shutil.which(name)
    if found:
        return found
    candidate = Path.home() / ".cargo/bin" / name
    if candidate.exists():
        return str(candidate)
    raise RuntimeError(f"Missing tool {name}")


def external_inputs(args, report):
    krea = args.krea_root.resolve()
    bundle = krea / "variants/fixed-tower-20"
    decoder = (bundle / "krea_2_turbo_realism-vae.aimodel").resolve(strict=True)
    fixtures = (args.fixtures or decoder.parent.parents[1] / "fixtures/4c12ae019488ff1c").resolve(strict=True)
    case = next(json.loads(line) for line in (fixtures / "cases.jsonl").read_text().splitlines()
                if json.loads(line)["id"] == "tower-768x1344")
    if (case["width"], case["height"], case["steps"], case["textShape"]) != (768, 1344, 8, [20, 30720]):
        raise RuntimeError("Unexpected fixed fixture dimensions")
    record_path = krea / "records/round4/fixed-paired-tower/record.json"
    record = json.loads(record_path.read_text())
    pair = record["pairs"][0]
    step_hashes = pair["stepLatentsSHA256"][1]
    if len(step_hashes) != 8 or step_hashes != pair["stepLatentsSHA256"][0]:
        raise RuntimeError("Swift baseline/fixed step hashes are incomplete or differ")
    for row in record["pairs"]:
        if len(set(row["latentSHA256"])) != 1 or len(set(row["pixelsSHA256"])) != 1:
            raise RuntimeError("Paired Swift reference does not match")
    first_root = krea / "records/round4/block-inputs-tower"
    first = json.loads((first_root / "inputs.json").read_text())
    rope = next(row for row in first["inputs"] if row["name"] == "rope_image")
    inputs = {
        "noise": {"path": str(fixtures / case["files"]["noise"]), "sha256": record["inputSHA256"]["noise"], "shape": [4032, 64], "dtype": "float32"},
        "text": {"path": str(fixtures / case["files"]["text"]), "sha256": record["inputSHA256"]["text"], "shape": [20, 30720], "dtype": "float32"},
        "rope_image": {"path": str(first_root / rope["file"]), "sha256": rope["sha256"], "shape": rope["shape"], "dtype": "float32"},
    }
    for name, info in inputs.items():
        if sha(info["path"]) != info["sha256"]:
            raise RuntimeError(f"External {name} fixture bytes changed")
    assets = []
    fixed_records = json.loads((krea / "records/round4/fixed-assets.json").read_text())
    for row in fixed_records:
        path = (krea / "forge/fixed-first" / Path(row["fixed"]["path"]).name).resolve(strict=True)
        assets.append({"path": str(path), "function": "segment", "source_sha256": row["fixed"]["sourceBytecodeSHA256"], "expect_frequent_reshapes": True})
    assets.append({"path": str(decoder), "function": "decode", "source_sha256": (decoder / "main.hash").read_bytes().hex(), "expect_frequent_reshapes": False})
    for info in assets:
        path = Path(info["path"]) / "main.mlirb"
        stored = (path.parent / "main.hash").read_bytes().hex()
        if stored != info["source_sha256"]:
            raise RuntimeError(f"Recorded/asset-declared source digest differs: {path}")
        info["source_bytes"] = path.stat().st_size
        info["mtime_ns"] = path.stat().st_mtime_ns
        info["full_source_hash_verified"] = not args.skip_large_hashes
        if not args.skip_large_hashes:
            print(f"Verifying external source bytes: {path.name} ({path.stat().st_size / 1e9:.2f} GB)", flush=True)
            if sha(path) != stored:
                raise RuntimeError(f"Model source bytes changed: {path}")
    pixels = krea / "records/round4/fixed-full-tower/fixed-pixels.f32"
    if sha(pixels) != pair["pixelsSHA256"][1]:
        raise RuntimeError("Saved Swift decoded pixel bytes differ from the reference record")
    result = {"krea_root": str(krea), "bundle": str(bundle), "fixture_root": str(fixtures), "case": case["id"],
              "inputs": inputs, "assets": assets,
              "swift_record": str(record_path), "swift_record_sha256": sha(record_path),
              "swift_step_hashes": step_hashes, "swift_final_hash": pair["latentSHA256"][1],
              "swift_pixel_hash": pair["pixelsSHA256"][1], "swift_pixels_file": str(pixels),
              "first_carries": {row["name"]: row["sha256"] for row in first["inputs"] if row["name"] != "rope_image"},
              "source_files": {str(krea / path): sha(krea / path) for path in [
                  "Sources/AetherDiffusion/FlowMatchSchedule.swift", "Sources/AetherRuntime/DiffusionStepKernel.swift",
                  "Sources/AetherRuntime/FunctionEngine.swift", "variants/fixed-tower-20/aether.json"]},
              "bindings": {"authoritative_latents": "float32 [84,48,64]", "denoiser_latents": "float16 [4032,64]",
                  "text": "float16 [20,30720]", "rope_image": "float32 [4032,2,128]", "sigma": "float32 [1]",
                  "carries": "float32 text_N[20,6144],image_N[4032,6144],cond[8,6144]",
                  "velocity": "float16 [4032,64]", "decoder_input": "float16 [84,48,64]", "pixels": "float32 CHW [3,1344,768]"},
              "resource_budget": {"concurrent_native_generations": 1, "recorded_single_model_metal_gib": 26.99,
                  "recorded_peak_rss_gib": 35.49, "recorded_host_ram_gib": 64,
                  "large_external_source_bytes": sum(a["source_bytes"] for a in assets),
                  "note": "Accounting values overlap and must not be summed. First correctness gate, no speed claim. No encoder loaded, no previews, no concurrent GPU job."}}
    report["external"] = result
    return result, case


def source_hashes():
    paths = [ROOT / "Cargo.toml", ROOT / "Cargo.lock", ROOT / "experiments/rust/krea_driver.rs",
             ROOT / "experiments/swift/KreaScheduleReference.swift", ROOT / "scripts/check_krea.py", BUILD / "data.rs"]
    paths += list((ROOT / "crates").rglob("*.rs")) + list((ROOT / "crates").rglob("Cargo.toml"))
    return {str(path.relative_to(ROOT)): sha(path) for path in sorted(set(paths)) if path.is_file()}


def prepare(args, report):
    external, case = external_inputs(args, report)
    oracle = BUILD / "schedule-reference"
    command(["xcrun", "swiftc", "-O", "-module-cache-path", BUILD / "swift-cache",
             ROOT / "experiments/swift/KreaScheduleReference.swift", "-o", oracle], report)
    schedule = json.loads(command([oracle], report).stdout)
    fixture_bits = [struct.unpack("<I", struct.pack("<f", x))[0] for x in case["timesteps"]]
    if fixture_bits != schedule["timestep_bits"]:
        raise RuntimeError("Swift schedule and original fixture timestep bits differ")
    report["schedule"] = schedule
    save(BUILD / "schedule.json", schedule)
    q = json.dumps
    generated = ["// Generated immutable external-input references; no weight or fixture bytes copied."]
    for key in ["noise", "text"]:
        generated.append(f"const {key.upper()}_PATH: &str = {q(external['inputs'][key]['path'])};")
    generated.append(f"const ROPE_PATH: &str = {q(external['inputs']['rope_image']['path'])};")
    generated.append("const MODELS: &[&str] = &[" + ",".join(q(row["path"]) for row in external["assets"][:4]) + "];")
    generated.append(f"const DECODER: &str = {q(external['assets'][4]['path'])};")
    generated.append("const FIRST_CARRIES: &[(&str,&str)] = &[" + ",".join(f"({q(k if k == 'cond' else k + '_1')},{q(v)})" for k, v in external["first_carries"].items()) + "];")
    for field in ["timestep_bits", "delta_bits"]:
        generated.append(f"const {field.upper()}: &[u32] = &[" + ",".join(str(value) for value in schedule[field]) + "];")
    generated.append("const STEP_HASHES: &[&str] = &[" + ",".join(q(value) for value in external["swift_step_hashes"]) + "];")
    generated.append(f"const FINAL_HASH: &str = {q(external['swift_final_hash'])};")
    generated.append(f"const PIXEL_HASH: &str = {q(external['swift_pixel_hash'])};")
    (BUILD / "data.rs").write_text("\n".join(generated) + "\n")
    sources = source_hashes()
    manifest_path = BUILD / "build-manifest.json"
    binary = BUILD / "driver"
    env = {"CORSAIRS_KREA_DATA": str(BUILD / "data.rs"), "CORSAIRS_KREA_WORKSPACE": str(ROOT)}
    if args.no_build:
        manifest = json.loads(manifest_path.read_text())
        if manifest["source_hashes"] != sources or manifest["binary_sha256"] != sha(binary):
            raise RuntimeError("--no-build rejected changed sources or driver")
        if manifest["rlib_sha256"] != sha(ROOT / "target/release/libcorsairs.rlib"):
            raise RuntimeError("--no-build rejected changed release rlib")
    else:
        command([tool("cargo"), "build", "--offline", "-p", "corsairs", "--release", "--lib"], report)
        rustc = tool("rustc")
        common = [rustc, "--edition=2024", "-Dwarnings", "-O", ROOT / "experiments/rust/krea_driver.rs",
                  "--extern", f"corsairs={ROOT / 'target/release/libcorsairs.rlib'}", "-L", f"dependency={ROOT / 'target/release/deps'}"]
        command(common + ["-o", binary], report, env=env)
        command(common + ["--emit=llvm-ir", "-o", BUILD / "driver.ll"], report, env=env)
        if source_hashes() != sources:
            raise RuntimeError("Sources changed during build; rerun for a stable snapshot")
        ir = (BUILD / "driver.ll").read_text()
        if "fmuladd" in ir or "llvm.fma." in ir or "rounded_product" not in ir:
            raise RuntimeError("Euler lowering contains contraction or missing separate product")
        manifest = {"source_hashes": sources, "binary_sha256": sha(binary), "rlib_sha256": sha(ROOT / "target/release/libcorsairs.rlib"),
                    "compiler": command([rustc, "--version"], report).stdout.strip(), "euler_ir_sha256": sha(BUILD / "driver.ll"),
                    "euler_lowering": "separate noinline f32 product followed by f32 addition; no llvm.fma/fmuladd intrinsic"}
        save(manifest_path, manifest)
    report["build_manifest_sha256"] = sha(manifest_path)
    report["build"] = manifest
    report["prepared"] = True
    return binary


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--krea-root", type=Path, default=Path.home() / "Code/atelier/lab/krea-lab")
    parser.add_argument("--fixtures", type=Path)
    parser.add_argument("--native", action="store_true")
    parser.add_argument("--timeout", type=int, default=1200, help="Native driver deadline in seconds; build commands retain their 300-second deadline")
    parser.add_argument("--mode", choices=["first-segment", "eight-step", "native-chain"], default="eight-step")
    parser.add_argument("--no-build", action="store_true")
    parser.add_argument("--skip-large-hashes", action="store_true", help="Trust stored model hashes; explicitly recorded as unverified full source bytes")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if args.timeout < 1:
        parser.error("--timeout must be positive")
    BUILD.mkdir(parents=True, exist_ok=True)
    output = (args.output or Path("/private/tmp") / ("corsairs-krea-" + datetime.now().strftime("%Y%m%d-%H%M%S"))).resolve()
    if output == ROOT or ROOT in output.parents:
        parser.error("Large outputs must be outside the Corsairs workspace")
    if output == args.krea_root.resolve() or args.krea_root.resolve() in output.parents:
        parser.error("The Krea tree must remain read-only")
    report = {"kind": "corsairs-krea-fixed-fixture-acceptance", "native_requested": args.native,
              "mode": args.mode, "large_output_directory": str(output), "commands": [], "passed": False,
              "scope": "One fixed 768x1344 fixture, four unchanged specialized denoisers, eight original Euler steps and original decoder; no prompt encoder or speed claim.",
              "execution": "Native text/rope upload once, native denoiser carries, velocity download for CPU float32 Euler and per-step half-latent upload; first carry checkpoint downloads; owned decoder call." if args.mode == "native-chain" else "Owned host-copy denoiser carries and decoder call.",
              "timing_scope": "Instrumented correctness run: model calls, readbacks, hashes, disk writes, CPU Euler and decoder load contribute different phase totals. One sequential run is not a controlled performance comparison."}
    try:
        binary = prepare(args, report)
        if args.native:
            output.mkdir(parents=True, exist_ok=True)
            completed = native_command([binary, output, args.mode], report, output, args.timeout)
            events = [json.loads(line) for line in completed.stdout.splitlines() if line.startswith("{")]
            if not events or events[-1].get("event") != "complete" or not events[-1].get("passed"):
                raise RuntimeError("Native driver did not complete successfully")
            if args.mode != "first-segment" and len([row for row in events if row.get("event", "").startswith("step") and row.get("event", "").endswith("_latents") and row.get("passed")]) != 8:
                raise RuntimeError("All eight Swift step hashes were not validated")
            if args.mode == "native-chain":
                expected_events = {"static_upload": 1, "step_upload": 8, "velocity_download": 8, "checkpoint_download": 3}
                for event, count in expected_events.items():
                    if sum(row.get("event") == event for row in events) != count:
                        raise RuntimeError(f"Native chaining expected {count} {event} events")
                segments = [row for row in events if row.get("event") == "segment"]
                if len(segments) != 32 or any(row.get("api") != "run_native" for row in segments):
                    raise RuntimeError("All 32 denoiser calls must use run_native")
            for event in events:
                if "file" in event and sha(event["file"]) != event["sha256"]:
                    raise RuntimeError("Saved native result changed")
            report["native_events"] = events
            report["native_validated"] = True
        else:
            report["native_validated"] = False
        report["passed"] = True
        save(BUILD / "checks.json", report)
        print(json.dumps({"prepared": True, "native_validated": report["native_validated"], "report": str(BUILD / "checks.json"), "large_results": str(output)}), flush=True)
        return 0
    except Exception as error:
        report["error"] = str(error)
        save(BUILD / "checks.json", report)
        print(str(error), file=sys.stderr, flush=True)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
