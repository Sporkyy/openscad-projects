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

lint: install
	$(VENV)/bin/ruff check .
	$(VENV)/bin/ruff format --check .

typecheck: install
	$(VENV)/bin/pyright
