#!/bin/bash
# Shared installer for the system packages a checkout needs, through Homebrew, MacPorts, or pacman.
# Keep this file identical across the sibling repos; each repo's scripts/install-deps.sh declares
# its own requirements and sources it. Anything already present and new enough is kept, whichever
# manager installed it. Pinned project tools (node_modules, .venv) are not installed here; each
# repo builds them on top of these runtimes.
#
# The repo script defines requirements(), calling `require LABEL PROBE BREW PORT PACMAN` once per
# requirement: PROBE is a shell command that succeeds when the requirement is met, and `-` marks a
# manager with no package for it. An optional after_install() runs once the packages are in, with
# MANAGER and MANAGER_BIN set; it can use installing, run_step, and run_root. The script then calls
# `install_deps "$@"`. PKG_MANAGER=brew|port|pacman overrides detection.
#
# macOS still ships bash 3.2, so this avoids associative arrays and never expands an empty array.

has() { command -v "$1" >/dev/null 2>&1; }

# Succeed when `CMD --version` reports at least MIN, comparing dotted numbers.
version_at_least() {
    local version min=$2 have want
    version=$("$1" --version 2>/dev/null | grep -Eo '[0-9]+(\.[0-9]+)+' | head -n 1) || return 1
    [[ -n $version ]] || return 1
    while [[ -n $min ]]; do
        have=${version%%.*}
        want=${min%%.*}
        if ((10#${have:-0} != 10#$want)); then
            ((10#${have:-0} > 10#$want))
            return
        fi
        if [[ $version == *.* ]]; then version=${version#*.}; else version=; fi
        if [[ $min == *.* ]]; then min=${min#*.}; else min=; fi
    done
}

# Succeed when any listed interpreter exists and reports at least MIN.
any_at_least() {
    local min=$1 candidate
    shift
    for candidate in "$@"; do
        if [[ -x $candidate ]] && version_at_least "$candidate" "$min"; then return 0; fi
    done
    return 1
}

REQ_LABELS=()
REQ_PROBES=()
REQ_PACKAGES=()
require() {
    local package
    REQ_LABELS+=("$1")
    REQ_PROBES+=("$2")
    case $MANAGER in
        brew) package=$3 ;;
        port) package=$4 ;;
        pacman) package=$5 ;;
        *) package=- ;;
    esac
    REQ_PACKAGES+=("$package")
}

# Prefer the manager already on PATH, then the standard prefixes, because GUI-launched editors
# often start without the login profile. On macOS Homebrew wins over MacPorts when both exist.
find_manager() {
    local name=$1 candidate
    shift
    if has "$name"; then
        command -v "$name"
        return
    fi
    for candidate in "$@"; do
        if [[ -x $candidate ]]; then
            echo "$candidate"
            return
        fi
    done
    return 1
}
BREW_PATHS=(/opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew)
detect_manager() {
    MANAGER=${PKG_MANAGER:-}
    MANAGER_BIN=
    case $MANAGER in
        brew) MANAGER_BIN=$(find_manager brew "${BREW_PATHS[@]}") || MANAGER_BIN=brew ;;
        port) MANAGER_BIN=$(find_manager port /opt/local/bin/port) || MANAGER_BIN=port ;;
        pacman) MANAGER_BIN=$(find_manager pacman /usr/bin/pacman) || MANAGER_BIN=pacman ;;
        '')
            if [[ $(uname -s) == Darwin ]]; then
                if MANAGER_BIN=$(find_manager brew "${BREW_PATHS[@]}"); then
                    MANAGER=brew
                elif MANAGER_BIN=$(find_manager port /opt/local/bin/port); then
                    MANAGER=port
                fi
            elif MANAGER_BIN=$(find_manager pacman /usr/bin/pacman); then
                MANAGER=pacman
            elif MANAGER_BIN=$(find_manager brew "${BREW_PATHS[@]}"); then
                MANAGER=brew
            fi
            ;;
        *)
            echo "error: PKG_MANAGER must be brew, port, or pacman, not $MANAGER" >&2
            exit 2
            ;;
    esac
    # Probe the manager's prefix too, so a fresh install is seen without a new shell.
    if [[ $MANAGER_BIN == */* ]]; then PATH="$PATH:$(dirname "$MANAGER_BIN")"; fi
}

listing() {
    local out=$1 item
    shift
    for item in "$@"; do out+=", $item"; done
    echo "$out"
}

# Fill MISSING (labels with a package), PACKAGES (deduplicated), and MANUAL (labels without one).
check_requirements() {
    local i package
    MISSING=()
    PACKAGES=()
    MANUAL=()
    for ((i = 0; i < ${#REQ_LABELS[@]}; i++)); do
        if (eval "${REQ_PROBES[i]}") >/dev/null 2>&1; then continue; fi
        package=${REQ_PACKAGES[i]}
        if [[ $package == - ]]; then
            MANUAL+=("${REQ_LABELS[i]}")
            continue
        fi
        MISSING+=("${REQ_LABELS[i]}")
        if ((${#PACKAGES[@]} == 0)) || [[ " ${PACKAGES[*]} " != *" $package "* ]]; then
            PACKAGES+=("$package")
        fi
    done
}

installing() { [[ " ${PACKAGES[*]:-} " == *" $1 "* ]]; }
run_step() {
    if ((DRY_RUN)); then
        echo "Would run: $*"
        return
    fi
    echo "Running: $*"
    "$@"
}
# Homebrew refuses root; MacPorts and pacman need it.
run_root() {
    if [[ $EUID == 0 ]]; then run_step "$@"; else run_step sudo "$@"; fi
}

install_deps() {
    DRY_RUN=0
    if [[ $# == 1 && $1 == --dry-run ]]; then
        DRY_RUN=1
    elif [[ $# != 0 ]]; then
        echo "Usage: $0 [--dry-run]" >&2
        exit 2
    fi
    detect_manager
    requirements
    check_requirements
    if ((${#MISSING[@]})); then
        echo "Missing: $(listing "${MISSING[@]}")"
        if [[ -z $MANAGER ]]; then
            echo 'error: no Homebrew, MacPorts, or pacman found; install one or set PKG_MANAGER' >&2
            exit 1
        fi
        case $MANAGER in
            brew) run_step "$MANAGER_BIN" install "${PACKAGES[@]}" ;;
            port) run_root "$MANAGER_BIN" -N install "${PACKAGES[@]}" ;;
            pacman) run_root "$MANAGER_BIN" -S --needed --noconfirm "${PACKAGES[@]}" ;;
        esac
        if declare -F after_install >/dev/null; then after_install; fi
        if ((DRY_RUN)); then
            if ((${#MANUAL[@]})); then echo "Install manually: $(listing "${MANUAL[@]}")"; fi
            return 0
        fi
        hash -r
        check_requirements
    fi
    if ((${#MISSING[@]})); then
        echo "error: still missing after install: $(listing "${MISSING[@]}"); check PATH" >&2
        exit 1
    fi
    if ((${#MANUAL[@]})); then
        echo "Install manually (no ${MANAGER:-package manager} package): $(listing "${MANUAL[@]}")" >&2
        if ((DRY_RUN)); then return 0; fi
        exit 1
    fi
    # Labels may carry an install hint in parentheses; drop it once the requirement is met.
    local labels=() label
    for label in "${REQ_LABELS[@]}"; do labels+=("${label%% (*}"); done
    echo "System requirements present: $(listing "${labels[@]}")"
}
