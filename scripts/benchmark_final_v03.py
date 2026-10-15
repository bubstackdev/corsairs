#!/usr/bin/env python3
"""Prepare or run final, same-asset Rust/Python tiny regression pairs.

--prepare hashes files/metadata only: no CoreAI imports or benchmark execution.
--native is root-coordinated, serial and bounded. Historical controllers/results
are untouched. One descriptive CPU and GPU pair is not a performance study.
"""
import argparse
import base64
import csv
from datetime import datetime, timezone
import hashlib
import importlib.metadata
import importlib.util
import json
import math
import os
from pathlib import Path
import platform
import signal
import statistics
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "docs/evidence/v0.3-final/benchmarks"
OUTPUT = Path("/private/tmp/corsairs-v03-final-benchmarks")
QUALIFY = ROOT / "target/qualify-v03/manifest.json"
BINARY = ROOT / "target/qualify-v03/benchmark"
RLIB = ROOT / "target/large-check/cargo/release/libcorsairs.rlib"
REFERENCE = ROOT / "scripts/reference/benchmark_v03.py"
ENVIRONMENT = ROOT / "scripts/reference/environment.py"
PHASES = ["owned_run", "native_run_download"]
CASES = [ROOT / "docs/evidence/v0.3-benchmarks/cases" / f"feedforward-{backend}.json"
         for backend in ["cpu", "gpu-preferred"]]
WARMUP, SAMPLES = 10, 100
_ENVIRONMENT_MODULE = None


def sha(path):
    h = hashlib.sha256()
    with Path(path).open("rb") as f:
        for block in iter(lambda: f.read(8 << 20), b""):
            h.update(block)
    return h.hexdigest()


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + ".tmp")
    temporary.write_text(json.dumps(value, indent=2, allow_nan=False) + "\n")
    temporary.replace(path)


def production_pins():
    paths = [ROOT / "Cargo.toml", ROOT / "Cargo.lock", ROOT / "scripts/qualify_v03.py"]
    paths += list((ROOT / "crates").rglob("*.rs")) + list((ROOT / "crates").rglob("Cargo.toml"))
    return {str(p.relative_to(ROOT)): sha(p) for p in sorted(paths)}


def environment_snapshot():
    # This module imports only stdlib and reads distribution metadata. Do not
    # import coreai, numpy, ml_dtypes or any extension while preparing/verifying.
    global _ENVIRONMENT_MODULE
    if _ENVIRONMENT_MODULE is None:
        spec = importlib.util.spec_from_file_location("final_benchmark_environment", ENVIRONMENT)
        _ENVIRONMENT_MODULE = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(_ENVIRONMENT_MODULE)
    env = _ENVIRONMENT_MODULE
    env.initialize()
    expected = {"coreai-core": "1.0.0b3", **env.DEPENDENCIES}
    distributions = {}
    for name, version in expected.items():
        dist = importlib.metadata.distribution(name)
        if dist.version != version:
            raise RuntimeError(f"Wrong reference dependency: {name} {dist.version}")
        files = list(dist.files or [])
        record = next((f for f in files if str(f).endswith(".dist-info/RECORD")), None)
        if record is None:
            raise RuntimeError(f"Missing RECORD: {name}")
        record_path = Path(dist.locate_file(record))
        payloads, skipped = [], []
        with record_path.open(newline="") as stream:
            for relative, encoded, _size in csv.reader(stream):
                if not encoded:
                    continue
                algorithm, wanted = encoded.split("=", 1)
                if algorithm != "sha256":
                    raise RuntimeError(f"Unsupported RECORD digest: {name}/{relative}")
                path = Path(dist.locate_file(relative))
                if not path.is_file():
                    # Uninstalled uv wheel archives may omit generated external
                    # CLI entrypoints. Importable package payloads must exist.
                    if ".." in Path(relative).parts:
                        skipped.append(relative)
                        continue
                    raise RuntimeError(f"Missing reference payload: {path}")
                actual = sha(path)
                encoded_actual = base64.urlsafe_b64encode(bytes.fromhex(actual)).decode().rstrip("=")
                if encoded_actual != wanted.rstrip("="):
                    raise RuntimeError(f"Changed reference payload: {path}")
                payloads.append([relative, actual])
        aggregate = hashlib.sha256(json.dumps(sorted(payloads), separators=(",", ":")).encode()).hexdigest()
        distributions[name] = {"version": version, "root": str(Path(dist.locate_file("")).resolve()),
            "record": str(record_path.resolve()), "record_sha256": sha(record_path),
            "verified_hashed_payloads": len(payloads), "verified_payloads_aggregate_sha256": aggregate,
            "missing_external_cli_entrypoints": sorted(skipped)}
    executable = Path(sys.executable).resolve()
    reference_identity = env.identity()
    reference_identity["executable"] = str(Path(reference_identity["executable"]).resolve())
    return {"python_executable": str(executable), "python_executable_sha256": sha(executable),
        "python_version": sys.version, "platform": platform.platform(),
        "reference_identity": reference_identity,
        "distributions": distributions,
        "scope": "Version/RECORD plus every available hashed payload verified without native imports; only missing external CLI entrypoints may be excluded."}


