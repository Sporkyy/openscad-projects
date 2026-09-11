<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Dowel end cap

[![Dowel end cap preview](dowel_endcap.png)](dowel_endcap.stl)

[View or download STL](dowel_endcap.stl) · [OpenSCAD source](dowel_endcap.scad)

A blind socket that closes off the end of a dowel. A plain cylinder with a
cylindrical recess bored into one end: the dowel pushes in until it bottoms out,
and the remaining material caps it.

One measurement drives the whole part. The outside diameter and the overall
length are not set directly — they fall out of the dowel diameter plus the meat
you want around it, so `wall_meat` thickens the side and the end together.

The recess is never measured. It is a dimension inside a hollow solid, which is
exactly what a caliper cannot reach, so it is bored to the dowel diameter plus a
clearance knob instead. Measure the dowel.

Set `screw_hole = true` and a countersunk hole runs through the closed end, so a
flat-head screw driven into the end grain holds the cap on rather than the fit or
a glue line. It ships off, and the plain cap is what the STL above is.

**Measuring.** One measurement, plus two more if you are fitting a screw:

| Parameter | Measure | Caliper |
| --- | --- | --- |
| `dowel_d` | Outside jaws on the dowel | 6 in |
| `screw_shank_d` | Outside jaws on the threaded shank | 6 in |
| `screw_head_d` | Outside jaws across the top face of the head | 6 in |

Take the dowel in two or three places and at a couple of rotations. Wooden dowel
is rarely round and rarely the size on the label, and it is the largest reading
that has to fit. The two screw measurements are ignored unless `screw_hole` is
on; the head is the one that decides how deep the countersink goes.

**Deciding.** `penetration_depth` is how far the dowel goes in; about one and a
half dowel diameters is plenty, and deeper mostly buys resistance to being
levered off sideways. `wall_meat` is the material around it, side and end both —
and it is also what the countersink has to fit inside, so a big screw head in a
thin end wall is what the asserts catch.

`dowel_clearance` is the fit. It ships at 0.3 mm for a glue or friction fit —
raise it if the cap will not seat, drop it toward zero for a press. Around 0.6 mm
makes it a slip fit that comes off by hand. `chamfer` breaks both outer rims and
`lead_in` funnels the mouth so the dowel starts square; both eat into the rim
face at the mouth, and the render echoes what is left of it.

`screw_clearance` opens both bored screw diameters together, so the shank slips
through instead of threading into the plastic and the head seats without binding.
The countersink itself has no angle knob: its depth is half the difference of the
two bored diameters, which makes it the 90° included angle flat heads are ground
to, whatever screw it is cut for. The render echoes the mouth diameter, the depth,
the straight hole left under it and the ring of end face left around it.

**Printing.** PETG or PLA, no supports. Print as modelled, closed end down. That
opens the bore upward so nothing bridges, and lays the one visible end face
against the plate. Flipped, the roof of the bore has to bridge its full width —
it works, but it leaves a rough ceiling for the dowel to bottom out against.

The countersink opens at the plate and closes in at 45°, so it is self-supporting
exactly like the chamfers. It does make the first layer a ring rather than a
disc; the end face is wide enough that there is plenty of adhesion left.
