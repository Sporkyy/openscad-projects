// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// SPDX-FileCopyrightText: openConnect slot profile — mitufy, CC BY 4.0,
// for openGrid by David D, CC BY 4.0. See the header below.
// ============================================================
// openConnect item holder — an open-topped box that hangs a
// device on an openGrid board by openConnect slots in its back.
//
// The device drops in from the top and stands on a lip around
// a hole in the floor. The hole lets a cord out underneath; the
// lip is what stops the device sliding out through it. A cut
// down the front leaves the device's face and ports reachable,
// keeping a strip at the bottom and each side so it cannot tip
// out forward.
//
// Shipped values fit a SABRENT VOLTIK charging station.
//
// THE openConnect SLOT PROFILE IS NOT ORIGINAL WORK, AND THIS
// NOTICE IS A LICENCE CONDITION RATHER THAN A COURTESY. It is
// rebuilt in plain OpenSCAD from mitufy's openConnect library,
// so that this file can stand alone:
//   https://github.com/mitufy/opengrid-projects
//   lib/openconnect_lib.scad (CC BY 4.0)
// openConnect is mitufy's connector system for openGrid:
//   https://www.printables.com/model/1559478
// openGrid itself is by David D — https://www.opengrid.world
// (CC BY 4.0). Both licences require attribution and a
// statement of modification, so: the slot as used here IS
// MODIFIED, in the two ways described below. Keep this block
// with the file.
//
// Nothing in this file derives from mitufy's general holder,
// which is CC BY-SA 4.0, or from QuackWorks, which is CC BY-NC-SA
// 4.0. The holder body is written from scratch.
//
// DEPARTURES FROM THE LIBRARY'S SLOT. Two, both because the
// slot stands upright in this part, where the library's slot
// has two flat ceilings, and neither touching the connector:
// - The seat roof. The pocket the connector's flange rests in
//   is flat across the top between its 45 deg chamfers, a 9 mm
//   ceiling. Here the chamfers run on until they meet in a
//   point. The flange then seats on the chamfers rather than the
//   flat, which sits it 0.04 mm higher and centres it; the extra
//   room above is never touched.
// - The mouth lead-in. Where the slot opens through the back
//   face, the top edge of the opening is a flat 0.8 mm ledge
//   7.4 mm wide. Here it is cut back at 45 deg toward the back
//   face. The connector's neck never reaches that edge, and the
//   45 deg face the flange bears on below it is unchanged.
// With both off (departures = false on openconnect_slot) the
// slot matches the library's to within 0.03 cubic mm, the
// difference being the library's own 0.005 mm overlaps.
//
// PRINT NOTES:
// - Print as modelled: floor on the plate, opening up. No
//   supports.
// - The worst overhang is 45 deg, on the slot chamfers, the
//   seat roof and the mouth lead-in. Every other face is
//   vertical or faces up.
// - The lip is part of the floor, so it prints flat on the
//   plate and costs nothing.
// - Hang it by lining the slots' lower ends up over openConnect
//   connectors on the board, pushing it in, and sliding it down
//   until the locks click.
// ============================================================

// ===== MEASURE THESE ON THE DEVICE =====
// All three are outside dimensions of the device, so plain calipers reach
// them. Each names the caliper it needs by the size printed on the tool: a 6 in
// caliper stops at 150 mm, an 8 in at 200 mm, a 12 in at 300 mm

item_width = 75; // Side to side — outside jaws, 6 in caliper

// Front to back — outside jaws, 6 in caliper. Take it over anything that
// stands proud of the back, such as rubber feet, and close the jaws gently:
// feet squash and read short
item_depth = 55;

item_height = 116; // Bottom to top — outside jaws, 6 in caliper

// ===== TUNING KNOBS =====

// Clearance added to the measured width and depth (mm), as a total rather
// than per side. A pocket prints a little under size, so zero is a press fit.
// The depth gets more here because rubber feet on the back drag on the wall
width_clearance = 1;
depth_clearance = 2;

// How far below the device's top the walls stop (mm). Zero puts the rim
// level with the top of the device
rim_drop = 0;