def case_snapshot(path):
    case = json.loads(path.read_text())
    if case.get("expect_frequent_reshapes") is not None or case.get("state"):
        raise RuntimeError("Final pairs require stateless, identical omitted reshape hints")
    model = Path(case["model"])
    files = {str(p): sha(p) for p in sorted(model.rglob("*")) if p.is_file()}
    main_hash = sha(model / "main.mlirb")
    if (model / "main.hash").read_bytes().hex() != main_hash:
        raise RuntimeError(f"Model source digest mismatch: {model}")
    for group in ["inputs", "outputs"]:
        if not case[group] or len({s["name"] for s in case[group]}) != len(case[group]):
            raise RuntimeError("Empty/duplicate tensor group")
        for tensor in case[group]:
            actual = sha(tensor["file"])
            if actual != tensor["sha256"]:
                raise RuntimeError(f"Changed fixture: {tensor['file']}")
            files[tensor["file"]] = actual
    for filename, field in [("suite.json", "source_suite_sha256"),
                             ("backend-goldens.json", "backend_goldens_sha256")]:
        fixture = ROOT / "fixtures/parity-v01" / filename
        if sha(fixture) != case[field]:
            raise RuntimeError(f"Changed source fixture inventory: {fixture}")
        files[str(fixture)] = case[field]
    return {"case": case, "case_file": str(path), "case_file_sha256": sha(path),
            "model_main_mlirb_sha256": main_hash, "files": files}


def frozen_snapshot():
    manifest = json.loads(QUALIFY.read_text())
    if production_pins() != manifest["sources"]:
        raise RuntimeError("Current production sources differ from final qualification freeze")
    binary_key = str(BINARY)
    if manifest["binaries"].get(binary_key) != sha(BINARY):
        raise RuntimeError("Final benchmark is absent/changed in qualification manifest")
    for path, digest in manifest["binaries"].items():
        if sha(path) != digest:
            raise RuntimeError(f"Changed frozen qualification binary: {path}")
    files = [Path(__file__).resolve(), REFERENCE, ENVIRONMENT,
             ROOT / "experiments/rust/benchmark_v03.rs", QUALIFY, BINARY, RLIB]
    return {"qualify_manifest_sha256": sha(QUALIFY), "production_sources": manifest["sources"],
            "files": {str(p.relative_to(ROOT)): sha(p) for p in files}}


def prepare():
    destination = EVIDENCE / "build.json"
    if destination.exists():
        raise RuntimeError("Final preparation already exists; preserve it and use a new evidence scope for a revision")
    frozen = frozen_snapshot()
    environment = environment_snapshot()
    cases = [case_snapshot(p) for p in CASES]
    receipt = {"schema": 1, "prepared_utc": datetime.now(timezone.utc).isoformat(),
        "native_executed": False, "frozen": frozen, "environment": environment, "cases": cases,
        "warmup": WARMUP, "samples": SAMPLES, "phases": PHASES,
        "orders": {"cpu": ["rust", "python"], "gpu-preferred": ["python", "rust"]},
        "native_command": [str(Path(sys.executable).resolve()), "-I", "-B", str(Path(__file__).resolve()), "--native"],
        "limits": "One final descriptive pair per setting; raw within-arm samples retained. No repeated-pair distribution/confidence, stable-clocks, full-render or universal speedup claim. H3 Python omitted; final qualification already collects current Rust H3 timings."}
    if frozen_snapshot() != frozen:
        raise RuntimeError("Frozen build changed during preparation")
    write(destination, receipt)
    print(json.dumps({"prepared": True, "native_executed": False, "receipt": str(destination)}), flush=True)


