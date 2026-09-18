# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Todd Sayre

import argparse
import os
import platform
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

import overhangs

ROOT = Path(__file__).resolve().parents[1]
MACOS_OPENSCAD = Path("/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD")
PREVIEW_SIZE = "1200,900"
PREVIEW_CAMERA = "0,0,0,55,0,25,0"
PREVIEW_COLORSCHEME = "Tomorrow Night"

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


def find_openscad():
    failures = []

    for command in command_candidates():
        try:
            result = subprocess.run(
                [*command, "--version"],
                capture_output=True,
                check=False,
                text=True,
            )
        except OSError:
            # Candidate isn't runnable — a stale OPENSCAD value, or a path that
            # existed at discovery and doesn't now. Try the next one
            failures.append(" ".join(command))
            continue
        if result.returncode == 0:
            version = (result.stdout or result.stderr).strip()
            print(f"Using {version}")
            return command
        failures.append(" ".join(command))

    attempted = ", ".join(failures) if failures else "no installed candidates"
    raise BuildError(
        "OpenSCAD CLI not found. Install OpenSCAD or set OPENSCAD to its executable "
        f"path. Attempted: {attempted}"
    )


def discover_sources(requested):
    if requested:
        sources = [Path(value).expanduser().resolve() for value in requested]
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
    """Warn if the mesh needs supports as modelled. Never fails the build.

    A steep face is a design problem to go back and fix, not a reason to
    withhold the artifact — the export is still correct, so it is written either
    way and the reader decides. Anything that goes wrong reading the mesh is
    reported and shrugged off for the same reason
    """
    try:
        _, groups = overhangs.scan(mesh)
        steep = overhangs.past_limit(groups)
    except (overhangs.MeshError, OSError) as error:
        print(f"warning: could not check {label} for overhangs: {error}")
        return False

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


def clean_artifacts(artifacts):
    for artifact in artifacts:
        artifact.staged.unlink(missing_ok=True)
        artifact.backup.unlink(missing_ok=True)


def clean_staged_artifacts(artifacts):
    for artifact in artifacts:
        artifact.staged.unlink(missing_ok=True)


def stage_model(openscad, source):
    artifacts = model_artifacts(source)
    stl_artifact, preview_artifact = artifacts
    relative_source = source.relative_to(ROOT)

    print(f"\nStaging {relative_source}")

    try:
        clean_artifacts(artifacts)
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
                "--autocenter",
                "--viewall",
                "--projection",
                "ortho",
                "--camera",
                PREVIEW_CAMERA,
                "--imgsize",
                PREVIEW_SIZE,
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
        clean_artifacts(artifacts)
        raise

    return StagedModel(source, artifacts, overhanging)


def publish_models(models):
    artifacts = [artifact for model in models for artifact in model.artifacts]
    backed_up = set()
    published = []
    preserve_backups = False

    try:
        for artifact in artifacts:
            artifact.backup.unlink(missing_ok=True)
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
