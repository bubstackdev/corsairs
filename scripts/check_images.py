#!/usr/bin/env python3
"""Check Corsairs image I/O byte for byte against fixtures/parity-v05/images.

Builds the corsairs library and experiments/rust/image_parity.rs, runs every
case on every backend (image inputs both tight and with padded rows), every
negative, a soak and drop/cancel cycles, then compares each output's SHA-256
with backend-goldens.json. The image set does not fit check_v01.py's tensor
grid, so its shape is pinned here instead. Writes only under --output unless
--report names an evidence path. Requires native Core AI.

    python3 -B scripts/check_images.py [--soak 10000] [--drop 100] [--report PATH]
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "fixtures/parity-v05/images"
BACKENDS = ["cpu", "gpu-preferred", "neural-engine-preferred"]
# Pinned shape: a change to the suite or goldens must update these together.
SHAPE = {"cases": 22, "image_input_cases": 19, "negatives": 7, "golden_outputs_per_backend": 23,
         "reviewed_digests": {"neural-engine-preferred": ["ARGB32_invert", "BGRA32_invert", "RGB24_invert"]}}
NEGATIVE_ERRORS = {"planar_420_run": "Unsupported", "planar_420_run_without_images": "Unsupported",
                   "wrong_format": "DescriptorMismatch", "wrong_size": "DescriptorMismatch",
                   "transposed_size": "DescriptorMismatch", "missing_image": "MissingTensor",
                   "unexpected_image": "UnexpectedTensor"}
# RSS growth allowed between the 10% sample and the end of a soak.
SOAK_RSS_GROWTH_KIB = 2048


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def run(argv, log, **kwargs):
    argv = [str(a) for a in argv]
    result = subprocess.run(argv, cwd=ROOT, capture_output=True, text=True, **kwargs)
    log.append({"command": argv, "exit_status": result.returncode, "stderr_tail": result.stderr[-2000:]})
    if result.returncode:
        raise RuntimeError(f"{argv[0]} failed ({result.returncode}): {result.stderr[-4000:]}")
    return result.stdout


def build(output, release, log):
    command = ["cargo", "build", "--offline", "-p", "corsairs", "--lib", "--message-format=json"]
    if release:
        command.append("--release")
    events = run(command, log)
    libraries = [Path(f) for line in events.splitlines() if line.startswith("{") for e in [json.loads(line)]
                 if e.get("reason") == "compiler-artifact" and e.get("target", {}).get("name") == "corsairs"
                 for f in e.get("filenames", []) if f.endswith(".rlib")]
    if len(libraries) != 1:
        raise RuntimeError("expected one corsairs library artifact")
    executable = output / "image-parity"
    command = ["rustc", "--edition=2024", "-Dwarnings", ROOT / "experiments/rust/image_parity.rs",
               "--extern", f"corsairs={libraries[0]}", "-L", f"dependency={libraries[0].parent}", "-o", executable]
    if release:
        command += ["-C", "opt-level=3"]
    run(command, log)
    return executable


def plan(suite, backends, soak, drops):
    lines = [f"backend {b}" for b in backends]
    for case in suite["cases"]:
        lines.append(f"case {case['name']} {case['model']}")
        for name, value in case["inputs"].items():
            if "image" in value:
                i = value["image"]
                lines.append(f"image {name} {i['os_type']} {i['width']} {i['height']} {i['file']}")
            else:
                t = value["tensor"]
                lines.append(f"tensor {name} {','.join(map(str, t['shape']))} {t['file']}")
    for negative in suite["negatives"]:
        lines.append(f"negative {negative['name']} {negative['model']} {negative['expected_error']}")
        for name, i in negative["images"].items():
            lines.append(f"request {name} {suite['formats'][i['format']]['os_type']} {i['width']} {i['height']}")
    if soak:
        lines.append(f"soak BGRA32_identity/model.aimodel {soak}")
    if drops:
        lines.append(f"drop RGB24_identity_3x5/model.aimodel {drops}")
    return "\n".join(lines) + "\n"


def expected_descriptor(case):
    def images(group):
        return [{"name": n, "os_type": v["image"]["os_type"], "width": v["image"]["width"],
                 "height": v["image"]["height"], "supported": True} for n, v in sorted(group.items()) if "image" in v]
    def tensors(group):
        return [n for n, v in sorted(group.items()) if "tensor" in v]
    return {"inputs": tensors(case["inputs"]), "outputs": tensors(case["outputs"]),
            "image_inputs": images(case["inputs"]), "image_outputs": images(case["outputs"])}


def normalized(descriptor):
    # Native descriptor order is the signature's; compare as sorted sets.
    return {"inputs": sorted(descriptor["inputs"]), "outputs": sorted(descriptor["outputs"]),
            "image_inputs": sorted(descriptor["image_inputs"], key=lambda d: d["name"]),
            "image_outputs": sorted(descriptor["image_outputs"], key=lambda d: d["name"])}


def compare(suite, goldens, report, backends, out):
    failures = []
    cases = {c["name"]: c for c in suite["cases"]}
    seen = set()
    for row in report["runs"]:
        case, backend, variant = cases[row["case"]], row["backend"], row["variant"]
        seen.add((case["name"], backend, variant))
        where = f"{case['name']} {backend} {variant}"
        if row["outcome"] != "completed":
            failures.append(f"{where}: {row['outcome']}")
            continue
        if normalized(row["descriptor"]) != expected_descriptor(case):
            failures.append(f"{where}: descriptor {row['descriptor']}")
        produced = {o["name"]: o for o in row["outputs"]}
        if set(produced) != set(case["outputs"]):
            failures.append(f"{where}: outputs {sorted(produced)}")
            continue
        row["sha256"] = {}
        for name, spec in case["outputs"].items():
            data = (out / backend / case["name"] / variant / f"{name}.bin").read_bytes()
            digest = row["sha256"][name] = sha256(data)
            golden = goldens["backends"][backend][case["name"]][name]
            if digest != golden["sha256"]:
                failures.append(f"{where}: {name} {digest} != golden {golden['sha256']}")
            value = spec.get("image") or spec["tensor"]
            if "image" in spec and (produced[name]["os_type"], produced[name]["width"], produced[name]["height"]) != (
                    value["os_type"], value["width"], value["height"]):
                failures.append(f"{where}: {name} image metadata {produced[name]}")
    wanted = {(c["name"], b, v) for c in suite["cases"] for b in backends
              for v in (["tight", "padded"] if any("image" in i for i in c["inputs"].values()) else ["tight"])}
    if seen != wanted:
        failures.append(f"run grid mismatch: missing {sorted(wanted - seen)[:5]}, extra {sorted(seen - wanted)[:5]}")
    negatives = [c for c in report["checks"] if c["check"] == "negative"]
    for check in report["checks"]:
        if not check["passed"]:
            failures.append(f"check failed: {check}")
    for check in negatives:
        if NEGATIVE_ERRORS[check["case"]] != check["expected"]:
            failures.append(f"negative {check['case']} expectation changed")
        if check["case"].startswith("planar"):
            image = check["descriptor"]["image_inputs"]
            if image != [{"name": "x", "os_type": 0x79343230, "width": 4, "height": 2, "supported": False}]:
                failures.append(f"planar descriptor {image}")
    if len(negatives) != len(NEGATIVE_ERRORS) * len(backends):
        failures.append("negative grid mismatch")
    for soak in report["soak"]:
        samples = [s["rss_kib"] for s in soak["rss_samples"]]
        soak["rss_growth_after_warmup_kib"] = samples[-1] - samples[1]
        if soak["mismatches"] or soak["rss_growth_after_warmup_kib"] > SOAK_RSS_GROWTH_KIB:
            failures.append(f"soak {soak['backend']}: {soak['mismatches']} mismatches, "
                            f"{soak['rss_growth_after_warmup_kib']} KiB growth")
    for drop in report["drop"]:
        if not drop["run_after_drain"]:
            failures.append(f"drop {drop['backend']}: no run after drain")
    return failures


def check_goldens(suite, goldens, backends):
    failures = []
    for backend in backends:
        table = goldens["backends"][backend]
        outputs = sum(len(c["outputs"]) for c in suite["cases"])
        if outputs != SHAPE["golden_outputs_per_backend"] or sum(len(v) for v in table.values()) != outputs:
            failures.append(f"{backend}: golden output count")
        reviewed = sorted(c for c, outs in table.items() if any(o.get("reviewed") for o in outs.values()))
        if reviewed != SHAPE["reviewed_digests"].get(backend, []):
            failures.append(f"{backend}: reviewed digests {reviewed}")
    image_inputs = sum(any("image" in v for v in c["inputs"].values()) for c in suite["cases"])
    if (len(suite["cases"]), image_inputs, len(suite["negatives"])) != (
            SHAPE["cases"], SHAPE["image_input_cases"], SHAPE["negatives"]):
        failures.append("suite shape changed")
    return failures


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--backends", nargs="+", choices=BACKENDS, default=BACKENDS)
    parser.add_argument("--soak", type=int, default=10000, help="soak iterations per backend (0 skips)")
    parser.add_argument("--drop", type=int, default=100, help="dropped and cancelled requests per backend")
    parser.add_argument("--debug", action="store_true", help="build without optimization")
    parser.add_argument("--output", type=Path, default=ROOT / "target/images")
    parser.add_argument("--report", type=Path, help="also write the report here (evidence)")
    args = parser.parse_args()
    output = args.output.resolve()
    if output.exists():
        shutil.rmtree(output)
    output.mkdir(parents=True)
    suite = json.loads((FIXTURES / "suite.json").read_text())
    goldens = json.loads((FIXTURES / "backend-goldens.json").read_text())
    log = []
    executable = build(output, not args.debug, log)
    (output / "plan.txt").write_text(plan(suite, args.backends, args.soak, args.drop))
    (output / "fixtures-root").write_text(str(FIXTURES) + "\n")
    stdout = run([executable, output / "plan.txt", output / "outputs"], log, timeout=7200)
    driver = json.loads(stdout)
    failures = check_goldens(suite, goldens, args.backends) + compare(
        suite, goldens, driver, args.backends, output / "outputs")
    report = {"schema": 1, "passed": not failures, "generated_utc": datetime.now(timezone.utc).isoformat(),
              "host": {"macos": platform.mac_ver()[0], "machine": platform.machine()},
              "profile": "debug" if args.debug else "release", "backends": args.backends,
              "shape": SHAPE, "failures": failures,
              "summary": {"runs": len(driver["runs"]), "checks": len(driver["checks"]),
                          "soak": [{k: s[k] for k in ["backend", "iterations", "mismatches", "seconds",
                                                      "rss_growth_after_warmup_kib"]} for s in driver["soak"]],
                          "drop": driver["drop"]},
              "sources": {str(p.relative_to(ROOT)): sha256(p.read_bytes()) for p in [
                  ROOT / "experiments/rust/image_parity.rs", ROOT / "scripts/check_images.py",
                  FIXTURES / "suite.json", FIXTURES / "backend-goldens.json",
                  *sorted((ROOT / "crates/corsairs-abi/src").rglob("*.rs"))]},
              "driver": driver, "commands": log}
    (output / "report.json").write_text(json.dumps(report, indent=1) + "\n")
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, indent=1) + "\n")
    print(json.dumps({"passed": report["passed"], "failures": failures[:20], "summary": report["summary"],
                      "report": str(args.report or output / "report.json")}, indent=1))
    if failures:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
