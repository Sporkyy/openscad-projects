// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// ============================================================
// Turn-N-Tube shelf brace — diagonal triangulating link
// The third link that makes two adjacent shelf units rigid.
//
// Two couplers at one level do not hold the units still. Each
// is pinned at both ends by a round tube in a round hole, so
// the pair forms a four-bar linkage: one degree of freedom, no
// matter how stiff the couplers are or how far apart they sit.
// The units stay parallel and shear sideways. That is
// kinematic, not a stiffness problem, which is why the
// coupler's old gap-filling wall never fixed it — friction was
// all it had.
//
// Two rigid bodies have three degrees of freedom in plan and
// each link removes one, so three links lock them together.
// This brace is the third. It runs diagonally from one unit's
// FRONT post to the other unit's BACK post, so it is not
// parallel to the couplers and takes away the freedom they
// leave behind.
//
// Three links is the entire requirement. One brace anywhere in
// the stack makes the pair rigid; couplers at the other levels
// only add stiffness.
//
// PRINT NOTES:
// - Modelled as a straight bar. The diagonal is where it goes,
//   not what it is.
// - Long. It always goes on the bed turned 45 degrees, which
//   is the only way the shipped length fits at all; the echoed
//   bed placement gives the square it needs.
// - PETG, no supports, flat on the bed. Flat runs the
//   perimeters along the load path; on edge would load the
//   part across its layers.
// - It shares posts with the couplers at whichever level it
//   goes on, resting on one at each end, so it sits level a
//   coupler's height above the shelf.
// - One per pair of units, not one per level.
// ============================================================

// MARK: Dimensions

// Measure the shelves
tube_od = 30; // mm
tube_to_edge = 20; // mm, tube to its shelf's facing edge
post_clear_gap = 200; // mm, between one unit's posts, smallest reading
brace_clear_gap = undef; // mm, diagonal gap if measured; undef derives it
// (tube_to_edge and shelf_gap must match the couplers)

// Override only if the two units differ
left_tube_to_edge = tube_to_edge; // mm
right_tube_to_edge = tube_to_edge; // mm

// Gap between the units' facing shelf edges
shelf_gap = 5; // mm

// MARK: Tuning

hole_clearance = 2; // mm, looser than the coupler's on purpose
wall_meat = 5; // mm, around each hole
brace_height = 5; // mm, match the coupler so it stacks flat
bed_size = 256; // mm, print bed's short side
bed_margin = 6; // mm, at each bed edge for brim and skirt

$fn = 100;

// MARK: Derived

// Across the gap: half a tube, the run out to each shelf edge, and the gap.
// Identical to the coupler's own hole spacing, by construction
across_center_distance = tube_od + left_tube_to_edge + shelf_gap + right_tube_to_edge;

// Front to back along one unit, centre to centre. The clear gap misses one
// tube radius at each end, so a whole diameter goes back on
depth_center_distance = post_clear_gap + tube_od;

// The diagonal itself: front post of one unit to back post of the other
derived_brace_distance = sqrt(across_center_distance * across_center_distance + depth_center_distance * depth_center_distance);
brace_center_distance = is_undef(brace_clear_gap) ? derived_brace_distance : brace_clear_gap + tube_od;

hole_r = tube_od / 2 + hole_clearance / 2;
collar_r = hole_r + wall_meat;

overall_length = brace_center_distance + 2 * collar_r;
overall_width = 2 * collar_r;

// Square bed requirement at 45 degrees, taken from the rounded bar silhouette
// rather than from its bounding box: the projected centre spacing plus the
// unchanged diameter of the round ends. Turning the bounding box instead counts
// corners a stadium never occupies and overstates the square by about 17 mm on
// the shipped dimensions
//
// There is no square-on case to choose between. A stadium always fits a smaller
// square turned, since the projected centre spacing is shorter than the spacing
// itself for every length the hole-overlap assert below leaves standing, so the
// angle is 45 whatever the parameters are set to
bed_square = brace_center_distance / sqrt(2) + 2 * collar_r;
bed_angle = 45;

// MARK: Checks

echo(str("across-the-gap hole spacing = ", across_center_distance, " mm"));
echo(str("front-to-back hole spacing = ", depth_center_distance, " mm"));
echo(str("brace hole spacing = ", brace_center_distance, " mm"));
echo(str("overall size = ", overall_length, " x ", overall_width, " mm"));
echo(str("bed placement = ", bed_angle, " deg, needs a ", bed_square, " mm square"));

assert(post_clear_gap > 0, "post_clear_gap is the open space between the two posts, not a span across them — measure inner face to inner face");
assert(brace_center_distance > 2 * hole_r, "the two holes overlap — check post_clear_gap and shelf_gap");
assert(bed_square <= bed_size - 2 * bed_margin, "brace does not fit the print bed — see the echoed bed placement, and split it into two bolted halves if the units really are this deep");

// MARK: Geometry

// 2D lozenge (stadium) shape: hull of two circles. Duplicated from
// shelf_tube_coupler.scad rather than shared, because every source here is
// meant to stand on its own
module lozenge_2d(r, cdist) {
  hull() {
    translate([-cdist / 2, 0])
      circle(r = r);
    translate([cdist / 2, 0])
      circle(r = r);
  }
}

module brace() {
  difference() {
    linear_extrude(height = brace_height)
      lozenge_2d(collar_r, brace_center_distance);

    // Through-holes for the two tube posts
    translate([-brace_center_distance / 2, 0, -1])
      cylinder(r = hole_r, h = brace_height + 2);
    translate([brace_center_distance / 2, 0, -1])
      cylinder(r = hole_r, h = brace_height + 2);
  }
}

brace();
