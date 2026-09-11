<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Zip tie corner blocks and sleeves

[![Zip tie corner blocks preview](zip_tie_corner_blocks.png)](zip_tie_corner_blocks.stl)

[View or download STL](zip_tie_corner_blocks.stl) · [OpenSCAD source](zip_tie_corner_blocks.scad)

A corner shoe that carries a zip tie around a square object instead of letting
the tie grab the corner. Truckers put something like it under a ratchet strap;
this one is proportioned for a nylon tie rather than a woven strap, and it is
one piece, so there are no indexing pegs to lose at this scale.

A tie pulled around a square touches it at four points. The tie wants to be a
circle, the object is a square, and what is left is a squircle with the square
inscribed in it — all the tension on four corner tips, with the tie itself doing
the digging.

Each block is a thick right angle. Two flat inner faces bear on the object's two
flats, and a curved channel runs through the block from one leg's end face to
the other's. The tie still takes the curve it wants; it just takes it inside the
channel, and the block turns that curve into pressure spread along the flats.
Four blocks make the tie a rounded square instead of a squircle. They are
identical and have no handedness — the block is symmetric about its own
diagonal, so the same print goes on all four corners, turned 90° each time.

A circular relief is knocked out of the inner corner so the block never bears on
the corner itself. A printed internal corner is never sharp, and a real corner
may carry a weld, a seam, an extrusion line, a fold of tape or a dent. Relieved,
the block sits on the two flats and ignores all of that.

**A gentler bend passes closer to the corner.** This is the one thing about the
part that runs backwards to intuition, and it is what sets how thick the block
comes out. The tie has to leave each block running parallel to the flat it came
off, or the runs between blocks would not lie straight, so the corner arc is
tangent to two lines standing off the flats. Grow that arc and it stops hugging
the corner and starts cutting the diagonal across it — at a radius of about 3.4
times the standoff it would pass through the corner point itself. The block buys
room for a bigger radius the only way it can: by standing the whole channel
further off the flats. So `bend_radius` sets the thickness, and `face_offset` —
the standoff, and the height the tie rides above each flat between blocks — is
echoed rather than chosen. Winding `bend_radius` down to the echoed
`min_bend_radius` gives the most compact block there is, with the arc concentric
with the corner and the standoff no more than the relief plus the web.

**Measuring.** Two measurements, both on the tie itself:

| Parameter | Measure | Caliper |
| --- | --- | --- |
| `tie_width` | Outside jaws across the flat of the strap | 6 in |
| `tie_thickness` | Outside jaws on the edge of the strap, over the teeth | 6 in |

Measure the plain strap well away from the head, and take the thickness across
the ratchet teeth rather than between them — the teeth are what has to clear the
channel. Nominal 4.8 mm ties run anywhere from 1.1 to 1.6 mm thick depending on
how heavy the tie is, so measure the one in your hand instead of trusting the
packet.

The object is never measured. Nothing in the part depends on how big it is, only
on its corner being square, so the blocks fit a 40 mm post and a 400 mm crate the
same way. The render echoes the two numbers that do depend on it: the shortest
flat two blocks fit on, which is twice `leg_length`, and the tie loop needed,
which is four times the object's side plus a fixed allowance for the four arcs.
Add room for the tie's head on whichever flat it lands on.

**Deciding.** `bend_radius` is the knob the part is built around — gentler bend,
thicker block, as above. `leg_length` is how far each leg reaches along its flat,
and everything past the corner relief is bearing surface, so it is the
load-spreading dimension; it also sets the shortest object the blocks fit.
`corner_relief_d` has to swallow the printed fillet in the block's own internal
corner plus whatever the object's corner is carrying — 4 mm is plenty for a clean
extrusion or a planed edge, and it opens up for a weld bead.

`corner_web` is the material between that relief and the channel, and it is not a
skin: a tensioned tie takes the shortest path through the channel, which means it
pulls against the wall on the corner side. That web is the load path from the tie
into the block, and from there into the two flats.

`tie_clearance` opens both channel dimensions together. It ships at 0.6 mm, which
is looser than a part like this would normally get, because the tie has to be
pushed through a 90° bend rather than dropped into a slot.

**Printing.** PETG, PLA or ASA, no supports. Print as modelled, one flat face
down and the corner edge vertical. That runs the layers across the block rather
than along the channel, so the tie's pull sits in the layer plane instead of
across the layer lines. Three or four perimeters and 30% infill or more — the
corner web is the piece that is loaded.

