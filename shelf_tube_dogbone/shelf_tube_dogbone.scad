// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// ============================================================
// Turn-N-Tube shelf dogbone — two-piece four-hole plate
// Makes a pair of adjacent shelf units rigid in one part,
// printed as two halves that bolt together.
//
// Couplers cannot hold two units square however many are
// fitted. Each is pinned at both ends by a round tube in a
// round hole and they all run the same direction, so the pair
// keeps a degree of freedom to shear front-to-back. Two pins
// into one unit is what removes it: pinned at two posts, a
// rigid plate cannot rotate relative to that unit, and a plate
// gripping two posts on each unit locks the two together.
//
// So this plate takes all four posts at one level — both units,
// front and back. Whole, it is about 286 mm long on the
// measured 200 mm post_clear_gap, past what a 256 mm bed
// takes; the bolted lap at mid-depth is what makes it
// printable here at all, and what keeps it printable on deeper
// units and smaller beds. It is one rigid body once assembled,
// which is all the geometry cares about.
//
// FOUR ROUND HOLES WOULD NOT GO ON. Four holes on four posts
// dictates the front-to-back post spacing of BOTH units at
// once, and two units that disagree by a few mm would leave
// the plate bridging nothing. So the front pair locates and
// the back pair are slots running front-to-back: the round
// holes fix position, the slots take up whatever the two units
// disagree about, and rotation stays fully constrained because
// each slot is elongated along the line to its own round hole.
// Nothing is left loose — every direction that matters is held
// by a hole wall, not by friction.
//
// PRINT NOTES:
// - PETG, no supports. Both halves print flat, lap face down,
//   and the step down to the lap is a drop in height rather
//   than an overhang.
// - The halves are exported side by side as two bodies. Let
//   the slicer arrange them; it is not a plate layout.
// - Assemble with two M4 bolts through the lap. The FRONT half
//   goes on as printed, the BACK half turns over — its lap
//   then sits on top of the front's and the assembly is flat
//   plate_thickness throughout.
// - One dogbone makes a pair of units rigid. It does not have
//   to be repeated per level; couplers elsewhere in the stack
//   only add stiffness.
// - Sits on top of whatever couplers share its posts.
// ============================================================

// ===== MEASURE THESE ON YOUR ACTUAL SHELVES =====
// Outside diameters, edge runs, and clear gaps between solids — every one of
// them is a measurement calipers can physically reach. Each names the caliper
// it needs, by the size printed on the tool: a 6 in caliper stops at 150 mm,
// an 8 in at 200 mm, a 12 in at 300 mm. This one wants a 12 in

tube_od = 30; // Outer diameter of the vertical tube post (mm) — outside jaws on the tube, 6 in caliper

// Tube's outer surface out to the facing edge of its own shelf (mm), 6 in
// caliper, measured on the side that faces the other unit
tube_to_edge = 20;

// Override these only if the two units differ
left_tube_to_edge = tube_to_edge;
right_tube_to_edge = tube_to_edge;

// Front-to-back clear gap between one unit's two posts, inner face to inner
// face (mm). 12 in caliper — 200.3 on these shelves is past where an 8 in one
// stops. Inside jaws into the open space between the front and back tube at
// any shelf level, wiggled for the smallest reading. Measured at 200.3 and
// recorded as 200 even. Unlike the brace, this one does not have to be right —
// the back slots absorb slot_travel worth of error either way. It only needs
// to be close enough to keep the real gap inside that window
post_clear_gap = 200;

// ===== DECIDE THIS =====
// Gap between the two units' facing shelf edges (mm). Must match what the
// couplers were printed with, since they set where the posts actually are
shelf_gap = 5;

// ===== TUNE THESE =====
hole_clearance = 0.6; // Added to hole diameter for slip fit (mm) — increase if too tight

// Front-to-back travel in the two back slots (mm). This is the whole tolerance
// budget: it covers error in post_clear_gap and any difference between the two
// units. The catalogue warns of half an inch of variation, so 30 is generous
// rather than optimistic
slot_travel = 30;

wall_meat = 5; // PETG thickness around each hole (mm)
plate_thickness = 5; // Thickness of the finished plate (mm) — match the coupler
spine_width = 30; // Width of the narrow waist between the two crossbars (mm)
fillet = 4; // Radius softening where the spine meets a crossbar (mm)

// ===== LAP JOINT =====
lap_length = 50; // How far the two tails overlap (mm)
bolt_d = 4.4; // Through-hole for an M4 bolt (mm)
bolt_spacing = 24; // Between the two lap bolts, front to back (mm)
bolt_edge = 10; // Material kept beyond a bolt centre (mm)

// ===== PRINTER =====
bed_size = 256; // Print bed, short side (mm)
bed_margin = 6; // Clearance at each bed edge for brim and skirt (mm)
part_gap = 8; // Separation between the two exported bodies (mm)

// Render the halves mated instead, to eyeball the lap and the slots
assembled_view = false;

$fn = 60;

// ===== DERIVED =====
// Across the gap: half a tube, the run out to each shelf edge, and the gap.
// Identical to the coupler's hole spacing, by construction
across_center_distance = tube_od + left_tube_to_edge + shelf_gap + right_tube_to_edge;

// Front to back along one unit, centre to centre. The clear gap misses one
// tube radius at each end, so a whole diameter goes back on
depth_center_distance = post_clear_gap + tube_od;

hole_r = tube_od / 2 + hole_clearance / 2;
collar_r = hole_r + wall_meat;

