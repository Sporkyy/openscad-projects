<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Pencil rest

[![Pencil rest preview](pencil_rest.png)](pencil_rest.stl)

[View or download STL](pencil_rest.stl) · [OpenSCAD source](pencil_rest.scad)

A block with a cradle down its top, to park a pencil on the desk instead of
letting it roll off. Every edge is chamfered and one cylindrical trough runs the
length of the top face; the pencil lies in the trough, and a notch cut clear
through the middle is what makes it possible to pick up again.

**The cradle is not a choice.** Its radius is the pencil plus a clearance, it is
cut to exactly half a cylinder, and the block is then made as tall as that cut
plus the floor left under it. The height falls out of the cradle rather than the
cradle being fitted into a height, and that is what makes it impossible for the
trough to reach the bottom: `floor_meat` is what is left under the deepest point,
always, whatever pencil the block is cut for and however wide or long it is made.

Cutting exactly half the cylinder is fixed the same way. The depth of the cut and
the radius of the cut are one expression, so the trough walls arrive at the top
face vertical. A deeper cut would undercut the pencil — it could not be dropped
in, only threaded in from one end, and the roof of the undercut would be an
overhang. Half is the deepest a cradle can be and still open upward, and it also
leaves the pencil standing half proud. The render echoes how far it stands.

**The notch is open at both sides.** It is not a hole to reach down into: it runs
clear out through both side faces, so a finger and thumb come in from the sides,
level with the underside of the pencil, and close on its whole diameter. That is
the difference between a grip that depends on how big your fingertips are and one
that does not. Neither of its limits is a number to get right:

- It cannot go deeper than the trough. Its floor is written as the trough's own
  deepest point rather than as a depth of its own, so the two are one plane and
  the notch can never be the feature that breaks the bottom.
- It cannot reach the base. What is left under it is `floor_meat` — the same
  floor the trough stands on and, with the notch open at both sides, also the
  whole tie between the two halves of the block.

That floor lands exactly level with the underside of the pencil, which is not a
coincidence worth tuning: a round pencil beds at the bottom of a round trough, so
its lowest point and the trough's are the same point whatever the clearance. A
finger does not have to get under the pencil — it comes in beside it, and the
render echoes that the notch exposes the full diameter from either side.

**What the notch costs.** Nothing off the bottom face: the block keeps its full
footprint on the desk. It does lose some mass as well as trough, so printing it
solid or nearly solid helps recover the weight and friction that keep a rest this
small in place. The cradle carries the pencil either side of the notch rather
than along the whole length, and the render echoes how much is left at each end —
36.4 mm apiece at the shipped sizes, against a 24 mm opening.
`notch_l` is asserted against leaving less than the pencil is thick at either
end, which is the point where a cradle has become a lip.

**Measuring.** One measurement, on the pencil:

| Parameter | Measure | Caliper |
| --- | --- | --- |
| `pencil_d` | Outside jaws on the barrel | 6 in |

A hexagonal pencil is not round. Take it across the corners rather than across
the flats and use the largest reading, since the corners are what the cradle has
to clear, and measure the barrel rather than the ferrule.

**Deciding.** `block_l` is how much of the pencil is carried — a long one is a
tray for several, a short one is a bridge under one. `block_w` is how much desk
it stands on, and so how hard it is to knock over. Neither can reach the cradle
or change its shape; the only way they fail is a width too narrow to leave a rim
either side of the trough, which is asserted and echoed.

`pencil_clearance` opens the cradle so the pencil drops in and lifts out instead
of being pressed into a socket. `floor_meat` is the material under the deepest
point, and raising it makes the block taller rather than the trough shallower.
`chamfer` breaks every edge of the block, `cradle_ease` breaks both rims of the
trough — the edge a pencil is rolled over on its way in — and `notch_ease` breaks
both walls of the notch at the top face, which is the edge a fingertip drags over.
All of them eat into the flat top face, and the render echoes what is left of it.

`notch_l` is the clear opening between the notch walls, which is the room a
finger and thumb actually get. It is the one knob here that is spent rather than
free: every millimetre of it comes out of the trough at each end, so widen it
against `block_l` and read the echoed run before printing.

**Printing.** PLA or PETG, no supports. Print as modelled, base down. Nothing
bridges: the cradle opens upward so its whole surface faces up, and so does the
notch — flat floor, walls straight up off it, open sky out both sides, and a
break at the mouth that flares outward as it rises. The only downward faces in
the part are the chamfers along the base, at 45°. Print it solid or near it — it
is a small block, the only thing it has to do is stay put, and the floor under
the notch is the one place it would break if it were picked up by an end and
swung.