def verify(receipt):
    if frozen_snapshot() != receipt["frozen"]:
        raise RuntimeError("Final source/binary/controller freeze changed")
    if environment_snapshot() != receipt["environment"]:
        raise RuntimeError("Pinned Python environment changed")
    if [case_snapshot(p) for p in CASES] != receipt["cases"]:
        raise RuntimeError("Final case or fixture/model bytes changed")


def child(command, name, output, deadline):
    started = time.monotonic()
    out_path, err_path = output / f"{name}.stdout", output / f"{name}.stderr"
    with out_path.open("w") as out, err_path.open("w") as err:
        process = subprocess.Popen(command, cwd=ROOT, stdout=out, stderr=err, start_new_session=True)
        expired = False
        try:
            process.wait(timeout=deadline)
        except subprocess.TimeoutExpired:
            expired = True
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            # Reap the direct child after killing its whole process group,
            # including the Rust helper's hashing subprocesses.
            process.wait(timeout=30)
    return {"command": command, "pid": process.pid, "exit_status": process.returncode,
        "timed_out": expired, "joined": process.returncode is not None,
        "seconds": time.monotonic() - started, "stdout": out_path.read_text(), "stderr": err_path.read_text()}


def identities(specs):
    return {s["name"]: (s["dtype"], s["shape"], s["sha256"]) for s in specs}


def validate(value, language, case_info, environment):
    case = case_info["case"]
    if not value.get("passed") or value.get("backend") != case["compute"]:
        raise RuntimeError(f"{language}: incomplete or wrong compute result")
    if value.get("expect_frequent_reshapes") is not None:
        raise RuntimeError("Different reshape-hint boundary")
    if value.get("model_main_mlirb_sha256") != case_info["model_main_mlirb_sha256"]:
        raise RuntimeError("Different model source bytes")
    if language == "rust":
        if not value.get("public_api_only") or Path(value["model"]).resolve() != Path(case["model"]).resolve():
            raise RuntimeError("Rust model/API identity mismatch")
        if value.get("function") != case.get("function", "main"):
            raise RuntimeError("Rust function mismatch")
        actual_inputs, actual_outputs = value["inputs"], value["expected_outputs"]
    else:
        reference = dict(value.get("reference", {}))
        if "executable" in reference:
            reference["executable"] = str(Path(reference["executable"]).resolve())
        if (not value.get("os_backed") or reference != environment["reference_identity"]
                or value.get("platform") != environment["platform"]):
            raise RuntimeError("Python is not the exact pinned OS-backed b3 environment")
        if value.get("case_file_sha256") != case_info["case_file_sha256"]:
            raise RuntimeError("Python case file mismatch")
        if Path(value["case"]["model"]).resolve() != Path(case["model"]).resolve():
            raise RuntimeError("Python model mismatch")
        if value["case"].get("function", "main") != case.get("function", "main"):
            raise RuntimeError("Python function mismatch")
        actual_inputs, actual_outputs = value["case"]["inputs"], value["case"]["outputs"]
    for actual, expected in [(actual_inputs, case["inputs"]), (actual_outputs, case["outputs"])]:
        if identities(actual) != identities(expected):
            raise RuntimeError("Tensor byte/metadata identity mismatch")
    phases = value.get("phases", [])
    if [p["phase"] for p in phases] != PHASES:
        raise RuntimeError("Missing, duplicate or unexpected timed phases")
    for phase in phases:
        samples = phase["samples_ns"]
        if (not phase.get("every_iteration_exact") or phase["warmup"] != WARMUP
                or phase["samples"] != SAMPLES or len(samples) != SAMPLES
                or any(not isinstance(n, (int, float)) or not math.isfinite(n) or n < 0 for n in samples)):
            raise RuntimeError("Incomplete all-byte validation or sample series")
        ordered = sorted(samples)
        if phase["median_ns"] != statistics.median(samples) or phase["p95_ns"] != ordered[math.ceil(SAMPLES * .95) - 1]:
            raise RuntimeError("Reported statistics disagree with retained samples")


