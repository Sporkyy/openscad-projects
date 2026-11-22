# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Todd Sayre

import io
import sys
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from math import radians, sqrt, tan
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

# The scripts are plain files rather than a package, so put them on the path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

import build
from test_overhangs import TETRAHEDRON, write_stl


class DiscoveryTests(unittest.TestCase):
    def test_duplicate_source_is_built_only_once(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            source = root / "part" / "part.scad"
            source.parent.mkdir()
            source.touch()

            with patch.object(build, "ROOT", root):
                sources = build.discover_sources([str(source), str(source)])

            self.assertEqual(sources, [source])

    def test_parameter_set_file_builds_its_source(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            source = root / "part" / "part.scad"
            source.parent.mkdir()
            source.touch()
            sets = source.with_suffix(".json")
            sets.touch()

            with patch.object(build, "ROOT", root):
                sources = build.discover_sources([str(sets), str(source)])

            self.assertEqual(sources, [source])

    def test_parameter_set_file_without_a_source_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            orphan = root / "part" / "part.json"
            orphan.parent.mkdir()
            orphan.touch()

            with (
                patch.object(build, "ROOT", root),
                self.assertRaisesRegex(build.BuildError, "no source beside them"),
            ):
                build.discover_sources([str(orphan)])


SETS = """{
    "parameterSets": {
        "Big Box": {"width": "70", "lid": "true"},
        "small box": {"width": "30"}
    },
    "fileFormatVersion": "1"
}"""
LISTING = SimpleNamespace(
    returncode=0,
    stdout='{"parameters": [{"name": "width", "type": "number"},'
    ' {"name": "lid", "type": "boolean"}]}',
    stderr="",
)


class ParameterSetTests(unittest.TestCase):
    def part(self, root, sets: str | None = SETS):
        source = root / "part" / "part.scad"
        source.parent.mkdir()
        source.touch()
        if sets is not None:
            source.with_suffix(".json").write_text(sets)
        return source

    def test_source_without_a_file_has_no_sets(self):
        with tempfile.TemporaryDirectory() as directory:
            source = self.part(Path(directory), sets=None)

            self.assertEqual(build.read_parameter_sets(source), {})

    def test_set_files_are_named_after_the_set(self):
        source = Path("/repo/part/part.scad")

        stl, png = build.model_artifacts(source, "Big Box (v2)")

        self.assertEqual(stl.target, Path("/repo/part/part_big_box_v2.stl"))
        self.assertEqual(png.target, Path("/repo/part/part_big_box_v2.png"))
        self.assertEqual(stl.staged, Path("/repo/part/.part_big_box_v2.tmp.stl"))

    def test_unquoted_value_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            source = self.part(
                Path(directory), '{"parameterSets": {"Box": {"width": 70}}}'
            )

            with self.assertRaisesRegex(build.BuildError, "quoted strings"):
                build.read_parameter_sets(source)

    def test_sets_that_would_share_files_are_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            source = self.part(
                Path(directory), '{"parameterSets": {"Big box": {}, "big-box": {}}}'
            )

            with self.assertRaisesRegex(build.BuildError, "share files"):
                build.read_parameter_sets(source)

    def test_unknown_parameter_and_mistyped_value_are_rejected(self):
        sets = {"Box": {"widht": "70", "lid": "yes", "width": "7e1"}}

        with (
            patch.object(build.subprocess, "run", return_value=LISTING),
            self.assertRaises(build.BuildError) as raised,
        ):
            build.check_parameter_sets(["openscad"], Path("part.scad"), sets)

        message = str(raised.exception)
        self.assertIn("sets widht, which the Customizer does not list", message)
        self.assertIn("sets lid to 'yes', which is not a boolean", message)
        self.assertNotIn("7e1", message)

    def test_stages_the_source_then_each_set_by_name(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            source = self.part(root)

            with (
                patch.object(build, "ROOT", root),
                patch.object(build.subprocess, "run", return_value=LISTING),
                patch.object(build, "run_export") as export,
                patch.object(build, "warn_about_overhangs", return_value=False),
                redirect_stdout(io.StringIO()),
            ):
                models = list(build.stage_source(["openscad"], source))
                label = models[1].label

            self.assertEqual(
                [model.parameter_set for model in models],
                [None, "Big Box", "small box"],
            )
            self.assertEqual(label, "part/part.scad [Big Box]")
            commands = [call.args[0] for call in export.call_args_list]
            self.assertNotIn("-P", commands[0])
            for command in commands[2:4]:
                index = command.index("-P")
                self.assertEqual(command[index + 1], "Big Box")
                self.assertEqual(command[index - 1], str(source.with_suffix(".json")))

    def test_set_that_would_overwrite_a_sibling_part_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            source = self.part(root)
            (source.parent / "part_small_box.scad").touch()

            with (
                patch.object(build, "ROOT", root),
                patch.object(build, "run_export") as export,
                self.assertRaisesRegex(build.BuildError, "overwrite part_small_box"),
            ):
                list(build.stage_source(["openscad"], source))

            export.assert_not_called()

    def test_warns_about_files_no_source_or_set_builds(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            source = self.part(root)
            for name in ("part", "part_big_box", "part_small_box", "part_old_box"):
                (source.parent / f"{name}.stl").touch()
            output = io.StringIO()

            with patch.object(build, "ROOT", root), redirect_stdout(output):
                build.warn_about_strays([source])

            self.assertEqual(
                output.getvalue().splitlines(),
                [
                    (
                        "warning: part/part_old_box.stl is not built by any source "
                        "or parameter set; delete it if it is stale"
                    )
                ],
            )


NATIVE = ["/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"]
ROSETTA = ["/usr/bin/arch", "-x86_64", *NATIVE]


class ProbeTests(unittest.TestCase):
    def probe(self, results):
        output = io.StringIO()
        with (
            patch.object(build, "command_candidates", return_value=[NATIVE, ROSETTA]),
            patch.object(build.subprocess, "run", side_effect=results),
            redirect_stdout(output),
        ):
            command = build.find_openscad()
        return command, output.getvalue()

    def test_reports_crashed_probe_when_a_later_candidate_succeeds(self):
        crashed = SimpleNamespace(
            returncode=-6, stdout="", stderr="qt.core: CPU features\nAbort trap"
        )
        answered = SimpleNamespace(
            returncode=0, stdout="", stderr="OpenSCAD version 2026.10.11\n"
        )

        command, output = self.probe([crashed, answered])

        self.assertEqual(command, ROSETTA)
        lines = output.splitlines()
        self.assertEqual(
            lines[0], f"warning: skipped {NATIVE[0]} (SIGABRT: Abort trap)"
        )
        self.assertEqual(lines[1], "Using OpenSCAD version 2026.10.11")

    def test_clean_first_probe_prints_no_warning(self):
        answered = SimpleNamespace(
            returncode=0, stdout="OpenSCAD version 1\n", stderr=""
        )

        command, output = self.probe([answered])

        self.assertEqual(command, NATIVE)
        self.assertNotIn("warning", output)

    def test_unrunnable_and_failing_probes_are_named_in_the_error(self):
        failed = SimpleNamespace(returncode=1, stdout="", stderr="")

        with self.assertRaises(build.BuildError) as raised:
            self.probe([FileNotFoundError("No such file"), failed])

        message = str(raised.exception)
        self.assertIn(f"{NATIVE[0]} (No such file)", message)
        self.assertIn("arch -x86_64", message)
        self.assertIn("(exit status 1)", message)


class MeshWarningTests(unittest.TestCase):
    def test_reports_open_mesh_without_classifying_it_as_an_overhang(self):
        with tempfile.TemporaryDirectory() as directory:
            mesh = Path(directory) / "holed.stl"
            write_stl(mesh, TETRAHEDRON[:-1])
            output = io.StringIO()

            with redirect_stdout(output):
                overhanging = build.warn_about_overhangs(mesh, "holed")

            self.assertFalse(overhanging)
            self.assertIn("NOT closed", output.getvalue())
            self.assertIn("3 open edges", output.getvalue())

    def test_malformed_mesh_stays_a_warning(self):
        with tempfile.TemporaryDirectory() as directory:
            mesh = Path(directory) / "empty.stl"
            write_stl(mesh, [])
            output = io.StringIO()

            with redirect_stdout(output):
                overhanging = build.warn_about_overhangs(mesh, "empty")

            self.assertFalse(overhanging)
            self.assertIn("warning:", output.getvalue())


class PreviewCameraTests(unittest.TestCase):
    def test_fits_projected_bounds_of_a_translated_asymmetric_mesh(self):
        triangle = ((0, 0, 1), [(10, 20, 5), (90, 20, 5), (10, 60, 5)])
        with tempfile.TemporaryDirectory() as directory:
            mesh = Path(directory) / "asymmetric.stl"
            write_stl(mesh, [triangle])
            with patch.dict(build.PREVIEW_ANGLES, {"asymmetric": (0, 45)}):
                flag, coordinates = build.preview_camera_options(mesh, "asymmetric")

        self.assertEqual(flag, "--camera")
        x, y, z, tilt, roll, azimuth, distance = map(float, coordinates.split(","))
        self.assertEqual((tilt, roll, azimuth), (0, 0, 45))
        self.assertAlmostEqual(x, 40)
        self.assertAlmostEqual(y, 30)
        self.assertAlmostEqual(z, 5)
        visible_height = 2 * distance * tan(radians(11.25))
        self.assertAlmostEqual((120 / sqrt(2)) / visible_height, 0.80)

    def test_unreadable_mesh_falls_back_to_openscad_framing(self):
        with tempfile.TemporaryDirectory() as directory:
            missing = Path(directory) / "missing.stl"
            options = build.preview_camera_options(missing, "shelf_tube_anchor")

        self.assertEqual(
            options, ["--autocenter", "--viewall", "--camera", "0,0,0,57,0,61,0"]
        )


class RecoveryTests(unittest.TestCase):
    def test_staging_preserves_existing_recovery_backup(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "part" / "part.scad"
            source.parent.mkdir()
            artifact = build.model_artifacts(source)[0]
            artifact.backup.write_text("recover me")

            with (
                patch.object(build, "ROOT", root),
                patch.object(build, "run_export") as export,
                self.assertRaisesRegex(build.BuildError, "recovery backup"),
            ):
                build.stage_model(["openscad"], source)

            self.assertEqual(artifact.backup.read_text(), "recover me")
            export.assert_not_called()

    def test_publishing_preserves_existing_recovery_backup(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "part.scad"
            artifacts = build.model_artifacts(source)
            for artifact in artifacts:
                artifact.target.write_text("current")
                artifact.staged.write_text("new")
            artifacts[0].backup.write_text("recover me")
            model = build.StagedModel(source, artifacts, False)

            with self.assertRaisesRegex(build.BuildError, "recovery backup"):
                build.publish_models([model])

            self.assertEqual(artifacts[0].backup.read_text(), "recover me")
            for artifact in artifacts:
                self.assertEqual(artifact.target.read_text(), "current")


class PublishModelsTests(unittest.TestCase):
    def test_failed_rollback_preserves_backup_for_the_next_build(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "part.scad"
            artifacts = build.model_artifacts(source)
            for artifact in artifacts:
                artifact.target.write_text("original")
            artifacts[0].staged.write_text("new")
            # The missing second export triggers rollback after the first was
            # published. A failed restore must keep the original for recovery.
            replace = Path.replace

            def fail_restore(path, target):
                if path == artifacts[0].backup:
                    raise OSError("restore denied")
                return replace(path, target)

            model = build.StagedModel(source, artifacts, False)
            with (
                patch.object(Path, "replace", fail_restore),
                self.assertRaisesRegex(build.BuildError, "Rollback also failed"),
            ):
                build.publish_models([model])

            self.assertEqual(artifacts[0].target.read_text(), "new")
            self.assertEqual(artifacts[0].backup.read_text(), "original")
            with self.assertRaisesRegex(build.BuildError, "recovery backup"):
                build.publish_models([model])
            self.assertEqual(artifacts[0].backup.read_text(), "original")

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
