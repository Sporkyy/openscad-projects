// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// SPDX-FileCopyrightText: openGrid snap profile — David D, CC BY 4.0,
// via mitufy/opengrid-projects, CC BY 4.0. See the header below.
// ============================================================
// openGrid magnet snap, front face — a full-thickness snap
// carrying a disc magnet in a blind bore.
//
// THIS IS THE VARIANT WHOSE MAGNET IS ON THE FRONT FACE: the
// wide end carrying the corner ears, which stays on the side
// you pushed the snap in from and faces you. Its sibling
// opengrid_magnet_snap_back.scad puts the magnet on the narrow
// end instead, where it comes to rest against whatever the tile
// is mounted on.
//
// Use this one when the magnet has to present outward — to
// catch something steel laid onto the tile — rather than to
// hold the tile up. To stick a tile to steel, use the back one.
//
// FRONT AND BACK, ON A SNAP, MEAN THE WIDE END AND THE NARROW
// END. Every feature a full snap has sits in its first 3.4 mm:
// the corner ears at the face itself, the nubs just behind
// them. The remaining 3.4 mm is plain shank. The shank is what
// goes into the tile, so the wide end stays on the side you
// pushed from and faces you — the front — while the narrow end
// runs away from you toward whatever the tile is mounted on —
// the back. Measured on the mesh, the front reaches 15.4 mm
// from the axis at the ears and the shank only 14.53 mm.
//
// A Heavy tile is 13.6 mm, twice a regular one, and is built to
// take a full 6.8 mm snap in each face. That is why it has two
// fronts and no back: both snaps present their ears outward and
// their shanks meet in the middle. Cells fitted from one side
// only are still half empty from the other.
//
// openGrid snaps normally present a connector on their front
// face: threads, an openConnect head, a zip tie bail. This one
// presents a magnet instead. Drop it into any cell of a regular
// 6.8 mm board, or either face of a 13.6 mm Heavy one, and that
// cell becomes a magnetic pad, so the board can hang off any
// steel surface with no fastener and no adhesive.
//
// It exists to hang an openGrid tile under the top plate of a
// steel speaker stand, where the tile carries an Underware
// cable channel. The cells that are not doing cable duty become
// magnets, and the tile holds itself up.
//
// THIS VARIANT'S BORE AND SLOTS WANT OPPOSITE ENDS UP. The bore
// has to open upward, because a 10.2 mm circular ceiling is not
// something to bridge, and here the bore is on the front face.
// So the front face goes up and the back face goes on the
// plate, which is the reverse of the back variant. That inverts
// the relief slots: instead of opening out of the back face
// they now run up from the plate and stop 0.6 mm short of the
// front face, leaving their closed ends as flat roofs.
//
// THOSE FOUR ROOFS ARE LEFT FLAT ON PURPOSE. Each spans the
// slot's 0.6 mm width, not its 12.4 mm length — a gap no
// support material could be placed in and no printer struggles
// to cross. Every way of angling them is taken out of the
// 0.6 mm of material above the slot, and that material is the
// root the arm hinges on. A 45 deg gable halves the root to
// 0.3 mm, under a single 0.42 mm perimeter. A ramp across the
// slot consumes it outright and opens a slit to the front face.
// The snap fit lives in that hinge and a 0.6 mm bridge does
// not, so the hinge wins. scripts/overhangs.py reports these on
// every build, and the report is correct — they are a decision,
// not an oversight.
//
// If either variant would do the job, print the back one. It
// has no flat roof anywhere.
//
// An optional hole runs from the floor of the bore out through
// the back face. It vents the bore, so cyanoacrylate cannot
// hydraulic-lock against the magnet and push it back out while
// it cures; it pushes a magnet out again if one has to come
// apart; and it passes a fastener, so the magnet can be a
// bolted pot magnet rather than a plain disc. Set through_hole
// false when the magnet is going on with an adhesive dot, which
// needs no vent and leaves a tidier face.
//
// Polarity does not matter. These stick to steel, not to each
// other, so a snap fitted the other way round holds exactly as
// well.
//
// THE SNAP PROFILE IS NOT ORIGINAL WORK, AND THIS NOTICE IS A
// LICENCE CONDITION RATHER THAN A COURTESY. It is the openGrid
// standard snap, reproduced here from mitufy's parametric
// generator so that this file can stand alone:
//   https://github.com/mitufy/opengrid-projects  (CC BY 4.0)
// openGrid itself is by David D — https://www.opengrid.world
// (CC BY 4.0). Both licences require that the profile be
// attributed and that modification be stated, so: the profile
// as used here IS MODIFIED, in the one way described below.
// Keep this block with the file.
// The dimensions in the openGrid interface block below are that
// standard. They are not tuning knobs and changing one makes a
// snap that does not fit a board.
//
// ONE THING HERE DEPARTS FROM THE STANDARD, AND IT IS HIDDEN.
// The official snap's relief groove has a flat roof, which is a
// 90 deg ceiling whichever way up the snap is printed. Here that
// roof is a gable instead. The change is entirely inboard of the
// face plane — the groove's mouth is still the standard 0.4 mm
// tall by 0.8 mm deep, so a board cannot tell the difference —
// and it takes about 2 cubic mm out of each arm root, in a
// pocket that exists to be empty.
//
// PRINT NOTES:
// - PETG, PLA or ASA, no supports needed.
// - Print as modeled, back face down and bore facing up. Do not
//   let the slicer turn it over: that puts a 10.2 mm ceiling
//   over the magnet bore, which is a real bridge rather than
//   the 0.6 mm ones this orientation accepts.
// - Worst overhang is 90 deg at the four slot roofs, by choice,
//   over a 0.6 mm span. Behind those it is 45 deg at the groove
//   gable and 35 deg at the nub faces. Still no supports —
//   turning them on would only scar the faces.
// - 4 perimeters, 30% infill or more. The four arms are what
//   the snap fit lives in and they are thin.
// - The whole back face lands on the plate, so first layer
//   adhesion is easier here than on the back variant, where
//   only the four ears touch.
// - Drop the magnet in after printing, bore side up. With the
//   through hole on, wick a little thin CA down it from the ear
//   side rather than puddling glue in the bore. With it off,
//   use an adhesive dot: a blind bore has nowhere to vent, and
//   a slug of CA under a disc will lift it back out.
// - Fit the snap to the board from the working-face side, the
//   same way any openGrid snap goes in. The ears pass the cell
//   and spring out behind it.
// ============================================================

