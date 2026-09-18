// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// ============================================================
// Zip tie corner block sleeve — a TPU liner that goes between
// one leg of a corner block and the flat it bears on
//
// The block is rigid, and everything it presses against is a
// painted, powder-coated or anodized flat. This sleeve is the
// soft layer in between: it grips, it spreads the tie's load
// over a surface that is never quite flat, and it is the part
// that takes the scuffing instead of the finish underneath.
//
// It is a shallow tray. The floor is the pad, and it is the
// whole working surface — it lies on the block's inner face
// and bears on the object. Three lips stand off it, and they
// cover the three faces next to that one: the block's top, its
// bottom, and the end face at the tip of the leg. The fourth
// edge is not a face at all. It is where the corner relief
// cuts the block away and the other leg's sleeve sits, so
// there is nothing there to wrap.
//
// The lips are not the fastening. Glue is. What they do is
// hold the sleeve still while the glue is wet, and each pair
// does it in a different direction: the side lips square the
// sleeve up across the face, and the end lip is a stop that
// locates it along the leg. Pushed on until it meets the leg
// tip, the sleeve is placed in every direction at once, with
// nothing to line up by eye. TPU is printed a shade narrow
// across the channel and snaps onto the block, and the glue
// cures with everything already where it belongs.
//
// The end lip has to stay clear of the mouth of the block's
// channel, which opens in that same end face. It is asserted
// below, and it is the constraint that decides how far any of
// the lips can reach.
//
// ONE LEG, ONE SLEEVE. A block has two inner faces, so it
// takes two of these, and a set of four blocks takes eight.
// They are all the same part, and it is symmetric top to
// bottom, so there is no handedness and no right way up. There
// is a right way round: the end lip goes to the tip of the
// leg, and the open end to the corner.
//
// The sleeve stands the block off the flats by its own pad
// thickness, which lifts the tie the same amount. Nothing in
// the block minds, and the corner relief only gains clearance,
// but the echoed standoff below is the one the assembled joint
// actually has.
//
// THE PARAMETERS UP TO THE SECOND BLOCK BELOW ARE COPIES.
// They have to hold the same values as the block's, or the
// tray will not fit the block it was cut for. Change one and
// change it in both files.
//
// Modeled in its print orientation: pad flat on the plate,
// lips pointing up.
//
// PRINT NOTES:
// - TPU, no supports needed. Print as modeled, pad down.
// - Nothing in the part hangs, at all. Every face is vertical,
//   on the plate, or facing up — including the two lead-in
//   bevels at the side lips, which taper the tips at 45 deg
//   and so point upward rather than down.
// - Only the side lips are tapered. They are the pair that has
//   to snap over the block; the end lip is slid up to rather
//   than pushed over, so it stays square.
// - Pad down puts the plate's finish on the face that bears on
//   the object and leaves the printed top surface as the glue
//   face, which is the way round that suits both.
// - The block's foot chamfer leaves a groove along one edge
//   between the pad and the block. That is a glue reservoir,
//   not a gap to close.
// - 3 perimeters. At this size the lips are perimeters the
//   whole way through, which is what makes them springy rather
//   than crumbly.
// - Cyanoacrylate or contact cement. TPU takes both; the rigid
//   filament under it is what decides.
// - This source emits ONE sleeve. Print eight for a set of
//   four blocks.
// ============================================================

// ===== MEASURE THESE ON YOUR ACTUAL ZIP TIE =====
// The same two measurements the block is built from, and they set the height
// of the channel here. Each names the caliper it needs by the size printed on
// the tool: a 6 in caliper stops at 150 mm, an 8 in at 200 mm, a 12 in at
// 300 mm

// Width of the tie's strap (mm) — outside jaws across the flat of the strap,
// 6 in caliper. Measure the plain strap well away from the head
tie_width = 3.5;

// Thickness of the tie's strap (mm) — outside jaws on the edge of the strap,
// over the ratchet teeth rather than between them, 6 in caliper
tie_thickness = 1.3;