The channel is a tunnel and not an open groove, so the tie cannot fall out while
everything is still slack. Its roof is a gable rising the full width of the slot
against half that in run, which puts both faces at 26.6° from vertical, so
nothing bridges and no value of `tie_thickness` can change that. Every other
surface in the part is vertical, on the plate, or facing up. The bottom edge of
each inner face is chamfered at 45° so an elephant foot cannot rock the block off
the flats.

The source emits one block; print four. Thread the tail through all four before
feeding it into the head — the head does not fit through the channel and is not
meant to, and it sits on a flat between two blocks.

## The TPU sleeve

[![Zip tie corner block sleeve preview](zip_tie_corner_block_sleeves.png)](zip_tie_corner_block_sleeves.stl)

[View or download STL](zip_tie_corner_block_sleeves.stl) · [OpenSCAD source](zip_tie_corner_block_sleeves.scad)

A soft liner that goes between one leg of a block and the flat it bears on. The
block is rigid and everything it presses against is painted, powder-coated or
anodized, so the sleeve is the layer that grips, that spreads the tie's load over
a surface which is never quite flat, and that takes the scuffing instead of the
finish underneath. It is optional — the blocks work bare.

It is a shallow tray. The floor is the pad, and it is the whole working surface:
it lies on the block's inner face and bears on the object. Three lips stand off
it, covering the three faces next to that one — the block's top, its bottom, and
the end face at the tip of the leg. The fourth edge is not a face at all, but the
place where the corner relief cuts the block away and the other leg's sleeve
sits, so there is nothing there to wrap.

The lips are not the fastening — glue is. What they do is hold the sleeve still
while the glue is wet, and each does it in a different direction: the side lips
square it up across the face, and the end lip is a stop that locates it along the
leg. Pushed on until it meets the leg tip, the sleeve is placed in every
direction at once, with nothing to line up by eye. The channel is printed a shade
narrow across and snapped onto the block, and the glue cures with everything
already where it belongs.

The end lip lies on the same face the block's channel opens in, so it has to stop
short of that mouth or it would cap the tie's exit. That is the constraint which
decides how far any of the lips can reach, and it is asserted and echoed rather
than left to be discovered on a print — at the shipped numbers the lip stops
2.8 mm short of it.

**One leg, one sleeve.** A block has two inner faces, so it takes two, and a set
of four blocks takes eight. They are all the same part, symmetric top to bottom,
so there is no handedness and no right way up. There is a right way round: the
end lip goes to the tip of the leg, and the open end to the corner.

**Matching the block.** The sleeve has to come out the same size as the block it
wraps, and every source here is self-contained, so it carries its own copies of
the block's `tie_clearance`, `deck`, `leg_length`, `corner_relief_d`,
`bend_radius`, `corner_web`, `outer_wall` and `foot_chamfer`, plus the same two
tie measurements. None of them is a free choice — change one and change it in
both files. Both sources echo the block height and the leg thickness, so the
quickest check that they are in step is to render the two and compare.

**Deciding.** `pad_thickness` is all of the cushion and all of the grip, and it
is also how far the block ends up standing off the flat, so the tie rides that
much higher — the sleeve echoes the standoff the assembled joint actually has. It
has to stay under the corner relief radius, or the two sleeves on one block meet
at the corner. `lip_reach` and `lip_thickness` size the lips: far enough over the
faces to hold the sleeve square and stop it, not so far that the end lip reaches
the channel mouth, and thin enough for the side pair to spring over the block
without tearing off it.

`block_pinch` is subtracted from the block height, so the channel is narrow by
that much and holds itself on before it is glued. `lip_lead_in` tapers the lip
tips so the sleeve can start out of square and still snap on.

**Printing.** TPU, no supports. Print as modelled, pad down. Nothing in this part
hangs at all — every face is vertical, on the plate, or facing up, the two
lead-in bevels included, since they taper the tips at 45° and so point upward
rather than down. Only the side lips are tapered: they are the pair that has to
snap over the block, while the end lip is slid up to rather than pushed over, and
a taper there would only shorten the stop. Pad down also puts the plate's finish on the face that bears on
the object and leaves the printed top surface as the glue face, which is the way
round that suits both.

Three perimeters; at this size the lips are perimeters the whole way through,
which is what makes them springy rather than crumbly. Cyanoacrylate or contact
cement — TPU takes both, and the rigid filament under it is what decides. The
block's foot chamfer leaves a groove along one edge between the pad and the
block; that is a glue reservoir, not a gap to close.
