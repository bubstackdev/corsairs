#!/usr/bin/env python3
"""Inventory actual b3 public exports and class members, including native classes."""
import argparse
import hashlib
import inspect
import json
from pathlib import Path
import sys
import types

sys.path.insert(0, str(Path(__file__).resolve().parent))
from environment import ROOT, FIXTURES, initialize, identity, write_json
initialize()
import coreai.authoring as authoring
import coreai.runtime as runtime

SUPPORTED = {
    "AIModel", "AIModel.load", "AIModel.function_names", "AIModel.load_function",
    "InferenceFunction", "InferenceFunction.__call__", "InferenceFunction.desc",
    "InferenceFunctionDescriptor", "InferenceFunctionDescriptor.name",
    "InferenceFunctionDescriptor.input_names", "InferenceFunctionDescriptor.output_names",
    "InferenceFunctionDescriptor.state_names", "InferenceFunctionDescriptor.input_descriptor",
    "InferenceFunctionDescriptor.output_descriptor", "InferenceFunctionDescriptor.state_descriptor",
    "NDArray", "NDArray.__init__", "NDArray.dtype", "NDArray.shape", "NDArray.strides",
    "NDArrayDescriptor", "NDArrayDescriptor.shape", "NDArrayDescriptor.dtype",
    "SpecializationOptions", "SpecializationOptions.cpu_only",
    "SpecializationOptions.from_preferred_compute_unit_kind", "ComputeUnitKind", "ComputeUnitKind.cpu",
    "ComputeUnitKind.gpu", "StorageKind", "StorageKind.BYTES",
}
COUNTERPARTS = {
    "AIModel": "corsairs::Model", "InferenceFunction": "corsairs::Function",
    "InferenceFunctionDescriptor": "corsairs::FunctionDescriptor", "NDArray": "corsairs::Tensor",
    "NDArrayDescriptor": "corsairs::TensorDescriptor", "SpecializationOptions": "corsairs::Compute",
    "ComputeUnitKind": "corsairs::Compute", "StorageKind": "owned Bytes backing",
}
SEMANTIC_DUNDERS = {"__init__", "__call__", "__enter__", "__exit__", "__getitem__", "__setitem__"}
MEMBER_COUNTERPARTS = {
    "AIModel.load": "corsairs::Runtime::load_model", "AIModel.function_names": "corsairs::Model::function_names",
    "AIModel.load_function": "corsairs::Model::load_function", "InferenceFunction.__call__": "corsairs::Function::run",
    "InferenceFunction.desc": "corsairs::Function::descriptor", "NDArray.__init__": "corsairs::Tensor::from_vec/from_bytes",
    "NDArray.dtype": "corsairs::Tensor::dtype", "NDArray.shape": "corsairs::Tensor::shape",
    "NDArray.strides": "corsairs::Tensor::strides", "NDArrayDescriptor.dtype": "corsairs::TensorDescriptor::dtype",
    "NDArrayDescriptor.shape": "corsairs::TensorDescriptor::shape",
    "SpecializationOptions.cpu_only": "corsairs::Compute::CpuOnly",
    "SpecializationOptions.from_preferred_compute_unit_kind": "corsairs::Compute::GpuPreferred (GPU choice only)",
    "ComputeUnitKind.cpu": "corsairs::Compute::CpuOnly", "ComputeUnitKind.gpu": "corsairs::Compute::GpuPreferred",
    "InferenceFunctionDescriptor.name": "corsairs::FunctionDescriptor::name",
    "InferenceFunctionDescriptor.input_names": "corsairs::FunctionDescriptor::inputs[*].name",
    "InferenceFunctionDescriptor.output_names": "corsairs::FunctionDescriptor::outputs[*].name",
    "InferenceFunctionDescriptor.state_names": "corsairs::FunctionDescriptor::states[*].name",
    "InferenceFunctionDescriptor.input_descriptor": "corsairs::FunctionDescriptor::inputs.iter().find(name)",
    "InferenceFunctionDescriptor.output_descriptor": "corsairs::FunctionDescriptor::outputs.iter().find(name)",
    "InferenceFunctionDescriptor.state_descriptor": "corsairs::FunctionDescriptor::states.iter().find(name)",
}


