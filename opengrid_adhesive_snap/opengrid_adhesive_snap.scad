// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// SPDX-FileCopyrightText: openGrid snap profile — David D, CC BY 4.0,
// via mitufy/opengrid-projects, CC BY 4.0. See the header below.
// ============================================================
// openGrid adhesive snap — a full-thickness snap with a plain
// front for a double-sided adhesive dot, and a thin lip that
// lands on the tile face so a small screwdriver can pry it out
//
// Flush front, nothing to grab: lip overhangs the snap by
// lip_overhang on every side and stands lip_thickness proud,
// with a 45 deg bevel on its tile side for the blade to enter
//
// THE SNAP PROFILE IS NOT ORIGINAL WORK, AND THIS NOTICE IS A
// LICENCE CONDITION RATHER THAN A COURTESY. It is the openGrid
// standard snap, reproduced from mitufy's parametric generator
// so that this file can stand alone:
//   https://github.com/mitufy/opengrid-projects  (CC BY 4.0)
// openGrid itself is by David D — https://www.opengrid.world
// (CC BY 4.0). Both licences require that the profile be
// attributed and that modification be stated, so: the profile
// as used here IS MODIFIED, in two ways. The relief groove's
// flat roof is a 45 deg gable, entirely inboard of the face
// plane, so a board cannot tell the difference. And a lip is
// added on the front face, outside the profile, which the
// board sees as a plate resting on its face.
// Keep this block with the file.
//
// PRINT NOTES:
// - PETG, PLA or ASA, no supports needed
// - Print as modeled, tape face down on a smooth plate
// - Worst overhang 45 deg, at the groove gable and the bed
//   chamfer; nub faces 35 deg
// - 4 perimeters, 30% infill or more, for the arms
// ============================================================

// MARK: Dimensions

// Measure the adhesive dot
tape_d = 20; // mm, across the dot

// MARK: Tuning

// Pry lip over the tile face
lip_thickness = 1.2; // mm, how far it stands proud of the tile
lip_overhang = 1; // mm, past the snap on each side
lip_bevel = 0.6; // mm, 45 deg pry gap against the tile
// (Lips in neighbouring cells must leave a gap between them)

// Edges
lip_corner_radius = 1.5; // mm
bed_chamfer = 0.4; // mm, 45 deg round the tape face

// MARK: openGrid Interface

// Reproduced from mitufy's generator, for a 28 mm pitch board
grid_pitch = 28; // Cell centre to cell centre
snap_thickness = 6.8; // Full snap: a regular board's thickness, half a Heavy one's
snap_across_flats = 24.8; // Body width across its flat faces
snap_corner_chamfer = 2.7 * sqrt(2) + 1; // Leg of the 45 deg corner chamfer

ear_height = 1.5; // How tall each corner ear is
ear_reach = 1.1; // How far an ear stands off its chamfer face
ear_tip_height = 0.4; // Height of the ear's full-reach tip, before the 45 deg taper

nub_height = 2; // How tall each face nub is
nub_reach = 0.4; // How far a nub stands off its face
nub_base_width = 10.8; // Nub width where it leaves the face
nub_tip_width = 6.8; // Nub width at full reach, before the tip rounding
nub_tip_radius = 15; // Rounding blending the nub tip into its sides
nub_face_angle = 35; // Nub top and bottom faces, degrees from vertical
nub_offset_to_front = 1.4; // Gap between the nub and the front face

slot_length = 12.4; // Length of the relief slot that frees each arm
slot_width = 0.6; // Radial width of the relief slot
slot_wall = 0.7; // Material left outboard of the slot — this is the arm
slot_offset_to_front = 0.6; // How far the slot stops short of the front face

groove_length = 12.4; // Length of the shallow groove above each slot
groove_depth = 0.8; // How far the groove cuts into the face
groove_height = 0.4; // Height of the groove
groove_offset_to_front = 0.8; // How far the groove sits from the front face
// (The standard, not knobs: change one and the snap stops fitting a board)

/* [Hidden] */

// MARK: Derived

half_flat = snap_across_flats / 2;
octagon_x = half_flat - snap_corner_chamfer; // Where a chamfer meets a flat