def run_native(deadline):
    receipt = json.loads((EVIDENCE / "build.json").read_text())
    verify(receipt)
    # Reserve every fresh report path before launching any native arm.
    for backend in ["cpu", "gpu-preferred"]:
        if (OUTPUT / backend).exists() or (EVIDENCE / f"feedforward-{backend}.json").exists():
            raise RuntimeError("Final native report/output exists; do not overwrite historical results")
    overall = {"passed": False, "started_utc": datetime.now(timezone.utc).isoformat(),
               "build_receipt_sha256": sha(EVIDENCE / "build.json"), "pairs": []}
    try:
        for info in receipt["cases"]:
            case = info["case"]
            backend = case["compute"]
            output = OUTPUT / backend
            output.mkdir(parents=True)
            destination = EVIDENCE / f"feedforward-{backend}.json"
            pair = {"passed": False, "case": case, "order": receipt["orders"][backend],
                "started_utc": datetime.now(timezone.utc).isoformat(), "processes": {},
                "deadline_per_arm_seconds": deadline, "build_receipt_sha256": sha(EVIDENCE / "build.json"),
                "interpretation": receipt["limits"], "host": dict(system=platform.system(), release=platform.release(), machine=platform.machine()),
                "coordination": "Caller reserves quiet host; controller launches no concurrent benchmark children and performs no cache purge."}
            try:
                for language in pair["order"]:
                    verify(receipt)
                    result_path = output / f"{language}.json"
                    common = ["--warmup", str(WARMUP), "--samples", str(SAMPLES),
                              "--phases", ",".join(PHASES), "--output", str(result_path)]
                    if language == "rust":
                        command = [str(BINARY), "--model", case["model"], "--function", case.get("function", "main"),
                                   "--backend", backend, "--reshape", "default", *common]
                        for group, flag in [("inputs", "--input"), ("outputs", "--expected")]:
                            for s in case[group]:
                                command += [flag, s["name"], s["dtype"], ",".join(map(str, s["shape"])) or "scalar", s["file"]]
                    else:
                        command = [str(Path(sys.executable).resolve()), "-I", "-B", str(REFERENCE),
                                   "--case", info["case_file"], "--backend", backend, *common]
                    print(json.dumps({"case": backend, "language": language, "stage": "starting"}), flush=True)
                    observation = child(command, language, output, deadline)
                    pair["processes"][language] = observation
                    write(destination, pair)
                    if observation["exit_status"] or observation["timed_out"] or not observation["joined"]:
                        raise RuntimeError(f"{language} failed/timed out: {observation['stderr'][-1200:]}")
                    value = json.loads(result_path.read_text())
                    validate(value, language, info, receipt["environment"])
                    pair[language] = value
                    verify(receipt)
                pair["summary"] = {phase: {
                    "rust_median_ns": next(p["median_ns"] for p in pair["rust"]["phases"] if p["phase"] == phase),
                    "python_median_ns": next(p["median_ns"] for p in pair["python"]["phases"] if p["phase"] == phase)} for phase in PHASES}
                pair["passed"] = True
            except Exception as error:
                pair["error"] = f"{type(error).__name__}: {error}"
                raise
            finally:
                write(destination, pair)
                overall["pairs"].append({"backend": backend, "passed": pair["passed"], "report": str(destination)})
        overall["passed"] = True
    except Exception as error:
        overall["error"] = f"{type(error).__name__}: {error}"
    write(EVIDENCE / "checks.json", overall)
    print(json.dumps({"passed": overall["passed"], "report": str(EVIDENCE / "checks.json")}), flush=True)
    return 0 if overall["passed"] else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument("--prepare", action="store_true")
    modes.add_argument("--native", action="store_true")
    parser.add_argument("--deadline", type=int, default=60)
    args = parser.parse_args()
    if not 1 <= args.deadline <= 130:
        parser.error("Per-arm deadline must be1..130seconds")
    if args.prepare:
        prepare()
        return 0
    return run_native(args.deadline)


if __name__ == "__main__":
    raise SystemExit(main())
