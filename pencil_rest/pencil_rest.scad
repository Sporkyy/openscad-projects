// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// ============================================================
// Pencil rest — a block with a cradle down its top, to park a
// pencil on the desk instead of letting it roll off
//
// A rectangular block with every edge chamfered and one
// cylindrical trough running the length of its top face. The
// pencil lies in the trough. Length is how much of the pencil
// is carried, width is how much desk the block stands on, and
// both are free choices.
//
// THE CRADLE IS NOT A CHOICE. Its radius is the pencil plus a
// clearance, it is cut to exactly half a cylinder, and the
// block is then made as tall as that cut plus the floor left
// under it. Height falls out of the cradle rather than the
// cradle being fitted into a height, which is what makes it
// impossible for the trough to reach the bottom: floor_meat is
// what is left under the deepest point, always, whatever
// pencil the block is cut for and however wide or long it is
// made.
//
// Cutting exactly half the cylinder is the other thing that is
// fixed by construction. The depth of the cut and the radius
// of the cut are one expression, so the trough walls arrive at
// the top face vertical. A deeper cut would undercut the
// pencil — it could not be dropped in, only threaded in from
// the end, and the roof of the undercut would be an overhang.
// Half is the deepest a cradle can be and still open upward,
// and it also leaves the pencil standing half proud, which is
// what makes it easy to pick up.
//
// The trough runs out through both ends. A blind dish would
// need end walls, and end walls in a scoop this shallow are
// the one place a support would be wanted.
//
// A notch across the middle is what makes the pencil possible
// to pick up. It runs clear out through both sides, so a
// finger and thumb come in from the sides and close on the
// pencil's whole diameter rather than reaching down a hole
// after it. Neither of its limits is a number to get right:
//
// - It cannot go deeper than the trough. Its floor is written
//   as the trough's own deepest point, not as a depth of its
//   own, so the two are one plane and the notch can never be
//   the feature that breaks the bottom.
// - It cannot reach the base. What is left under it is
//   floor_meat — the same floor the trough stands on, and,
//   with the notch open at both sides, also the whole tie
//   between the two halves of the block.
//
// That floor lands exactly level with the underside of the
// pencil, which is not a coincidence to be tuned: a round
// pencil beds at the bottom of a round trough, so its lowest
// point and the trough's are the same point whatever the
// clearance. A finger comes in beside the pencil, level with
// its underside, and closes on all of it.
//
// The notch takes nothing off the bottom face. The block
// stands on the footprint it always did and holds the desk the
// same way; what the notch costs is trough. The cradle carries
// the pencil either side of it rather than along the whole
// length, which is why notch_l is asserted against leaving
// less trough at each end than the pencil is thick.
//
// PRINT NOTES:
// - PLA or PETG, no supports needed. Print as modeled, base
//   down.
// - Nothing bridges. The cradle opens upward, so its whole
//   surface faces up, and so does the notch: flat floor,
//   walls straight up off it, open sky out both sides, and a
//   break at the mouth that flares outward as it rises, so
//   even that faces up. The only downward faces in the part
//   are the chamfers along the base, at 45 deg.
// - Every chamfer here has its run and its rise in the same
//   expression, so no value of any knob can turn one into an
//   overhang.
// - Print it solid, or near it. It is a small block and the
//   only thing it has to do is stay put, which is a question
//   of mass and of the friction of the bottom face. The floor
//   under the notch is the one place the block would break if
//   it were picked up by an end and swung, and solid infill is
//   what makes that a non-question.
// - The bottom face is the one that shows least and the top
//   face is the one a pencil rolls on, so this way up also
//   puts the plate's finish where it does no harm.
// ============================================================

// MARK: Dimensions

// Measure the pencil across its corners
pencil_d = 10; // mm

// Size the block
block_l = 100; // mm, along the pencil
block_w = 30; // mm, across the pencil

// MARK: Tuning