def signature(obj):
    try:
        return {"signature": str(inspect.signature(obj)), "signature_source": "inspect.signature"}
    except (ValueError, TypeError):
        doc = inspect.getdoc(obj) or ""
        return {"signature": None, "signature_source": "native descriptor; signature unavailable via inspect",
                "native_doc": doc}


def entry(surface, name, obj, kind, exported=True):
    private = name.split(".")[0].startswith("_")
    supported = surface == "runtime" and name in SUPPORTED and not private
    cls_name = name.split(".")[0]
    row = {"surface": surface, "name": name, "kind": kind, "declared_in_all": exported,
           "public": not private, "v0_1_scope": "supported" if supported else "deferred",
           "verification": "pending Rust differential validation" if supported else "outside v0.1",
           "rust_counterpart": MEMBER_COUNTERPARTS.get(name, COUNTERPARTS.get(cls_name)) if supported else None,
           "deferral_reason": None if supported else ("Rust graph authoring deferred" if surface == "authoring" else "Outside the limited v0.1 runtime surface"),
           "scope_note": "Supported entries describe planned v0.1 features, not evidence of complete class parity. Tensor support is owned contiguous Bytes f16/f32/i32/i64/bool; CPU-only and GPU-preferred."
                         if supported else None}
    if isinstance(obj, property):
        row.update(signature(obj.fget))
        row["writable"] = obj.fset is not None
    elif callable(obj):
        row.update(signature(obj))
    else:
        row["signature"] = None
        row["value_type"] = type(obj).__name__
    return row


rows = []
counts = {}
for surface, module in [("runtime", runtime), ("authoring", authoring)]:
    declared = set(module.__all__)
    # Include public reachable symbols omitted from __all__ (notably StorageKind),
    # excluding imported package modules themselves.
    names = declared | {name for name, obj in vars(module).items()
                        if not name.startswith("_") and not isinstance(obj, types.ModuleType)}
    top = 0
    for name in sorted(names):
        obj = getattr(module, name)
        rows.append(entry(surface, name, obj, "class" if inspect.isclass(obj) else "function" if callable(obj) else "value", name in declared))
        top += 1
        if not inspect.isclass(obj):
            continue
        for member in sorted(dir(obj)):
            if member.startswith("_") and member not in SEMANTIC_DUNDERS:
                continue
            descriptor = inspect.getattr_static(obj, member)
            if isinstance(descriptor, (staticmethod, classmethod)):
                descriptor = descriptor.__func__
            owner = next((base for base in obj.__mro__ if member in vars(base)), obj)
            # Standard inherited object/string/enum convenience methods are not
            # package API entries; own overrides and CoreAI base members are.
            if owner.__module__ in ["builtins", "enum"]:
                continue
            row = entry(surface, f"{name}.{member}", descriptor,
                        "property" if isinstance(descriptor, property) or inspect.isgetsetdescriptor(descriptor) else "method" if callable(descriptor) else "attribute", name in declared)
            row["declaring_class"] = f"{owner.__module__}.{owner.__qualname__}"
            rows.append(row)
    counts[surface] = {"top_level_exports": top, "entries_including_class_members": len([r for r in rows if r["surface"] == surface])}

report = {"reference": identity(), "counts": counts, "entries": rows,
          "method": "Runtime imports of pinned wheel; module __all__ union public nonmodule symbols; public class members and semantic construction/call/context/index dunders; inherited builtin/enum methods excluded.",
          "limits": ["No native descriptor signature is invented where inspect.signature is unavailable; native docstrings are retained.",
                     "Support is scoped per member and constrained by scope_note; exporting a Rust Model does not mean every Python Model behavior is supported.",
                     "Private declared exports are retained with public=false; unsupported raw coreai._compiler is outside published stable public API."]}
