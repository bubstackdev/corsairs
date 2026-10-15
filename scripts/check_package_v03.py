#!/usr/bin/env python3
"""Qualify a frozen local package; never contact a registry or upload anything.

Default: verify current native-core evidence, package offline, inspect every
archive member, and build an isolated extracted-archive consumer and package.
--native --no-build: verify those exact retained inputs/binaries, then run the
eight archived examples, packaged CLI and BF16 checks. --native alone also
prepares first. All subprocess timeouts are bounded by 300 seconds.

The package name/version come from Cargo.toml. A final version is required;
--allow-dirty is an explicit local-candidate policy, not a clean-commit claim.
The root release owner runs this only after the version/source freeze.
"""

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import subprocess
import tarfile
import tempfile
import tomllib


ROOT = Path(__file__).resolve().parents[1]
CRATE = ROOT / "crates/corsairs-abi"
EXAMPLES = ("feedforward", "stateful", "native_chain", "metal_chain")
GENERATED = {"Cargo.toml", "Cargo.lock", ".cargo_vcs_info.json"}
BF16_PROBE = '''#![forbid(unsafe_code)]
use corsairs::{BFloat16, DType, Tensor};
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let bits: Vec<_> = (0..=u16::MAX).map(BFloat16::from_bits).collect();
    let tensor = Tensor::from_vec([bits.len()], bits.clone())?;
    assert_eq!(tensor.dtype(), DType::BFloat16);
    assert_eq!(tensor.to_vec::<BFloat16>()?, bits);
    let bytes: Vec<_> = (0..=u16::MAX).flat_map(u16::to_le_bytes).collect();
    assert_eq!(tensor.as_bytes(), bytes);
    let raw = Tensor::from_bytes(DType::BFloat16, [bits.len()], bytes)?;
    assert_eq!(raw.to_vec::<BFloat16>()?, bits);
    println!("BF16 host API: all 65536 raw encodings passed");
    Ok(())
}
'''


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load(path):
    return json.loads(path.read_text())


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def local(path):
    result = Path(path)
    return result if result.is_absolute() else ROOT / result


def relative_file(root, name):
    """Reject ambiguous/traversing names, symlinks and missing ordinary files."""
    parts = PurePosixPath(name)
    if parts.is_absolute() or not parts.parts or any(p in (".", "..") for p in parts.parts):
        raise RuntimeError(f"Unsafe relative file name: {name}")
    if str(parts) != name or "\\" in name:
        raise RuntimeError(f"Noncanonical relative file name: {name}")
    result = root.joinpath(*parts.parts)
    for parent in (result, *result.parents):
        if parent == root:
            break
        if parent.is_symlink():
            raise RuntimeError(f"Symlink in qualified input: {result}")
    if not result.is_file():
        raise RuntimeError(f"Missing ordinary file: {result}")
    return result


def tree_hashes(root):
    files = {}
    for path in sorted(root.rglob("*")):
        if path.is_symlink():
            raise RuntimeError(f"Symlink in qualified tree: {path}")
        if path.is_file():
            files[path.relative_to(root).as_posix()] = sha(path)
        elif not path.is_dir():
            raise RuntimeError(f"Unexpected filesystem entry: {path}")
    return files


def assert_hashes(root, expected):
    for name, digest in expected.items():
        if sha(relative_file(root, name)) != digest:
            raise RuntimeError(f"Frozen input changed: {root / name}")


def check_core(manifest_path, checks_path):
    manifest, checks = load(manifest_path), load(checks_path)
    hashes = manifest["source_hashes"]
    identity = hashlib.sha256(json.dumps(hashes, sort_keys=True).encode()).hexdigest()
    if identity != manifest["source_identity_sha256"]:
        raise RuntimeError("Core source identity is internally inconsistent")
    if (checks.get("passed") is not True or checks.get("native_validated") is not True
            or checks.get("build_manifest_sha256") != sha(manifest_path)
            or checks.get("source_hashes") != hashes
            or checks.get("source_identity_sha256") != identity):
        raise RuntimeError("Passing native core evidence must bind this source manifest")
    if not {"debug", "release"}.issubset(manifest.get("binaries", {})):
        raise RuntimeError("Both debug and release native core gates are required")
    for profile in ("debug", "release"):
        for driver in ("dynamic_shapes", "native_handles", "native_parity", "metal_parity"):
            suffix = f"/{driver}-{profile}"
            names = [name for name in manifest["binaries"][profile] if name.endswith(suffix)]
            if len(names) != 1 or not any(
                entry.get("returncode") == 0
                and entry.get("command", [None])[0] == str(ROOT / names[0])
                and any(e.get("event") == "complete" and e.get("passed") is True
                        for e in entry.get("events", []))
                for entry in checks.get("commands", [])
            ):
                raise RuntimeError(f"Missing passing native core command: {driver}-{profile}")
    assert_hashes(ROOT, hashes)
    return manifest