pencil_clearance = 0.5; // mm, on the cradle radius
floor_meat = 5; // mm, under the deepest point of the cradle
chamfer = 1; // mm, on every block edge
cradle_ease = 0.6; // mm, along both cradle rims
notch_l = 24; // mm, finger notch opening along the block
notch_ease = 0.6; // mm, along the notch walls at the top face

$fn = 120;

// MARK: Derived

// The cradle. Radius from the pencil, depth from the radius: one expression
// for both, so the cut is half a cylinder whatever the pencil measures and the
// walls always reach the top face vertical
cradle_r = pencil_d / 2 + pencil_clearance;
cradle_depth = cradle_r;

// Height of the block. It is the cut plus the floor, in that order — the
// cradle is not fitted into a height, the height is made to hold the cradle
block_h = cradle_depth + floor_meat;

// Width of the cradle's mouth in the top face, before the rims are broken. Cut
// to half a cylinder, so it is exactly the cradle's diameter
mouth_w = 2 * cradle_r;

// Flat left of the top face either side of the cradle, once the outer chamfer
// has taken from one edge and the cradle's own ease from the other
rim = (block_w - mouth_w) / 2 - chamfer - cradle_ease;

// How far the pencil stands above the top face, resting on the arc. Half of it
// less whatever the clearance lets it settle, and it is what there is to pinch
// hold of from above
pencil_proud = pencil_d / 2 - pencil_clearance;

// Where the cradle's ease meets the arc. Held on the circle rather than guessed
// at, so the chamfer runs into the trough wall instead of leaving a step in it
ease_foot = sqrt(cradle_r * cradle_r - cradle_ease * cradle_ease);

// The notch. Its floor is the trough's deepest point written out again rather
// than a depth of its own, so the two are the same plane and no arithmetic
// stands between the notch and the floor it must not break
notch_floor = block_h - cradle_depth;
notch_depth = block_h - notch_floor;

// What the notch opens in the top face, once its own ease has been taken off
// both walls
notch_mouth = notch_l + 2 * notch_ease;

// Trough left at each end of the block, outside the notch and inside the end
// chamfer. With the middle open, this is what carries the pencil
cradle_run = (block_l - notch_mouth) / 2 - chamfer;

// How much of the pencil's side a finger can close on at the notch. The floor
// of the notch is level with the underside of the pencil and the cut runs out
// through both sides, so it is all of it, from either hand
notch_grip = pencil_d;

overshoot = 1; // Run past both ends, so the trough cuts through cleanly

// MARK: Checks

echo(str("block = ", block_w, " x ", block_l, " x ", block_h, " mm"));
echo(str("cradle = ", mouth_w, " mm across, ", cradle_depth, " mm deep"));
echo(str("floor under the cradle = ", floor_meat, " mm"));
echo(str("flat rim either side = ", rim, " mm"));
echo(str("pencil stands proud of the top face by = ", pencil_proud, " mm"));
echo(str("notch = ", notch_l, " mm along the block, ", notch_mouth, " mm at the mouth, ", notch_depth, " mm deep, open out both sides"));
echo(str("notch floor is level with the trough, on the same ", floor_meat, " mm of floor"));
echo(str("trough left carrying the pencil = ", cradle_run, " mm at each end"));
echo(str("pencil exposed at the notch = ", notch_grip, " mm, its full diameter, from either side"));

assert(pencil_d > 0, "pencil_d has to be positive");
assert(cradle_r > 0, "pencil_clearance has closed the cradle — it cannot be more negative than the pencil is thick");
assert(floor_meat > 0, "floor_meat has to be positive — it is the whole floor under the cradle, and the only tie between the two halves of the block once the notch is cut");
assert(rim > 0, "the cradle has eaten the top face — widen block_w, or reduce chamfer or cradle_ease");
assert(pencil_proud > 0, "the clearance has sunk the pencil below the top face — reduce pencil_clearance");
assert(cradle_ease < cradle_r, "the cradle's ease is wider than the cradle — reduce cradle_ease");
assert(notch_l > 0, "notch_l has to be positive — it is the whole finger opening");
assert(cradle_run >= pencil_d, "the notch has left less trough at each end than the pencil is thick, which is a lip rather than a cradle — shorten notch_l, or lengthen block_l");
assert(notch_ease < notch_depth, "the notch's ease is deeper than the notch — reduce notch_ease");
assert(2 * chamfer < block_w, "the width chamfers have met — reduce chamfer or widen block_w");
assert(2 * chamfer < block_l, "the length chamfers have met — reduce chamfer or lengthen block_l");
assert(2 * chamfer < block_h, "the height chamfers have met — reduce chamfer, or add floor_meat to make the block taller");