native_path = FIXTURES / "backend-goldens.json"
if native_path.exists():
    native = json.loads(native_path.read_text())
    exercised = {
        "AIModel.load", "AIModel.load_function", "InferenceFunction.__call__", "InferenceFunction.desc",
        "InferenceFunctionDescriptor.name", "InferenceFunctionDescriptor.input_names", "InferenceFunctionDescriptor.output_names",
        "InferenceFunctionDescriptor.state_names", "NDArray.__init__", "NDArray.dtype", "NDArray.shape", "NDArray.strides",
        "SpecializationOptions.cpu_only", "SpecializationOptions.from_preferred_compute_unit_kind",
        "SpecializationOptions.allowed_compute_unit_kinds", "SpecializationOptions.preferred_compute_unit_kind", "ComputeUnitKind.gpu",
    }
    report["native_python_reference"] = {
        "evidence": "backend-goldens.json", "executed_positive_cases": native["native_execution_successes"],
        "negative_expected_errors": native["negative_reference_errors"],
        "reference_to_math": "31 matching configurations; GPU-preferred float_edges differs in NaN payload and subnormal result",
        "rust_verification": "pending; Python execution alone does not establish Rust parity",
    }
    for row in rows:
        row["differential_fixture"] = "fixtures/parity-v01/suite.json" if row["v0_1_scope"] == "supported" else None
        if row["surface"] == "runtime" and row["name"] in exercised:
            row["native_python_validation"] = "Exercised by the 32-case CPU/GPU-preferred reference grid; member behavior sampled, not exhaustive"
            row["native_python_evidence"] = "fixtures/parity-v01/backend-goldens.json"

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--rust-report", type=Path, action="append", default=[],
                    help="Retained successful native v0.1 report; may be repeated for debug/release")
args = parser.parse_args()
if not args.rust_report:
    args.rust_report = [path for profile in ["debug", "release"]
                       if (path := ROOT / "docs/evidence/v0.1" / f"checks-{profile}.json").is_file()]
rust_evidence = []
verified_profiles = set()
for path in args.rust_report:
    path = path.resolve()
    retained = json.loads(path.read_text())
    if not (retained.get("passed") and retained.get("native_validated") and retained.get("public_api_only")
            and retained.get("driver_forbids_unsafe")):
        raise RuntimeError(f"Rust report lacks a successful native public-API result: {path}")
    if retained["fixtures"]["goldens_sha256"] != hashlib.sha256(native_path.read_bytes()).hexdigest():
        raise RuntimeError(f"Rust report used different frozen Python goldens: {path}")
    manifest_path = path.parent / "build-manifest.json"
    if hashlib.sha256(manifest_path.read_bytes()).hexdigest() != retained["build_manifest_sha256"]:
        raise RuntimeError(f"Retained Rust build manifest differs: {manifest_path}")
    manifest = json.loads(manifest_path.read_text())
    if manifest["source_hashes"] != retained["source_hashes"]:
        raise RuntimeError("Retained build/report source identities differ")
    for profile in retained["profiles"]:
        commands = [row for row in retained["commands"] if Path(row["command"][0]).name == f"driver-{profile}"]
        events = [event for row in commands for event in row.get("events", [])]
        if len([row for row in events if row.get("event") == "parity" and row.get("passed")]) != 32:
            raise RuntimeError(f"Rust report does not cover all 32 {profile} configurations")
        if len([row for row in events if row.get("event") == "negative" and row.get("passed")]) != 16:
            raise RuntimeError(f"Rust report does not cover all 16 {profile} negatives")
        if len([row for row in events if row.get("event") == "stress" and row.get("passed")]) != 2:
            raise RuntimeError(f"Rust report lacks both {profile} backend lifecycle probes")
        if (retained["stress"]["stateless_and_stateful_each"] < 10000 or retained["stress"]["load_drop"] < 100
                or retained["stress"]["dropped_each_kind"] < 100):
            raise RuntimeError(f"Rust lifecycle report does not meet the retained release counts: {path}")
        verified_profiles.add(profile)
    relative = str(path.relative_to(ROOT))
    rust_evidence.append({"report": relative, "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        "profiles": retained["profiles"], "source_identity_sha256": retained["source_identity_sha256"],
        "build_manifest_sha256": retained["build_manifest_sha256"], "stress": retained["stress"],
        "driver_sha256": retained["driver_sha256"]})