wall_thickness = 2; // Side walls, front wall, and material behind the slots
floor_thickness = 2; // Floor, which is also the lip's thickness
corner_radius = 3; // Rounds the four vertical outside edges

// Floor opening. bottom_lip is how far the floor reaches in from each wall
// around the hole; that ledge is what the device stands on
bottom_opening = true;
bottom_lip = 5;
bottom_opening_radius = 3; // Rounds the hole's corners

// Front opening, cut from the rim down. front_side_lip is the strip of front
// wall left standing at each side, front_lip_height the strip left standing
// above the floor
front_opening = true;
front_side_lip = 8;
front_lip_height = 12;
front_opening_radius = 6; // Rounds the opening's two bottom corners

// Slots that carry a lock nub. Every slot holds; a lock is what clicks the
// holder in place, and more of them make it tighter and harder to fit
lock_every_slot = false; // false puts locks on the four corner slots only

// openConnect slot fit, as mitufy's generator ships it. Raise the clearances
// if the slots feel tight on your printer
slot_side_clearance = 0.1;
slot_depth_clearance = 0.1;
slot_bridge_min = 0.8; // Thinnest lip at the slot mouth, two 0.4 mm lines
slot_wall_min = 0.6; // Thinnest wall beside the slot mouth

// ===== openConnect INTERFACE — THE STANDARD, NOT KNOBS =====
// The connector head as mitufy's library defines it. A slot is the head grown
// by the clearances above, plus the track it slides along and the ramp it
// enters by. Change one of these and the slot stops fitting a connector

oc_pitch = 28; // openGrid tile pitch
oc_head_bottom = 0.6; // Wide flange at the tip of the head
oc_head_middle = 1.4; // 45 deg taper from the flange to the neck
oc_head_top = 0.6; // Neck, where the head leaves its base
oc_head_width = 17; // Flange width
oc_head_height = 10.6; // Flange height, flat bottom to chamfered top
oc_head_chamfer = 4; // 45 deg chamfer on the flange's two top corners
oc_head_offset = 0.4; // Head sits this far above the tile centre
oc_nub_from_top = 7.2; // Lock nub position, down from the flange top
oc_nub_depth = 0.6; // How far a lock nub stands into the slot
oc_nub_tip = 1.2; // Nub tip width, before rounding
oc_nub_fillet = 0.8; // Nub tip and root rounding
oc_slide = 10.6; // How far the head travels from the ramp to its seat
oc_ramp_clearance = 0.8; // Entry ramp's margin around the flange
oc_ramp_peak = 4; // Height of the 45 deg peak above the ramp

// ===== DERIVED =====

t22 = tan(22.5); // Converts a 45 deg chamfer's offset into its leg change

inner_width = item_width + width_clearance;
inner_depth = item_depth + depth_clearance;
pocket_height = item_height - rim_drop;

// Slot layers, from the deepest out to the back face
slot_bottom = oc_head_bottom + slot_side_clearance * t22 + slot_depth_clearance;
slot_middle = oc_head_middle;
slot_top = oc_head_top - slot_side_clearance * t22;
slot_depth = slot_bottom + slot_middle + slot_top;

flange_w = oc_head_width + 2 * slot_side_clearance;
flange_h = oc_head_height + 2 * slot_side_clearance;
flange_chamfer = oc_head_chamfer + slot_side_clearance * (1 - t22);
neck_w = flange_w - 2 * oc_head_middle;
neck_chamfer = oc_head_chamfer - oc_head_middle * (1 - t22) + slot_side_clearance * (1 - t22);
flange_top = flange_w / 2 + oc_head_offset;
neck_top = neck_w / 2 + oc_head_offset;
seat_bottom = flange_top - flange_h; // Flange and neck share this flat bottom
track_end = seat_bottom - oc_slide - oc_ramp_clearance;

// Minimum-width lip at the mouth: the neck is widened until the lip over the
// taper is slot_bridge_min thick at its edge, on the top and on the side away
// from the nub, and slot_wall_min on the nub side
mouth_top_widen = max(0, slot_bridge_min - slot_top);
mouth_side_widen = max(0, slot_bridge_min - slot_top);
mouth_nub_widen = max(0, slot_wall_min - slot_top);