// ===== THESE MUST MATCH THE BLOCK =====
// Copies of the block's knobs, carried here because the sleeve has to come out
// the same size as the block it wraps. Nothing below is a free choice: read
// each one off the block's source and keep the two files in step

tie_clearance = 0.6; // The block's channel clearance — feeds the block height
deck = 1.6; // The block's top and bottom skins — feeds the block height
leg_length = 10; // How far the block reaches along each flat
corner_relief_d = 4; // The block's corner relief — where its inner face starts
bend_radius = 10; // The block's bend radius — feeds the leg thickness
corner_web = 2.5; // The block's corner web — feeds the leg thickness
outer_wall = 2.4; // The block's outer flange — feeds the leg thickness
foot_chamfer = 0.6; // The block's foot chamfer — the groove it leaves is the glue reservoir

// ===== DECIDE THESE =====
// The sleeve's own shape

// Thickness of the pad (mm). All of the cushion and all of the grip is this
// number, and it is also how far the block is stood off the flat. It has to
// stay under the corner relief radius or the two sleeves on one block meet at
// the corner
pad_thickness = 1.6;

// How far every lip folds over the face behind it (mm). Enough to hold the
// sleeve square and stop it while the glue goes off; it does not have to reach
// far, and the end lip is the one that runs out of room first, since the
// block's channel opens in the face it lies on
lip_reach = 3;

// Thickness of each lip (mm). Thin enough for the side pair to spring over the
// block, thick enough not to tear off it
lip_thickness = 1.2;

// ===== TUNE THESE =====
block_pinch = 0.2; // SUBTRACTED from the block height (mm) — the channel is printed narrow and stretched on, so it holds itself in place before it is glued
lip_lead_in = 0.6; // Taper at the mouth of each side lip (mm) — how far out of square the sleeve can start and still snap on

// ===== DERIVED =====
slot_w = tie_thickness + tie_clearance;
slot_h = tie_width + tie_clearance;
gable = slot_w;
relief_r = corner_relief_d / 2;

// The block's height, rebuilt from the same numbers the block builds it from.
// This is the dimension the channel has to match, so check it against the
// block's own echo
block_h = 2 * deck + slot_h + gable;

// The block's leg thickness, and how far its channel stands off the inner
// face, both rebuilt the same way. The side lips fold over a face that is
// leg_thickness deep; the end lip folds over one that is only clear as far as
// face_offset, because the channel's mouth is what comes next
tie_offset = ((sqrt(2) - 1) * bend_radius + slot_w / 2 + relief_r + corner_web) / sqrt(2);
face_offset = tie_offset - slot_w / 2;
leg_thickness = face_offset + slot_w + outer_wall;

// Length of the block's inner face, from where the corner relief lets go of it
// to the end of the leg. The pad covers all of it and no more
sleeve_length = leg_length - relief_r;

// Clear width of the channel. Narrower than the block by the pinch, which is
// what the side lips have to stretch over
gap = block_h - block_pinch;

// Outside of the tray. Each dimension is the block's own plus the lips that
// stand outside it — one lip at the end, two across
sleeve_width = gap + 2 * lip_thickness;
sleeve_overall = sleeve_length + lip_thickness;
sleeve_height = pad_thickness + lip_reach;

// Where the tie ends up once the sleeves are on: the block's own standoff plus
// the pad under it. This is the height the tie rides above each flat on the
// runs between blocks
sleeved_face_offset = face_offset + pad_thickness;

// What is left of the block's top and bottom faces outside the side lips. They
// fold over the face, not around the back of it
lip_clearance = leg_thickness - lip_reach;

// What is left of the end face between the end lip and the mouth of the
// block's channel. The tie comes out there, so this is the one that has to
// stay positive
mouth_clearance = face_offset - lip_reach;

// Just clear of a face, for a cut that has to overshoot one rather than land on
// it
eps = 0.01;