// Axis to a chamfer face, where an ear stands
chamfer_face = (half_flat + octagon_x) / sqrt(2);

ear_base_width = snap_corner_chamfer * sqrt(2); // Ear width at the chamfer face
ear_tip_width = ear_base_width - 2 * ear_reach; // 45 deg taper on each side
ear_taper = ear_height - ear_tip_height; // Vertical run of the 45 deg underside

// Nub top and bottom close in as it reaches out, so its tip is shorter
nub_tip_height = nub_height - 2 * nub_reach / tan(nub_face_angle);

// Lateral run of a nub side per unit of reach
nub_side_slope = (nub_base_width - nub_tip_width) / 2 / nub_reach;

// Tip rounding: one arc tangent to both tip face and sloped side
nub_arc_reach = nub_reach - nub_tip_radius;
nub_arc_x = nub_base_width / 2 - nub_side_slope * nub_arc_reach - nub_tip_radius * sqrt(1 + nub_side_slope * nub_side_slope);
nub_arc_sweep = atan2(1, nub_side_slope); // Where the arc leaves the side

nub_bottom = nub_offset_to_front;
nub_centre_z = nub_bottom + nub_height / 2;

// Lip outline: the snap octagon grown by lip_overhang on the flats, and on the
// corners grown past the ears as well, so every ear lands on the lip
lip_flat = half_flat + lip_overhang;
lip_chamfer_face = chamfer_face + ear_reach + lip_overhang;
lip_chamfer_half = sqrt(2) * lip_flat - lip_chamfer_face; // Half a corner face's length

// Clear gap to the same lip in the next cell
neighbour_gap = grid_pitch - 2 * lip_flat;

// Spare radius round the dot on the flat tape face
tape_margin = lip_flat - bed_chamfer - tape_d / 2;

$fa = 1;
$fs = 0.25;
eps = 0.01;

// MARK: Checks

assert(tape_d > 0, "tape_d must be positive");
assert(tape_margin >= 0, "Adhesive dot is wider than the tape face — use a smaller dot");
assert(lip_thickness > 0 && lip_overhang > 0, "Lip needs a positive thickness and overhang");
assert(lip_bevel > 0 && lip_bevel < lip_overhang, "Pry bevel must be positive and stay outside the snap");
assert(bed_chamfer >= 0, "bed_chamfer cannot be negative");
assert(lip_bevel + bed_chamfer < lip_thickness, "Bevel and bed chamfer meet — thicken the lip or shrink them");
assert(neighbour_gap >= 0.5, "Lip overhang would collide with a lip in the next cell");
assert(lip_corner_radius >= 0 && lip_corner_radius * tan(22.5) <= lip_chamfer_half, "lip_corner_radius is larger than the lip's corner faces");

// Ear underside is 45 deg only when its reach and taper agree
assert(ear_taper == ear_reach, "Ear underside is no longer 45 deg — ear_height minus ear_tip_height must equal ear_reach");
assert(nub_face_angle <= 45, "Nub faces are past 45 deg from vertical");

echo(str("Snap body: ", snap_across_flats, " mm across flats, ", snap_thickness, " mm thick"));
echo(str("Lip: ", 2 * lip_flat, " mm across flats, ", lip_thickness, " mm proud of the tile"));
echo(str("Gap to a lip in the next cell: ", neighbour_gap, " mm"));
echo(str("Pry bevel: ", lip_bevel, " mm at 45 deg"));
echo(str("Margin round a ", tape_d, " mm dot: ", tape_margin, " mm"));

// MARK: Geometry

// Modeled in its print orientation: tape face on the plate at z = 0, lip on
// top of it, snap standing on the lip with its back face up

// Octagon with flats at distance f and corner faces at distance c
module octagon(f, c) {
  v = sqrt(2) * c - f;
  polygon([
    [f, v],
    [v, f],
    [-v, f],
    [-f, v],
    [-f, -v],
    [-v, -f],
    [v, -f],
    [f, -v],
  ]);
}

