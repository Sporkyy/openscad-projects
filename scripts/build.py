# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Todd Sayre

import argparse
import os
import platform
import re
import shutil
import signal
import subprocess
import sys
from dataclasses import dataclass
from math import cos, radians, sin, tan
from pathlib import Path

import overhangs

ROOT = Path(__file__).resolve().parents[1]
MACOS_OPENSCAD = Path("/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD")
PREVIEW_WIDTH, PREVIEW_HEIGHT = 1200, 900
PREVIEW_FILL = 0.80
PREVIEW_FOV = 22.5  # OpenSCAD's default camera field of view, in degrees
PREVIEW_COLORSCHEME = "Nord Light"
DEFAULT_PREVIEW_ANGLES = (46, 25)
# Tilt and azimuth in OpenSCAD camera coordinates. Keep matched variants in the
# same view, and turn sided parts to show their working faces.
PREVIEW_ANGLES = {
    "foot_with_post": (60, 25),
    "opengrid_magnet_snap_back": (52, 29),
    "opengrid_magnet_snap_front": (52, 29),
    "pencil_rest": (45, 305),
    "round_washer": (42, 25),
    "shelf_tube_anchor": (57, 61),
    "shelf_tube_brace": (31, 36),
    "shelf_tube_coupler": (40, 26),
    "single_screwdriver_holder": (53, 154),
    "square_washer": (43, 18),
    "zip_tie_corner_block_sleeves": (55, 25),
    "zip_tie_corner_blocks": (63, 154),
}

# OpenSCAD reports both on success; matched as one phrase so an unrelated
# "NoError" elsewhere in the output can't stand in for the status line
MANIFOLD_RESULT = re.compile(r"\(manifold\):\s*\n\s*Status:\s*NoError")


class BuildError(RuntimeError):
    pass


@dataclass(frozen=True)
class Artifact:
    staged: Path
    target: Path
    backup: Path


@dataclass(frozen=True)
class StagedModel:
    source: Path
    artifacts: tuple[Artifact, ...]
    overhanging: bool


def executable_candidates():
    configured = os.environ.get("OPENSCAD")
    if configured:
        yield Path(configured).expanduser()

    on_path = shutil.which("openscad")
    if on_path:
        yield Path(on_path)

    if MACOS_OPENSCAD.exists():
        yield MACOS_OPENSCAD

    if os.name == "nt":
        program_files = Path(os.environ.get("PROGRAMFILES", "C:/Program Files"))
        windows_openscad = program_files / "OpenSCAD" / "openscad.exe"
        if windows_openscad.exists():
            yield windows_openscad


def command_candidates():
    seen = set()
    arch = shutil.which("arch")

    for executable in executable_candidates():
        direct = (str(executable),)
        if direct not in seen:
            seen.add(direct)
            yield list(direct)

        if sys.platform == "darwin" and platform.machine() == "arm64" and arch:
            translated = (arch, "-x86_64", str(executable))
            if translated not in seen:
                seen.add(translated)
                yield list(translated)


def describe_probe_failure(result):
    if result.returncode < 0:
        try:
            status = signal.Signals(-result.returncode).name
        except ValueError:
            status = f"signal {-result.returncode}"
    else:
        status = f"exit status {result.returncode}"
    output = (result.stderr or result.stdout or "").strip().splitlines()
    return f"{status}: {output[-1]}" if output else status


def find_openscad():
    failures = []

    for command in command_candidates():
        label = " ".join(command)
        try:
            result = subprocess.run(
                [*command, "--version"],
                capture_output=True,
                check=False,
                text=True,
            )
        except OSError as error:
            # Candidate isn't runnable — a stale OPENSCAD value, or a path that
            # existed at discovery and doesn't now. Try the next one
            failures.append((label, str(error)))
            continue
        if result.returncode == 0:
            # A later candidate succeeding must not hide an earlier crash: a
            # sandboxed native launch aborts in Qt and Rosetta then answers, so
            # the version line alone would look like a clean start. See
            # OPENSCAD.md
            for failed, reason in failures:
                print(f"warning: skipped {failed} ({reason})")
            version = (result.stdout or result.stderr).strip()
            print(f"Using {version}")
            return command
        failures.append((label, describe_probe_failure(result)))

    attempted = (
        "; ".join(f"{failed} ({reason})" for failed, reason in failures)
        if failures
        else "no installed candidates"
    )
    raise BuildError(
        "OpenSCAD CLI not found. Install OpenSCAD or set OPENSCAD to its executable "
        f"path. Attempted: {attempted}"
    )