nub_y = flange_top - oc_nub_from_top - slot_side_clearance;

back_thickness = slot_depth + wall_thickness;
body_width = inner_width + 2 * wall_thickness;
body_depth = inner_depth + wall_thickness + back_thickness;
body_height = floor_thickness + pocket_height;

// The entry ramp sits below the seat by the slide, and off to the nub side
ramp_x = -(oc_ramp_clearance + slot_middle);
ramp_top = flange_top - oc_slide;

// Ahead of this, every part of the slot is a plain run along y: the track's
// dovetail and the ramp's straight sides, side by side. That stretch is built
// as one extrusion, so the slot's end face belongs to a single solid and the
// pieces behind it never meet in a shared plane there
front_split = seat_bottom - oc_slide;

// The seat roof's apex, where its chamfers meet. See DEPARTURES, above
seat_apex = flange_top - flange_chamfer + flange_w / 2;

// How far one slot's cut reaches from its cell centre: across, from the ramp's
// far side to the flange's, and from the seat roof's apex down to the end of
// the track
slot_reach_left = oc_ramp_clearance + slot_middle - ramp_x + flange_w / 2;
slot_reach_right = flange_w / 2;
slot_reach_up = seat_apex;
slot_reach_down = -track_end;

// As many slots as fit on the flat of the back, on a grid centred on the
// back, keeping wall_thickness of the flat clear all round. A slot reaches
// further one way than the other, so it is the longer reach that decides
slot_flat_half_width = body_width / 2 - corner_radius - wall_thickness;
slot_flat_half_height = body_height / 2 - wall_thickness;
slot_columns = floor((slot_flat_half_width - max(slot_reach_left, slot_reach_right)) / (oc_pitch / 2)) + 1;
slot_rows = floor((slot_flat_half_height - max(slot_reach_up, slot_reach_down)) / (oc_pitch / 2)) + 1;

// Thinnest point of a rounded outside corner: from the inner corner to the
// arc, on the diagonal
corner_material = corner_radius <= wall_thickness ? wall_thickness : corner_radius - (corner_radius - wall_thickness) * sqrt(2);

$fa = 2;
$fs = 0.25;
eps = 0.01;

// ===== SANITY CHECKS =====

assert(item_width > 0 && item_depth > 0 && item_height > 0);
assert(width_clearance >= 0 && depth_clearance >= 0);
assert(pocket_height > floor_thickness, "rim_drop leaves no pocket");
assert(wall_thickness >= 1.2 && floor_thickness >= 1.2, "Walls under 1.2 mm are three lines or fewer");
assert(corner_material >= 1.2, "corner_radius thins the outside corners below 1.2 mm");
assert(slot_columns >= 1 && slot_rows >= 1, "Back is too small for a single openConnect slot");
assert(track_end < front_split && front_split < ramp_top - flange_chamfer, "Front of the slot is no longer a plain run");
assert(!bottom_opening || (bottom_lip > 0 && 2 * bottom_lip < min(inner_width, inner_depth) - 2 * bottom_opening_radius), "bottom_lip leaves no hole");
assert(!front_opening || (front_side_lip > 0 && 2 * front_side_lip < inner_width - 2 * front_opening_radius), "front_side_lip leaves no opening");
assert(!front_opening || (front_lip_height > 0 && front_lip_height < pocket_height - front_opening_radius), "front_lip_height leaves no opening");
assert(flange_w / 2 - flange_chamfer - oc_ramp_peak > 0, "Ramp peak overruns its own top");

echo(str("Pocket: ", inner_width, " x ", inner_depth, " x ", pocket_height, " mm (W x D x H)"));
echo(str("Body: ", body_width, " x ", body_depth, " x ", body_height, " mm (W x D x H)"));
echo(str("Back wall: ", back_thickness, " mm, slot depth ", slot_depth, " mm"));
echo(str("Slots: ", slot_columns, " x ", slot_rows, " on ", oc_pitch, " mm pitch, locks on ", lock_every_slot ? "every slot" : "the corners"));
echo(str("Floor opening: ", bottom_opening ? str(inner_width - 2 * bottom_lip, " x ", inner_depth - 2 * bottom_lip, " mm inside a ", bottom_lip, " mm lip") : "none"));
echo(str("Front opening: ", front_opening ? str(inner_width - 2 * front_side_lip, " mm wide, from ", front_lip_height, " mm above the floor") : "none"));
echo(str("Thinnest outside corner: ", corner_material, " mm"));

