#!/usr/bin/env python3
"""Check creator-defined asset metadata against a Swift oracle.

Calibrates every lowering from CreatorMetadataReference.swift's emitted IR/SIL,
confirms the committed fixture is what CreatorMetadataWriter.swift writes, then
compares `corsairs inspect` with the oracle value for value on that fixture, on
every repository asset and on generated edge assets (nesting at Core AI's JSON
limit, the value budget, and JSON Core AI rejects). Optionally soaks repeated
inspections for resident-memory growth. Writes only under target/.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import re
from pathlib import Path
import shutil
import struct
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "target" / "creator-metadata"
SDK_TBDS = ("System/Library/SubFrameworks/CoreAIAsset.framework/CoreAIAsset.tbd", "usr/lib/swift/libswiftCore.tbd")
FIXTURE = ROOT / "fixtures/asset-metadata-creator/model.aimodel"
SOURCE = ROOT / "fixtures/double_f32_2x3/double_f32_2x3.aimodel"
VALUE = "$s11CoreAIAsset12AIModelAssetV8MetadataV19CreatorDefinedValueO"
CASES = ("6stringyAGSScAGmFWC", "7integeryAGSicAGmFWC", "6numberyAGSdcAGmFWC", "4boolyAGSbcAGmFWC",
         "5arrayyAGSayAGGcAGmFWC", "10dictionaryyAGSDySSAGGcAGmFWC")
GETTER = "$s11CoreAIAsset12AIModelAssetV8MetadataV014creatorDefinedE0SDySSAE07CreatorG5ValueOGvg"
# Exact compiler declarations the Rust binding follows (prefixes before attributes).
OPTIMIZED_IR = (
    f'declare swiftcc ptr @"{GETTER}"(ptr noalias swiftself)',
    f'declare swiftcc %swift.metadata_response @"{VALUE}Ma"(i64)',
    "%GetEnumTag = load ptr",
    "getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 88",
    "getelementptr inbounds nuw i8, ptr %.valueWitnesses, i64 96",
    "%DestructiveProjectEnumData",
    # Payloads load from offset 0 after projection: String words at 0 and 8, an i1 Bool.
    "%._guts._object._object = getelementptr inbounds nuw i8, ptr %5, i64 8",
    "load i1, ptr %5, align 16",
    *(f'load i32, ptr @"{VALUE}{case}"' for case in CASES),
)
UNOPTIMIZED_IR = (
    'declare swiftcc i64 @"$sSD5countSivg"(ptr, ptr, ptr, ptr)',
    'declare swiftcc ptr @"$sSD4keysSD4KeysVyxq__Gvg"(ptr, ptr, ptr, ptr)',
    'declare swiftcc void @"$sSD4KeysV12makeIteratorAB0C0Vyxq___GyF"(ptr noalias sret(%TSD4KeysV8IteratorV) captures(none), ptr, ptr, ptr, ptr)',
    'declare swiftcc void @"$sSD4KeysV8IteratorV4nextxSgyF"(ptr noalias sret(%swift.opaque), ptr, ptr swiftself captures(none) dereferenceable(40))',
    'declare swiftcc %swift.metadata_response @"$sSD4KeysV8IteratorVMa"(i64, ptr, ptr, ptr)',
    'declare swiftcc void @"$sSDyq_Sgxcig"(ptr noalias sret(%swift.opaque), ptr noalias, ptr, ptr, ptr, ptr)',
    'declare swiftcc i64 @"$sSa5countSivg"(ptr, ptr)',
    'declare swiftcc void @"$sSayxSicig"(ptr noalias sret(%swift.opaque), i64, ptr, ptr)',
    '%2 = call swiftcc %swift.metadata_response @"$sSD4KeysV8IteratorVMa"(i64 0, ptr %K, ptr %V, ptr %K.Hashable)',
    'ptr @"$sSSN", ptr %7, ptr @"$sSSSHsWP")',
)
OWNERSHIP_SIL = (
    f"sil [available 27.0] @{GETTER} : $@convention(method) (@in_guaranteed AIModelAsset.Metadata) -> @owned Dictionary<String, AIModelAsset.Metadata.CreatorDefinedValue>",
    "sil @$sSD5countSivg : $@convention(method) <Key, Value where Key : Hashable> (@guaranteed Dictionary<Key, Value>) -> Int",
    "sil @$sSD4keysSD4KeysVyxq__Gvg : $@convention(method) <Key, Value where Key : Hashable> (@guaranteed Dictionary<Key, Value>) -> @owned Dictionary<Key, Value>.Keys",
    "@$sSD4KeysV12makeIteratorAB0C0Vyxq___GyF : $@convention(method) <Key, Value where Key : Hashable> (@owned Dictionary<Key, Value>.Keys) -> @owned Dictionary<Key, Value>.Keys.Iterator",
    "@$sSD4KeysV8IteratorV4nextxSgyF : $@convention(method) <Key, Value where Key : Hashable> (@inout Dictionary<Key, Value>.Keys.Iterator) -> @out Optional<Key>",
    "sil @$sSDyq_Sgxcig : $@convention(method) <Key, Value where Key : Hashable> (@in_guaranteed Key, @guaranteed Dictionary<Key, Value>) -> @out Optional<Value>",
    "sil @$sSayxSicig : $@convention(method) <Element> (Int, @guaranteed Array<Element>) -> @out Element",
)
SYMBOLS = (GETTER, f"{VALUE}Ma", *(VALUE + case for case in CASES), "$sSD5countSivg", "$sSD4keysSD4KeysVyxq__Gvg",
           "$sSD4KeysV12makeIteratorAB0C0Vyxq___GyF", "$sSD4KeysV8IteratorV4nextxSgyF", "$sSD4KeysV8IteratorVMa",
           "$sSDyq_Sgxcig", "$sSSSHsWP", "$sSSN")
# Generated assets whose outcomes differ by design (all others must match).
RUST_LIMITED = {"wide-65536": "more than 65536 values", "wide-65537": "more than 65536 values",
                "string-bytes-over-budget": "more than 16777216 string bytes"}
# Generated assets that `corsairs inspect` must also read with the debug build,
# on its default worker stack.
DEBUG_ASSETS = ("deep-511", "deep-511-dictionaries", "deep-511-alternating")
# The RSS soak samples every SOAK_INTERVAL inspections and measures growth from
# SOAK_WARMUP on; shorter or unaligned soaks would make the window vacuous.
SOAK_INTERVAL, SOAK_WARMUP, SOAK_MIN = 1000, 4000, 8000
# Strings longer than this are summarized in the retained oracle evidence.
EVIDENCE_STRING_LIMIT = 4096
COMMANDS = []
# The 511-level edge values exceed Python's default recursion limit when
# summarized or converted, with two frames per dictionary level.
sys.setrecursionlimit(10_000)


def run(command, *, timeout=600, check=True):
    completed = subprocess.run([str(part) for part in command], cwd=ROOT, capture_output=True, text=True, timeout=timeout)
    COMMANDS.append({"command": [str(part) for part in command], "returncode": completed.returncode,
                     "stderr_tail": completed.stderr[-2000:]})
    if check and completed.returncode != 0:
        raise RuntimeError(f"command failed ({completed.returncode}): {command}\n{completed.stderr[-4000:]}")
    return completed


def tool(name):
    found = shutil.which(name) or str(Path.home() / ".cargo/bin" / name)
    if not Path(found).is_file():
        raise RuntimeError(f"Required tool is unavailable: {name}")
    return found


def swiftc(output, *options, source="CreatorMetadataReference.swift"):
    run(["xcrun", "swiftc", "-parse-as-library", "-module-cache-path", OUTPUT / "module-cache", *options,
         ROOT / "experiments/swift" / source, "-o", output])
    return output


def require_lines(text, expected, label):
    missing = [line for line in expected if line not in text]
    if missing:
        raise AssertionError(f"{label} lacks expected compiler output: {missing}")
    return [next(row.strip() for row in text.splitlines() if line in row) for line in expected]


def calibrate():
    sdk = Path(run(["xcrun", "--show-sdk-path"]).stdout.strip())
    exported = "\n".join((sdk / tbd).read_text() for tbd in SDK_TBDS)
    absent = [symbol for symbol in SYMBOLS if not re.search(r"'?_" + re.escape(symbol) + r"'?[,\s\]]", exported)]
    if absent:
        raise AssertionError(f"symbols absent from SDK .tbd files: {absent}")
    optimized = swiftc(OUTPUT / "reference-O.ll", "-O", "-emit-ir").read_text()
    unoptimized = swiftc(OUTPUT / "reference-Onone.ll", "-Onone", "-emit-ir").read_text()
    sil = swiftc(OUTPUT / "reference-Onone.sil", "-Onone", "-emit-sil").read_text()
    sil += swiftc(OUTPUT / "reference-O.sil", "-O", "-emit-sil").read_text()
    return {"sdk_symbols": list(SYMBOLS),
            "optimized_ir": require_lines(optimized, OPTIMIZED_IR, "-O IR"),
            "unoptimized_ir": require_lines(unoptimized, UNOPTIMIZED_IR, "-Onone IR"),
            "sil_ownership": require_lines(sil, OWNERSHIP_SIL, "SIL")}


def nested(levels, opens, closes, leaf="7"):
    """`levels` containers around `leaf`, cycling through `opens`/`closes`."""
    return ("".join(opens[i % len(opens)] for i in range(levels)) + leaf
            + "".join(closes[i % len(closes)] for i in reversed(range(levels))))


def edge_assets():
    """Copies of the x+x asset with hand-written creator JSON Core AI's writer cannot produce."""
    base = json.loads((SOURCE / "metadata.json").read_text())
    long = "a" * 1_100_000
    cases = {
        "deep-511": nested(510, ["["], ["]"]),  # deepest value Core AI's JSON reader accepts
        "deep-512": nested(511, ["["], ["]"]),  # one level more: Core AI rejects the asset
        # Nested dictionaries once cost two recursive frames per level in Rust.
        "deep-511-dictionaries": nested(510, ['{"a":'], ["}"]),
        "deep-512-dictionaries": nested(511, ['{"a":'], ["}"]),
        "deep-511-alternating": nested(510, ['{"a":', "["], ["}", "]"]),
        "wide-65535": "[" + ",".join(["2"] * 65535) + "]",  # with its key, exactly the Rust budget
        "wide-65536": "[" + ",".join(["2"] * 65536) + "]",  # one value over the Rust budget
        "wide-65537": "[" + ",".join(["2"] * 65537) + "]",  # over MAX_ENTRIES too: still the budget error
        # Strings over the general 1 MiB native string bound, within the creator byte budget.
        "string-value-1100000": json.dumps(long),
        "string-key-1100000": "{" + json.dumps(long) + ": 1}",
        "string-bytes-over-budget": json.dumps("a" * ((1 << 24) + 1)),
        # Canonically equivalent keys in one object: Core AI keeps one of them.
        "hand-written-canonical-keys": '{"\u00e9": "precomposed", "e\u0301": "decomposed"}',
        "null": "null",
        "uint64-max": "18446744073709551615",
        "overflow-1e999": "1e999",
        "hand-written-numbers": '{"one": 1, "one_point_zero": 1.0, "zero_point_zero": 0.0, "minus_zero": -0.0,'
                                ' "two_point_zero": 2.0, "exponent": 1e2, "huge": 1e19, "half": 0.5}',
    }
    paths = {}
    for name, value in cases.items():
        destination = OUTPUT / "assets" / f"{name}.aimodel"
        shutil.rmtree(destination, ignore_errors=True)
        shutil.copytree(SOURCE, destination)
        text = json.dumps(base, indent=1)[:-1].rstrip() + ',\n "creatorDefinedMetadata": {"value": ' + value + "}\n}\n"
        (destination / "metadata.json").write_text(text)
        paths[name] = destination
    destination = OUTPUT / "assets" / "not-a-dictionary.aimodel"
    shutil.rmtree(destination, ignore_errors=True)
    shutil.copytree(SOURCE, destination)
    (destination / "metadata.json").write_text(json.dumps({**base, "creatorDefinedMetadata": [1, 2]}))
    paths["not-a-dictionary"] = destination
    return paths