def inspect_archive(archive, prefix):
    """Read all regular payloads without tar extraction or following links."""
    payloads = {}
    with tarfile.open(archive, "r:gz") as stream:
        for member in stream.getmembers():
            path = PurePosixPath(member.name)
            if (not member.isfile() or member.issparse() or path.is_absolute()
                    or len(path.parts) < 2 or path.parts[0] != prefix
                    or any(part in (".", "..") for part in path.parts)
                    or str(path) != member.name or "\\" in member.name):
                raise RuntimeError(f"Unexpected archive member: {member.name}")
            name = PurePosixPath(*path.parts[1:]).as_posix()
            if name in payloads:
                raise RuntimeError(f"Duplicate archive member: {name}")
            file = stream.extractfile(member)
            if file is None:
                raise RuntimeError(f"Unreadable archive member: {name}")
            with file:
                payload = file.read()
            if len(payload) != member.size:
                raise RuntimeError(f"Truncated archive member: {name}")
            payloads[name] = payload
    if not payloads:
        raise RuntimeError("Empty archive")
    return payloads


def package_contract(payloads, original, workspace, core):
    normalized = tomllib.loads(payloads["Cargo.toml"].decode())
    package = normalized["package"]
    wanted = original["package"]
    for field in ("name", "version", "license", "readme", "description", "repository"):
        if package.get(field) != wanted.get(field):
            raise RuntimeError(f"Normalized package metadata differs: {field}")
    for field in ("edition", "rust-version"):
        value = wanted[field]
        if isinstance(value, dict) and value.get("workspace"):
            value = workspace["workspace"]["package"][field]
        if package.get(field) != value:
            raise RuntimeError(f"Normalized package metadata differs: {field}")
    if package.get("build") is not False or package.get("publish") is not True:
        raise RuntimeError("Unexpected build script or publication policy")
    if normalized.get("features") != {"abi-research": [], "default": []}:
        raise RuntimeError("Expected empty default and standalone research features")
    for table in [normalized, *normalized.get("target", {}).values()]:
        for kind in ("dependencies", "dev-dependencies", "build-dependencies"):
            if table.get(kind):
                raise RuntimeError(f"Unexpected dependency table: {kind}")
    lock = tomllib.loads(payloads["Cargo.lock"].decode())
    if lock.get("package") != [{"name": wanted["name"], "version": wanted["version"]}]:
        raise RuntimeError("Package lockfile contains unexpected packages/dependencies")
    if ".cargo_vcs_info.json" in payloads:
        vcs = json.loads(payloads[".cargo_vcs_info.json"])
        if (not re.fullmatch(r"(?:[0-9a-f]{40}|[0-9a-f]{64})", vcs.get("git", {}).get("sha1", ""))
                or vcs.get("path_in_vcs") != CRATE.relative_to(ROOT).as_posix()
                or not isinstance(vcs["git"].get("dirty", False), bool)):
            raise RuntimeError("Unexpected generated VCS metadata")
    if payloads["Cargo.toml.orig"] != (CRATE / "Cargo.toml").read_bytes():
        raise RuntimeError("Cargo.toml.orig differs from current source manifest")
    files = {name: hashlib.sha256(data).hexdigest() for name, data in payloads.items()}
    required = {"LICENSE-MIT", "LICENSE-APACHE", "README.md", "models/manifest.json",
                "src/lib.rs", "src/bin/corsairs.rs", "Cargo.toml.orig", "Cargo.lock"}
    required.update(f"examples/{name}.rs" for name in EXAMPLES)
    if not required.issubset(files):
        raise RuntimeError(f"Required archive files omitted: {sorted(required - files.keys())}")
    for name, digest in files.items():
        if name in GENERATED:
            continue
        source = "Cargo.toml" if name == "Cargo.toml.orig" else name
        if sha(relative_file(CRATE, source)) != digest:
            raise RuntimeError(f"Archive/current source differs: {name}")
        if source.startswith("src/") or source == "Cargo.toml":
            relative = (CRATE / source).relative_to(ROOT).as_posix()
            if core["source_hashes"].get(relative) != digest:
                raise RuntimeError(f"Packaged production file not in native core freeze: {name}")
    for directory in ("src", "examples", "models", "tests"):
        expected = {f"{directory}/{name}" for name in tree_hashes(CRATE / directory)}
        actual = {name for name in files if name.startswith(directory + "/")}
        if actual != expected:
            raise RuntimeError(f"Archive file set differs from current {directory}")
    model_manifest = json.loads(payloads["models/manifest.json"])
    for name, digest in model_manifest["sha256"].items():
        if files.get(f"models/{name}") != digest:
            raise RuntimeError(f"Packaged model provenance mismatch: {name}")
    return files, normalized


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", action="store_true")
    parser.add_argument("--no-build", action="store_true", help="native stage of exact retained preparation")
    parser.add_argument("--allow-dirty", action="store_true")
    parser.add_argument("--expected-version", help="optional additional final-version assertion")
    parser.add_argument("--output", default="target/package-check-v03")
    parser.add_argument("--report", default="docs/evidence/v0.3/package-verification.json")
    parser.add_argument("--dist-dir", help="separate dirty-candidate/clean-release destinations; default dist/NAME-VERSION")
    parser.add_argument("--core-manifest", default="target/v02-check/build-manifest.json")
    parser.add_argument("--core-checks", default="target/v02-check/checks.json")
    parser.add_argument("--timeout", type=int, default=180)
    args = parser.parse_args()
    if args.no_build and not args.native:
        parser.error("--no-build requires --native")
    if not 1 <= args.timeout <= 300:
        parser.error("--timeout must be between 1 and 300 seconds")
    output, report_path = local(args.output), local(args.report)
    output.mkdir(parents=True, exist_ok=True)
    prepared_path = output / "prepared.json"
    report = {"schema": 1, "started_at": datetime.now(timezone.utc).isoformat(),
              "native_requested": args.native, "preparation_only": not args.native,
              "commands": [], "passed": False, "native_validated": False,
              "uploaded": False, "registry_checked": False,
              "checker_sha256": sha(Path(__file__))}

    def run(command, *, env=None):
        command = list(map(str, command))
        try:
            result = subprocess.run(command, cwd=ROOT, env={**os.environ, **(env or {})},
                                    capture_output=True, text=True, timeout=args.timeout)
        except subprocess.TimeoutExpired as error:
            report["commands"].append({"command": command, "timed_out": True,
                                       "timeout_seconds": args.timeout})
            write(report_path, report)
            raise RuntimeError(f"Timed out: {command}") from error
        report["commands"].append({"command": command, "environment_overrides": env or {},
                                   "exit_status": result.returncode,
                                   "stdout": result.stdout, "stderr": result.stderr})
        write(report_path, report)
        if result.returncode:
            raise RuntimeError(f"Failed ({result.returncode}): {command}")
        return result.stdout

    try:
        original = tomllib.loads((CRATE / "Cargo.toml").read_text())
        workspace = tomllib.loads((ROOT / "Cargo.toml").read_text())
        name, version = (original["package"][field] for field in ("name", "version"))
        if name != "corsairs" or not re.fullmatch(r"0\.3\.[0-9]+", version):
            raise RuntimeError("Freeze a final corsairs 0.3.x version before this release gate")
        if args.expected_version and version != args.expected_version:
            raise RuntimeError("Current package version differs from --expected-version")
        report.update(package=name, version=version)
        core_manifest, core_checks = local(args.core_manifest), local(args.core_checks)
        core = check_core(core_manifest, core_checks)
        core_pins = {str(core_manifest): sha(core_manifest), str(core_checks): sha(core_checks)}
        prefix = f"{name}-{version}"
        if args.no_build:
            prepared = load(prepared_path)
            if (prepared["checker_sha256"] != report["checker_sha256"]
                    or prepared["package"] != name or prepared["version"] != version
                    or prepared["core_evidence_sha256"] != core_pins):
                raise RuntimeError("Prepared package/checker/core identity changed; prepare again")
            report["preparation_manifest"] = {"path": str(prepared_path), "sha256": sha(prepared_path)}
        else:
            # The archive must live outside this repository's Cargo workspace.
            # Mutating its exact normalized manifest to add [workspace] would
            # invalidate the archive/source identity being qualified.
            session = Path(tempfile.mkdtemp(prefix=f"{prefix}-", dir="/private/tmp"))
            report["rustc"] = run(["rustc", "-Vv"]).strip()
            report["os"] = run(["sw_vers"]).strip()
            # Isolate all Cargo package/build output from native core rlib aliases.
            package_env = {"CARGO_TARGET_DIR": str(session / "cargo-package")}
            flags = ["--allow-dirty"] if args.allow_dirty else []
            command = ["cargo", "package", "--offline", "--locked", "-p", name]
            listed = set(run([*command, "--list", *flags], env=package_env).splitlines())
            run([*command, *flags], env=package_env)
            archive = session / "cargo-package/package" / f"{prefix}.crate"
            payloads = inspect_archive(archive, prefix)
            if listed != set(payloads):
                raise RuntimeError("cargo package --list and archive member sets differ")
            files, normalized = package_contract(payloads, original, workspace, core)
            package = session / "extracted" / prefix
            package.mkdir(parents=True)
            # All names validated above; exclusive writes into a fresh tree.
            for member, payload in payloads.items():
                path = package / member
                path.parent.mkdir(parents=True, exist_ok=True)
                with path.open("xb") as file:
                    file.write(payload)
            consumer = session / "consumer"
            consumer.mkdir()
            consumer_manifest = consumer / "Cargo.toml"
            consumer_manifest.write_text(
                '[package]\nname = "corsairs-release-consumer"\nversion = "0.0.0"\nedition = "2024"\n'
                '\n[dependencies]\ncorsairs = { version = ' + json.dumps("=" + version)
                + ', path = ' + json.dumps(str(package)) + ' }\n\n[workspace]\n')
            for directory in ("examples", "models"):
                shutil.copytree(package / directory, consumer / directory)
            (consumer / "src/bin").mkdir(parents=True)
            (consumer / "src/bin/bfloat16_smoke.rs").write_text(BF16_PROBE)
            for example in EXAMPLES:
                path = consumer / f"examples/{example}.rs"
                if sha(path) != files[f"examples/{example}.rs"] or "#![forbid(unsafe_code)]" not in path.read_text():
                    raise RuntimeError(f"Consumer example differs or permits unsafe: {example}")
            consumer_target, package_target = session / "consumer-target", session / "package-target"
            run(["cargo", "generate-lockfile", "--offline", "--manifest-path", consumer_manifest])
            features = run(["cargo", "tree", "--offline", "--locked", "--edges", "features",
                            "--manifest-path", consumer_manifest])
            if "abi-research" in features:
                raise RuntimeError("Research features leaked into ordinary consumer")
            run(["cargo", "build", "--offline", "--locked", "--release", "--examples",
                 "--bins", "--manifest-path", consumer_manifest], env={"CARGO_TARGET_DIR": str(consumer_target)})
            run(["cargo", "build", "--offline", "--locked", "--release", "--examples",
                 "--bin", name, "--manifest-path", package / "Cargo.toml"],
                env={"CARGO_TARGET_DIR": str(package_target)})
            binaries = [target / "release/examples" / example
                        for target in (package_target, consumer_target) for example in EXAMPLES]
            cli, bf16 = package_target / "release" / name, consumer_target / "release/bfloat16_smoke"
            binaries.extend((cli, bf16))
            # External BF16 numerical fixture is frozen separately, never claimed
            # to be included in the package. Copy it for isolated native CLI runs.
            bf16_source = ROOT / "fixtures/parity-v02/bfloat16"
            bf16_files = {"manifest.json": sha(bf16_source / "manifest.json")}
            fixture = load(bf16_source / "manifest.json")
            for member, digest in fixture["sha256"].items():
                if member.startswith("double/"):
                    if core["source_hashes"].get(f"fixtures/parity-v02/bfloat16/{member}") != digest:
                        raise RuntimeError(f"BF16 fixture missing from core freeze: {member}")
                    bf16_files[member] = digest
            assert_hashes(bf16_source, bf16_files)
            fixture_copy = session / "bfloat16-fixture"
            for member in bf16_files:
                destination = fixture_copy / member
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(bf16_source / member, destination)
            prepared = {"schema": 1, "package": name, "version": version,
                        "checker_sha256": report["checker_sha256"],
                        "core_evidence_sha256": core_pins,
                        "tested_source_identity_sha256": core["source_identity_sha256"],
                        "allow_dirty": args.allow_dirty, "session": str(session),
                        "archive": {"path": str(archive), "sha256": sha(archive), "bytes": archive.stat().st_size},
                        "packaged_files_sha256": files, "package_path": str(package),
                        "normalized_manifest": normalized,
                        "vcs_metadata": json.loads(payloads[".cargo_vcs_info.json"]) if ".cargo_vcs_info.json" in payloads else None,
                        "consumer": {"path": str(consumer), "files_sha256": tree_hashes(consumer),
                                     "default_features_only": True, "examples_forbid_unsafe": True},
                        "package_target": str(package_target), "consumer_target": str(consumer_target),
                        "binaries_sha256": {str(path): sha(path) for path in binaries},
                        "bf16_fixture": {"source": str(bf16_source), "path": str(fixture_copy),
                                         "files_sha256": bf16_files, "included_in_archive": False},
                        "preparation_commands": list(report["commands"])}
            write(prepared_path, prepared)
            report["preparation_manifest"] = {"path": str(prepared_path), "sha256": sha(prepared_path)}

        def verify_frozen():
            check_core(core_manifest, core_checks)
            for path, digest in core_pins.items():
                if sha(Path(path)) != digest:
                    raise RuntimeError(f"Core evidence changed: {path}")
            if sha(Path(__file__)) != prepared["checker_sha256"]:
                raise RuntimeError("Package checker changed during qualification")
            archive = Path(prepared["archive"]["path"])
            if sha(archive) != prepared["archive"]["sha256"]:
                raise RuntimeError("Prepared archive changed")
            payloads = inspect_archive(archive, prefix)
            files, _ = package_contract(payloads, original, workspace, core)
            if files != prepared["packaged_files_sha256"]:
                raise RuntimeError("Prepared archive member identity changed")
            if tree_hashes(Path(prepared["package_path"])) != files:
                raise RuntimeError("Extracted package tree differs from complete archive")
            if tree_hashes(Path(prepared["consumer"]["path"])) != prepared["consumer"]["files_sha256"]:
                raise RuntimeError("Prepared consumer input tree changed")
            for path, digest in prepared["binaries_sha256"].items():
                if sha(Path(path)) != digest:
                    raise RuntimeError(f"Prepared binary changed: {path}")
            for key in ("source", "path"):
                assert_hashes(Path(prepared["bf16_fixture"][key]), prepared["bf16_fixture"]["files_sha256"])

        verify_frozen()
        if args.native:
            report["native_example_runs"] = []
            for target in (prepared["package_target"], prepared["consumer_target"]):
                for example in EXAMPLES:
                    binary = Path(target) / "release/examples" / example
                    run([binary])
                    report["native_example_runs"].append({"path": str(binary), "sha256": sha(binary), "exit_status": 0})
            cli = Path(prepared["package_target"]) / "release" / name
            if run([cli, "--version"]).strip() != f"{name} {version}":
                raise RuntimeError("Packaged CLI version differs from qualified archive")
            if "bfloat16" not in run([cli, "--help"]):
                raise RuntimeError("Packaged CLI omits BF16")
            inspection = json.loads(run([cli, "inspect", Path(prepared["package_path"]) / "models/feedforward.aimodel",
                                         "--compute", "gpu-preferred"]))
            if not inspection.get("functions"):
                raise RuntimeError("Packaged CLI inspection returned no functions")
            run([Path(prepared["consumer_target"]) / "release/bfloat16_smoke"])
            fixture = Path(prepared["bf16_fixture"]["path"]) / "double"
            for compute in ("cpu", "gpu-preferred"):
                actual = json.loads(run([cli, "run", fixture / "model.aimodel", "--compute", compute,
                                         "--input", "x", "bfloat16", "2,3", fixture / "0-x.bin"]))
                outputs = actual.get("outputs", [])
                if (len(outputs) != 1 or outputs[0].get("name") != "y"
                        or outputs[0].get("dtype") != "bfloat16" or outputs[0].get("shape") != [2, 3]
                        or outputs[0].get("hex") != (fixture / "0-expected-y.bin").read_bytes().hex()
                        or actual.get("states") != []):
                    raise RuntimeError(f"Packaged BF16 CLI full-output mismatch: {compute}")
            report["native_validated"] = True
        verify_frozen()
        # Local distribution only. Dist is version-derived and never a registry.
        dist = local(args.dist_dir) if args.dist_dir else ROOT / "dist" / prefix
        dist.mkdir(parents=True, exist_ok=True)
        candidate = dist / f"{prefix}.crate"
        if candidate.exists() and sha(candidate) != prepared["archive"]["sha256"]:
            raise RuntimeError(f"Refusing to replace a differently hashed candidate: {candidate}")
        if not candidate.exists():
            shutil.copyfile(prepared["archive"]["path"], candidate)
        (dist / f"{candidate.name}.sha256").write_text(f"{sha(candidate)}  {candidate.name}\n")
        write(dist / "source-manifest.json", prepared)
        report.update(prepared=prepared, candidate=str(candidate), passed=True)
    except Exception as error:
        report["error"] = str(error)
        print(error)
    report["finished_at"] = datetime.now(timezone.utc).isoformat()
    write(report_path, report)
    print(json.dumps({"passed": report["passed"], "native_validated": report["native_validated"],
                      "report": str(report_path)}))
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