// MARK: Dimensions

// Measure the magnets you have
magnet_d = 10; // mm
magnet_h = 3; // mm

// MARK: Tuning

magnet_fit = 0.2; // mm, on the diameter for a slip fit
magnet_recess = 0; // mm, below the face; negative stands it proud
// (Never press-fit a plated magnet: chipped plating breaks the bond)

// Hole from the bore out the back face
through_hole = true;
through_hole_d = 3; // mm, clears an M3
// (Vents glue and pushes a magnet out; turn off for an adhesive dot)

// MARK: openGrid Interface

// Reproduced from mitufy's generator, for a 28 mm pitch board
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

// MARK: Derived

half_flat = snap_across_flats / 2;
octagon_x = half_flat - snap_corner_chamfer; // Where a chamfer meets a flat

// Distance from the axis out to a chamfer face, which is where an ear stands
chamfer_face = (half_flat + octagon_x) / sqrt(2);

ear_base_width = snap_corner_chamfer * sqrt(2); // Ear width at the chamfer face
ear_tip_width = ear_base_width - 2 * ear_reach; // 45 deg taper on each side
ear_taper = ear_height - ear_tip_height; // Vertical run of the 45 deg underside

// A nub's top and bottom close in as it reaches out, so its tip is shorter
// than its base
nub_tip_height = nub_height - 2 * nub_reach / tan(nub_face_angle);

// How fast a nub's sides close in, as lateral run per unit of reach
nub_side_slope = (nub_base_width - nub_tip_width) / 2 / nub_reach;

// The tip rounding is one arc tangent to both the tip face and the sloped
// side. Tangency to the tip face puts its centre a full radius back; tangency
// to the side then fixes the centre laterally, so the arc cannot float free
// of either face whatever radius is asked for
nub_arc_reach = nub_reach - nub_tip_radius;
nub_arc_x = nub_base_width / 2 - nub_side_slope * nub_arc_reach - nub_tip_radius * sqrt(1 + nub_side_slope * nub_side_slope);
nub_arc_sweep = atan2(1, nub_side_slope); // Where the arc leaves the side

// The front face is the datum every openGrid feature is measured from, and on
// this variant it is the top face rather than the one on the plate, so all of
// those offsets run downward from it
front_face = snap_thickness;
nub_top = front_face - nub_offset_to_front;
nub_centre_z = nub_top - nub_height / 2;

slot_roof = front_face - slot_offset_to_front; // Closed end of the relief slot
groove_bottom = front_face - groove_offset_to_front - groove_height;
groove_top = front_face - groove_offset_to_front;

bore_d = magnet_d + magnet_fit;
bore_depth = magnet_h + magnet_recess;
bore_floor = snap_thickness - bore_depth; // Material left under the magnet

$fa = 1;
$fs = 0.25;
eps = 0.01;

// MARK: Checks

assert(bore_floor >= 1.2, "Magnet bore leaves too little floor — use a thinner magnet");
assert(bore_d / 2 < half_flat - slot_wall - slot_width, "Magnet bore breaks into the relief slots — use a smaller magnet");
assert(!through_hole || through_hole_d < bore_d, "Through hole is wider than the magnet bore");

// magnet_recess going negative stands the magnet proud, which is a legitimate
// thing to want, but the bore still has to hold it. Half the disc buried is
// the point where the pocket stops being a pocket
assert(bore_depth >= magnet_h / 2, "Magnet stands more than half proud — the bore cannot hold it");

