// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// ============================================================
// Dowel end cap — a blind socket that closes off a dowel end
//
// A plain cylinder with a cylindrical recess bored into one
// end. The dowel pushes into the recess until it bottoms out;
// the remaining material caps the end.
//
// Optionally a countersunk screw hole runs through the closed
// end, so a flat-head screw can pull the cap down onto the
// dowel instead of the fit or a glue line holding it there.
//
// Modeled mouth up, closed end on the plate.
//
// The cap DEFINES its own proportions from one measurement.
// Everything is driven by the dowel diameter plus the meat you
// want around it, so the outside diameter and the overall
// length both fall out of the numbers below rather than being
// set directly.
//
// The recess is a dimension inside a hollow solid, so it is
// never measured — it is bored to the dowel diameter plus a
// clearance knob. Measure the dowel, not the hole you want.
//
// PRINT NOTES:
// - PETG or PLA, no supports needed.
// - Print as modeled, closed end down. The bore opens upward,
//   so nothing bridges, and the visible end face is laid
//   against the plate. Flipped, the bore roof has to bridge
//   its full width — it works, but it leaves a rough ceiling
//   for the dowel to bottom out against.
// - The bore prints round with the axis vertical either way.
// - Chamfers break both rims and take the elephant foot off
//   whichever end lands on the plate.
// - The countersink opens at the plate and closes in at 45
//   deg, so it is self-supporting exactly like the chamfers.
//   It makes the first layer a ring rather than a disc, which
//   costs a little bed adhesion — the end face is wide, so
//   there is plenty left.
// ============================================================

// MARK: Dimensions

// Measure the dowel at its widest
dowel_d = 9.7; // mm

// How the cap fits it
penetration_depth = 30; // mm, how far the dowel goes in
wall_meat = 10; // mm, around the dowel and over its end
// (About 1.5 dowel diameters of penetration is plenty)

// Countersunk hole for a flat-head screw into the end grain
screw_hole = false;
screw_shank_d = 3; // mm, over the threads
screw_head_d = 7; // mm, at its widest

// MARK: Tuning

dowel_clearance = 0.3; // mm, on the bore; raise if it will not seat
screw_clearance = 0.4; // mm, on both screw diameters
chamfer = 1; // mm, on both outer rims
lead_in = 0.6; // mm, funnel at the bore mouth

$fn = 100;

// MARK: Derived

bore_d = dowel_d + dowel_clearance;
cap_d = dowel_d + 2 * wall_meat;
cap_length = penetration_depth + wall_meat;
screw_shank_hole_d = screw_shank_d + screw_clearance;
screw_head_hole_d = screw_head_d + screw_clearance;

// Depth of the countersink cone. It is half the difference of the two bored
// diameters and nothing else, which is what makes the cone 45 deg to the plate
// — a 90 deg included angle, the flat-head standard — whatever screw it is cut
// for
countersink_depth = (screw_head_hole_d - screw_shank_hole_d) / 2;

// Straight-walled part of the screw hole, left under the cone. The cone eats
// down from the plate and the bore floor caps it from above, so this is what
// keeps the two from meeting
screw_seat = wall_meat - countersink_depth;

// Material left on the end face, once the outer chamfer has taken from the
// outside and the countersink mouth has opened up in the middle
end_face_ring = (cap_d - 2 * chamfer - screw_head_hole_d) / 2;

// Material left on the face of the rim, once the outer chamfer has taken from
// the outside and the lead-in funnel has taken from the inside. The cap is
// only as strong at the mouth as this, and it is the first thing a large
// chamfer or a generous lead-in eats
rim_face = (cap_d - bore_d) / 2 - chamfer - lead_in;

// MARK: Checks

echo(str("outside diameter = ", cap_d, " mm"));
echo(str("overall length = ", cap_length, " mm"));
echo(str("bored diameter = ", bore_d, " mm"));
echo(str("rim face at the mouth = ", rim_face, " mm"));

if (screw_hole) {
  echo(str("screw shank hole = ", screw_shank_hole_d, " mm"));
  echo(str("countersink mouth = ", screw_head_hole_d, " mm across, ", countersink_depth, " mm deep"));
  echo(str("straight hole under the countersink = ", screw_seat, " mm"));
  echo(str("end face ring outside the countersink = ", end_face_ring, " mm"));
}

assert(wall_meat > 0, "wall_meat has to be positive — there is no cap without material around the dowel");
assert(penetration_depth > 0, "penetration_depth has to be positive — the dowel has to go somewhere");
assert(bore_d > 0, "dowel_clearance has closed the bore — it cannot be more negative than the dowel is wide");
assert(rim_face > 0, "the mouth has no rim left — reduce chamfer or lead_in, or add wall_meat");
assert(chamfer < cap_length / 2, "the two outer chamfers have met in the middle — reduce chamfer");
assert(lead_in < penetration_depth, "the lead-in funnel is deeper than the bore — reduce lead_in");
assert(!screw_hole || screw_head_d > screw_shank_d, "screw_head_d is no wider than screw_shank_d — that screw has no head to countersink");
assert(!screw_hole || screw_shank_hole_d < bore_d, "the screw hole is wider than the bore — it would break out through the socket wall instead of into the end of the dowel");
assert(!screw_hole || screw_seat > 0, "the countersink has cut through into the bore — use a smaller screw or add wall_meat");
assert(!screw_hole || end_face_ring > 0, "the countersink has run off the end face — use a smaller screw head, reduce chamfer, or add wall_meat");

// MARK: Geometry

// Outer silhouette, revolved: a cylinder with both rims broken. x is radius
// out from the axis, y is height up from the closed end
module cap_body() {
  r = cap_d / 2;
  rotate_extrude()
    polygon([
      [0, 0],
      [r - chamfer, 0],
      [r, chamfer],
      [r, cap_length - chamfer],
      [r - chamfer, cap_length],
      [0, cap_length],
    ]);
}

module dowel_endcap() {
  difference() {
    cap_body();

    // Blind bore for the dowel, opening upward at the mouth
    translate([0, 0, wall_meat])
      cylinder(d = bore_d, h = penetration_depth + 1);

    // Funnel at the mouth, so the dowel starts square instead of
    // catching on the rim
    translate([0, 0, cap_length - lead_in])
      cylinder(d1 = bore_d, d2 = bore_d + 2 * lead_in, h = lead_in);

    if (screw_hole) {
      // Clearance hole for the shank, from the plate up through the end
      // wall and into the bore
      cylinder(d = screw_shank_hole_d, h = wall_meat + 1);

      // Countersink, so a flat head finishes flush with the end face. The
      // cone's radial change equals its height, so it stays at 45 deg to
      // the plate whatever screw it is cut for. It is dropped 1 mm below
      // the plate — which is where the 2 mm on the mouth diameter comes
      // from — so the mouth cuts cleanly instead of landing on the end
      // face as a coincident edge
      translate([0, 0, -1])
        cylinder(d1 = screw_head_hole_d + 2, d2 = screw_shank_hole_d, h = countersink_depth + 1);
    }
  }
}

dowel_endcap();
