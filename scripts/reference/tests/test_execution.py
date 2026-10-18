"""Reference acceptance regressions; no native bindings or dependencies needed."""
import argparse
import asyncio
import builtins
import contextlib
import copy
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from types import ModuleType
import unittest
from unittest.mock import Mock, patch

REFERENCE = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REFERENCE))
import freeze_goldens
import run_suite


class ReferenceExecutionTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.fixtures = Path(self.temporary.name)
        self.case = {"name": "double_float32"}
        (self.fixtures / "suite.json").write_text(json.dumps({"cases": [self.case]}))

    def run_observation(self, status="passed", returncode=0, os_backed=True, stdout=None):
        observation = {"status": status, "os_backed": os_backed}
        completed = subprocess.CompletedProcess(
            ["reference-child"], returncode,
            json.dumps(observation) + "\n" if stdout is None else stdout,
            "native teardown diagnostic")
        args = argparse.Namespace(case=self.case["name"], child=False, backend="cpu", negative=None,
                                  report=str(self.fixtures / "report.json"), timeout=1)
        with patch.object(run_suite, "FIXTURES", self.fixtures), \
             patch.object(run_suite, "identity", return_value={}), \
             patch.object(run_suite.subprocess, "run", return_value=completed) as child, \
             contextlib.redirect_stdout(io.StringIO()):
            exit_code = run_suite.suite_main(args)
        return exit_code, json.loads(Path(args.report).read_text()), child

    def test_clean_success_and_expected_error_remain_successful(self):
        for status in ["passed", "expected_error"]:
            with self.subTest(status=status):
                exit_code, report, _ = self.run_observation(status=status)
                self.assertEqual(exit_code, 0)
                self.assertTrue(report["passed"])

    def test_success_json_cannot_hide_an_abnormal_exit(self):
        for status in ["passed", "expected_error"]:
            for returncode in [-11, -6, 1, 23]:
                with self.subTest(status=status, returncode=returncode):
                    exit_code, report, _ = self.run_observation(status=status, returncode=returncode)
                    self.assertEqual(exit_code, 1)
                    self.assertFalse(report["passed"])
                    row = report["results"][0]
                    self.assertEqual(row["status"], "native_failure")
                    self.assertEqual(row["reported_status"], status)
                    self.assertEqual(row["returncode"], returncode)
                    self.assertIn("native teardown diagnostic", row["stderr"])

    def test_mismatch_is_recorded_but_never_passes_the_suite(self):
        exit_code, report, _ = self.run_observation(status="mismatch", returncode=1)
        self.assertEqual(exit_code, 1)
        self.assertFalse(report["passed"])
        self.assertEqual(report["results"][0]["status"], "mismatch")

    def test_malformed_child_output_is_a_failed_observation(self):
        for stdout in ["", "native failure", "[]", '{"status": [], "os_backed": true}']:
            with self.subTest(stdout=stdout):
                exit_code, report, _ = self.run_observation(stdout=stdout)
                self.assertEqual(exit_code, 1)
                self.assertFalse(report["passed"])
                self.assertEqual(report["results"][0]["status"], "native_failure")

    def test_parent_rejects_missing_or_alternate_os_backing(self):
        for backing in [False, None, 1, "true"]:
            with self.subTest(backing=backing):
                exit_code, report, _ = self.run_observation(os_backed=backing)
                self.assertEqual(exit_code, 1)
                self.assertFalse(report["passed"])
                self.assertIn("OS Core AI", report["results"][0]["validation_error"])

    def test_parent_overrides_inherited_local_framework_selection(self):
        with patch.dict(os.environ, {"USE_LOCAL_COREAI": "0", "REFERENCE_TEST_TOKEN": "keep"}):
            _, _, child = self.run_observation()
            environment = child.call_args.kwargs["env"]
            self.assertEqual(environment["USE_OS_COREAI"], "1")
            self.assertNotIn("USE_LOCAL_COREAI", environment)
            self.assertEqual(environment["REFERENCE_TEST_TOKEN"], "keep")
            self.assertEqual(os.environ["USE_LOCAL_COREAI"], "0")

    def test_child_rejects_alternate_backing_before_model_work_even_for_negatives(self):
        runtime = ModuleType("coreai.runtime")
        runtime._use_os_coreai = False
        for name in ["AIModel", "ComputeUnitKind", "NDArray", "SpecializationOptions"]:
            setattr(runtime, name, Mock())
        coreai = ModuleType("coreai")
        coreai.runtime = runtime
        original_import = builtins.__import__

        def check_import(name, *args, **kwargs):
            if name == "coreai.runtime":
                self.assertEqual(os.environ["USE_OS_COREAI"], "1")
                self.assertNotIn("USE_LOCAL_COREAI", os.environ)
            return original_import(name, *args, **kwargs)

        with patch.dict(sys.modules, {"coreai": coreai, "coreai.runtime": runtime}), \
             patch.dict(os.environ, {"USE_LOCAL_COREAI": "0"}), \
             patch("builtins.__import__", new=check_import), \
             patch.object(run_suite, "FIXTURES", self.fixtures), \
             contextlib.redirect_stdout(io.StringIO()):
            exit_code = asyncio.run(run_suite.run_child(self.case, "cpu", "missing_asset"))
            self.assertEqual(os.environ["USE_OS_COREAI"], "1")
            self.assertNotIn("USE_LOCAL_COREAI", os.environ)
        self.assertEqual(exit_code, 1)
        report = json.loads((self.fixtures / "results/cpu/double_float32/missing_asset/observation.json").read_text())
        self.assertEqual(report["status"], "error")
        self.assertEqual(report["failure_stage"], "reference_backing")
        runtime.AIModel.load.assert_not_called()
        runtime.SpecializationOptions.cpu_only.assert_not_called()


class GoldenFreezingTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.fixtures = Path(self.temporary.name)
        self.report = json.loads((freeze_goldens.FIXTURES / "python-results.json").read_text())

    def write_report(self):
        # A fresh reviewed regeneration, so the original-file guard cannot mask
        # a missing execution check in the freezer.
        (self.fixtures / "python-results.json").write_text(json.dumps(self.report))

    def copy_payloads(self):
        for row in self.report["results"]:
            for step in row.get("steps", []):
                for group in step.values():
                    for tensor in group.values():
                        destination = self.fixtures / tensor["file"]
                        destination.parent.mkdir(parents=True, exist_ok=True)
                        destination.write_bytes((freeze_goldens.FIXTURES / tensor["file"]).read_bytes())

    def assert_rejected_before_writes(self):
        self.write_report()
        with self.assertRaisesRegex(RuntimeError, "Invalid native reference"):
            freeze_goldens.freeze(self.fixtures)
        self.assertFalse((self.fixtures / "python-results.initial.json").exists())
        self.assertFalse((self.fixtures / "goldens").exists())
        self.assertFalse((self.fixtures / "backend-goldens.json").exists())

    def test_rejects_crashed_success_and_expected_error_rows(self):
        original = copy.deepcopy(self.report)
        for status in ["passed", "expected_error"]:
            for returncode in [-11, -6, 1, 23, None, False]:
                with self.subTest(status=status, returncode=returncode):
                    self.report = copy.deepcopy(original)
                    row = next(row for row in self.report["results"] if row["status"] == status)
                    row["returncode"] = returncode
                    self.assert_rejected_before_writes()

    def test_reviewed_mismatch_still_requires_normal_exit_one(self):
        row = next(row for row in self.report["results"] if row["status"] == "mismatch")
        for returncode in [-11, -6, 0, 23, None]:
            with self.subTest(returncode=returncode):
                row["returncode"] = returncode
                self.assert_rejected_before_writes()

    def test_rejects_alternate_or_missing_backing_in_any_row(self):
        for backing in [False, None, 1, "true"]:
            with self.subTest(backing=backing):
                self.report["results"][-1]["os_backed"] = backing
                self.assert_rejected_before_writes()

    def test_retained_os_reference_and_reviewed_mismatch_still_freeze(self):
        self.copy_payloads()
        self.write_report()
        with contextlib.redirect_stdout(io.StringIO()):
            freeze_goldens.freeze(self.fixtures)
        goldens = json.loads((self.fixtures / "backend-goldens.json").read_text())
        self.assertEqual(goldens["native_execution_successes"], 32)
        self.assertEqual(goldens["negative_reference_errors"], 16)
        mismatches = [row for row in goldens["cases"] if row["reference_to_math"] == "mismatch"]
        self.assertEqual([(row["backend"], row["case"]) for row in mismatches],
                         [("gpu-preferred", "float_edges")])
        # The immutable snapshot remains enforced on subsequent regenerations.
        self.report["results"][0]["elapsed_seconds"] += 1
        self.write_report()
        with self.assertRaisesRegex(RuntimeError, "Original reference observations changed"):
            freeze_goldens.freeze(self.fixtures)

    def test_normal_exit_does_not_bypass_the_mismatch_digest_review(self):
        self.copy_payloads()
        row = next(row for row in self.report["results"] if row["status"] == "mismatch")
        row["steps"][0]["outputs"]["y"]["sha256"] = "unreviewed"
        self.write_report()
        with self.assertRaisesRegex(RuntimeError, "Unreviewed Python-to-math mismatch"):
            freeze_goldens.freeze(self.fixtures)


