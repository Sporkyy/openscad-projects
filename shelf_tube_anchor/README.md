<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Shelf tube wall anchor

[![Shelf tube wall anchor preview](shelf_tube_anchor.png)](shelf_tube_anchor.stl)

[View or download STL](shelf_tube_anchor.stl) · [OpenSCAD source](shelf_tube_anchor.scad)

A plain collar that slips over one vertical tube post and carries a lug with a
zip tie channel through it, so the tie that holds the post back to the wall
never has to go around the post.

A tie run straight from the wall around a 30 mm post spends about 95 mm of its
length on the post before it has anchored anything, which is why doing this
without the part means reaching for a long tie. Here the ring takes care of
staying on the post and the tie only has to reach the wall and come back, so a
much shorter tie does the job and the loop that used to be strangling the post
is a neat bar on one side instead.

**The channel is a U-turn, and it has to be.** A tie is a closed loop, so it has
to come back on itself, and a channel bored straight at the wall cannot — its
inner end runs into the post. A channel running across the lug instead leaves the
tie to make a right-angle turn over the mouth edge, with the corner carrying the
whole redirection on a point.

So the channel goes in and comes back out: two straight legs running out towards
the wall, joined by a 180° bend at the inboard end. Both mouths face the wall,
both legs leave pointing at whatever the tie is anchored to, and the only bend in
the part is one smooth arc at a radius that is chosen rather than whatever a
corner happened to be. Pulled tight, the bend bears on the island of material
between the two legs across the whole half turn instead of on two corner tips.

That island is what the tie is really holding, and the decks above and below the
channel are what hold it — they are the load path out of the lug and into the
ring.

**Measuring.** Three measurements, all reachable from outside:

| Parameter | Measure | Caliper |
| --- | --- | --- |
| `tube_od` | Outside jaws on a vertical tube post | 6 in |
| `tie_width` | Outside jaws across the flat of the strap | 6 in |
| `tie_thickness` | Outside jaws on the edge of the strap, over the teeth | 6 in |

The two tie measurements are the same ones the corner blocks want, and they are
taken the same way — the plain strap well away from the head, and the thickness
across the ratchet teeth rather than between them.

The wall is never measured. Nothing in the part knows how far away it is or what
is screwed into it. The render echoes the loop the tie needs to come straight
back on itself at the two mouths, and the reach out to the fixture and back is
added on top of that.

**Deciding.** `bend_radius` is the knob the lug is built around, and it sets three
things at once: how gently the tie turns, how far apart the two mouths sit, and
how far the lug stands off the ring. Winding it down is a smaller bump, a shorter
tie and a sharper turn; it stops at the echoed `min_bend_radius`, below which the
two legs have eaten the island between them.

`collar_height` is the other one that matters. The tie's pull is a radial tug at a
single point on a round post, which is a tipping load, and collar height is the
only thing resisting it — so this collar is taller than a coupler on purpose. It
cannot go below the echoed `min_collar_height`, which is what the channel and its
two decks need.

`straight_run` is how far the mouths stand past the end of the bend, and it is
what actually aims the tie: with none, the mouths would open mid-bend and point
the tie across the lug. `corner_round` rounds the island's tip as well as the
lug's outboard corners, because the tie's legs converge onto that tip when the
wall fixture sits close in. `tie_clearance` opens both channel dimensions
together and ships loose, at 0.6 mm, because the tie has to be threaded round a
half turn by hand.

The echoed `lug_reach` is worth reading before printing: the lug stands that far
past the ring towards the wall, and the post needs at least that much clear or
the lug lands on the wall instead of the tie.

**Printing.** PETG, PLA or ASA, no supports. Print as modelled, collar axis
vertical: the bore then comes out round and slides onto the post, and the layers
run across the lug so the tie's pull sits in the layer plane instead of across the
layer lines. Three or four perimeters and 30% infill or more — the decks are the
only thing holding the island on, and they are only `deck` thick.

The channel's roof is a gable rising the full width of the slot against half that
in run, and it follows the bend the whole way round, so every roof face sits at
26.6° from vertical and no value of `tie_thickness` can turn it into a bridge.
That is the worst overhang in the part; everything else is vertical, on the plate,
or facing up.

The collar slips over the post from the end, so the shelf above has to come off to
fit one, and it rests on the shelf below. Thread the tie in one mouth and out the
other, then around the wall fixture and into its own head — the head does not fit
through the channel and is not meant to.
