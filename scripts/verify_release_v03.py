#!/usr/bin/env python3
"""Read-only v0.3 qualification audit; write only the selected aggregate report.

Runs no subprocess, compiler, framework, registry or GPU operation. Missing,
failed, stale or incompletely observed required gates are failures. Historical
diagnostics never substitute for explicitly selected final receipts. This is a
pre-publication qualification gate, not a publication/registry consumer check.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import math
from pathlib import Path
import re
import statistics
import sys
import tomllib

sys.dont_write_bytecode = True
from check_package_v03 import inspect_archive, package_contract, tree_hashes

ROOT = Path(__file__).resolve().parents[1]
FINAL = ROOT / "docs/evidence/v0.3-final"
CRATE = ROOT / "crates/corsairs-abi"
LARGE = ROOT / "docs/evidence/v0.3-large-tensors/release"
HEX = re.compile(r"[0-9a-f]{64}")
LARGE_CASES = {
    ("h3-hidden", "cpu"): "h3-hidden-cpu-quiet-native.json",
    ("h3-rgb124", "cpu"): "h3-rgb124-cpu-native.json",
    ("h3-rgb345", "cpu"): "h3-rgb345-cpu-native.json",
    ("limit-f32", "cpu"): "limit-f32-cpu-quiet-native.json",
    ("h3-hidden", "gpu-preferred"): "h3-hidden-gpu-preferred-native.json",
    ("h3-rgb124", "gpu-preferred"): "h3-rgb124-gpu-preferred-native.json",
    ("h3-rgb173", "gpu-preferred"): "h3-rgb173-native.json",
    ("gpu-limit-f32", "gpu-preferred"): "gpu-limit-f32-native.json",
}
PATH_FACTORS = {"owned": 2, "native": 2, "native-chain": 4,
                "native-after-abandoned": 1, "metal-bound": 2,
                "metal-auto-chain": 4, "metal-after-abandoned": 1}
NATIVE_TESTS = (
    "facade::batch::tests::native_batch_joins_errors_and_releases_dropped_future_models",
    "facade::function_batch::tests::native_function_batch_join_and_drop_cleanup",
    "facade::handles::tests::native_gpu_stream_reuses_queue_and_drains_private_handles",
    "facade::handles::tests::native_handles_retain_chain_and_release_abandoned_results",
    "facade::metal::tests::native_metal_import_reuse_abandoned_futures_and_cleanup",
    "facade::tests::native_dropped_futures_release_model_and_function_handles",
)


def sha(path):
    digest = hashlib.sha256()
    with Path(path).open("rb") as file:
        for block in iter(lambda: file.read(8 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def identity(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def events(text):
    return [json.loads(line) for line in text.splitlines() if line.startswith("{")]


def current_production():
    paths = {ROOT / "Cargo.toml", ROOT / "Cargo.lock"}
    paths.update((ROOT / "crates").rglob("*.rs"))
    paths.update((ROOT / "crates").rglob("Cargo.toml"))
    return {path.relative_to(ROOT).as_posix(): sha(path) for path in sorted(paths)}


class Audit:
    def __init__(self, selection):
        self.inputs = {}
        self.selection = selection
        self.production = current_production()
        self.readme = sha(CRATE / "README.md")
        self.freeze = None

    def read(self, path):
        path = Path(path)
        data = path.read_bytes()
        digest = hashlib.sha256(data).hexdigest()
        key = str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else str(path)
        require(key not in self.inputs or self.inputs[key] == digest, f"Evidence changed while auditing: {path}")
        self.inputs[key] = digest
        return json.loads(data)

    def pins(self, pins, *, require_production=True):
        require(isinstance(pins, dict) and pins, "Empty source pin table")
        if require_production:
            require(self.production.keys() <= pins.keys(), "Build manifest omits production/Cargo source pins")
            require(all(pins[name] == digest for name, digest in self.production.items()), "Build production identity differs from current source")
        for name, digest in pins.items():
            require(HEX.fullmatch(digest) is not None, f"Invalid digest: {name}")
            require(sha(ROOT / name) == digest, f"Frozen source/binary changed: {name}")

    def native(self, gate, filename, tokens=()):
        path = Path(self.selection.get(gate, str(FINAL / filename)))
        if not path.is_absolute():
            path = ROOT / path
        require(path.is_relative_to(FINAL), "Selected native receipts must be in v0.3-final")
        document = self.read(path)
        require(document.get("isError") is not True, "REA tool returned an error")
        envelope = document.get("structuredContent", document)
        if "normalized_result" not in envelope and "content" in document:
            envelope = json.loads(next(row["text"] for row in document["content"] if row.get("type") == "text"))
        result = envelope["normalized_result"]
        process, coverage = result["process"], result["coverage"]
        require(coverage.get("status") == "complete" and not coverage.get("event_limit_reached")
                and not coverage.get("resource_limit_reached") and not coverage.get("unresolved_breakpoints"), "REA coverage incomplete")
        require(process.get("outcome") == "exited" and process.get("exit_status") == 0
                and process.get("terminated") is True, "REA root did not exit successfully")
        for channel in ("stdout", "stderr"):
            require(process[channel].get("complete") is True and process[channel].get("truncated") is False,
                    f"REA {channel} incomplete")
        stops = process.get("other_stops", [])
        require(all(stop == "signal SIGSTOP" for stop in stops), f"REA non-launch/exception stops: {stops}")
        target = result["target"]
        require(target.get("launch_identity", {}).get("stable") is True, "REA selected executable identity unstable")
        require(sha(target["path"]) == target["sha256"], "Observed parent executable changed")
        arguments = target.get("arguments", [])
        require(all(token in arguments or (token.startswith("scripts/") and str(ROOT / token) in arguments)
                    for token in tokens), "Selected native receipt has different gate arguments")
        parent_name = Path(target["path"]).name
        if parent_name in ("observation-parent", "observation-parent-quiet"):
            parent = self.read(FINAL / f"{parent_name}.json")
            require(sha(ROOT / parent["source"]) == parent["source_sha256"]
                    and sha(ROOT / parent["binary"]) == parent["binary_sha256"] == target["sha256"], "Observation parent source/binary pins differ")
            if parent_name == "observation-parent":
                require(parent["exit_status_checks"] == {"true": 0, "false": 1}, "Observation parent exit propagation differs")
            else:
                smoke = parent["ordinary_cpu_smoke"]
                require(len(smoke) == 2 and all(row["passed"] is True and row["exit_status"] == row["expected_exit_status"] for row in smoke)
                        and {Path(row["command"][1]).name: row["exit_status"] for row in smoke} == {"true": 0, "false": 1}
                        and parent["compile"]["exit_status"] == 0, "Quiet observation parent exit propagation/compile failed")
        return result

    def report(self, filename, *, frozen=True):
        value = self.read(FINAL / filename)
        require(value.get("passed") is True, f"Gate report not passing: {filename}")
        if frozen:
            require(value.get("manifest_sha256") == sha(FINAL / "manifest.json"), "Gate does not bind final production/binary freeze")
        for command in value.get("commands", []):
            status = command.get("status", command.get("returncode", command.get("exit_status")))
            require(status == 0 and not command.get("timed_out"), f"Gate command failed: {command.get('command', command.get('argv'))}")
        return value

    def freeze_gate(self):
        self.freeze = self.read(FINAL / "manifest.json")
        self.pins(self.freeze["sources"])
        self.pins(self.freeze["binaries"], require_production=False)
        package = tomllib.loads((CRATE / "Cargo.toml").read_text())["package"]
        require(package["name"] == "corsairs" and package["version"] == "0.3.0", "Expected final corsairs 0.3.0 manifest")
        return {"version": package["version"], "production_identity_sha256": identity(self.production),
                "source_freeze_sha256": sha(FINAL / "manifest.json"), "production_files": len(self.production),
                "package_readme_sha256": sha(CRATE / "README.md")}

    def static_gate(self):
        value = self.report("preparation.json", frozen=False)
        commands = value["commands"]
        wanted = (["cargo", "fmt", "--all", "--check"],
                  ["cargo", "clippy", "--offline", "-p", "corsairs", "--all-targets", "--no-default-features", "--", "-D", "warnings"],
                  ["cargo", "clippy", "--offline", "--workspace", "--all-targets", "--all-features", "--", "-D", "warnings"],
                  ["cargo", "doc", "--offline", "--workspace", "--all-features", "--no-deps"])
        require(all(any(row["command"] == command for row in commands) for command in wanted), "Static check matrix incomplete")
        pure = next(row for row in commands if row["command"] == ["cargo", "test", "--offline", "-p", "corsairs", "--lib", "--no-default-features"])
        require("test result: ok. 41 passed; 0 failed; 6 ignored;" in pure["stdout"], "Expected 41 pure library tests and 6 native ignores")
        docs = next(row for row in commands if row["command"] == ["cargo", "test", "--offline", "--workspace", "--all-features", "--doc"])
        require("test result: ok. 1 passed; 0 failed; 0 ignored;" in docs["stdout"], "Public doc example missing")
        return {"pure_tests": 41, "native_ignored_in_pure_run": 6, "doctests": 1}

    def core_gate(self):
        self.native("core", "core-native.json", ("scripts/qualify_v03.py", "core"))
        self.report("core.json")
        value, build = self.read(FINAL / "core-checks.json"), self.read(FINAL / "core-build.json")
        self.pins(build["source_hashes"])
        require(value.get("passed") is True and value.get("native_validated") is True, "Native core not passing")
        require(value["build_manifest_sha256"] == sha(FINAL / "core-build.json"), "Core build/report digest mismatch")
        require(value["source_hashes"] == build["source_hashes"] and value["source_identity_sha256"] == identity(build["source_hashes"]), "Core source identity mismatch")
        for profile in ("debug", "release"):
            self.pins(build["binaries"][profile], require_production=False)
            for driver, count in (("native_parity", 32), ("metal_parity", 64), ("dynamic_shapes", None), ("native_handles", None)):
                row = next(row for row in value["commands"] if row["command"][0].endswith(f"/{driver}-{profile}"))
                require(row["returncode"] == 0, f"Core {driver}-{profile} failed")
                observed = events(row["stdout"])
                require(observed[-1].get("event") == "complete" and observed[-1].get("passed") is True, "Core driver incomplete")
                if count:
                    require(observed[-1].get("configurations") == count, "Core configuration count differs")
                    require(sum(event.get("event") == driver and event.get("passed") is True for event in observed) == count, "Core positive result count differs")
                elif driver == "dynamic_shapes":
                    require(len(observed) == 7 and all(row.get("passed") is True for row in observed), "Dynamic/options matrix incomplete")
        return {"profiles": 2, "native_configurations_each": 32, "metal_configurations_each": 64, "source_identity_sha256": value["source_identity_sha256"]}

    def lifecycle_gate(self):
        self.native("lifecycle", "lifecycle-native.json", ("scripts/qualify_v03.py", "lifecycle"))
        value = self.report("lifecycle.json")
        rows = value["commands"]
        library = next(row for row in rows if "test result: ok. 47 passed; 0 failed; 0 ignored;" in row["stdout"])
        require(all(f"test {name} ... ok" in library["stdout"] for name in NATIVE_TESTS), "One of six native lifecycle tests missing")
        require(all(any(f"test result: ok. {count} passed; 0 failed; 0 ignored;" in row["stdout"] for row in rows) for count in (1, 2)), "CLI/metadata tests missing")
        return {"library_tests": 47, "native_lifecycle_tests": 6, "pure_library_tests": 41, "metadata_tests": 2, "cli_tests": 1}

    def bf16_gate(self, profile):
        self.native(f"bf16-{profile}", f"bf16-{profile}-native.json", ("scripts/qualify_v03.py", f"bf16-{profile}"))
        value = self.report(f"bf16-{profile}.json")
        build = self.read(FINAL / "bf16/rust-build.json")
        self.pins(build["files_sha256"], require_production=False)
        for name, digest in self.production.items():
            if name.startswith("crates/corsairs-abi/src/"):
                require(build["files_sha256"].get(name) == digest, f"BF16 build omits current production source: {name}")
        require(len(value["commands"]) == 1, "Unexpected BF16 command count")
        row = value["commands"][0]
        require(build["files_sha256"].get(str(Path(row["command"][0]).relative_to(ROOT))) == sha(row["command"][0]), "BF16 executed binary differs from build")
        observed = events(row["stdout"])
        require(observed[0] == {"event": "bf16_raw", "encodings": 65536, "native_exact": True, "metal_exact": True, "clone_drop": True}, "BF16 raw encoding coverage incomplete")
        require(observed[-1].get("event") == "complete" and observed[-1].get("passed") is True
                and observed[-1].get("configurations") == 46 and observed[-1].get("chained_backends") == 2
                and observed[-1].get("abandoned_iterations") == 20, "BF16 final counts incomplete")
        values = [event for event in observed if event.get("event") == "bf16_value"]
        require(len(values) == 104 and all(event.get("exact") is True for event in values), "BF16 full tensor exactness incomplete")
        for event in values:
            path = Path(row["command"][2]) / event["file"]
            elements = 1
            for extent in event["shape"]:
                elements *= extent
            require(event["dtype"] == "bfloat16" and path.stat().st_size == elements * 2, "BF16 returned payload size differs")
        return {"configurations": 46, "exact_values": 104, "raw_encodings": 65536, "native_and_metal_raw": True}

    def stress_gate(self, profile):
        receipt = "stress-release-retry-native.json" if profile == "release" else "stress-debug-native.json"
        self.native(f"stress-{profile}", receipt, ("scripts/qualify_v03.py", f"stress-{profile}"))
        self.report(f"stress-{profile}.json")
        value = self.read(FINAL / f"stress-{profile}-checks.json")
        build = self.read(ROOT / "target/v01-check/build-manifest.json")
        self.pins(build["source_hashes"])
        require(value.get("passed") is True and value.get("native_validated") is True and value.get("profiles") == [profile], "Stress native/profile incomplete")
        require(value["build_manifest_sha256"] == sha(ROOT / "target/v01-check/build-manifest.json")
                and value["source_hashes"] == build["source_hashes"]
                and value["source_identity_sha256"] == identity(build["source_hashes"]), "Stress report source/build mismatch")
        self.pins(build["binaries"][profile], require_production=False)
        require(value["driver_sha256"][profile] == sha(ROOT / f"target/v01-check/driver-{profile}"), "Stress executed driver digest differs")
        require(value["stress"] == {"stateless_and_stateful_each": 10000, "load_drop": 100, "dropped_each_kind": 100, "per_backend_per_profile": True}, "Stress requested counts differ")
        rows = value["commands"]
        parity = next(row for row in rows if len(row.get("command", [])) > 2 and row["command"][2] == "parity")
        run = next(row for row in rows if len(row.get("command", [])) > 2 and row["command"][2] == "stress")
        require(parity["returncode"] == run["returncode"] == 0 and parity["native_complete"] and run["native_complete"], "Stress/parity command incomplete")
        require(sum(e.get("event") == "parity" and e.get("passed") is True for e in parity["events"]) == 32
                and sum(e.get("event") == "negative" and e.get("passed") is True for e in parity["events"]) == 16, "Stress profile parity matrix incomplete")
        counts = next(e for e in run["events"] if e.get("event") == "stress_counts")
        require(counts == {"event": "stress_counts", "stateless_per_backend": 10000, "stateful_per_backend": 10000,
                           "load_drop_per_backend": 100, "abandoned_each_kind_per_backend": 100}, "Actual stress counts differ")
        require({e.get("backend") for e in run["events"] if e.get("event") == "stress" and e.get("passed") is True} == {"cpu", "gpu-preferred"}, "Stress backends incomplete")
        return {"validated_inferences": 40000, "load_drop_each_backend": 100, "abandoned_each_kind_each_backend": 100}

    def large_gate(self, name, compute, native_file):
        gate = f"large-{name}-{compute}"
        native = self.native(gate, native_file, ("scripts/check_large_tensors.py", name, "--native"))
        arguments = native["target"]["arguments"]
        selected_compute = arguments[arguments.index("--compute") + 1] if "--compute" in arguments else "gpu-preferred"
        require(selected_compute == compute, "Selected large native receipt has a different compute setting")
        value = self.read(LARGE / f"{name}-{compute}-release.json")
        build = self.read(LARGE / "build-manifest.json")
        self.pins(build["source_hashes"])
        self.pins(build["binaries"], require_production=False)
        require(value.get("passed") is True and value.get("native_validated") is True
                and value.get("case", {}).get("name") == name and value.get("compute") == compute
                and value.get("profile") == "release" and value.get("concurrent_native_processes") == 1,
                "Large report identity/native result differs")
        require(value["build_manifest_sha256"] == sha(LARGE / "build-manifest.json"), "Large build/report mismatch")
        expected_bytes = {"h3-hidden": 1105477632, "h3-rgb124": 1535901696, "h3-rgb345": 4273274880,
                          "h3-rgb173": 2142830592, "limit-f32": 1 << 32, "gpu-limit-f32": 1 << 31}
        require(value["case"]["bytes"] == expected_bytes[name], "Required large boundary extent differs")
        for key in ("swift_process", "rust_process"):
            row = value[key]
            require(row["exit_status"] == 0 and row.get("timed_out") is False, f"Large {key} failed")
            binary = str(Path(row["command"][0]).relative_to(ROOT))
            require(build["binaries"].get(binary) == sha(row["command"][0]), f"Large {key} executed binary mismatch")
        oracle = value["swift"]
        require(oracle.get("passed") is True and oracle.get("production_helper") is False
                and oracle["shape"] == value["case"]["shape"] and oracle["bytes"] == value["case"]["bytes"], "Independent Swift shape/size incomplete")
        hashes = {1: oracle["input_sha256"], 2: oracle["double_sha256"], 4: oracle["chain_sha256"]}
        require(all(HEX.fullmatch(digest) for digest in hashes.values()), "Invalid full-payload oracle hashes")
        values = value["values"]
        require(len(values) == 7 and {row["label"] for row in values} == PATH_FACTORS.keys(), "Seven-path coverage incomplete")
        require(all(row["passed"] is True and row["bytes"] == oracle["bytes"]
                    and row["factor"] == PATH_FACTORS[row["label"]]
                    and row["sha256"] == hashes[row["factor"]] for row in values), "Large full-byte result differs from independent Swift")
        observed = events(value["rust_process"]["stdout"])
        require([row for row in observed if row.get("event") == "value"] == values
                and observed[-1] == {"event": "complete", "values": 7, "bytes": oracle["bytes"], "passed": True}, "Large stdout/report inconsistency")
        helper = (ROOT / "experiments/rust/large_tensors.rs").read_text()
        require(len(re.findall(r"for _ in 0\.\.3\s*\{", helper)) == 2
                and re.search(r"for _ in 0\.\.3\s*\{\s*drop\(function\.run_native.*?runtime\.drain\(\)\.wait\(\)\?;", helper, re.S)
                and re.search(r"for _ in 0\.\.3\s*\{\s*drop\(function\.encode.*?queue\.fence\(\)\.wait\(\)\?;\s*runtime\.drain\(\)\.wait\(\)\?;", helper, re.S), "Frozen three-iteration abandonment/drain helper missing")
        return {"bytes_each_value": oracle["bytes"], "full_byte_paths": 7, "abandoned_iterations_per_api": 3}

    def raw_gate(self):
        self.native("raw-storage", "raw-storage-retry-native.json", ("scripts/qualify_v03.py", "raw-storage"))
        value = self.report("raw-storage.json")
        require(len(value["commands"]) == 1, "Unexpected raw-storage command count")
        row = value["commands"][0]
        require(self.freeze["binaries"].get(row["command"][0]) == sha(row["command"][0]), "Raw-storage binary not in final freeze")
        observed = events(row["stdout"])
        require(observed[-1] == {"event": "complete", "selected_dtypes": 6, "full_round_trips": 6,
                                 "empty_round_trips": 6, "typed_negative_cases": 12, "passed": True}, "Raw-storage coverage incomplete")
        types = {"bool", "float16", "bfloat16", "float32", "int32", "int64"}
        for dtype in types:
            full = [e for e in observed if e.get("label") == "full-upload-download" and e.get("dtype") == dtype]
            require(len(full) == 1 and full[0].get("passed") is True and full[0]["bytes"] == 1 << 32
                    and full[0]["mismatch_bytes"] == 0 and full[0]["sha256"] == full[0]["expected_sha256"], f"Raw-storage full-byte mismatch: {dtype}")
            require(sum(e.get("label") == "empty-upload-download" and e.get("dtype") == dtype
                        and e.get("passed") is True and e.get("mismatch_bytes") == 0 for e in observed) == 1, "Raw maximal-empty missing")
            require(sum(e.get("label") == "empty-over-limit" and e.get("dtype") == dtype
                        and e.get("phase") == "before-runtime" and e.get("error") == "TensorLimit"
                        and e.get("passed") is True for e in observed) == 2, "Raw pre-runtime rejection missing")
        return {"full_4gib_roundtrips": 6, "maximal_empty_roundtrips": 6, "typed_negatives": 12}

    def h3_gate(self):
        self.native("h3", "h3-native.json", ("scripts/qualify_v03.py", "h3"))
        report = self.report("h3.json")
        value = report["h3"]
        binary = str(ROOT / "target/qualify-v03/benchmark")
        require(any(row["command"][0] == binary for row in report["commands"])
                and self.freeze["binaries"].get(binary) == sha(binary), "H3 did not use frozen final benchmark binary")
        require(value["passed"] is True and value.get("public_api_only") is True
                and value["backend"] == "gpu-preferred" and value["expect_frequent_reshapes"] is None,
                "H3 public API/options result incomplete")
        require(len(value["inputs"]) == 15 and len(value["expected_outputs"]) == 1
                and value["expected_outputs"][0]["shape"] == [1, 19333, 5376], "H3 functional signature differs")
        require({row["phase"] for row in value["phases"]} == {"native_run_download", "metal_encode_download"}
                and all(row["every_iteration_exact"] is True and row["warmup"] == 1
                        and row["samples"] == 3 and len(row["samples_ns"]) == 3 for row in value["phases"]), "H3 every-iteration exactness incomplete")
        assets = self.read(FINAL / "h3-assets.json")
        require(assets["passed"] is True, "H3 full input/model hash receipt failed")
        asset = next(case for case in assets["cases"] if case["name"] == "h3-functional-19333")
        require(asset["matches_declared_main_hash"] is True and asset["model_main_mlirb_sha256"] == value["model_main_mlirb_sha256"], "H3 model identity differs")
        require(sha(ROOT / asset["case_file"]) == asset["case_sha256"], "H3 case specification changed")
        specs = value["inputs"] + value["expected_outputs"]
        require(len(asset["files"]) == len(specs) and all(
            any(item["name"] == spec["name"] and item["passed"] is True
                and item["expected_sha256"] == item["actual_sha256"] == spec["sha256"] for item in asset["files"])
            for spec in specs), "H3 complete input/golden hash identities differ")
        return {"inputs": 15, "phases": 2, "exact_measured_iterations_each": 3, "warmup_each": 1}

    def krea_gate(self):
        self.native("krea", "krea-native.json", ("scripts/check_krea.py", "--native", "--parallel-loads"))
        value = self.read(FINAL / "krea-checks.json")
        require(value.get("passed") is True and value.get("native_validated") is True
                and value.get("mode") == "metal-chain" and value.get("load_policy") == "parallel", "Krea native/mode/policy incomplete")
        self.pins(value["build"]["source_hashes"])
        receipt = self.read(FINAL / "krea-build.json")
        require(value["build_manifest_sha256"] == receipt["build_manifest_sha256"]
                and value["build"] == receipt["build"], "Krea build identity differs from final preparation")
        require(sha(ROOT / "target/krea-check/driver") == value["build"]["binary_sha256"]
                and sha(Path(value["build"]["cargo_target_directory"]) / "release/libcorsairs.rlib") == value["build"]["rlib_sha256"], "Current Krea driver/library differs from final build")
        observed = value["native_events"]
        hashes = [row for row in observed if "expected_sha256" in row]
        wanted = {"first_cond", "first_image_1", "first_text_1", "final_latents", "decoded_pixels"}
        wanted.update(f"step{step}_latents" for step in range(8))
        require(len(hashes) == 13 and {row["event"] for row in hashes} == wanted
                and all(row["passed"] is True and row["sha256"] == row["expected_sha256"] for row in hashes), "Krea thirteen full-byte hashes incomplete")
        require(len([row for row in observed if row.get("event") == "segment" and row.get("api") == "encode"]) == 32, "Krea 32 Metal calls missing")
        for phase in ("batch_load", "function_batch_load"):
            row = next(row for row in observed if row.get("event") == phase)
            require(all(row[key] == 4 for key in ("requested", "entries", "returns", "peak_in_flight"))
                    and row["active_at_join"] == 0, "Krea native outstanding load counts incomplete")
        require(observed[-1].get("event") == "complete" and observed[-1].get("passed") is True
                and observed[-1].get("steps") == 8, "Krea complete event missing")
        return {"exact_hashes": 13, "metal_calls": 32, "steps": 8, "model_and_function_peak": 4}

    def package_gate(self, clean):
        native_file = "package-clean-native.json" if clean else "package-candidate-native.json"
        self.native("package-clean" if clean else "package-candidate", native_file, ("scripts/check_package_v03.py", "--native", "--no-build"))
        path = ROOT / "docs/evidence/v0.3" / ("package-clean-verification.json" if clean else "package-verification.json")
        value = self.read(path)
        require(value.get("passed") is True and value.get("native_validated") is True and value.get("version") == "0.3.0", "Archive native qualification incomplete")
        prepared = value["prepared"]
        require(prepared["checker_sha256"] == sha(ROOT / "scripts/check_package_v03.py"), "Package checker differs from prepared qualification")
        if clean:
            require(prepared["allow_dirty"] is False and prepared.get("vcs_metadata") is not None
                    and not prepared["vcs_metadata"]["git"].get("dirty", False), "Final release package is not a clean VCS archive")
        archive = Path(value["candidate"])
        require(sha(archive) == prepared["archive"]["sha256"] and archive.stat().st_size == prepared["archive"]["bytes"], "Qualified archive digest/size changed")
        payloads = inspect_archive(archive, "corsairs-0.3.0")
        core = self.read(FINAL / "core-build.json")
        require(prepared["tested_source_identity_sha256"] == identity(core["source_hashes"]), "Archive core source identity differs")
        files, _ = package_contract(payloads, tomllib.loads((CRATE / "Cargo.toml").read_text()), tomllib.loads((ROOT / "Cargo.toml").read_text()), core)
        require(files == prepared["packaged_files_sha256"] and tree_hashes(Path(prepared["package_path"])) == files, "Complete archive member/extraction identity differs")
        require(tree_hashes(Path(prepared["consumer"]["path"])) == prepared["consumer"]["files_sha256"]
                and prepared["consumer"]["default_features_only"] is True
                and prepared["consumer"]["examples_forbid_unsafe"] is True, "Isolated ordinary consumer changed")
        self.pins(prepared["binaries_sha256"], require_production=False)
        runs = value["native_example_runs"]
        require(len(runs) == 8 and len({row["path"] for row in runs}) == 8
                and all(row["exit_status"] == 0 and sha(row["path"]) == row["sha256"] for row in runs), "Eight packaged/consumer native example exits missing")
        require(files["README.md"] == sha(CRATE / "README.md"), "Current package README not in qualified archive")
        commands = value["commands"]
        require(all(row["exit_status"] == 0 for row in commands), "Packaged native command failed")
        version = next(row for row in commands if row["command"][1:] == ["--version"])
        require(version["stdout"].strip() == "corsairs 0.3.0", "Packaged CLI version differs")
        require(any(Path(row["command"][0]).name == "bfloat16_smoke" for row in commands), "Safe consumer BF16 host probe missing")
        cli_runs = [row for row in commands if len(row["command"]) > 1 and row["command"][1] == "run"]
        require(len(cli_runs) == 2 and {row["command"][row["command"].index("--compute") + 1] for row in cli_runs} == {"cpu", "gpu-preferred"}, "Packaged CLI BF16 backends incomplete")
        fixture = Path(prepared["bf16_fixture"]["path"])
        self.pins({str(fixture / name): digest for name, digest in prepared["bf16_fixture"]["files_sha256"].items()}, require_production=False)
        for row in cli_runs:
            actual = json.loads(row["stdout"])
            require(len(actual.get("outputs", [])) == 1 and actual.get("states") == [], "Packaged BF16 CLI output count differs")
            output = actual["outputs"][0]
            require(output["dtype"] == "bfloat16" and output["shape"] == [2, 3] and output["name"] == "y"
                    and output["hex"] == (fixture / "double/0-expected-y.bin").read_bytes().hex(), "Packaged BF16 CLI full bytes differ")
        return {"archive": str(archive), "sha256": sha(archive), "bytes": archive.stat().st_size,
                "files": len(files), "native_examples": 8, "bf16_cli_backends": 2, "clean": clean, "readme_sha256": files["README.md"]}

    def rejection_gate(self):
        self.native("gpu-rejections", "gpu-rejections-retry-native.json", ("scripts/check_gpu_rejections.py", "--native"))
        value = self.read(FINAL / "gpu-rejections-final.json")
        # This gate intentionally has no optimistic fallback to the failed first
        # attempt. The final producer's explicit result schema is checked below.
        require(value.get("passed") is True and value.get("native_validated") is True, "Final GPU rejection report missing native acceptance")
        self.pins(value["source_hashes"])
        process = value["process"]
        require(process["exit_status"] == 0 and process.get("timed_out") is False, "GPU rejection native child failed")
        manifest = Path(process["command"][0]).parent / "build-manifest.json"
        build = self.read(manifest)
        self.pins(build["source_hashes"])
        self.pins(build["binaries"], require_production=False)
        require(value["build_manifest_sha256"] == sha(manifest) and value["source_hashes"] == build["source_hashes"], "GPU rejection source/build mismatch")
        observed = value["events"]
        require(events(process["stdout"]) == observed, "GPU rejection stdout/report mismatch")
        complete = next(row for row in reversed(observed) if row.get("event") == "complete")
        require(complete.get("passed") is True, "GPU rejection driver did not complete")
        require(all(complete.get(key) == value.get(key) == count for key, count in
                    (("inference_checks", 19), ("expected_gpu_rejections", 11), ("positive_empty_results", 8))), "GPU rejection actual counts differ")
        checks = [row for row in observed if row.get("event") == "check"]
        require(len(observed) == 46 and len(checks) == 45 and all(row.get("passed") is True for row in observed), "GPU rejection metadata/lifecycle result count incomplete")
        inference = [row for row in checks if row["kind"] in ("value", "unsupported")]
        require(len(inference) == 19 and sum(row["kind"] == "unsupported" for row in inference) == 11
                and len({(row["case"], row["compute"], row["api"], row["kind"]) for row in inference}) == 19, "GPU rejection inference results duplicated or incomplete")
        return {"inference_calls": 19, "typed_gpu_unsupported": 11}

    def benchmark_gate(self):
        self.native("smallbench", "smallbench-final-native.json", ("scripts/benchmark_final_v03.py", "--native"))
        value = self.read(FINAL / "benchmarks/checks.json")
        require(value.get("passed") is True, "Final small benchmark did not pass")
        build_path = FINAL / "benchmarks/build.json"
        build = self.read(build_path)
        require(value["build_receipt_sha256"] == sha(build_path), "Benchmark final build receipt mismatch")
        self.pins(build["frozen"]["production_sources"])
        self.pins(build["frozen"]["files"], require_production=False)
        require(build["frozen"]["qualify_manifest_sha256"] == sha(FINAL / "manifest.json")
                and build["warmup"] == 10 and build["samples"] == 100
                and build["phases"] == ["owned_run", "native_run_download"], "Benchmark source freeze or boundary differs")
        environment = build["environment"]
        reference = environment["reference_identity"]
        require(reference["coreai_core"] == "1.0.0b3" and reference["wheel_sha256"] == "8db70074eb049b0a86bd263e137ea173f3298f7f1b60ec1a7f7c592f4c26c4a9"
                and sha(environment["python_executable"]) == environment["python_executable_sha256"], "Pinned published Python b3 identity differs")
        for distribution in environment["distributions"].values():
            require(distribution["verified_hashed_payloads"] > 0 and sha(distribution["record"]) == distribution["record_sha256"], "Python distribution RECORD changed")
        pairs = value.get("pairs", [])
        require(len(pairs) == 2 and {pair["backend"] for pair in pairs} == {"cpu", "gpu-preferred"}
                and all(pair.get("passed") is True for pair in pairs), "Final CPU/GPU pair missing or failed")
        for entry in pairs:
            pair = self.read(entry["report"])
            backend = entry["backend"]
            case_info = next(info for info in build["cases"] if info["case"]["compute"] == backend)
            require(pair["passed"] is True and pair["order"] == build["orders"][backend]
                    and pair["build_receipt_sha256"] == sha(build_path), "Benchmark pair order/build differs")
            require(sha(case_info["case_file"]) == case_info["case_file_sha256"], "Benchmark case file changed")
            self.pins(case_info["files"], require_production=False)
            for language in ("rust", "python"):
                process = pair["processes"][language]
                require(process["exit_status"] == 0 and process["timed_out"] is False and process["joined"] is True, "Benchmark arm not joined successfully")
                arm = pair[language]
                require(arm["passed"] is True and arm["backend"] == backend and arm["expect_frequent_reshapes"] is None
                        and arm["model_main_mlirb_sha256"] == case_info["model_main_mlirb_sha256"], "Benchmark options/model result differs")
                if language == "rust":
                    require(arm["public_api_only"] is True, "Benchmark Rust arm uses nonpublic API")
                    inputs, outputs = arm["inputs"], arm["expected_outputs"]
                else:
                    require(arm["os_backed"] is True and arm["reference"] == reference
                            and arm["case_file_sha256"] == case_info["case_file_sha256"], "Benchmark Python arm is not pinned OS-backed b3")
                    inputs, outputs = arm["case"]["inputs"], arm["case"]["outputs"]
                tensor_ids = lambda specs: {row["name"]: (row["dtype"], row["shape"], row["sha256"]) for row in specs}
                require(tensor_ids(inputs) == tensor_ids(case_info["case"]["inputs"])
                        and tensor_ids(outputs) == tensor_ids(case_info["case"]["outputs"]), "Benchmark arm input/golden bytes differ")
                require([row["phase"] for row in arm["phases"]] == build["phases"], "Benchmark timed phases differ")
                for phase in arm["phases"]:
                    samples = phase["samples_ns"]
                    require(phase["every_iteration_exact"] is True and phase["warmup"] == 10
                            and phase["samples"] == len(samples) == 100
                            and all(isinstance(sample, (int, float)) and math.isfinite(sample) and sample >= 0 for sample in samples), "Benchmark exactness/sample coverage incomplete")
                    require(phase["median_ns"] == statistics.median(samples)
                            and phase["p95_ns"] == sorted(samples)[94], "Benchmark statistics disagree with raw samples")
        return {"descriptive_pairs": 2, "backends": 2, "languages": 2, "phases_each": 2, "samples_each": 100, "warmup_each": 10}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--report", type=Path, default=FINAL / "aggregate.json")
    parser.add_argument("--native-selection", type=Path, help="explicit gate-to-final-receipt path overrides for clean retries")
    args = parser.parse_args()
    selection = json.loads(args.native_selection.read_text()) if args.native_selection else {}
    audit = Audit(selection)
    if args.native_selection:
        audit.read(args.native_selection.resolve())
    result = {"schema": 1, "version": "0.3.0", "created_utc": datetime.now(timezone.utc).isoformat(),
              "passed": False, "published": False, "registry_checked": False,
              "scope": "Read-only local pre-publication qualification. Source, member and retained binary identities are reread. External multi-GB asset hashes are checked against retained full-hash preparation receipts, not rehashed here. REA selected-file identity is not a loaded-image digest.",
              "verifier_sha256": sha(Path(__file__)), "native_selection": selection, "gates": {}, "gaps": []}
    gates = [("freeze", audit.freeze_gate), ("static", audit.static_gate), ("core", audit.core_gate),
             ("lifecycle", audit.lifecycle_gate)]
    for profile in ("debug", "release"):
        gates.extend(((f"bf16-{profile}", lambda p=profile: audit.bf16_gate(p)),
                      (f"stress-{profile}", lambda p=profile: audit.stress_gate(p))))
    gates.extend((f"large-{name}-{compute}", lambda n=name, c=compute, f=file: audit.large_gate(n, c, f))
                 for (name, compute), file in LARGE_CASES.items())
    gates.extend((("raw-storage", audit.raw_gate), ("h3", audit.h3_gate), ("krea", audit.krea_gate),
                  ("gpu-rejections", audit.rejection_gate), ("smallbench", audit.benchmark_gate),
                  ("package-candidate", lambda: audit.package_gate(False)),
                  ("package-clean", lambda: audit.package_gate(True))))
    for name, check in gates:
        try:
            result["gates"][name] = {"passed": True, "checks": check()}
        except Exception as error:
            result["gates"][name] = {"passed": False, "error": str(error)}
            result["gaps"].append({"gate": name, "error": str(error)})
    try:
        require(current_production() == audit.production, "Production changed during the aggregate audit")
        require(sha(CRATE / "README.md") == audit.readme, "Package README changed during aggregate audit")
        for path, digest in audit.inputs.items():
            require(sha(ROOT / path) == digest, f"Evidence changed during aggregate audit: {path}")
        require(sha(Path(__file__)) == result["verifier_sha256"], "Verifier changed during its audit")
    except Exception as error:
        result["gaps"].append({"gate": "stable-inputs", "error": str(error)})
    result["production_sha256"] = audit.production
    result["package_readme_sha256"] = sha(CRATE / "README.md")
    result["evidence_sha256"] = audit.inputs
    result["qualification_identity_sha256"] = identity({"version": result["version"],
        "production": audit.production, "package_readme": result["package_readme_sha256"],
        "evidence": audit.inputs, "verifier": result["verifier_sha256"]})
    result["passed"] = not result["gaps"]
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps({"passed": result["passed"], "passed_gates": sum(row["passed"] for row in result["gates"].values()),
                      "required_gates": len(gates), "gaps": result["gaps"], "report": str(args.report)}))
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