class SupplementaryFreezingTests(GoldenFreezingTests):
    BACKEND = "neural-engine-preferred"

    def setUp(self):
        super().setUp()
        self.report = json.loads((freeze_goldens.FIXTURES / f"python-results-{self.BACKEND}.json").read_text())

    def write_report(self):
        (self.fixtures / f"python-results-{self.BACKEND}.json").write_text(json.dumps(self.report))

    def assert_rejected_before_writes(self):
        self.write_report()
        with self.assertRaisesRegex(RuntimeError, "Invalid native reference"):
            freeze_goldens.freeze_supplement(self.BACKEND, self.fixtures)
        self.assertFalse((self.fixtures / f"python-results-{self.BACKEND}.initial.json").exists())
        self.assertFalse((self.fixtures / "goldens").exists())
        self.assertFalse((self.fixtures / f"backend-goldens-{self.BACKEND}.json").exists())

    def test_retained_os_reference_and_reviewed_mismatch_still_freeze(self):
        self.copy_payloads()
        self.write_report()
        with contextlib.redirect_stdout(io.StringIO()):
            freeze_goldens.freeze_supplement(self.BACKEND, self.fixtures)
        goldens = json.loads((self.fixtures / f"backend-goldens-{self.BACKEND}.json").read_text())
        self.assertEqual((goldens["native_execution_successes"], goldens["negative_reference_errors"]), (16, 8))
        self.assertEqual(goldens["python_to_math_mismatches"], ["float_edges"])
        # Freezing a supplement never creates or alters the original grid.
        self.assertFalse((self.fixtures / "backend-goldens.json").exists())
        self.report["results"][0]["elapsed_seconds"] += 1
        self.write_report()
        with self.assertRaisesRegex(RuntimeError, "Original reference observations changed"):
            freeze_goldens.freeze_supplement(self.BACKEND, self.fixtures)

    def test_normal_exit_does_not_bypass_the_mismatch_digest_review(self):
        self.copy_payloads()
        row = next(row for row in self.report["results"] if row["status"] == "mismatch")
        row["steps"][0]["outputs"]["y"]["sha256"] = "unreviewed"
        self.write_report()
        with self.assertRaisesRegex(RuntimeError, "Unreviewed Python-to-math mismatch"):
            freeze_goldens.freeze_supplement(self.BACKEND, self.fixtures)

    def test_rejects_mixed_backends_and_unknown_supplements(self):
        self.report["results"][0]["backend"] = "gpu-preferred"
        self.write_report()
        with self.assertRaisesRegex(RuntimeError, "mixes backends"):
            freeze_goldens.freeze_supplement(self.BACKEND, self.fixtures)
        self.assertFalse((self.fixtures / f"python-results-{self.BACKEND}.initial.json").exists())
        with self.assertRaisesRegex(RuntimeError, "Not a supplementary backend"):
            freeze_goldens.freeze_supplement("gpu-preferred", self.fixtures)


if __name__ == "__main__":
    unittest.main()
