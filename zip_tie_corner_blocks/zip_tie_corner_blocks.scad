// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// ============================================================
// Zip tie corner blocks — a corner shoe that carries a zip
// tie around a square object without letting it grab the
// corner
//
// A zip tie pulled around a square object touches it at four
// points, one per corner. The tie tries to be a circle, the
// object is a square, and what is left is a squircle with the
// square inscribed in it: all the tension lands on four
// corners, and the tie itself is what digs into them.
//
// This block sits on one corner. It is a thick right angle
// with two flat inner faces that bear on the object's two
// flats, and a curved channel running through it that the tie
// is threaded through. The tie is still allowed to take the
// curve it wants — it just takes it inside the channel, and
// the block turns that curve into pressure spread along the
// two flats. Four of them make the tie a rounded square
// instead of a squircle.
//
// A circular relief is knocked out of the inner corner so the
// block never bears on the corner itself. A printed internal
// corner is never sharp, and a real corner may carry a weld, a
// seam, an extrusion line, a fold of tape or a dent. Relieved,
// the block seats on the two flats and ignores all of it.
//
// The channel is a tunnel rather than an open groove, so the
// tie cannot fall out while everything is still slack. Thread
// the tail through all four blocks before feeding it into the
// head.
//
// THE ONE THING THAT IS NOT OBVIOUS: a gentler bend passes
// CLOSER to the corner. The tie's path has to leave each block
// running parallel to the flat it came off, so the corner arc
// is tangent to two lines offset from the flats. Grow that
// arc's radius and it stops hugging the corner and starts
// cutting across it — at bend_radius = tie_offset * (2 +
// sqrt(2)) the arc would pass straight through the corner
// itself. So the block buys room for a bigger radius the only
// way it can: by standing the whole channel further off the
// flats. A gentle bend is a thick block, and that is a
// straight trade, not a bug. face_offset is echoed so the cost
// is visible before printing.
//
// Modeled in its print orientation: corner edge vertical, one
// flat face on the plate.
//
// This source emits ONE block. Print four.
//
// A TPU sleeve for the inner faces sits beside this file. It
// is optional — the block works bare — and it adds grip and
// keeps the block's edges off the finish. Fitted, it stands
// the block off each flat by its own pad thickness, so the tie
// rides that much higher than the offset echoed here. Its
// source carries copies of the parameters below that decide
// how big it has to be, so change one of those and change it
// in both files.
//
// PRINT NOTES:
// - PETG, PLA or ASA, no supports needed.
// - Print as modeled, flat face down, corner edge vertical.
//   The channel roof is a gable at 26.6 deg from vertical, so
//   the tunnel needs no bridging, and every other face in the
//   part is vertical, on the plate, or facing up.
// - The layers then run across the block rather than along the
//   channel, which puts the tie's pull in the layer plane
//   instead of across the layer lines.
// - 3 or 4 perimeters and 30% infill or more. The corner web
//   between the relief and the channel is the piece the tie
//   presses on, and it is only corner_web thick.
// - The bottom edge of each inner face is chamfered at 45 deg
//   so an elephant foot cannot rock the block off the flats.
// - The tie's head does not fit through the channel and is not
//   meant to. Thread the tail through all four blocks, then
//   into the head, and let the head sit on a flat between two
//   blocks.
// ============================================================

// MARK: Dimensions

// Measure the zip tie
tie_width = 3.5; // mm, across the flat of the strap
tie_thickness = 1.3; // mm, over the ratchet teeth

// Size the block
bend_radius = 10; // mm, the tie's bend at mid-strap
leg_length = 10; // mm, along each flat from the corner
corner_relief_d = 4; // mm, open it up for a weld bead
// (bend_radius cannot go below the echoed min_bend_radius)

// MARK: Tuning

tie_clearance = 0.6; // mm, on both channel dimensions
corner_web = 2.5; // mm, between the relief and the channel
outer_wall = 2.4; // mm, outside the channel
deck = 1.6; // mm, under the channel floor and over the gable peak
foot_chamfer = 0.6; // mm, clears an elephant foot

