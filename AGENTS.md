# AGENTS.md

OpenSCAD source for 3D-printable parts. Each project has its own directory,
holding a `.scad` file per model alongside its generated `.stl` and `.png`
distribution files. Parts that are printed and used together belong in one
directory; a part that stands alone gets its own. Measured dimensions are
top-level variables in the source.

One `.scad` is normally one printable part. The exception is a model that is a
single object split into pieces to fit the bed: its pieces share every parameter
and have to agree with each other to assemble, so they stay in one source and
export as separate bodies in one `.stl`. Splitting those across files would only
invite them to drift apart. Emit the bodies clear of one another and leave the
arrangement to the slicer.

Every `.scad` stays self-contained — no `include` or `use` across files, even
between parts sitting in the same directory. Duplicate the handful of lines
instead. Each source is meant to be downloaded on its own and render.

## Formatting

Run `scadformat` on every `.scad` file you touch, after the edit. Do not
hand-format OpenSCAD — no manual alignment of `=`, no reflowing argument lists,
no adjusting indentation by eye. The formatter owns all of that.

```sh
scadformat path/to/file.scad   # Formats in place
```

It also reads stdin and writes stdout if you need a diff without touching the
file — and that form drops no backup, so prefer it when you only want to check
whether a file is already clean.

v0.10, not managed by Homebrew, so the path varies by machine: `~/.bin/scadformat`
on the work MacBook Pro, `~/.local/bin/scadformat` elsewhere. Use whichever
exists if it isn't on `$PATH`. It has no `--version`; `--log-level` is the only
flag, and it prints its version banner on every run. A fresh download may still
carry a quarantine attribute — `xattr -d com.apple.quarantine <path>` clears it,
and the binary usually arrives already executable.

Formatting in place drops a timestamped `.scadbak` backup beside the file, with
no flag to disable it. These are gitignored and harmless — do not worry about
them. Don't commit one, don't clean them up, and don't flag them as stale; just
leave them be.

The formatter is opinionated and lossy: two-space indent, no column alignment,
`for(` with the space closed up, and it collapses wrapped expressions onto one
long line. Don't fight it. Write a
comment that needs to span lines as its own block *above* the statement, not as
a trailing continuation — trailing comment lines get de-indented to column 0 and
end up looking orphaned.

VS Code formats `.scad` on save via the `vaaski.scadformat` extension, so a file
the user has open may already be formatted. Re-run it anyway — it's idempotent.

## Rendering

OpenSCAD has no CLI symlink; call the binary inside the app bundle:

```sh
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o out.stl part/part.scad
```

Render after changing geometry and confirm the output says `manifold` and
`Status: NoError`. Override variables without editing the file using `-D`:

```sh
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o out.stl -D 'tube_od=25' part/part.scad
```

Write one-off test renders to a scratch directory, not the repo. The `.stl` and
`.png` beside each source are generated distribution files: rebuild them with
`python3 scripts/build.py`, inspect the preview, and commit them with every source
change. Never edit either generated file by hand.

The build must report `manifold` and `Status: NoError` before replacing tracked
artifacts. It exports binary STL files and consistent fixed-view catalog
previews. A failed build must leave the last known-good artifacts intact.

That status line only appears when OpenSCAD has an actual boolean to compute.
A part that is one primitive, one `rotate_extrude`, or one `linear_extrude`
exports as a `PolySet` and prints no `manifold` line at all, so the build
rejects it — the mesh is fine, but the gate has nothing to read. Wrapping the
lone child in `union()` or `render()` does not help; the operation has to have
something to do. Two or more operands do it, including the implicit union of two
top-level objects, and so does `hull()` on a single child.

This is not a reason to bolt a dummy operation onto a part. A model made of two
stacked or intersecting solids should be written as the `union()` it already is
rather than flattened into one profile, which is what the foot with post needed.
A part that is genuinely one revolved silhouette — the dowel end cap, had it no
bore — has no honest boolean to add, and that is worth raising rather than
papering over.

The `.3mf` is a Bambu Studio project rather than a mesh export and remains
gitignored. The models are single-material prints, so these files hold only seam
and infill preferences — taste that reasonable people disagree about, not a
recipe worth versioning. Slicing is the user's job either way: if a source change
makes an export stale, say so and stop.

