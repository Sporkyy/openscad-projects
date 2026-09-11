<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Foot with post

[![Foot with post preview](foot_with_post.png)](foot_with_post.stl)

[View or download STL](foot_with_post.stl) · [OpenSCAD source](foot_with_post.scad)

A TPU foot that plugs into a socket already in the bottom of whatever it holds
up. Two stacked cylinders: the lower, wider one stands on the floor and lifts
the object by its own height, and the upper, narrower one is a plug for the
hole.

The step between them is the shoulder, and that is what the object rests on.
The post carries nothing down the axis — it is there so the foot cannot walk out
from under the object or drop off when the thing is picked up. In TPU the foot
also grips the floor and damps whatever the object does.

Both rims are chamfered, for opposite reasons. The bottom one is room for the
first layer to spread into: TPU squashes more than a rigid filament does, and a
foot is the one part where a flared elephant foot is guaranteed to end up as the
surface bearing on the floor. The top one is a lead-in, because a soft post
pushed at a hole it is not quite lined up with folds over instead of entering.

**Measuring.** Two measurements, both on the socket, which opens at the bottom
face where an ordinary caliper reaches it:

| Parameter | Measure | Caliper |
| --- | --- | --- |
| `socket_d` | Inside jaws opened against the wall of the hole | 6 in |
| `socket_depth` | Depth rod down the hole until it stops | 6 in |

Take the diameter at a couple of rotations. A molded socket is often slightly
oval, and here it is the *smallest* reading that matters, since that is what the
post has to pass. The depth is only used to check that the post is not longer
than the hole.

The post itself is never measured. It is the socket plus `post_interference`,
because TPU is fitted by squeezing it rather than by clearing it — the knob is
*added* to the socket diameter and ships at 0.2 mm. Raise it for more grip, drop
it toward zero if the post will not start, and go negative only if the socket is
soft as well.

**Deciding.** `foot_d` and `foot_h` are the foot: how wide the contact patch and
the shoulder are, and how far the object is lifted. `post_h` is how far the post
reaches into the socket — it grips over its whole length, so most of the socket
is worth using, and the assert is what keeps it from bottoming out before the
shoulder seats. The render echoes the overall height, the shoulder ring, the
contact patch left after the chamfer and the air left under the post.

`foot_chamfer` and `post_chamfer` size the two rims. Neither has an angle: each
is written with its radial run equal to its rise, so it stays at 45° whatever
value it is given.

**Printing.** TPU, no supports. Print as modelled, foot down. Nothing in the part
hangs — the top chamfer closes inward, the shoulder faces up, and the only
downward face is the foot's bottom chamfer at 45°, in the first millimetre or two
off the plate.

Slow it down; TPU at speed under-extrudes on the small circumference of the post,
and the post is the part that has to hold. Infill is the squish — a foot at 15%
gives under weight and a solid one barely does, and neither is wrong, since that
is what the foot is for. Three perimeters either way, so the post has walls in it
rather than infill. Print the set together and they come out the same height;
printed one at a time they will not, quite.
