<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# OpenSCAD launch and troubleshooting

## Launch procedure on macOS

Run OpenSCAD from an ordinary Terminal session or from an agent tool command approved to run outside
its execution sandbox. Use that execution context from the first invocation, including `--version`
checks. The Python build helper must run outside the sandbox too, because its OpenSCAD child
processes inherit the restrictions.

In Codex, set `sandbox_permissions="require_escalated"` on the command tool call and use its normal
approval mechanism. This is an execution-context choice, not an OpenSCAD flag or a request to use
`sudo`.

From the repository root, build one model and its catalog preview:

```sh
.venv/bin/python scripts/build.py round_washer/round_washer.scad
```

Omit the source argument to build every model. Use the build helper for distribution artifacts so
its manifold checks, fixed preview settings, and staged publication remain in effect.

For a direct version check or a scratch render, call the app-bundle executable. There is no CLI
symlink on the verified installation:

```sh
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD --version
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD --hardwarnings --export-format binstl -o /tmp/round_washer-check.stl round_washer/round_washer.scad
```

Let each CLI process finish normally and inspect its exit status and output. These commands do not
need a separate GUI quit command. A geometry export must report `manifold` and `Status: NoError`;
inspect the generated preview and read the mesh warnings as described in
[AGENTS.md](AGENTS.md#rendering).

## Why the sandbox causes trouble

The investigation on **2026-11-04** used OpenSCAD **2026.10.11**, bundled Qt **6.8.4**, and an Apple
Silicon Mac running macOS **27.2**. Two native ARM processes launched by the agent's Python commands
crashed at startup, at **14:16:27 and 14:16:52 Eastern**. Both reports recorded `SIGABRT` with
`qDetectCpuFeatures` and `qAbort` in QtCore, before OpenSCAD loaded the model.

The agent sandbox denied the CPU-feature queries used during Qt startup. The query for
`hw.optional.neon` failed with `Operation not permitted` inside the sandbox; outside it, that query
and the queries for `hw.optional.armv8_crc32` and `hw.optional.arm.FEAT_AES` all returned `1`. The
[Qt 6.8.4 detection code](https://github.com/qt/qtbase/blob/v6.8.4-lts-lgpl/src/corelib/global/qsimd.cpp#L134-L146)
uses those queries and aborts if detected features do not satisfy the build's requirements. Together
with the crash stacks and successful native launches outside the sandbox, this identifies the
execution restrictions as the cause of these startup failures.

The source link first pointed at `v6.8.3`, because qtbase has no plain `v6.8.4` tag: 6.8 is an LTS
branch, and its open-source releases after 6.8.3 are tagged `v6.8.4-lts-lgpl` and so on. The bundle
reports `CFBundleVersion` 6.8.4 in `QtCore.framework/Resources/Info.plist`, so the link now names
the LTS tag. The Darwin ARM detection block is the same in both.

There was a second failure after the build helper fell back to Rosetta: the sandboxed PNG export
reported `CGLChoosePixelFormat() failed: invalid CoreGraphics connection (10017)` and
`Unable to obtain GL Context`. Running under Rosetta did not supply the missing graphics access.

The initial assumptions were wrong: these popups were real startup crashes, rather than evidence of
an incorrect quit procedure or a broken washer model. Also, a successful `Using OpenSCAD version`
line did not mean that every startup attempt had succeeded. `find_openscad()` in
[`scripts/build.py`](scripts/build.py) tries the native executable first and then an x86-64/Rosetta
candidate on Apple Silicon; it captures failed probes without printing their diagnostics when a
later candidate succeeds. That behavior is unchanged. Avoid triggering the failed native probe by
running the entire command outside the sandbox from the start.

## Verified results and future diagnosis

Outside the sandbox, explicit native ARM launches using `/usr/bin/arch -arm64` passed all three
checks: version detection, binary STL export, and PNG rendering with the catalog settings. Both
geometry exports reported manifold `Status: NoError`, and no new OpenSCAD crash reports appeared.
The normal build helper also successfully produced the washer's distribution files outside the
sandbox. An architecture override is therefore unnecessary for the normal launch procedure.

If a crash popup returns, inspect the newest `OpenSCAD-*.ips` files in
`~/Library/Logs/DiagnosticReports/`. Compare the timestamp, parent process, architecture, exception,
and triggered thread with the command that ran. Check the command's stderr and exit status as well
as the build summary. Stop repeating sandboxed launches once this startup signature is identified;
use the approved execution context and verify again. A crash that persists outside the sandbox or
has a different stack needs a fresh investigation. The findings above establish the cause of these
two crashes, not every possible OpenSCAD failure.
