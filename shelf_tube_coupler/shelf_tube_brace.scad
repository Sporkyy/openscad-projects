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

// ===== MEASURE THESE ON YOUR ACTUAL SHELVES =====
// Outside diameters, edge runs, and clear gaps between solids — every one of
// them is a measurement calipers can physically reach. Each names the caliper
// it needs, by the size printed on the tool: a 6 in caliper stops at 150 mm,
// an 8 in at 200 mm, a 12 in at 300 mm. This one wants a 12 in

tube_od = 30; // Outer diameter of the vertical tube post (mm) — outside jaws on the tube, 6 in caliper

// Tube's outer surface out to the facing edge of its own shelf (mm), 6 in
// caliper, measured on the side that faces the other unit. Same measurement the
// coupler uses, and it has to match — the two parts share the across-the-gap
// hole spacing
tube_to_edge = 20;

// Override these only if the two units differ
left_tube_to_edge = tube_to_edge;
right_tube_to_edge = tube_to_edge;

// Front-to-back clear gap between one unit's two posts, inner face to inner
// face (mm). 12 in caliper — 200.3 on these shelves is past where an 8 in one
// stops, and that is the whole reason this parameter is a gap and not a span.
// Inside jaws into the open space between the front and back tube at any shelf
// level, wiggled for the smallest reading — that minimum is the gap along the
// line of centres, which is what this wants. Measured at 200.3 and recorded as
// 200 even. Re-measure it for other units rather than deriving it from the
// board depth: this number sets the brace length almost one-for-one
post_clear_gap = 200;

// Ground truth, if you would rather not trust the two spans agreeing. Measure
// the diagonal clear gap across the assembled pair, one unit's front tube to
// the other unit's back tube, nearest faces, and put it here. 12 in caliper: it
// runs longer than post_clear_gap, about 212 on these shelves. Leave it undef
// to derive the diagonal instead
brace_clear_gap = undef;

// ===== DECIDE THIS =====
// Gap between the two units' facing shelf edges (mm). Must be the same value
// the couplers were printed with — they set the gap, and the brace has to
// agree with where they put the posts
shelf_gap = 5;

// ===== TUNE THESE =====
// Deliberately looser than the coupler's fit. The brace is a length-critical
// part with no slot to take up error, and its diagonal is derived from two
// measurements rather than read off the shelves directly, so this buys
// tolerance for both. It costs about half of it in residual sway, which is
// nothing against the free degree of freedom it removes
hole_clearance = 2;

wall_meat = 5; // PETG thickness around each hole (mm)
brace_height = 5; // Thickness of the bar (mm) — match the coupler so it stacks flat
bed_size = 256; // Print bed, short side (mm)
bed_margin = 6; // Clearance at each bed edge for brim and skirt (mm)

$fn = 100;

// ===== DERIVED =====
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

echo(str("across-the-gap hole spacing = ", across_center_distance, " mm"));
echo(str("front-to-back hole spacing = ", depth_center_distance, " mm"));
echo(str("brace hole spacing = ", brace_center_distance, " mm"));
echo(str("overall size = ", overall_length, " x ", overall_width, " mm"));
echo(str("bed placement = ", bed_angle, " deg, needs a ", bed_square, " mm square"));

assert(post_clear_gap > 0, "post_clear_gap is the open space between the two posts, not a span across them — measure inner face to inner face");
assert(brace_center_distance > 2 * hole_r, "the two holes overlap — check post_clear_gap and shelf_gap");
assert(bed_square <= bed_size - 2 * bed_margin, "brace does not fit the print bed — see the echoed bed placement, and split it into two bolted halves if the units really are this deep");

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