// ===== openConnect SLOT =====
// Built in slot coordinates: x across, y the direction the head slides into
// its seat (up, on the holder), z out of the wall. z = 0 is the floor of the
// slot and z = slot_depth is the back face; excess carries the cut past it

function top_chamfered(x0, x1, y0, y1, cl, cr) =
  [
    [x0, y0],
    [x1, y0],
    [x1, y1 - cr],
    [x1 - cr, y1],
    [x0 + cl, y1],
    [x0, y1 - cl]
  ];

// The mouth's widened outline, by its edges
mouth_x0 = -neck_w / 2 - mouth_nub_widen;
mouth_x1 = neck_w / 2 + mouth_side_widen;
mouth_top = neck_top + mouth_top_widen;
mouth_chamfer_nub = neck_chamfer + mouth_top_widen + mouth_nub_widen;
mouth_chamfer_side = neck_chamfer + mouth_top_widen + mouth_side_widen;

// The flange, neck and mouth outlines, each running the whole track
deep_outline = top_chamfered(-flange_w / 2, flange_w / 2, track_end, flange_top, flange_chamfer, flange_chamfer);
neck_outline = top_chamfered(-neck_w / 2, neck_w / 2, track_end, neck_top, neck_chamfer, neck_chamfer);
mouth_outline = top_chamfered(mouth_x0, mouth_x1, track_end, mouth_top, mouth_chamfer_nub, mouth_chamfer_side);

// The entry ramp: the flange outline dropped back by the slide and moved
// toward the nub side, with a 45 deg peak on top, all grown by the ramp
// clearance. Written out corner by corner rather than built with offset(), so
// its corners are the same numbers as everything that meets them
ramp_l = ramp_x - flange_w / 2 - oc_ramp_clearance;
ramp_r = ramp_x + flange_w / 2 + oc_ramp_clearance;
ramp_peak_y = ramp_top + oc_ramp_peak + oc_ramp_clearance;
// Each 45 deg side as the constant along it, x + y on the right and y - x on
// the left, pushed out by the clearance
ramp_side_r = ramp_x + flange_w / 2 + ramp_top - flange_chamfer + oc_ramp_clearance * sqrt(2);
ramp_side_l = -(ramp_x - flange_w / 2) + ramp_top - flange_chamfer + oc_ramp_clearance * sqrt(2);
ramp_outline = [
  [ramp_l, track_end],
  [ramp_r, track_end],
  [ramp_r, ramp_side_r - ramp_r],
  [ramp_side_r - ramp_peak_y, ramp_peak_y],
  [ramp_peak_y - ramp_side_l, ramp_peak_y],
  [ramp_l, ramp_side_l + ramp_l],
];

// One arc of n segments, centre c, radius r, from angle a0 to a1
function arc(c, r, a0, a1, n = 8) =
  [
    for (k = [0:n])
      let (a = a0 + (a1 - a0) * k / n)
        c + r * [cos(a), sin(a)]
  ];

// The lock nub's outline, u along the wall and v out from it. A trapezoid
// with 45 deg sides, its tip rounded and its root flared into the wall
nub_root_half = oc_nub_tip / 2 + oc_nub_depth;
nub_setback = oc_nub_fillet * t22;
// The root runs eps into the wall, so the nub and the wall overlap rather than
// meet in a shared plane
nub_outline = concat([
  [nub_root_half + nub_setback, -eps]
], arc([nub_root_half + nub_setback, oc_nub_fillet], oc_nub_fillet, 270, 225), arc([oc_nub_tip / 2 - nub_setback, oc_nub_depth - oc_nub_fillet], oc_nub_fillet, 45, 90), arc([-oc_nub_tip / 2 + nub_setback, oc_nub_depth - oc_nub_fillet], oc_nub_fillet, 90, 135), arc([-nub_root_half - nub_setback, oc_nub_fillet], oc_nub_fillet, 315, 270), [
  [-nub_root_half - nub_setback, -eps]
]);

