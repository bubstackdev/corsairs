"""check_v01.prepare_data must reject golden sets that silently shrink coverage."""
import json
from pathlib import Path
import shutil
import sys
import tempfile
import unittest

SCRIPTS = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(SCRIPTS))
import check_v01  # noqa: E402


class GoldenGridShapeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temporary = tempfile.TemporaryDirectory()
        root = Path(cls.temporary.name)
        for name in ["parity-v01", "parity-v04"]:
            shutil.copytree(check_v01.ROOT / "fixtures" / name, root / "fixtures" / name)
        cls.fixtures = root / "fixtures" / "parity-v01"
        cls.output = root / "output"

    @classmethod
    def tearDownClass(cls):
        cls.temporary.cleanup()

    def setUp(self):
        self.originals = {}
        self.patches = [(check_v01, "FIXTURES", self.fixtures), (check_v01, "OUTPUT", self.output)]
        self.saved = [(module, name, getattr(module, name)) for module, name, _ in self.patches]
        for module, name, value in self.patches:
            setattr(module, name, value)

    def tearDown(self):
        for path, payload in self.originals.items():
            path.write_text(payload)
        for module, name, value in self.saved:
            setattr(module, name, value)

    def edit(self, relative, change):
        path = self.fixtures / relative
        self.originals.setdefault(path, path.read_text())
        goldens = json.loads(path.read_text())
        change(goldens)
        path.write_text(json.dumps(goldens))

    def test_retained_goldens_have_the_pinned_shape(self):
        result = check_v01.prepare_data()
        self.assertEqual((result["cases"], result["negative_cases"]), (181, 24))

    def test_emptied_set_is_rejected(self):
        self.edit("../parity-v04/float8/backend-goldens.json", lambda g: g.update(cases=[]))
        with self.assertRaisesRegex(RuntimeError, "shape changed"):
            check_v01.prepare_data()

    def test_dropped_backend_is_rejected(self):
        def drop(goldens):
            for key in ["cases", "native_errors"]:
                goldens[key] = [row for row in goldens[key] if row["backend"] != "neural-engine-preferred"]
        self.edit("../parity-v04/scalar-types/backend-goldens.json", drop)
        with self.assertRaisesRegex(RuntimeError, "shape changed"):
            check_v01.prepare_data()

    def test_success_relabelled_as_native_error_is_rejected(self):
        def relabel(goldens):
            row = goldens["cases"].pop()
            goldens["native_errors"].append({"backend": row["backend"], "case": row["case"],
                                             "python_error_type": "RuntimeError", "python_error": "invented"})
            goldens["cases"].append(goldens["cases"][0])  # keep the count; duplicate a pair
            goldens["native_errors"].pop(0)
        self.edit("../parity-v04/scalar-types/backend-goldens.json", relabel)
        with self.assertRaisesRegex(RuntimeError, "exactly once|Unreviewed native error"):
            check_v01.prepare_data()

    def test_unreviewed_native_error_text_is_rejected(self):
        self.edit("../parity-v04/scalar-types/backend-goldens.json",
                  lambda g: g["native_errors"][0].update(python_error="something else"))
        with self.assertRaisesRegex(RuntimeError, "Unreviewed native error"):
            check_v01.prepare_data()

    def test_missing_negative_backend_is_rejected(self):
        def swap(goldens):
            goldens["negative_cases"][0] = dict(goldens["negative_cases"][1])
        self.edit("backend-goldens.json", swap)
        with self.assertRaisesRegex(RuntimeError, "Negative grid"):
            check_v01.prepare_data()


if __name__ == "__main__":
    unittest.main()