// Lip outline with rounded corners, shrunk by inset for the chamfers
module lip_outline(inset) {
  offset(delta = -inset)
    offset(r = lip_corner_radius)
      offset(delta = -lip_corner_radius)
        octagon(lip_flat, lip_chamfer_face);
}

// Hull runs from the thin slabs' outer faces, so each slope rises exactly its
// own run and both edges stay 45 deg
module lip() {
  hull() {
    linear_extrude(height = eps)
      lip_outline(bed_chamfer);
    translate([0, 0, bed_chamfer])
      linear_extrude(height = lip_thickness - lip_bevel - bed_chamfer)
        lip_outline(0);
    translate([0, 0, lip_thickness - eps])
      linear_extrude(height = eps)
        lip_outline(lip_bevel);
  }
}

// Snap body, sunk eps below its front face into the lip so the two share no plane
module body() {
  translate([0, 0, -eps])
    linear_extrude(height = snap_thickness + eps)
      octagon(half_flat, chamfer_face);
}

// One corner ear off the +y chamfer face, tip on the lip, tapering away upward
module corner_ear() {
  hull() {
    translate([-ear_base_width / 2, chamfer_face - eps, -eps])
      cube([ear_base_width, eps, ear_height + eps]);
    translate([-ear_tip_width / 2, chamfer_face + ear_reach - eps, -eps])
      cube([ear_tip_width, eps, ear_tip_height + eps]);
  }
}

// Half a nub's plan outline on the +y face, buried root round to mid tip
function nub_half_outline() =
  concat([
    [nub_base_width / 2, half_flat - eps]
  ], [
    for (i = [0:16])
      let (a = nub_arc_sweep * (1 - i / 16))
        [nub_arc_x + nub_tip_radius * sin(a), half_flat + nub_arc_reach + nub_tip_radius * cos(a)]
  ]);

// Plan outline crossed with a wedge closing top and bottom at nub_face_angle,
// so tip rounding and face angle stay independent
module nub() {
  intersection() {
    translate([0, 0, -eps])
      linear_extrude(height = snap_thickness + 2 * eps)
        polygon(concat(nub_half_outline(), [
          for (i = [len(nub_half_outline()) - 1:-1:0])
            [-nub_half_outline()[i][0], nub_half_outline()[i][1]]
        ]));
    hull() {
      translate([-snap_across_flats, half_flat - 0.5, nub_centre_z - nub_height / 2])
        cube([2 * snap_across_flats, 0.5, nub_height]);
      translate([-snap_across_flats, half_flat + nub_reach - eps, nub_centre_z - nub_tip_height / 2])
        cube([2 * snap_across_flats, eps, nub_tip_height]);
    }
  }
}

// Slot freeing one arm, open out of the back face, so no roof to bridge
module relief_slot() {
  translate([0, half_flat - slot_wall - slot_width / 2, slot_offset_to_front])
    hull() {
      for(s = [-1, 1])
        translate([s * (slot_length - slot_width) / 2, 0, 0])
          cylinder(d = slot_width, h = snap_thickness, $fn = 32);
    }
}

// Relief groove with a 45 deg gable for a roof; mouth stays the standard.
// Outboard point rides the same 45 deg line, hence the eps drop
module face_groove() {
  groove_top = groove_offset_to_front + groove_height;
  groove_peak = groove_depth / 2;
  rotate([0, 0, 90])
    rotate([90, 0, 0])
      linear_extrude(height = groove_length, center = true)
        polygon([
          [half_flat + eps, groove_offset_to_front],
          [half_flat - groove_depth, groove_offset_to_front],
          [half_flat - groove_depth, groove_top],
          [half_flat - groove_peak, groove_top + groove_peak],
          [half_flat + eps, groove_top - eps],
        ]);
}

module snap() {
  difference() {
    union() {
      body();
      for(a = [45:90:315])
        rotate([0, 0, a])
          corner_ear();
      for(a = [0:90:270])
        rotate([0, 0, a])
          nub();
    }
    for(a = [0:90:270])
      rotate([0, 0, a]) {
        relief_slot();
        face_groove();
      }
  }
}

module adhesive_snap() {
  lip();
  translate([0, 0, lip_thickness])
    snap();
}

adhesive_snap();
