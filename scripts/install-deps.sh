#!/bin/bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Todd Sayre
# Install the system packages this checkout needs: Python 3.14 from the Makefile's candidates,
# OpenSCAD (the app bundle the build calls, or openscad on PATH), and Node.js 22+ with npm for the
# Markdown tools. scadformat has no package; it is reported for a manual install. Arch ships
# Python 3.14 only as python3, which the Makefile does not probe. See scripts/lib/install-deps.sh,
# shared with the sibling repos, for the format.
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/lib/install-deps.sh

# The same interpreters as the Makefile's PYTHON_CANDIDATES.
PYTHON314='any_at_least 3.14 /opt/homebrew/opt/python@3.14/bin/python3.14 \
    /usr/local/opt/python@3.14/bin/python3.14 /opt/local/bin/python3.14'
SCADFORMAT='has scadformat || [[ -x ~/.bin/scadformat || -x ~/.local/bin/scadformat ]]'
requirements() {
    require 'Python 3.14' "$PYTHON314" python@3.14 python314 -
    require OpenSCAD '[[ -x /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD ]] || has openscad' \
        openscad - openscad
    require 'Node.js 22+' 'version_at_least node 22' node nodejs24 nodejs
    require npm 'has npm' node npm11 npm
    require 'scadformat (github.com/hugheaves/scadformat releases)' "$SCADFORMAT" - - -
}

install_deps "$@"