def discover_sources(requested):
    if requested:
        sources = list(
            dict.fromkeys(Path(value).expanduser().resolve() for value in requested)
        )
    else:
        sources = sorted(ROOT.glob("*/*.scad"))

    if not sources:
        raise BuildError("No object sources found")

    for source in sources:
        if not source.is_file() or source.suffix.lower() != ".scad":
            raise BuildError(f"Not an OpenSCAD source file: {source}")
        if source.parent.parent != ROOT:
            raise BuildError(
                f"Object source must be one folder below the repository root: {source}"
            )

    return sources


def run_export(command, label):
    result = subprocess.run(
        command,
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
        text=True,
    )
    if result.stdout:
        print(result.stdout, end="")
    if result.returncode != 0:
        raise BuildError(f"{label} failed with exit code {result.returncode}")
    if not MANIFOLD_RESULT.search(result.stdout):
        raise BuildError(f"{label} did not report a manifold NoError result")


def warn_about_overhangs(mesh, label):
    """Warn about mesh defects and return whether supports are needed.

    A steep face is a design problem to go back and fix, not a reason to
    withhold the artifact — the export is still correct, so it is written either
    way and the reader decides. Anything that goes wrong reading the mesh is
    reported and shrugged off for the same reason
    """
    try:
        facets = list(overhangs.read_facets(mesh))
        _, groups = overhangs.group_facets(facets)
        closure = overhangs.closure_of(facets)
        steep = overhangs.past_limit(groups)
    except (overhangs.MeshError, OSError) as error:
        print(f"warning: could not check {label} mesh: {error}")
        return False

    if not closure.closed or closure.degenerate_facets:
        print(f"warning: {label} has mesh defects:")
        overhangs.report_closure(closure)

    if not steep:
        return False

    print(
        f"warning: {label} needs supports as modelled — surfaces past "
        f"{overhangs.LIMIT}° from vertical:"
    )
    for group in steep:
        print(f"  {overhangs.describe(group)}")
    print(
        "  see Overhangs in AGENTS.md; "
        ".venv/bin/python scripts/overhangs.py for the full picture"
    )
    return True


def model_artifacts(source):
    stem = source.stem
    return (
        Artifact(
            source.with_name(f".{stem}.tmp.stl"),
            source.with_suffix(".stl"),
            source.with_name(f".{stem}.previous.tmp.stl"),
        ),
        Artifact(
            source.with_name(f".{stem}.tmp.png"),
            source.with_suffix(".png"),
            source.with_name(f".{stem}.previous.tmp.png"),
        ),
    )


def check_recovery_backups(artifacts):
    for artifact in artifacts:
        if artifact.backup.exists() or artifact.backup.is_symlink():
            raise BuildError(
                f"Preserved recovery backup exists: {artifact.backup}. "
                "Restore it to its target or move it to a safe location before rebuilding."
            )


def clean_staged_artifacts(artifacts):
    for artifact in artifacts:
        artifact.staged.unlink(missing_ok=True)


def preview_camera_options(mesh, model):
    """Frame the mesh in the selected orthographic view with even margins."""
    tilt, azimuth = PREVIEW_ANGLES.get(model, DEFAULT_PREVIEW_ANGLES)
    automatic = ["--autocenter", "--viewall", "--camera", f"0,0,0,{tilt},0,{azimuth},0"]
    try:
        points = {
            point for _, vertices in overhangs.read_facets(mesh) for point in vertices
        }
    except (overhangs.MeshError, OSError):
        # The mesh checker reports read errors as warnings. Let OpenSCAD frame
        # the source itself when there is no usable STL to take bounds from.
        return automatic

    x_angle, z_angle = radians(90 - tilt), radians(-azimuth)
    sx, cx = sin(x_angle), cos(x_angle)
    sz, cz = sin(z_angle), cos(z_angle)
    # OpenSCAD applies Z rotation before X. These are the screen right, up,
    # and depth axes in world coordinates.
    axes = ((cz, -sz, 0.0), (sx * sz, sx * cz, cx), (cx * sz, cx * cz, -sx))
    centers, spans = [], []
    for ax, ay, az in axes:
        projections = [ax * x + ay * y + az * z for x, y, z in points]
        low, high = min(projections), max(projections)
        centers.append((low + high) / 2)
        spans.append(high - low)

    # The inverse rotation converts the center back to a 3D camera target.
    target = [
        sum(axis * center for axis, center in zip(column, centers, strict=True))
        for column in zip(*axes, strict=True)
    ]
    width, height, depth = spans
    visible_height = max(width * PREVIEW_HEIGHT / PREVIEW_WIDTH, height)
    orthographic_scale = 2 * tan(radians(PREVIEW_FOV / 2))
    # Keep the full depth inside OpenSCAD's ±100 camera-distance clip planes.
    distance = max(visible_height / (PREVIEW_FILL * orthographic_scale), depth / 100)
    if distance == 0:
        return automatic
    camera = ",".join(
        f"{value:.12g}" for value in (*target, tilt, 0, azimuth, distance)
    )
    return ["--camera", camera]