// The ear underside runs ear_reach outward while rising ear_taper, so it is
// 45 deg exactly when the two agree. Assert it rather than trusting the two
// knobs to stay in step, since an ear that tapers slower than this hangs
assert(ear_taper == ear_reach, "Ear underside is no longer 45 deg — ear_height minus ear_tip_height must equal ear_reach");
assert(nub_face_angle <= 45, "Nub faces are past 45 deg from vertical");

echo(str("Body: ", snap_across_flats, " mm across flats, ", snap_thickness, " mm thick"));
echo(str("Ear reach past the chamfer face at radius ", chamfer_face, ": ", ear_reach, " mm"));
echo(str("Nub tip: ", nub_tip_height, " mm tall at ", nub_reach, " mm reach"));
echo(str("Magnet bore: ", bore_d, " mm dia x ", bore_depth, " mm deep"));
echo(str("Floor under the magnet: ", bore_floor, " mm"));
echo(str("Through hole: ", through_hole ? str(through_hole_d, " mm dia") : "none, magnet goes on with adhesive"));

// MARK: Geometry

// Modeled in its print orientation: back face on the plate at z = 0, front face
// and its magnet bore facing up

module body() {
  linear_extrude(height = snap_thickness)
    polygon([
      [half_flat, octagon_x],
      [octagon_x, half_flat],
      [-octagon_x, half_flat],
      [-half_flat, octagon_x],
      [-half_flat, -octagon_x],
      [-octagon_x, -half_flat],
      [octagon_x, -half_flat],
      [half_flat, -octagon_x],
    ]);
}

// One corner ear, standing off the +y chamfer face. Here the ears are at the
// top, so unlike on the back variant their undersides are what hang: each
// reaches ear_reach outward while rising ear_taper, and the assertion above
// holds those two equal, so the underside is 45 deg and no ear dimension can
// tip it past
module corner_ear() {
  hull() {
    translate([-ear_base_width / 2, chamfer_face - eps, front_face - ear_height])
      cube([ear_base_width, eps, ear_height]);
    translate([-ear_tip_width / 2, chamfer_face + ear_reach - eps, front_face - ear_tip_height])
      cube([ear_tip_width, eps, ear_tip_height]);
  }
}

// Half the plan outline of a nub on the +y face, from the buried root round to
// the middle of the tip. Points are [x, y] with y absolute
function nub_half_outline() =
  concat([
    [nub_base_width / 2, half_flat - eps]
  ], [
    for (i = [0:16])
      let (a = nub_arc_sweep * (1 - i / 16))
        [nub_arc_x + nub_tip_radius * sin(a), half_flat + nub_arc_reach + nub_tip_radius * cos(a)]
  ]);

// The nub is the plan outline crossed with a wedge that closes the nub's top
// and bottom in at nub_face_angle as it reaches out. Building it as an
// intersection keeps the two independent: the outline owns the tip rounding,
// the wedge owns the face angle, and neither can distort the other
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

// The slot that frees one arm to flex. It opens out of the back face on the
// plate and stops slot_offset_to_front short of the front face, so its closed end
// is a roof. That roof is deliberately left flat — see the note at the top of
// the file. It spans slot_width, and the alternative comes out of the hinge
module relief_slot() {
  translate([0, half_flat - slot_wall - slot_width / 2, -eps])
    hull() {
      for(s = [-1, 1])
        translate([s * (slot_length - slot_width) / 2, 0, 0])
          cylinder(d = slot_width, h = slot_roof + eps, $fn = 32);
    }
}

// The relief groove above each slot. Its roof is a gable rather than a flat
// bridge, the same trick the shelf tube anchor's tie channel uses: each slope
// runs half the groove's depth outward while rising the same half, so it is
// 45 deg whatever groove_depth is set to, and no value can turn it back into a
// ceiling. The mouth is untouched — the gable only lifts the hidden interior —
// so the face profile the board sees is still the openGrid standard.
//
// The outboard point rides the same 45 deg line rather than sitting square out
// from the face, which is why it drops by eps as well as stepping out by it.
// Extending it horizontally instead would leave that one facet at 45.7 deg:
// the eps is there to clear the face for a clean cut, and it has no business
// changing the angle it clears it at
module face_groove() {
  groove_peak = groove_depth / 2;
  rotate([0, 0, 90])
    rotate([90, 0, 0])
      linear_extrude(height = groove_length, center = true)
        polygon([
          [half_flat + eps, groove_bottom],
          [half_flat - groove_depth, groove_bottom],
          [half_flat - groove_depth, groove_top],
          [half_flat - groove_peak, groove_top + groove_peak],
          [half_flat + eps, groove_top - eps],
        ]);
}

module magnet_snap() {
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
    translate([0, 0, bore_floor])
      cylinder(d = bore_d, h = bore_depth + eps);
    if (through_hole)
      translate([0, 0, -eps])
        cylinder(d = through_hole_d, h = snap_thickness + 2 * eps);
  }
}

magnet_snap();
