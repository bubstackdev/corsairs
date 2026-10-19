"""check_images.verify_fixtures must reject any change to the frozen image set."""
import hashlib
import json
from pathlib import Path
import shutil
import sys
import tempfile
import unittest

SCRIPTS = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(SCRIPTS))
sys.path.insert(0, str(SCRIPTS / "reference"))
import check_images  # noqa: E402
import freeze_image_goldens  # noqa: E402


def sha256(data):
    return hashlib.sha256(data).hexdigest()


class ImageFixtureIdentityTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.fixtures = Path(self.temporary.name) / "images"
        shutil.copytree(check_images.FIXTURES, self.fixtures)

    def tearDown(self):
        self.temporary.cleanup()

    def edit_json(self, name, change):
        path = self.fixtures / name
        value = json.loads(path.read_text())
        change(value)
        path.write_text(json.dumps(value, indent=1, sort_keys=True) + "\n")

    def test_frozen_set_verifies(self):
        self.assertEqual(check_images.verify_fixtures(self.fixtures), [])

    def test_checker_and_freezer_list_the_same_files(self):
        self.assertEqual(check_images.fixture_files(self.fixtures),
                         freeze_image_goldens.fixture_files(self.fixtures))

    def test_edited_input_with_matching_goldens_is_rejected(self):
        path = self.fixtures / "BGRA32_to_tensor/x.bin"
        data = bytearray(path.read_bytes())
        data[0] ^= 0xFF
        path.write_bytes(bytes(data))
        expected = self.fixtures / "BGRA32_to_tensor/expected-y.bin"
        expected.write_bytes(bytes(data))

        def goldens(value):
            for table in value["backends"].values():
                table["BGRA32_to_tensor"]["y"].update(sha256=sha256(data), hex=bytes(data).hex())
        self.edit_json("backend-goldens.json", goldens)
        failures = check_images.verify_fixtures(self.fixtures)
        self.assertIn("fixture file changed: BGRA32_to_tensor/x.bin", failures)
        self.assertIn("fixture file changed: backend-goldens.json", failures)

    def test_swapped_model_is_rejected(self):
        source = self.fixtures / "BGRA32_aligned_to_tensor/model.aimodel"
        target = self.fixtures / "BGRA32_to_tensor/model.aimodel"
        shutil.rmtree(target)
        shutil.copytree(source, target)
        failures = check_images.verify_fixtures(self.fixtures)
        self.assertIn("fixture file changed: BGRA32_to_tensor/model.aimodel/main.mlirb", failures)

    def test_added_and_missing_files_are_rejected(self):
        (self.fixtures / "BGRA32_to_tensor/graph.mlir").rename(self.fixtures / "BGRA32_to_tensor/extra.mlir")
        failures = check_images.verify_fixtures(self.fixtures)
        self.assertIn("fixture file missing: BGRA32_to_tensor/graph.mlir", failures)
        self.assertIn("fixture file added: BGRA32_to_tensor/extra.mlir", failures)

    def test_rewritten_manifest_is_rejected(self):
        (self.fixtures / "RGB24_identity/x.bin").write_bytes(b"\0" * 24)
        files = {name: sha256((self.fixtures / name).read_bytes())
                 for name in check_images.fixture_files(self.fixtures)}
        self.edit_json("sha256.json", lambda value: value.update(files=files))
        self.assertEqual(check_images.verify_fixtures(self.fixtures), ["sha256.json is not the pinned manifest"])

    def test_cross_file_consistency_without_manifest(self):
        # With the manifest pin bypassed, the suite, results and golden
        # cross-checks still catch an input edit and a golden edit.
        (self.fixtures / "RGB24_identity/x.bin").write_bytes(b"\0" * 24)

        def goldens(value):
            value["backends"]["cpu"]["RGB24_invert"]["y"]["hex"] = "00" * 24
        self.edit_json("backend-goldens.json", goldens)
        manifest = sha256((self.fixtures / "sha256.json").read_bytes())
        failures = check_images.verify_fixtures(self.fixtures, manifest)
        self.assertIn("RGB24_identity x: RGB24_identity/x.bin digest", failures)
        self.assertIn("cpu RGB24_invert y: golden hex and sha256 differ", failures)
        self.assertIn("cpu RGB24_invert y: golden differs from swift-oracle", failures)


if __name__ == "__main__":
    unittest.main()