// MARK: Geometry

// A rectangle with all four corners cut at 45 deg, centred on the origin. Each
// corner takes the same amount off both edges, so the cut is 45 deg whatever
// chamfer is set to. Used three times, once per pair of faces, and the
// intersection of the three is a block with all twelve edges broken
module chamfered_rect_2d(across, up) {
  polygon([
    [-across / 2 + chamfer, -up / 2],
    [across / 2 - chamfer, -up / 2],
    [across / 2, -up / 2 + chamfer],
    [across / 2, up / 2 - chamfer],
    [across / 2 - chamfer, up / 2],
    [-across / 2 + chamfer, up / 2],
    [-across / 2, up / 2 - chamfer],
    [-across / 2, -up / 2 + chamfer],
  ]);
}

// The cradle, in cross section: x is across the width, y is up from the base.
// The circle sits on the top face, so half of it is in the block and half is
// in the air above it — that is the half cylinder, drawn rather than
// calculated. The trapezoid breaks both rims, and its lower corners are held
// on the circle so the break runs into the arc without a step
module cradle_2d() {
  circle(r = cradle_r);

  translate([0, -cradle_ease])
    polygon([
      [-ease_foot, 0],
      [ease_foot, 0],
      [cradle_r + cradle_ease, cradle_ease],
      [-cradle_r - cradle_ease, cradle_ease],
    ]);
}

// The finger notch, in cross section: x is up from the base, y is along the
// length of the block, which is the order across_width extrudes in. A flat
// floor on the trough's own deepest point, walls straight up off it, and a
// break at the mouth whose run and its rise are one expression, so it is 45
// deg whatever notch_ease is set to. It flares outward as it rises, the way a
// countersink does, so it faces up like everything else in the cut — the notch
// contributes no downward face at all
module notch_2d() {
  polygon([
    [notch_floor, -notch_l / 2],
    [notch_floor, notch_l / 2],
    [block_h - notch_ease, notch_l / 2],
    [block_h + overshoot, notch_l / 2 + notch_ease + overshoot],
    [block_h + overshoot, -notch_l / 2 - notch_ease - overshoot],
    [block_h - notch_ease, -notch_l / 2],
  ]);
}

// Run a cross section the length of the block, clear of both ends
module along_length(extra = 0) {
  translate([0, block_l / 2 + overshoot + extra, 0])
    rotate([90, 0, 0])
      linear_extrude(block_l + 2 * (overshoot + extra))
        children();
}

// Run a cross section across the width of the block, clear of both sides
module across_width(extra = 0) {
  translate([block_w / 2 + overshoot + extra, 0, 0])
    rotate([0, -90, 0])
      linear_extrude(block_w + 2 * (overshoot + extra))
        children();
}

// The block: three chamfered rectangles, one per pair of opposite faces,
// intersected. Each one breaks the four edges its own corners stand in for —
// the plan takes the uprights, and the two elevations take the top and bottom
// edges between them
module block_body() {
  intersection() {
    linear_extrude(block_h)
      chamfered_rect_2d(block_w, block_l);

    along_length()
      translate([0, block_h / 2])
        chamfered_rect_2d(block_w, block_h);

    across_width()
      translate([block_h / 2, 0])
        chamfered_rect_2d(block_h, block_l);
  }
}

module pencil_rest() {
  difference() {
    block_body();

    along_length(1)
      translate([0, block_h])
        cradle_2d();

    // The notch, cut clear through both sides
    across_width(1)
      notch_2d();
  }
}

pencil_rest();
