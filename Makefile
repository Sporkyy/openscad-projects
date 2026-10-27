# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Todd Sayre

SHELL := /bin/sh

VENV := .venv
PY := $(VENV)/bin/python

# Build from Homebrew's python@3.14 rather than from whatever `python3` the PATH
# offers — macOS ships its own interpreter, and a shim wins the PATH often
# enough that an unpinned `python3 -m venv` is how you end up debugging a 3.9
# traceback. Probed in the order the sibling repos use: Apple Silicon Homebrew,
# Intel Homebrew, then MacPorts. `brew install python@3.14` if none of them is
# there.
PYTHON_CANDIDATES := \
	/opt/homebrew/opt/python@3.14/bin/python3.14 \
	/usr/local/opt/python@3.14/bin/python3.14 \
	/opt/local/bin/python3.14
BREW_PYTHON := $(firstword $(wildcard $(PYTHON_CANDIDATES)))

.DEFAULT_GOAL := install

.PHONY: venv install reset-venv test lint typecheck

# System packages (Python 3.14, OpenSCAD, Node.js) from Homebrew, MacPorts, or
# pacman; anything already present is kept. `bootstrap` then builds the venv and
# node_modules
.PHONY: system-deps bootstrap
system-deps:
	./scripts/install-deps.sh
bootstrap: system-deps install md-tools

# Markdown tooling is pinned in package.json/package-lock.json and run from
# node_modules, never a global npm install, which drifts the same way an
# unpinned ruff would. Prettier formats (prose wrapped at 100, tables aligned);
# markdownlint checks what a formatter can't
MD_BIN := node_modules/.bin
MD_FILES := '**/*.md'

node_modules/.package-lock.json: package.json package-lock.json
	npm ci --no-audit --no-fund

.PHONY: md-tools format-md lint-md
md-tools: node_modules/.package-lock.json

format-md: md-tools
	$(MD_BIN)/prettier --write $(MD_FILES)
	$(MD_BIN)/markdownlint --fix --ignore-path .gitignore $(MD_FILES)

lint-md: md-tools
	$(MD_BIN)/prettier --check $(MD_FILES)
	$(MD_BIN)/markdownlint --ignore-path .gitignore $(MD_FILES)

venv: $(PY)

# Built once and kept. Deleting it is the way to start over, which `reset-venv`
# does; `install` on its own is safe to re-run, and re-running it is how an
# edited requirements file reaches the venv
$(PY):
	@test -n "$(BREW_PYTHON)" || { \
		echo "No Python 3.14 found. Tried:"; \
		echo "  $(PYTHON_CANDIDATES)"; \
		echo "Install one: brew install python@3.14"; \
		exit 1; }
	$(BREW_PYTHON) -m venv $(VENV)
	$(PY) -m pip install --upgrade pip

install: venv
	$(PY) -m pip install --quiet --requirement requirements-dev.txt

reset-venv:
	rm -rf $(VENV)
	$(MAKE) install

# All three depend on install rather than on venv, so a fresh clone gets the
# tools built instead of `No such file or directory` from a path that is not
# there yet. install is a no-op once the venv holds what requirements-dev.txt
# names, so the dependency costs a pip call and nothing else
test: install
	$(PY) -m unittest discover -s tests

lint: install lint-md
	$(VENV)/bin/ruff check .
	$(VENV)/bin/ruff format --check .

typecheck: install
	$(VENV)/bin/pyright