Finished-part geometry belongs in OpenSCAD; build-plate placement and print
orientation belong in the slicer. Do not change or flag source geometry merely
because a slicer may initially place it in an inconvenient orientation. Document
an orientation when it is useful, but treat rotating the finished model for
printing as a slicer concern.

## Overhangs

Everything here prints without supports, and that is a design constraint rather
than a slicer setting. Supports on a part this size cost more in scarred surfaces
and cleanup than the feature that needed them is usually worth. Design the
overhang out; do not print it and support it.

Consider overhangs on every geometry change, not only on new parts. Adding a
chamfer, deepening a recess, or changing the value of an existing knob can all
introduce a face that hangs.

**The limit is 45° from vertical.** A vertical wall is 0°, a flat ceiling is 90°,
and anything past 45° wants support. Design sloped faces at 45° or shallower.

**Fix the angle by construction, not by the value of a knob.** Write a chamfer so
its horizontal run and vertical rise are the same expression, and a conical
lead-in or countersink so its radial change equals its height:

```
[r - chamfer, 0], [r, chamfer]                              // Rim, always 45 deg
cylinder(d1 = bore_d, d2 = bore_d + 2 * lead_in, h = lead_in) // Funnel, always 45 deg
```

Written that way the knob changes the size of the feature and never its angle,
so no value a reader picks can turn it into an overhang. A chamfer given an
independent width and height is a knob that can be tuned into a support
requirement, and it will be.

**Prefer removing the overhang to tolerating it.** A blind bore modelled opening
upward has no roof to bridge; the same bore modelled the other way up bridges its
full width. Reach for the arrangement with nothing hanging before reaching for
the one that merely gets away with it. Prefer a chamfer to a fillet at a bottom
rim for the same reason — the fillet leaves the plate tangent to horizontal,
which is the worst overhang in the part, while the chamfer that replaces it is
45° all the way.

**This does not conflict with leaving orientation to the slicer.** Which way up a
part is authored is a source decision, and it should be the way it is meant to
print; where it lands on the plate and how it is arranged there is the slicer's.
Model the part in its intended print orientation, choose that orientation to be
the one needing no supports, and say so in the print notes. Then leave placement
alone.

**Verify against the mesh, not by eye.** A surface you reasoned was
self-supporting and a surface that actually is are two different claims, and only
the mesh settles which one is in the file. `scripts/build.py` checks every object
it exports and prints a warning naming the steep faces and their heights, so a
normal build already tells you. Read those warnings; do not build past them.

The check only warns. A steep face is a design problem to go back and fix, not a
reason to withhold a correct export, so the artifacts are still written and the
build still exits zero. Nothing will stop you committing a part that needs
supports except reading the output.

**Temporary exception — front-face openGrid magnet snap.** Its four relief-slot
roofs are flat at 90° but span only the 0.6 mm slot width. The exception is
approved while slicer orientations and physical prints are evaluated; it does
not relax the 45° rule for any other face or part. Keep the warning visible in
normal builds, keep the exception documented beside the part, and revisit the
geometry and print notes when the tests establish whether printing as modelled,
using supports, or tilting the part 45° gives the best result.

To check a mesh on its own, or to see the shallow faces the build stays quiet
about:

```sh
python3 scripts/overhangs.py part/part.stl
```

It groups the downward-facing facets by angle and height, ignores the first layer
on the plate, and exits non-zero if anything is past 45°.

Both scripts have tests in `tests/`, run with
`python3 -m unittest discover -s tests` from the repository root. The test files
put `scripts/` on `sys.path` themselves, so no `PYTHONPATH` is needed.

**Assert what a knob can break.** If a parameter can drive a feature past the
limit, or a large value can eat the bed adhesion out from under a tall part,
`assert()` it so the render fails instead of the print. Note the worst overhang
in the print notes whenever anything in the part comes near the limit.

## Documentation

The OpenSCAD source is canonical. Documentation follows the behavior and
parameters defined by the code, so treat a mismatch as stale documentation unless
the requested design behavior clearly says otherwise.