if rust_evidence:
    report["rust_safe_api_evidence"] = rust_evidence
    report["rust_evidence_limit"] = "Only the bounded v0.1 runtime argument/storage/dtype subset is exercised. Reports bind the recorded source/binary snapshots; they do not establish full Python API or authoring parity."
    report["native_python_reference"]["rust_verification"] = "Bounded safe-API subset validated in retained reports; complete Python API parity unclaimed"
    for row in rows:
        if row["v0_1_scope"] == "supported":
            row["verification"] = f"bounded v0.1 subset validated ({', '.join(sorted(verified_profiles))}); full Python API parity unclaimed"
            row["rust_safe_api_reports"] = [item["report"] for item in rust_evidence]
write_json(FIXTURES / "api-inventory.json", report)
lines = ["# Published coreai-core 1.0.0b3 API inventory", "", f"Wheel SHA-256: `{identity()['wheel_sha256']}`.", "",
         "Each row marks planned v0.1 scope. Passing Rust evidence is tracked separately; this inventory does not claim full parity.", "",
         "All graph authoring is deferred. Runtime support is limited to owned contiguous Bytes tensors (f16/f32/i32/i64/bool), named inputs/outputs/state, descriptors, model/function loading, CPU-only and GPU-preferred choices. NumPy/DLPack interop, image/storage variants, diagnostics, cancellation, Neural Engine, and the other members below remain deferred.", ""]
if native_path.exists():
    lines += ["The pinned Python reference executed all 32 positive configurations and reported 16 expected negative errors. 31 configurations matched independent math expectations; GPU-preferred `float_edges` flushed a subnormal and canonicalized a NaN payload. Backend-specific exact-byte goldens preserve these observations. Rust safe-API validation is recorded separately below.", ""]
if rust_evidence:
    profiles = ", ".join(sorted(verified_profiles))
    links = ", ".join(f"[{Path(item['report']).name}](../../{item['report']})" for item in rust_evidence)
    lines += [f"The bounded safe Rust subset passed all 32 positive and 16 typed negative configurations in {profiles}, plus 10,000 stateless and 10,000 stateful calls per backend/profile, 100 load/drop cycles, and 100 abandoned futures of each tested kind. Retained source/binary snapshots: {links}. These results establish the tested v0.1 subset on the recorded host; they do not establish full Python class/argument behavior, authoring parity, or other OS/SDK support.", ""]
for surface in ["runtime", "authoring"]:
    lines += [f"## {surface}", "", f"{counts[surface]['top_level_exports']} top-level exports; {counts[surface]['entries_including_class_members']} entries including class members.", "",
              "| Entry | Kind | v0.1 | Verification | Signature |", "| --- | --- | --- | --- | --- |"]
    for row in rows:
        if row["surface"] != surface or not row["public"]:
            continue
        sig = (row.get("signature") or "native/unavailable").replace("|", "\\|").replace("\n", " ")
        verification = f"tested subset ({', '.join(sorted(verified_profiles))})" if rust_evidence and row["v0_1_scope"] == "supported" else "pending" if row["v0_1_scope"] == "supported" else "deferred"
        lines.append(f"| `{row['name']}` | {row['kind']} | {row['v0_1_scope']} | {verification} | `{sig}` |")
    lines.append("")
(FIXTURES / "API-INVENTORY.md").write_text("\n".join(lines))
print(json.dumps(counts), flush=True)
