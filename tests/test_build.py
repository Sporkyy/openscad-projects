# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Todd Sayre

import io
import sys
import tempfile
import unittest
from contextlib import redirect_stderr
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

# The scripts are plain files rather than a package, so put them on the path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

import build


class PublishModelsTests(unittest.TestCase):
    def test_stages_every_model_before_publishing(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            staged_path = root / "first.tmp.stl"
            staged_path.write_text("new first")
            first_model = build.StagedModel(
                root / "first.scad",
                (
                    build.Artifact(
                        staged_path,
                        root / "first.stl",
                        root / "first.previous.tmp.stl",
                    ),
                ),
                False,
            )

            with (
                redirect_stderr(io.StringIO()),
                patch.object(
                    build,
                    "parse_args",
                    return_value=SimpleNamespace(sources=[]),
                ),
                patch.object(
                    build,
                    "discover_sources",
                    return_value=[root / "first.scad", root / "second.scad"],
                ),
                patch.object(build, "find_openscad", return_value=["openscad"]),
                patch.object(
                    build,
                    "stage_model",
                    side_effect=[first_model, build.BuildError("second failed")],
                ),
                patch.object(build, "publish_models") as publish,
            ):
                self.assertEqual(build.main(), 1)

            publish.assert_not_called()
            self.assertFalse(staged_path.exists())

    def test_restores_published_artifacts_when_later_publish_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            first_target = root / "first.stl"
            second_target = root / "second.png"
            first_staged = root / "first.tmp.stl"
            missing_staged = root / "second.tmp.png"
            first_backup = root / "first.previous.tmp.stl"
            second_backup = root / "second.previous.tmp.png"

            first_target.write_text("old first")
            second_target.write_text("old second")
            first_staged.write_text("new first")

            models = [
                build.StagedModel(
                    root / "first.scad",
                    (build.Artifact(first_staged, first_target, first_backup),),
                    False,
                ),
                build.StagedModel(
                    root / "second.scad",
                    (build.Artifact(missing_staged, second_target, second_backup),),
                    False,
                ),
            ]

            with self.assertRaises(build.BuildError):
                build.publish_models(models)

            self.assertEqual(first_target.read_text(), "old first")
            self.assertEqual(second_target.read_text(), "old second")
            self.assertFalse(first_backup.exists())
            self.assertFalse(second_backup.exists())


if __name__ == "__main__":
    unittest.main()