def oracle_form(value):
    """Convert one CLI tagged value into the oracle's encoding (numbers as bits)."""
    (case, payload), = value.items()
    if case == "number":
        special = {"NaN": float("nan"), "inf": float("inf"), "-inf": float("-inf")}
        number = special[payload] if isinstance(payload, str) else float(payload)
        return {"number_bits": struct.pack(">d", number).hex()}
    if case == "array":
        return {"array": [oracle_form(item) for item in payload]}
    if case == "dictionary":
        return {"dictionary": {key: oracle_form(item) for key, item in payload.items()}}
    return {case: payload}


def compare(name, path, oracle_row, cli):
    row = {"asset": name, "oracle_error": oracle_row.get("error_type"), "rust_error": None}
    completed = run([cli, "inspect", path], check=False)
    if completed.returncode == 0:
        rust = {key: oracle_form(value) for key, value in json.loads(completed.stdout)["asset"]["creator_defined"].items()}
        row["entries"] = len(rust)
    else:
        rust = None
        row["rust_error"] = json.loads(completed.stderr.strip().splitlines()[-1])["error"]
    oracle = oracle_row.get("creator_defined")
    if name in RUST_LIMITED:
        row["outcome"] = "rust_limit" if (rust is None and oracle is not None
                                           and RUST_LIMITED[name] in row["rust_error"]) else "unexpected"
    elif rust is None and oracle is None:
        row["outcome"] = "both_rejected"
    elif rust == oracle:
        row["outcome"] = "match"
    else:
        row["outcome"] = "mismatch"
        (OUTPUT / f"mismatch-{name.replace('/', '_')}.json").write_text(json.dumps({"rust": rust, "oracle": oracle}, indent=1))
    if name.startswith("hand-written") and oracle is not None:
        row["oracle_values"] = oracle
    return row