After every source change, make a dedicated documentation pass. Check the README,
source comments, measuring instructions, tuning guidance, derived-value
descriptions, print notes, generated STL, and preview image for content that needs
to follow the new code.

Documentation sits at three levels, and the test for which level something
belongs at is how long it outlives the thing it describes.

- **The top-level `README.md` is a catalogue.** One card per project: preview,
  links, and a few sentences saying what the part is and when to reach for it.
  It has to stay scannable as parts accumulate, so nothing longer than a card
  goes here.
- **A `README.md` beside the part** carries the full treatment — measuring table,
  tuning guidance, print notes — and GitHub renders it when you browse into the
  directory. Every project directory has one, because every explanation here ran
  past what a card can hold; a genuinely trivial part could still live on its
  card alone, so do not add an empty file for symmetry. A card links to the
  README and stops repeating it. Where a directory holds several parts, one
  README covers them as the system they are.
- **A top-level subject file** holds knowledge that spans parts and outlives any
  of them — an external system's dimensions, its licence, the conventions for
  building against it. `OPENGRID.md` is the first. Put facts there once and link
  to them rather than restating them in each part that uses them.

Two licences apply, split by what a file is rather than where it sits. Printable
objects and their documentation — including `.scad`, `.stl`, `.png`, every
Markdown document, and other design artifacts — are CC BY 4.0. Software and
repository tooling — including `scripts/`, `tests/`, `.vscode/`, and repository
configuration — are MIT. The lists are inclusive, not exhaustive; `LICENSE`
explains the boundary. Every new editable file gets an
`SPDX-License-Identifier` line first, or immediately after a shebang. Put it in
an HTML comment at the top of Markdown. Do not paper over the split by
relicensing one side to match the other.

Record the corrections, not just the conclusions. A subject file should say which
plausible assumptions turned out to be wrong and what the right answer was, since
that is the part a reader cannot re-derive from the finished geometry and is the
part most likely to be got wrong twice.

## Design conventions

- Measurements come from calipers, so parameters must be things a caliper can
  reach: outside diameters, clear gaps, edge-to-edge spans. Never ask for a
  center-to-center distance or any dimension inside a hollow solid — derive
  those instead.
- Every measured parameter names the caliper that reaches it. Capacity is what
  the tool is sold by and it reads nothing past that: 6 in is 150 mm, 8 in is
  200 mm, 12 in is 300 mm. State the smallest size that covers the shipped
  value, in inches, since that is the size printed on the tool — `— 6 in
  caliper`, `— 12 in caliper`. A value sitting within about 5 mm of a capacity
  calls for the next size up, because the jaws run out before the scale does.
  This is a sanity check as much as a shopping list: a parameter whose value
  needs a bigger caliper than the reader owns was measured some other way, and
  a measurement taken some other way is how the wrong dimension gets entered.
- Keep measured inputs, tuning knobs, and derived values in separate labelled
  blocks, in that order.
- Guard derived geometry with `assert()` for interferences and overhangs, and
  `echo()` the derived values so they can be sanity-checked against the physical
  part before printing.
- Sloped faces stay at or under 45° from vertical so the part prints without
  supports, and the angle is fixed by how the geometry is written rather than by
  the value of a knob. See **Overhangs** above.

## Git

Commit and push without asking. Both are pre-authorized for routine work on this
repo: staging files, committing, and pushing to `origin/main` (the branch tracks
it, and working directly on `main` is fine here).

Never create a feature branch or open a pull request. This is a personal project
on a private remote with no review flow, so every change lands on `main`
directly. This overrides any default policy about branching before committing to
the default branch — do not branch, and do not ask whether to.

Commit each logical change as you finish it rather than batching unrelated work.
Subject line is `<gitmoji> <Title>`, imperative and capitalized, 64 chars or
fewer excluding the emoji, no trailing period — e.g. `✨ Add tube coupler`.
Common ones: ✨ feature, 🐛 fix, ♻️ refactor, 📝 docs, 🎨 formatting, 🔧 config,
🔥 remove. Add a body only when the subject needs explaining, and write it about
why, not what.

Still ask first for anything that rewrites or discards history: force-push,
`reset --hard`, rebasing pushed commits, deleting branches, or tags and
releases.
