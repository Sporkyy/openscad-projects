// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// Adhesive mounting disc — a flat adhesive face and an upward blind pilot bore.
// Screw an openGrid tile into the plastic; stick the closed face to the TV.
// All dimensions are millimetres. Sized for 30 mm adhesive pads;
// starting screw choice is 3.5 x 10 mm countersunk for a 6.8 mm Full tile.
// Screw and pilot fit still need a trial with the actual hardware.
// Print closed face down, bore up. Vertical walls need no supports or bridges.

// ===== MEASURE THESE =====

// Adhesive disc outside diameter (mm) — outside jaws across the disc,
// 6 in caliper. The printed disc extends beyond it by adhesive_margin per side.
adhesive_disc_diameter = 30;

// Screw outside diameter over the threads (mm) — outside jaws on the threaded
// shank, 6 in caliper. The pilot bore must be smaller so the threads can bite.
screw_diameter = 3.5;

// ===== TUNE THESE =====

// Printed margin beyond the adhesive disc, radially on each side (mm).
adhesive_margin = 1;

// Nominal pilot-bore diameter (mm). Choose for the screw and printed material;
// no fit allowance is added. Check a trial print before mounting anything.
bore_diameter = 2.8;

// Depth from the open face to the flat bore floor (mm). Allow room for the
// ENTIRE screw tip projecting behind the tile, with clearance above the floor.
bore_depth = 6;

// Solid plastic under the bore (mm). At least 1 mm is enforced below.
// This is a geometric minimum, not a stop that a self-drilling screw cannot pierce.
floor_thickness = 1;

$fn = 128;

// ===== DERIVED =====
outer_diameter = adhesive_disc_diameter + 2 * adhesive_margin;
thickness = bore_depth + floor_thickness;
// Radial material remaining at the screw's full thread diameter.
screw_wall = (outer_diameter - screw_diameter) / 2;
// Extend only above the mouth; never extend the cut below the bore floor.
cut_overlap = 0.01;

assert(adhesive_disc_diameter > 0, "adhesive_disc_diameter must be positive");
assert(adhesive_margin > 0, "adhesive_margin must be positive so the printed disc is wider than the adhesive");
assert(bore_diameter > 0, "bore_diameter must be positive to leave a pilot bore");
assert(screw_diameter > bore_diameter, "screw_diameter must exceed bore_diameter so the threads can bite");
assert(screw_wall > 0, "outer_diameter must exceed screw_diameter to leave material around the screw");
assert(bore_depth > 0, "bore_depth must be positive");
assert(floor_thickness >= 1, "floor_thickness must be at least 1 mm to keep a solid bottom under the blind bore");

echo(str("outer diameter = ", outer_diameter, " mm"));
echo(str("overall thickness = ", thickness, " mm"));
echo(str("pilot bore = ", bore_diameter, " mm diameter x ", bore_depth, " mm deep"));
echo(str("solid floor = ", floor_thickness, " mm (minimum 1 mm)"));
echo(str("radial wall at screw thread diameter = ", screw_wall, " mm"));

module adhesive_mounting_disc() {
  difference() {
    cylinder(d = outer_diameter, h = thickness);
    translate([0, 0, floor_thickness])
      cylinder(d = bore_diameter, h = bore_depth + cut_overlap);
  }
}

adhesive_mounting_disc();
