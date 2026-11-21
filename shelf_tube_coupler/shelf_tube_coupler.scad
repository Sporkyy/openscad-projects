// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// ============================================================
// Turn-N-Tube shelf coupler — rigid lozenge collar
// Connects two adjacent shelf units at one tube height.
// Replaces zip ties: a lozenge collar slips over both vertical
// tube posts and holds them at a fixed spacing.
//
// The coupler DEFINES the spacing — it does not have to fit
// the units as they currently sit. Set the gap you want and
// the hole spacing follows from the tube and the tube-to-edge
// run on each unit. Nothing here depends on how far apart the
// units happen to be today.
//
// A deliberate gap is worth having: adjacent units rarely have
// their shelves at the same height, and the gap keeps that
// mismatch from reading as a misalignment.
//
// There is deliberately no gap-filling wall. An earlier version
// hung one below the collar to stiffen the pair and it did
// nothing: couplers are pinned at both ends by a round tube in
// a round hole, and every one of them runs the same direction,
// so the pair keeps a degree of freedom to shear sideways
// however many are fitted. A wall can only fight that with
// friction, and it lost. Printing it back would buy nothing —
// shelf_tube_brace.scad is the diagonal link that removes the
// freedom itself.
//
// PRINT NOTES:
// - PETG, no supports needed — a flat plate with round holes.
// - Print with the collar axis vertical (as modeled) so the
//   holes print round and the tube slides through cleanly.
// - Rests on the shelf below. Two per shelf level (front and
//   back post pair), 8 total for a 5-tier unit — the top shelf
//   has no tube above it.
// - These hold the spacing, not the squareness. Add one
//   shelf_tube_brace per pair of units.
// ============================================================

// MARK: Dimensions

// Measure the shelves
tube_od = 30; // mm
tube_to_edge = 20; // mm, tube to its shelf's facing edge

// Override only if the two units differ
left_tube_to_edge = tube_to_edge; // mm
right_tube_to_edge = tube_to_edge; // mm

// Gap between the units' facing shelf edges
shelf_gap = 5; // mm

// MARK: Tuning

hole_clearance = 0.6; // mm, on each hole; raise if too tight
wall_meat = 5; // mm, around each hole
collar_height = 5; // mm

$fn = 100;

// MARK: Derived

// Tube centre to tube centre: half a tube, the run out to each shelf
// edge, and the gap between those edges
center_distance = tube_od + left_tube_to_edge + shelf_gap + right_tube_to_edge;

hole_r = tube_od / 2 + hole_clearance / 2;
collar_r = hole_r + wall_meat;

// Narrowest material across the waist, between the two holes. The collar is
// only as strong as this, and it is what a very small shelf_gap eats into
waist = center_distance - 2 * hole_r;

// MARK: Checks

echo(str("center-to-center hole spacing = ", center_distance, " mm"));
echo(str("overall length = ", center_distance + 2 * collar_r, " mm"));
echo(str("waist between the holes = ", waist, " mm"));

assert(waist > 0, "the two holes have run together — shelf_gap plus the tube-to-edge runs has to beat hole_clearance");

// MARK: Geometry

// 2D lozenge (stadium) shape: hull of two circles
module lozenge_2d(r, cdist) {
  hull() {
    translate([-cdist / 2, 0])
      circle(r = r);
    translate([cdist / 2, 0])
      circle(r = r);
  }
}

module coupler() {
  difference() {
    linear_extrude(height = collar_height)
      lozenge_2d(collar_r, center_distance);

    // Through-holes for the two tube posts
    translate([-center_distance / 2, 0, -1])
      cylinder(r = hole_r, h = collar_height + 2);
    translate([center_distance / 2, 0, -1])
      cylinder(r = hole_r, h = collar_height + 2);
  }
}

coupler();
