// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// Round washer — a flat annular disc with a concentric through bore.
// All dimensions are millimetres. Defaults are a shelf-spacer trial, not a load rating.
// Print as modelled, flat face on the plate and bore axis vertical.
// Outer edge chamfers are 45 degrees; no supports or bridges are needed.

// MARK: Dimensions

// Measure an existing washer, or choose the finished size
inner_diameter = 6.5; // mm
outer_diameter = 50.8; // mm
thickness = 6; // mm
// (Put any fit clearance in inner_diameter)

// MARK: Tuning

edge_chamfer = 0.5; // mm, 45 deg on both outer edges; 0 disables
$fn = 128;

// MARK: Derived

radial_width = (outer_diameter - inner_diameter) / 2;
outer_radius = outer_diameter / 2;
bearing_diameter = outer_diameter - 2 * edge_chamfer;
// Extend the bore past both faces so the cut has no coincident end faces.
cut_overlap = 0.01;

// MARK: Checks

assert(inner_diameter > 0, "inner_diameter must be positive to leave a through bore");
assert(radial_width > 0, "outer_diameter must exceed inner_diameter to leave material around the bore");
assert(thickness > 0, "thickness must be positive");
assert(edge_chamfer >= 0, "edge_chamfer must not be negative");
assert(2 * edge_chamfer < thickness, "edge chamfers must leave a straight outer wall");
assert(edge_chamfer < radial_width, "edge chamfers must leave flat bearing faces around the bore");

echo(str("inner diameter (ID) = ", inner_diameter, " mm"));
echo(str("outer diameter (OD) = ", outer_diameter, " mm"));
echo(str("thickness = ", thickness, " mm"));
echo(str("radial width = ", radial_width, " mm"));
echo(str("outer edge chamfer = ", edge_chamfer, " mm at 45 degrees"));
echo(str("flat bearing diameter = ", bearing_diameter, " mm"));

// MARK: Geometry

module round_washer() {
  difference() {
    if (edge_chamfer == 0)
      cylinder(d = outer_diameter, h = thickness);
    else
      rotate_extrude()
        polygon([
          [0, 0],
          [outer_radius - edge_chamfer, 0],
          [outer_radius, edge_chamfer],
          [outer_radius, thickness - edge_chamfer],
          [outer_radius - edge_chamfer, thickness],
          [0, thickness]
        ]);
    translate([0, 0, -cut_overlap])
      cylinder(d = inner_diameter, h = thickness + 2 * cut_overlap);
  }
}

round_washer();