// Each tail reaches past the midpoint by half the overlap, so the two halves
// are the same length and their bolt holes land on each other
tail_reach = (depth_center_distance + lap_length) / 2;
lap_thickness = plate_thickness / 2;

// Bolts sit either side of the midpoint, which is the middle of the overlap
bolt_x = depth_center_distance / 2;

// The back crossbar reaches slot_travel / 2 further out than a round-holed one
// would, so the finished plate is longer than the hole spacing suggests
assembled_length = depth_center_distance + 2 * collar_r + slot_travel / 2;

front_half_length = collar_r + tail_reach;
back_half_length = collar_r + slot_travel / 2 + tail_reach;
half_width = across_center_distance + 2 * collar_r;

// Conservative square bed requirement from the back half bounding rectangle
// Both dimensions counted at 0 degrees, compared with the rectangle at 45
turned_square = (back_half_length + half_width) / sqrt(2);
unturned_square = max(back_half_length, half_width);
bed_square = min(unturned_square, turned_square);
bed_angle = turned_square < unturned_square ? 45 : 0;

echo(str("across-the-gap hole spacing = ", across_center_distance, " mm"));
echo(str("front-to-back hole spacing = ", depth_center_distance, " mm"));
echo(str("assembled plate = ", assembled_length, " x ", half_width, " x ", plate_thickness, " mm"));
echo(str("front half = ", front_half_length, " x ", half_width, " mm"));
echo(str("back half = ", back_half_length, " x ", half_width, " mm"));
echo(str("bed placement = ", bed_angle, " deg for the back half, needs a ", bed_square, " mm square"));
echo(str("post_clear_gap tolerated = ", post_clear_gap - slot_travel / 2, " to ", post_clear_gap + slot_travel / 2, " mm"));

assert(post_clear_gap > 0, "post_clear_gap is the open space between the two posts, not a span across them — measure inner face to inner face");
assert(across_center_distance > 2 * hole_r, "the two holes in a crossbar have run together — check shelf_gap and the tube-to-edge runs");
assert(bolt_x + bolt_spacing / 2 <= tail_reach - bolt_edge, "the outer lap bolt has run off the end of the tail — raise lap_length or lower bolt_spacing");
assert(bolt_x - bolt_spacing / 2 >= tail_reach - lap_length + bolt_edge, "the inner lap bolt has run past where the overlap starts — raise lap_length or lower bolt_spacing");
assert(spine_width >= bolt_d + 2 * bolt_edge, "the lap bolts have no material either side of them — widen spine_width");
assert(spine_width > 2 * fillet, "fillet has eaten the spine — lower it or widen spine_width");
assert(bed_square <= bed_size - 2 * bed_margin, "a half does not fit the print bed — see the echoed sizes");

// 2D lozenge (stadium) shape: hull of two circles, long axis along X.
// Duplicated from the coupler rather than shared, because every source here
// is meant to stand on its own. A cdist of 0 collapses it to a circle, which
// is how the front half gets round holes from the same code as the slots
module lozenge_2d(r, cdist) {
  hull() {
    translate([-cdist / 2, 0])
      circle(r = r);
    translate([cdist / 2, 0])
      circle(r = r);
  }
}

// The wide bar carrying one half's two holes, stretched along X by travel so
// the collar keeps its meat all the way to the ends of a slot
module crossbar_2d(travel) {
  rotate([0, 0, 90])
    lozenge_2d(collar_r, across_center_distance);

  for(s = [-1, 1])
    translate([0, s * across_center_distance / 2])
      lozenge_2d(collar_r, travel);
}

// Crossbar plus the tail that reaches to the lap, concave corners filleted
module half_outline_2d(travel) {
  offset(r = -fillet)
    offset(r = fillet) {
      crossbar_2d(travel);

      translate([-collar_r, -spine_width / 2])
        square([collar_r + tail_reach, spine_width]);
    }
}

// One half, lap tongue on the bottom face. Both halves are the same shape;
// travel is 0 for the locating front half and slot_travel for the back
module dogbone_half(travel) {
  difference() {
    union() {
      // Full thickness everywhere the lap is not
      linear_extrude(height = plate_thickness)
        difference() {
          half_outline_2d(travel);

          translate([tail_reach - lap_length, -spine_width])
            square([lap_length + 1, 2 * spine_width]);
        }

      // The lap itself, half thickness so the two tongues stack flush
      linear_extrude(height = lap_thickness)
        half_outline_2d(travel);
    }

    // Tube holes: round on the front half, front-to-back slots on the back
    for(s = [-1, 1])
      translate([0, s * across_center_distance / 2, -1])
        linear_extrude(height = plate_thickness + 2)
          lozenge_2d(hole_r, travel);

    // Lap bolts
    for(b = [-1, 1])
      translate([bolt_x + b * bolt_spacing / 2, 0, -1])
        cylinder(r = bolt_d / 2, h = plate_thickness + 2);
  }
}

// The back half turned over onto the front one, as it goes together
module assembled() {
  dogbone_half(0);

  translate([depth_center_distance, 0, plate_thickness])
    rotate([0, 180, 0])
      dogbone_half(slot_travel);
}

if (assembled_view) {
  assembled();
} else {
  translate([0, (half_width + part_gap) / 2, 0])
    dogbone_half(0);

  translate([0, -(half_width + part_gap) / 2, 0])
    dogbone_half(slot_travel);
}