$fn = 120;

// MARK: Derived

slot_w = tie_thickness + tie_clearance; // Channel across the strap's thickness, radially
slot_h = tie_width + tie_clearance; // Channel across the strap's width, vertically
relief_r = corner_relief_d / 2;

// Rise of the gable over the channel. It is the full slot width against a half
// slot width of run, so each roof face sits at 26.6 deg from vertical whatever
// the tie measures — no value of tie_thickness can turn this into a bridge
gable = slot_w;

block_h = 2 * deck + slot_h + gable;

// Tightest bend the corner can hold: the arc is concentric with the corner,
// and the material inside it is exactly the relief plus the web
min_bend_radius = slot_w / 2 + relief_r + corner_web;

// Standoff of the middle of the strap from each flat. Solved from the corner
// instead of chosen: the middle of the arc runs
// sqrt(2) * tie_offset - (sqrt(2) - 1) * bend_radius from the corner, and half
// a slot in from that is the wall that has to leave the relief and the web
// intact. A bigger bend_radius pushes the whole channel off the flats to pay
// for itself
tie_offset = ((sqrt(2) - 1) * bend_radius + slot_w / 2 + relief_r + corner_web) / sqrt(2);

// Material between the channel and each flat, and so the height the tie stands
// off the object along the runs between blocks
face_offset = tie_offset - slot_w / 2;

leg_thickness = face_offset + slot_w + outer_wall;

// Where the arc's centre sits, on the diagonal inside the object, and equally
// the distance from the corner to each tangent point. The channel is straight
// from there out to the mouth, which is what makes the tie leave parallel to
// the flat
arc_c = bend_radius - tie_offset;

straight_run = leg_length - arc_c;
contact_length = leg_length - relief_r;

// Shortest flat the blocks fit on: two of them, corner to corner, with nothing
// left between. Anything at or near this is too short in practice — leave room
// for the tie's head as well
min_object_side = 2 * leg_length;

// What four blocks add to the tie's loop over the bare perimeter of the
// object: four 90 deg arcs instead of four sharp corners, less the straight
// run each arc replaces
tie_path_extra = 2 * PI * bend_radius - 8 * arc_c;

mouth_over = 1; // Overshoot past the end faces, so the channel cuts through cleanly
seam = 0.02; // Overlap where the straight runs meet the arc

// Channel cross section, drawn in the plane the path is swept along: x is
// across the strap's thickness, y is up. Square where the tie sits, gabled
// above it so the roof carries itself
channel_profile = [
  [-slot_w / 2, 0],
  [slot_w / 2, 0],
  [slot_w / 2, slot_h],
  [0, slot_h + gable],
  [-slot_w / 2, slot_h],
];

// MARK: Checks

echo(str("block = ", leg_thickness + leg_length, " x ", leg_thickness + leg_length, " x ", block_h, " mm"));
echo(str("leg thickness = ", leg_thickness, " mm"));
echo(str("channel = ", slot_w, " mm across the strap by ", slot_h, " mm tall"));
echo(str("tie stands off each flat by = ", face_offset, " mm"));
echo(str("bearing length per flat = ", contact_length, " mm"));
echo(str("straight run at each mouth = ", straight_run, " mm"));
echo(str("smallest bend_radius this tie and relief allow = ", min_bend_radius, " mm"));
echo(str("shortest object flat two blocks fit on = ", min_object_side, " mm"));
echo(str("tie loop needed = 4 x the object's side + ", tie_path_extra, " mm"));

