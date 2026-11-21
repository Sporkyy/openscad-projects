// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// Adhesive mounting disc — a flat adhesive face and an upward blind pilot bore.
// Screw an openGrid tile into the plastic; stick the closed face to the TV.
// All dimensions are millimetres. Sized for 30 mm adhesive pads;
// starting screw choice is 3.5 x 10 mm countersunk for a 6.8 mm Full tile.
// Screw and pilot fit still need a trial with the actual hardware.
// Print closed face down, bore up. Vertical walls need no supports or bridges.

// MARK: Dimensions

// Measure the pad and screw with calipers
adhesive_disc_diameter = 30; // mm
screw_diameter = 3.5; // mm, over the threads

// MARK: Tuning

// Printed disc beyond the pad, per side
adhesive_margin = 1; // mm

// Pilot bore
bore_diameter = 2.8; // mm
bore_depth = 6; // mm, open face to bore floor
// (No fit allowance is added; trial-print before mounting anything)

// Solid plastic under the bore
floor_thickness = 1; // mm
// (At least 1 mm; a self-drilling screw can still pierce it)

$fn = 128;

// MARK: Derived

outer_diameter = adhesive_disc_diameter + 2 * adhesive_margin;
thickness = bore_depth + floor_thickness;
// Radial material remaining at the screw's full thread diameter.
screw_wall = (outer_diameter - screw_diameter) / 2;
// Extend only above the mouth; never extend the cut below the bore floor.
cut_overlap = 0.01;

// MARK: Checks

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

// MARK: Geometry

module adhesive_mounting_disc() {
  difference() {
    cylinder(d = outer_diameter, h = thickness);
    translate([0, 0, floor_thickness])
      cylinder(d = bore_diameter, h = bore_depth + cut_overlap);
  }
}

adhesive_mounting_disc();