// The nub stands on the slot's left wall. Through the flange layer it keeps
// its depth; through the taper it leans in with the wall, so its reach runs
// out where the taper meets the neck
module lock_nub() {
  lean = slot_middle - oc_nub_depth;
  translate([-flange_w / 2, nub_y, 0]) {
    translate([0, 0, -eps])
      linear_extrude(slot_bottom + eps)
        nub_2d();
    translate([0, 0, slot_bottom])
      multmatrix([
        [1, 0, lean / slot_middle, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0]
      ])
        linear_extrude(slot_middle)
          nub_2d();
  }
  module nub_2d() {
    polygon([
      for (p = nub_outline)
        [p[1], -p[0]]
    ]);
  }
}

// One solid through a stack of outlines, outline k at height zs[k] along
// axis, vertex to vertex. Every outline runs anticlockwise with the same
// vertex count, and each side face is planar because matching edges are
// parallel. Building a layered shape this way, rather than as layers unioned
// together, leaves no shared plane between the layers for the boolean to seam.
// Every solid in the slot but the lock nub, which only ever crosses other
// faces, is built this way rather than by extruding a 2D shape, so that
// solids which meet do so at exactly the same numbers: a 2D
// shape is rounded onto a fine grid before it is extruded, and two faces a
// rounding apart are what leave a boolean with slivers to resolve.
// axis "y" lays the outline in x and z and stacks it along -y; "x" lays it in
// y and z and stacks it along x
module stack(outlines, zs, axis = "z") {
  n = len(outlines[0]);
  m = len(outlines);
  polyhedron(points = [
    for (k = [0:m - 1], p = outlines[k])
      axis == "x" ? [zs[k], p[0], p[1]] : axis == "y" ? [p[0], -zs[k], p[1]] : [p[0], p[1], zs[k]]
  ], faces = concat([
    [
      for (i = [0:n - 1])
        i
    ]
  ], [
    [
      for (i = [n - 1:-1:0])
        (m - 1) * n + i
    ]
  ], [
    for (k = [0:m - 2], i = [0:n - 1])
      [k * n + i, (k + 1) * n + i, (k + 1) * n + (i + 1) % n, k * n + (i + 1) % n]
  ]));
}

function shifted(outline, dx) =
  [
    for (p = outline)
      [p[0] + dx, p[1]]
  ];

// The seat's roof. The standard flange outline is flat across the top between
// its chamfers, which is a ceiling once the slot stands upright; here the
// chamfers run on until they meet. See DEPARTURES, above. Only the triangle
// above the flat is added, built on its own along the flat's full length, so
// its corners are the flat's own corners
seat_roof = [
  [flange_w / 2 - flange_chamfer, flange_top],
  [0, seat_apex],
  [-flange_w / 2 + flange_chamfer, flange_top],
];

// Depth at which the mouth's flat top takes over from the taper above the
// seat. Out from here to the back face the mouth's top edge is a ceiling, so
// it is cut back at 45 deg instead. See DEPARTURES, above
mouth_lip_z = slot_bottom + max(0, flange_top - mouth_top);

// Everything ahead of front_split as one extrusion along y, through the
// outline of the track, ramp and mouth together, worked out by hand so that
// no union is needed. The ramp always reaches further to the nub side than
// the track, and the track further to the other side than the ramp, until it
// narrows past the mouth's widened edge
module front_block(top) {
  taper_top = slot_bottom + slot_middle;
  mouth_z = slot_bottom + min(slot_middle, flange_w / 2 - mouth_x1);
  outline = [
    [ramp_l, 0],
    [flange_w / 2, 0],
    [flange_w / 2, slot_bottom],
    [mouth_x1, mouth_z],
    [mouth_x1, top],
    [ramp_l - slot_middle, top],
    [ramp_l - slot_middle, taper_top],
    [ramp_l, slot_bottom],
  ];
  stack([outline, outline], [-front_split, -track_end], axis = "y");
}

