<!--
SPDX-FileCopyrightText: 2026 Todd Sayre
SPDX-License-Identifier: CC-BY-4.0
-->

# openGrid mount for triple 4-tier bookshelf

Mount openGrid tiles to the outer sides of an industrial-style triple 4-tier
bookshelf: black square steel tube frame, wood shelves. Not yet modelled — this
file holds the design decision and the measurements needed to start.

System-level openGrid facts — tile and snap thicknesses, the snap profile, print
orientation rules, and licensing across the ecosystem — are in
[OPENGRID.md](../OPENGRID.md). Read that before modelling anything that has to
mate with a tile.

## The approach

The side of each tower is not a panel, it is a ladder: front post, rear post,
and horizontal rungs at every shelf level, plus an X-brace bay. The openings
above and below each rung give clear access to reach around behind it.

**Hook the rungs. No adhesive in the load path.**

- Vertical rails run down the side, each carrying C-hooks that drop over a rung
  from above and wrap behind it. Gravity seats them.
- Tiles screw to the rails through their own countersunk mounting holes.
- Tape, if used at all, is anti-rattle only.

### Why this and not tape

Prior installations on similar units used an over-the-top hook with double-sided
tape on the "fingertips". That holds, because on a top face the adhesive is in
shear with gravity pressing the bond closed. On the sides the same tape fails,
because the panel's moment works the bond in **peel** — an order of magnitude
weaker — and peel resistance scales with bond width, of which a ~20 mm post has
almost none. Once peel starts at one edge it unzips. Better tape will not fix
this; geometry will.

### Why this fixes the pitch mismatch

Post spacing is set by the shelf manufacturer and will never land on openGrid's
28 mm pitch. But the rungs are continuous, so a hook can sit anywhere along one.
The rails become an adapter layer: they hook the frame wherever it happens to be
and present mounting points wherever the tiles want them. The two pitches never
have to agree.

### What still needs restraining

Both minor, once the rails are hooked over several rungs each:

- **Sliding front-to-back along the rungs** — one nylon set screw per hook
  bearing on the tube, or let the tile array tie the rails together into a
  ladder that cannot shift independently.
- **Lifting off** — requires deliberately raising the whole array. A spring lip
  or one zip tie at the bottom hook makes it captive if wanted.

## Measurements needed

All caliper-reachable, all within 6 in caliper capacity:

- [ ] Rung tube cross-section, width x depth — 6 in caliper
- [ ] Post tube cross-section, width x depth, if different from the rung — 6 in caliper
- [ ] **Rung setback from the posts' outer face** — 6 in caliper.
      Flush or inset, and by how much. This decides whether tiles land on the
      posts or stand off them, and it changes the hook profile more than
      anything else here.
- [ ] Clear span between posts on the side — 12 in caliper
- [ ] Rung-to-rung vertical spacing, and how many rungs per side — 12 in caliper

Also worth noting while measuring: whether the X-brace bay leaves a usable rung
at its top and bottom, and whether the two towers' sides differ.

## Design constraints to carry into the model

- **Print orientation:** lay the C-hook profile flat in the bed plane and
  extrude upward by the rail thickness. Every layer is then identical, so there
  are no overhangs at all, and the load runs in-plane with the layers rather
  than peeling them apart.
- Rails likely exceed the bed. Split into segments in one source, and put the
  splice at a hook, where bending moment is near zero and the hook body doubles
  as the fishplate.
- Check what tile widths actually fit the clear span before committing to a rail
  layout.