def stage_model(openscad, source):
    artifacts = model_artifacts(source)
    stl_artifact, preview_artifact = artifacts
    relative_source = source.relative_to(ROOT)

    check_recovery_backups(artifacts)
    print(f"\nStaging {relative_source}")

    try:
        clean_staged_artifacts(artifacts)
        run_export(
            [
                *openscad,
                "--hardwarnings",
                "--export-format",
                "binstl",
                "-o",
                str(stl_artifact.staged),
                str(source),
            ],
            f"STL export for {relative_source}",
        )
        run_export(
            [
                *openscad,
                "--hardwarnings",
                "--render",
                "--projection",
                "ortho",
                *preview_camera_options(stl_artifact.staged, source.stem),
                "--imgsize",
                f"{PREVIEW_WIDTH},{PREVIEW_HEIGHT}",
                "--colorscheme",
                PREVIEW_COLORSCHEME,
                "-o",
                str(preview_artifact.staged),
                str(source),
            ],
            f"PNG export for {relative_source}",
        )
        overhanging = warn_about_overhangs(stl_artifact.staged, relative_source)
    except Exception:
        clean_staged_artifacts(artifacts)
        raise

    return StagedModel(source, artifacts, overhanging)


def publish_models(models):
    artifacts = [artifact for model in models for artifact in model.artifacts]
    check_recovery_backups(artifacts)
    backed_up = set()
    published = []
    preserve_backups = False

    try:
        for artifact in artifacts:
            if artifact.target.exists():
                shutil.copy2(artifact.target, artifact.backup)
                backed_up.add(artifact.target)

        for artifact in artifacts:
            artifact.staged.replace(artifact.target)
            published.append(artifact)
    except OSError as error:
        rollback_errors = []
        for artifact in reversed(published):
            try:
                if artifact.target in backed_up:
                    artifact.backup.replace(artifact.target)
                else:
                    artifact.target.unlink(missing_ok=True)
            except OSError as rollback_error:
                rollback_errors.append(str(rollback_error))

        if rollback_errors:
            preserve_backups = True
            details = "; ".join(rollback_errors)
            raise BuildError(
                f"Could not publish artifacts: {error}. Rollback also failed: {details}"
            ) from error
        raise BuildError(f"Could not publish artifacts: {error}") from error
    finally:
        for artifact in artifacts:
            artifact.staged.unlink(missing_ok=True)
            if not preserve_backups:
                artifact.backup.unlink(missing_ok=True)


def report_published(models):
    for model in models:
        for artifact in model.artifacts:
            print(f"Wrote {artifact.target.relative_to(ROOT)}")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Build tracked STL and PNG files from object OpenSCAD sources"
    )
    parser.add_argument(
        "sources",
        nargs="*",
        help="Object .scad files to build; defaults to every object",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    staged = []
    try:
        sources = discover_sources(args.sources)
        openscad = find_openscad()
        for source in sources:
            staged.append(stage_model(openscad, source))
        publish_models(staged)
    except BuildError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    finally:
        for model in staged:
            clean_staged_artifacts(model.artifacts)

    report_published(staged)
    warned = [model.source for model in staged if model.overhanging]

    if warned:
        print(f"\n{len(warned)} of {len(sources)} objects need supports as modelled:")
        for source in warned:
            print(f"  {source.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