def driver():
    rustc, cargo = tool("rustc"), tool("cargo")
    run([cargo, "build", "--offline", "-p", "corsairs", "--lib", "--release"])
    binary = OUTPUT / "creator-metadata-soak"
    run([rustc, "--edition=2024", "-Dwarnings", "-C", "opt-level=3", ROOT / "experiments/rust/creator_metadata_soak.rs",
         "--extern", f"corsairs={ROOT / 'target/release/libcorsairs.rlib'}",
         "-L", f"dependency={ROOT / 'target/release/deps'}", "-o", binary])
    return binary


def soak(binary, count):
    if count < SOAK_MIN or count % SOAK_INTERVAL:
        raise ValueError(f"--soak must be a multiple of {SOAK_INTERVAL} and at least {SOAK_MIN}")
    result = json.loads(run([binary, FIXTURE, count], timeout=3600).stdout)
    samples = dict(result["rss_kib"])
    window = (SOAK_WARMUP, count)
    result["growth_kib_after_warmup"] = samples[window[1]] - samples[window[0]]
    result["window"] = window
    return result


def relative(text):
    return text.replace(str(ROOT) + "/", "")


def summarized(value):
    """The oracle row with very long strings replaced by their length and digest."""
    if isinstance(value, str) and len(value) > EVIDENCE_STRING_LIMIT:
        return {"long_string_utf8_bytes": len(value.encode()),
                "sha256": hashlib.sha256(value.encode()).hexdigest()}
    if isinstance(value, list):
        return [summarized(item) for item in value]
    if isinstance(value, dict):
        return {summarized(key) if len(key) <= EVIDENCE_STRING_LIMIT else
                f"<key of {len(key.encode())} UTF-8 bytes, sha256 {hashlib.sha256(key.encode()).hexdigest()}>":
                summarized(item) for key, item in value.items()}
    return value


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--soak", type=int, default=0, help="inspections for the RSS soak (0 skips it)")
    parser.add_argument("--max-soak-growth-kib", type=int, default=1024)
    args = parser.parse_args()
    if args.soak and (args.soak < SOAK_MIN or args.soak % SOAK_INTERVAL):
        parser.error(f"--soak must be 0, or a multiple of {SOAK_INTERVAL} and at least {SOAK_MIN}")
    OUTPUT.mkdir(parents=True, exist_ok=True)
    report = {"schema": 1, "passed": False, "generated_utc": datetime.now(timezone.utc).isoformat(),
              "macos": run(["sw_vers", "-productVersion"]).stdout.strip(),
              "swiftc": run(["xcrun", "swiftc", "--version"]).stderr.strip() or run(["xcrun", "swiftc", "--version"]).stdout.strip()}
    try:
        report["calibration"] = calibrate()
        oracle = swiftc(OUTPUT / "oracle", "-O")
        writer = swiftc(OUTPUT / "writer", "-O", source="CreatorMetadataWriter.swift")
        regenerated = OUTPUT / "regenerated.aimodel"
        run([writer, SOURCE, regenerated])
        # The writer's dictionary order varies per process, so compare parsed JSON.
        if json.loads((regenerated / "metadata.json").read_text()) != json.loads((FIXTURE / "metadata.json").read_text()):
            raise AssertionError("committed fixture differs from CreatorMetadataWriter.swift output")
        for part in ("main.mlirb", "main.hash"):
            if (regenerated / part).read_bytes() != (FIXTURE / part).read_bytes():
                raise AssertionError(f"committed fixture {part} differs from its source")
        report["fixture_regenerated_identically"] = True
        run([tool("cargo"), "build", "--offline", "-p", "corsairs", "--bin", "corsairs", "--release"])
        cli = ROOT / "target/release/corsairs"
        assets = sorted(path.relative_to(ROOT) for top in ("fixtures", "crates") for path in (ROOT / top).rglob("*.aimodel")
                        if path.is_dir())
        named = {str(path): ROOT / path for path in assets} | edge_assets()
        oracle_rows = json.loads(run([oracle, *named.values()]).stdout)["assets"]
        # JSONSerialization escapes "/", so paths are relativized after parsing.
        retained = [{**summarized(row), "path": relative(row["path"])} for row in oracle_rows]
        (OUTPUT / "swift-oracle.json").write_text(
            '{"assets": [\n' + ",\n".join(json.dumps(row, ensure_ascii=False, sort_keys=True) for row in retained)
            + "\n]}\n")
        rows = [compare(name, path, oracle_row, cli) for (name, path), oracle_row in zip(named.items(), oracle_rows)]
        # `corsairs inspect` loads the model first, so also record what
        # Runtime::inspect_asset alone reports for each generated asset.
        binary = driver()
        for row in rows[len(assets):]:
            row["inspect_asset"] = json.loads(run([binary, named[row["asset"]], 0]).stdout)
            if ("error" in row["inspect_asset"]) != (row["outcome"] != "match"):
                row["outcome"] = "unexpected"
        # The deepest accepted values must also fit the debug build's worker stack.
        run([tool("cargo"), "build", "--offline", "-p", "corsairs", "--bin", "corsairs"])
        report["debug_cli"] = {}
        for name in DEBUG_ASSETS:
            debug = compare(name, named[name], oracle_rows[list(named).index(name)], ROOT / "target/debug/corsairs")
            report["debug_cli"][name] = debug["outcome"]
            if debug["outcome"] != "match":
                rows.append({**debug, "asset": f"{name} (debug)", "outcome": "mismatch"})
        report["assets"] = rows
        report["repository_assets"] = len(assets)
        report["repository_assets_with_creator_metadata"] = [r["asset"] for r in rows[:len(assets)] if r.get("entries")]
        failures = [r["asset"] for r in rows if r["outcome"] in ("mismatch", "unexpected")]
        failures += [r["asset"] for r in rows[:len(assets)] if r["outcome"] != "match"]
        if args.soak:
            report["soak"] = soak(binary, args.soak)
            if report["soak"]["growth_kib_after_warmup"] > args.max_soak_growth_kib:
                failures.append("soak")
        report["failures"] = failures
        report["passed"] = not failures
    finally:
        report["commands"] = COMMANDS
        # Paths are recorded relative to the checkout so the report can be retained.
        text = relative(json.dumps(report, indent=1, ensure_ascii=False))
        (OUTPUT / "report.json").write_text(text + "\n")
    print(json.dumps({"passed": report["passed"], "report": str(OUTPUT / "report.json"),
                      "failures": report.get("failures")}))
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