echo(str("sleeve = ", sleeve_width, " x ", sleeve_overall, " x ", sleeve_height, " mm"));
echo(str("channel = ", gap, " mm clear, onto a ", block_h, " mm block"));
echo(str("pad covers ", sleeve_length, " mm of face, ", pad_thickness, " mm thick"));
echo(str("side lips fold ", lip_reach, " mm over a ", leg_thickness, " mm leg, leaving ", lip_clearance, " mm"));
echo(str("end lip stops ", mouth_clearance, " mm short of the channel mouth"));
echo(str("glue groove along the chamfered edge = ", foot_chamfer, " mm"));
echo(str("tie stands off each flat by = ", sleeved_face_offset, " mm once sleeved"));
echo("print eight for a set of four blocks");

assert(pad_thickness > 0, "pad_thickness has to be positive — the pad is the whole point of the sleeve");
assert(pad_thickness < relief_r, "the two sleeves on one block would meet at the corner — thin the pad, or open corner_relief_d in both files");
assert(lip_thickness > 0, "lip_thickness has to be positive");
assert(lip_reach > 0, "lip_reach has to be positive — without the lips this is a shim, and it will not stay put");
assert(mouth_clearance > 0, "the end lip has reached the mouth of the block's channel and would cap the tie's exit — reduce lip_reach, or raise bend_radius in both files to stand the channel further off the flats");
assert(gap > 0, "block_pinch has closed the channel — it cannot be more negative than the block is tall");
assert(block_pinch >= 0, "a negative block_pinch is slack, and slack is what the side lips are there to remove — leave it at 0 for a slip fit");
assert(sleeve_length > 0, "the corner relief has eaten the whole inner face — lengthen leg_length or reduce corner_relief_d, in both files");
assert(lip_lead_in < lip_thickness, "the lead-in has tapered the side lips to nothing — reduce lip_lead_in");
assert(lip_lead_in < lip_reach, "the lead-in is deeper than the lips are long — reduce lip_lead_in");

// The channel, as a cross section: x is across the block's height, y is up out
// of the plate. It is the air above the pad and between the lips, with the
// lead-in taken off the mouth: that taper moves out and up by the same amount,
// so it is 45 deg whatever lip_lead_in is set to. The eps rides the same 45 deg
// line rather than stepping out square from the wall, because a square step
// would leave the lead-in the one face in the part past 45
//
// Only the mouth is tapered. The end lip is slid up to rather than pushed over,
// so it stays square, and a taper there would only shorten the stop
module channel_2d() {
  polygon([
    [-gap / 2, pad_thickness],
    [gap / 2, pad_thickness],
    [gap / 2, sleeve_height - lip_lead_in],
    [gap / 2 + lip_lead_in + eps, sleeve_height + eps],
    [-gap / 2 - lip_lead_in - eps, sleeve_height + eps],
    [-gap / 2, sleeve_height - lip_lead_in],
  ]);
}

// The channel run from clear of the open end to sleeve_length, so its far face
// is the end lip's inner face and its near face is out in the air rather than
// on the sleeve's own end
module channel() {
  translate([0, sleeve_length, 0])
    rotate([90, 0, 0])
      linear_extrude(sleeve_length + eps)
        channel_2d();
}

// The sleeve is the block with the channel cut out of it, rather than a pad
// unioned with three lips.
//
// That difference is not a matter of taste — it is what keeps the exported mesh
// watertight. A pad and a lip that share the plane x = sleeve_width / 2 present
// two coincident faces there, and the boolean that merges them leaves zero-area
// facets along the seam: the export comes out with a third of its facets
// carrying no area and its edges unmatched, which scripts/overhangs.py reports
// as not closed. Every face this cut makes is either inside the block or past
// it, so nothing is coplanar with anything, and the mesh comes out clean.
//
// The block is the tray's own silhouette. The pad already runs the full width
// and the lips are the outer edges of it, so the outline is a plain box and all
// of the tray is carved out of it. The end lip is what the cut leaves standing
// where it stops
module zip_tie_corner_block_sleeve() {
  difference() {
    translate([-sleeve_width / 2, 0, 0])
      cube([sleeve_width, sleeve_overall, sleeve_height]);

    channel();
  }
}

zip_tie_corner_block_sleeve();