assert(bend_radius >= min_bend_radius, "bend_radius is tighter than the corner can hold — the arc would cut into the relief. Raise bend_radius to min_bend_radius or above, or take it out of corner_relief_d or corner_web");
assert(straight_run > 0, "leg_length stops short of the tangent point, so the channel would open mid-bend and aim the tie across the flat instead of along it — lengthen leg_length or reduce bend_radius");
assert(contact_length > 0, "the corner relief has eaten the whole bearing face — lengthen leg_length or reduce corner_relief_d");
assert(corner_web > 0, "corner_web has to be positive — the tie pulls against it");
assert(slot_w > 0 && slot_h > 0, "tie_clearance has closed the channel — it cannot be more negative than the tie is thick");
assert(foot_chamfer < face_offset, "the foot chamfer has reached the channel — reduce foot_chamfer, or raise bend_radius to stand the channel further off the flats");
assert(foot_chamfer < deck, "the foot chamfer has reached the channel floor — reduce foot_chamfer or add deck");
assert(relief_r < leg_thickness, "the corner relief is wider than the block is thick — reduce corner_relief_d");

// MARK: Geometry

// One leg's straight run, in plan. The other leg is this one mirrored across
// the diagonal, so the two can never drift apart
module channel_leg_2d() {
  translate([-tie_offset - slot_w / 2, arc_c - seam])
    square([slot_w, leg_length + mouth_over - arc_c + seam]);
}

// The 90 deg bend, in plan: a quarter of an annulus centred on the diagonal,
// tangent to both straight runs where it meets them
module channel_arc_2d() {
  reach = bend_radius + slot_w;
  translate([arc_c, arc_c])
    intersection() {
      difference() {
        circle(r = bend_radius + slot_w / 2);
        circle(r = bend_radius - slot_w / 2);
      }
      translate([-reach, -reach])
        square(reach);
    }
}

module channel_2d() {
  channel_leg_2d();
  mirror([1, -1, 0])
    channel_leg_2d();
  channel_arc_2d();
}

// The skin between one leg's channel and the flat it lies against
module inner_skin_2d() {
  translate([-face_offset, 0])
    square([face_offset, leg_length]);
}

// Plan of the block: the channel wrapped in material, clipped back to the
// legs, with the object's own quadrant and the corner relief taken out. The
// disc fills everything inside the bend, which is where the corner web comes
// from — it is tangent to both inner walls, so it never reaches past them
module body_2d() {
  difference() {
    intersection() {
      union() {
        offset(r = outer_wall)
          channel_2d();
        inner_skin_2d();
        mirror([1, -1, 0])
          inner_skin_2d();
        translate([arc_c, arc_c])
          circle(r = bend_radius - slot_w / 2);
      }
      translate([-leg_thickness, -leg_thickness])
        square(leg_thickness + leg_length);
    }

    // The object's corner occupies this quadrant
    square(leg_length + 1);

    // Corner relief, so the block bears on the flats and never on the corner
    circle(r = relief_r);
  }
}

module channel_leg_3d() {
  translate([-tie_offset, leg_length + mouth_over, deck])
    rotate([90, 0, 0])
      linear_extrude(leg_length + mouth_over - arc_c + seam)
        polygon(channel_profile);
}

module channel_arc_3d() {
  translate([arc_c, arc_c, deck])
    rotate([0, 0, 180])
      rotate_extrude(angle = 90)
        translate([bend_radius, 0])
          polygon(channel_profile);
}

module channel_3d() {
  channel_leg_3d();
  mirror([1, -1, 0])
    channel_leg_3d();
  channel_arc_3d();
}

// Chamfer along the bottom edge of one inner face. Its run and rise are the
// same expression, so it is 45 deg whatever foot_chamfer is set to
module foot_chamfer_3d() {
  translate([0, leg_length + 1, 0])
    rotate([90, 0, 0])
      linear_extrude(leg_length + 1)
        polygon([
          [0, 0],
          [-foot_chamfer, 0],
          [0, foot_chamfer]
        ]);
}

module zip_tie_corner_block() {
  difference() {
    linear_extrude(block_h)
      body_2d();
    channel_3d();
    foot_chamfer_3d();
    mirror([1, -1, 0])
      foot_chamfer_3d();
  }
}

zip_tie_corner_block();
