#!/usr/bin/env python3
"""Build an unintegrated Metal ABI proof without changing production sources.

The private backend is appended only to a disposable, source-pinned crate copy.
This command compiles the proof; it never executes Core AI or Metal.
"""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--release", action="store_true")
    args = parser.parse_args()
    base = ROOT / "target/metal-proof"
    copied = base / "source"
    copied.mkdir(parents=True, exist_ok=True)
    source = ROOT / "crates/corsairs-abi/src"
    shutil.copytree(source, copied / "src", dirs_exist_ok=True)
    original = sorted(source.rglob("*.rs"))
    additions = [ROOT / "experiments/rust/metal_proof.rs", ROOT / "experiments/rust/metal_proof_backend.rs", Path(__file__)]
    pinned = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in original + additions}
    backend = ROOT / "experiments/rust/metal_proof_backend.rs"
    with (copied / "src/native/owned.rs").open("a") as stream:
        stream.write("\n#[path = " + json.dumps(str(backend)) + "]\nmod metal_proof;\n")
    shutil.copyfile(ROOT / "experiments/rust/metal_proof.rs", copied / "driver.rs")
    manifest = '''[package]
name = "corsairs-metal-proof"
version = "0.0.0"
edition = "2024"
rust-version = "1.99"
publish = false

[lib]
name = "corsairs"
path = "src/lib.rs"

[[bin]]
name = "corsairs-metal-proof"
path = "driver.rs"

[features]
default = ["abi-research"]
abi-research = []

[lints.rust]
unsafe_op_in_unsafe_fn = "deny"

[workspace]
'''
    (copied / "Cargo.toml").write_text(manifest)
    command = ["cargo", "build", "--offline", "--manifest-path", str(copied / "Cargo.toml"), "--target-dir", str(base / "build"), "--bin", "corsairs-metal-proof"]
    if args.release:
        command.append("--release")
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True)
    profile = "release" if args.release else "debug"
    binary = base / f"build/{profile}/corsairs-metal-proof"
    record = {"production_sources_modified": False, "native_executed": False, "profile": profile, "source_hashes": pinned, "command": command, "exit_code": result.returncode, "stdout": result.stdout, "stderr": result.stderr}
    if result.returncode == 0:
        record["binary"] = str(binary.relative_to(ROOT))
        record["binary_sha256"] = hashlib.sha256(binary.read_bytes()).hexdigest()
    (base / f"build-{profile}.json").write_text(json.dumps(record, indent=2) + "\n")
    print(result.stderr, end="")
    if result.returncode:
        raise SystemExit(result.returncode)
    print(binary)


if __name__ == "__main__":
    main()