// The 45 deg cut along the top of the mouth, across its flat between the
// chamfers. It starts eps inside the mouth so that its faces cross the
// mouth's rather than lying on them
module mouth_lead_in(top) {
  outline = [
    [mouth_top - eps, mouth_lip_z - eps],
    [mouth_top + top - mouth_lip_z, top],
    [mouth_top - eps, top],
  ];
  stack([outline, outline], [mouth_x0 + mouth_chamfer_nub, mouth_x1 - mouth_chamfer_side], axis = "x");
}

// departures = false builds the slot exactly as the library does, which is
// what to compare against the reference generator
module openconnect_slot(lock = true, excess = 1, departures = true) {
  top = slot_depth + excess;
  taper_top = slot_bottom + slot_middle;
  front_block(top);
  // Every piece runs the whole track, ends level with one another, and is
  // then cut back to front_split in one operation. The front block meets that
  // single cut face with an identical outline
  intersection() {
    union() {
      difference() {
        union() {
          // The dovetail: flange, 45 deg taper, neck
          stack([deep_outline, deep_outline, neck_outline, neck_outline], [0, slot_bottom, taper_top, top]);
          // The ramp, leaning toward the nub side through the taper
          stack([ramp_outline, ramp_outline, shifted(ramp_outline, -slot_middle), shifted(ramp_outline, -slot_middle)], [0, slot_bottom, taper_top, top]);
          if (departures)
            stack([seat_roof, seat_roof], [0, slot_bottom]);
        }
        if (lock)
          lock_nub();
      }
      // The widened mouth goes on after the nub is cut, as in the library, so
      // where the two cross the mouth wins
      stack([mouth_outline, mouth_outline], [slot_bottom, top]);
      if (departures)
        mouth_lead_in(top);
    }
    translate([-oc_pitch, front_split, -1])
      cube([2 * oc_pitch, 2 * oc_pitch, top + 2]);
  }
}

// ===== GEOMETRY =====
// Modelled in print orientation: floor on the plate at z = 0, back face in
// the plane y = 0, front toward -y

module rounded_rect(size, r) {
  if (r > 0)
    offset(r = r)
      offset(delta = -r)
        square(size);
  else
    square(size);
}

module body() {
  translate([-body_width / 2, -body_depth, 0])
    linear_extrude(body_height)
      rounded_rect([body_width, body_depth], corner_radius);
}

module pocket() {
  translate([-inner_width / 2, -back_thickness - inner_depth, floor_thickness])
    cube([inner_width, inner_depth, pocket_height + eps]);
}

module floor_hole() {
  translate([-inner_width / 2 + bottom_lip, -back_thickness - inner_depth + bottom_lip, -eps])
    linear_extrude(floor_thickness + 2 * eps)
      rounded_rect([inner_width - 2 * bottom_lip, inner_depth - 2 * bottom_lip], bottom_opening_radius);
}

module front_cut() {
  w = inner_width - 2 * front_side_lip;
  r = front_opening_radius;
  z0 = floor_thickness + front_lip_height;
  translate([0, -body_depth - eps, 0])
    rotate([-90, 0, 0])
      linear_extrude(wall_thickness + 2 * eps)
        mirror([0, 1, 0])
          hull() {
            for(x = [-w / 2 + r, w / 2 - r])
              translate([x, z0 + r])
                circle(r = r);
            translate([-w / 2, z0 + r])
              square([w, body_height - z0 - r + eps]);
          }
}

// Slot coordinates onto the back face: slot x runs to the holder's -x, so the
// slot reads the right way round seen from behind; slot y runs up; slot z
// runs out of the back face, which is y = 0
module slot_grid() {
  for(i = [0:slot_columns - 1], j = [0:slot_rows - 1]) {
    corner = (i == 0 || i == slot_columns - 1) && (j == 0 || j == slot_rows - 1);
    x = (i - (slot_columns - 1) / 2) * oc_pitch;
    z = body_height / 2 + (j - (slot_rows - 1) / 2) * oc_pitch;
    multmatrix([
      [-1, 0, 0, x],
      [0, 0, 1, -slot_depth],
      [0, 1, 0, z]
    ])
      openconnect_slot(lock = lock_every_slot || corner);
  }
}

difference() {
  body();
  pocket();
  if (bottom_opening)
    floor_hole();
  if (front_opening)
    front_cut();
  slot_grid();
}
