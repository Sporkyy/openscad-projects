// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// Square washer — a flat square plate with a centred round through bore.
// All dimensions are millimetres. Defaults are examples, not a standard size.
// Print as modelled, flat face on the plate and bore axis vertical.
// The walls are vertical; no supports or bridges are needed.

// MARK: Dimensions

// Measure an existing washer, or choose the finished size
inner_diameter = 6.5; // mm
side_length = 20; // mm
thickness = 2; // mm
// (Put any fit clearance in inner_diameter)

// MARK: Tuning

$fn = 128;

// MARK: Derived

// Narrowest material between the bore and any of the four straight edges.
minimum_edge_width = (side_length - inner_diameter) / 2;
// Extend the bore past both faces so the cut has no coincident end faces.
cut_overlap = 0.01;

// MARK: Checks

assert(inner_diameter > 0, "inner_diameter must be positive to leave a through bore");
assert(minimum_edge_width > 0, "side_length must exceed inner_diameter to leave material around the bore");
assert(thickness > 0, "thickness must be positive");

echo(str("inner diameter (ID) = ", inner_diameter, " mm"));
echo(str("square side length = ", side_length, " mm"));
echo(str("thickness = ", thickness, " mm"));
echo(str("minimum edge width = ", minimum_edge_width, " mm"));

// MARK: Geometry

module square_washer() {
  difference() {
    translate([-side_length / 2, -side_length / 2, 0])
      cube([side_length, side_length, thickness]);
    translate([0, 0, -cut_overlap])
      cylinder(d = inner_diameter, h = thickness + 2 * cut_overlap);
  }
}

square_washer();
