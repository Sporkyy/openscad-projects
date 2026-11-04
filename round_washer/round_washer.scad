// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// Round washer — a flat annular disc with a concentric through bore.
// All dimensions are millimetres. Defaults are examples, not a standard size.
// Print as modelled, flat face on the plate and bore axis vertical.
// The walls are vertical; no supports or bridges are needed.

// ===== DIMENSIONS =====
// Measure an existing washer or choose the finished dimensions you need.

// Inner diameter (ID) of the through bore (mm) — inside jaws at the bore
// opening, 6 in caliper. Include any desired fit clearance in this value.
inner_diameter = 6.5;

// Outer diameter (OD) of the washer (mm) — outside jaws across the rim,
// 6 in caliper.
outer_diameter = 20;

// Axial thickness between the two flat faces (mm) — outside jaws on the
// faces, 6 in caliper.
thickness = 2;

// ===== TUNE THESE =====
$fn = 128;

// ===== DERIVED =====
radial_width = (outer_diameter - inner_diameter) / 2;
// Extend the bore past both faces so the cut has no coincident end faces.
cut_overlap = 0.01;

assert(inner_diameter > 0, "inner_diameter must be positive to leave a through bore");
assert(radial_width > 0, "outer_diameter must exceed inner_diameter to leave material around the bore");
assert(thickness > 0, "thickness must be positive");

echo(str("inner diameter (ID) = ", inner_diameter, " mm"));
echo(str("outer diameter (OD) = ", outer_diameter, " mm"));
echo(str("thickness = ", thickness, " mm"));
echo(str("radial width = ", radial_width, " mm"));

module round_washer() {
  difference() {
    cylinder(d = outer_diameter, h = thickness);
    translate([0, 0, -cut_overlap])
      cylinder(d = inner_diameter, h = thickness + 2 * cut_overlap);
  }
}

round_washer();
