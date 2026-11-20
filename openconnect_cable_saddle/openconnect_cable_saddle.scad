// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre
// SPDX-FileCopyrightText: openConnect slot profile — mitufy, CC BY 4.0,
// for openGrid by David D, CC BY 4.0. See the header below.
// ============================================================
// openConnect cable saddle — a wall hook for a coiled cable,
// shaped like a garden hose hanger: a curved saddle the coil
// drapes over, standing out from a back plate, with a lip at
// the front so the coil cannot slide off. It hangs on an
// openGrid board by openConnect slots in the back plate.
//
// Shipped values are for the Ethernet coil that runs to the
// Apple TV, taken from memory: 100 mm inside, 20 mm thick.
// Measure it before printing.
//
// IT PRINTS ON ITS SIDE, standing on one wing tip, and is
// modelled that way: z is across the wall, x is up the wall,
// and the back plate's back face is the plane y = 0. Three
// things follow from that orientation:
// - The saddle is an arc swept outward from the wall. Lying on
//   its side, its surfaces hang no further than the arc's angle
//   at the wing tips, so keeping that within 45 deg keeps the
//   whole saddle self-supporting. The plate's width sets where
//   the wings end, so the plate is sized from the coil: as many
//   tiles across as the saddle's curve allows before its wing
//   tips would hang past 45 deg, and as many up as it takes to
//   carry the wings.
// - The layer lines run along the arm, out from the wall. The
//   coil's weight bends the arm at its root, and that stress
//   runs within each layer rather than pulling layers apart.
// - The openConnect slots print on their side, with the slide
//   direction horizontal and the lock nubs on the lower wall.
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
// Nothing in this file derives from mitufy's hooks or holders,
// which are CC BY-SA 4.0. The saddle is written from scratch.
//
// DEPARTURES FROM THE LIBRARY'S SLOT. Two, both on the slot's
// upper side as printed, both because a slot printed on its
// side has two flat ceilings there, and neither touching the
// connector:
// - The flange bevel. The pocket the connector's flange slides
//   in has square sides, so its upper side is a ceiling 0.74 mm
//   deep. Here the 45 deg taper above it runs on down to the
//   floor of the slot instead. The extra room is beyond the
//   flange's edge; the taper the flange bears on is unchanged.
// - The mouth flare. Where the slot opens through the back face,
//   its upper edge is a flat ledge 0.8 mm deep. Here it is cut
//   back at 45 deg toward the face. The connector's neck never
//   reaches it.
// With both off (departures = false on openconnect_slot) the
// slot matches the library's to within 0.03 cubic mm, the
// difference being the library's own 0.005 mm overlaps.
//
// PRINT NOTES:
// - Print as modelled, on its side, no supports. The worst
//   overhang is 45 deg: the slot tapers and chamfers, the bevel
//   and flare, and the saddle's surfaces at the wing tips.
// - It stands as tall as the plate is wide, 56 mm for the
//   shipped coil, on a narrow footprint, so make sure the first
//   layer is well squished, or add a brim.
// - Hang it by lining the slots' lower ends up over openConnect
//   connectors on the board, pushing it in, and sliding it down
//   until the locks click.
// ============================================================

// ===== MEASURE THESE ON THE COIL =====
// The inside of a coil is an open gap, so plain calipers reach it. Each names
// the caliper it needs by the size printed on the tool: a 6 in caliper stops at
// 150 mm, an 8 in at 200 mm, a 12 in at 300 mm

// Smallest inside diameter of the coil, where it will hang — inside jaws, 6 in
// caliper. A coil hangs into a teardrop, so take it across the top loop
coil_inner_d = 100;

coil_thickness = 20; // Thickness of the coiled bundle — outside jaws, 6 in caliper

// ===== TUNING KNOBS =====

// How much smaller the saddle's radius is than the coil's inside radius, so
// the coil drops on without being forced round it
saddle_clearance = 5;

// Clear room between the back plate and the lip, beyond the coil's thickness
depth_clearance = 5;

band_thickness = 5; // Radial thickness of the saddle
lip_height = 10; // How far the front lip stands above the saddle
lip_thickness = 3; // Lip thickness, out from the wall

// The back plate is sized from the coil, in whole openGrid tiles: as wide as
// the saddle's curve allows and as tall as its wings need. These only limit
// that. plate_tiles_across_max caps the width, 0 for no cap; plate_tiles_up_min
// makes the plate taller than it needs to be, for more slots
plate_tiles_across_max = 0;
plate_tiles_up_min = 1;

wall_thickness = 2; // Material behind the slots, and kept clear round them

// Slots that carry a lock nub. Every slot holds; a lock is what clicks the
// saddle in place, and more of them make it tighter and harder to fit
lock_every_slot = false; // false puts locks on the corner slots only

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

saddle_r = coil_inner_d / 2 - saddle_clearance; // Outer, where the coil rests
saddle_inner_r = saddle_r - band_thickness;
channel_depth = coil_thickness + depth_clearance;

// Printed on its side, the saddle's inner face hangs steepest at the upper
// wing tip, at the angle whose sine is half the plate's width over the inner
// radius. So the widest plate that keeps it within 45 deg has a half-width of
// the inner radius times sin 45, and the plate takes as many whole tiles as fit
// in that
plate_tiles_fit = floor(2 * saddle_inner_r * sin(45) / oc_pitch);
plate_tiles_across = plate_tiles_across_max > 0 ? min(plate_tiles_fit, plate_tiles_across_max) : plate_tiles_fit;
plate_across = plate_tiles_across * oc_pitch;

// The saddle's crown sits half a band below the plate's top edge, and the
// plate reaches down at least to the wings' lowest point, on the inner face at
// the wing tips. That drop is the band's half plus the inner face's sag
// across the plate
saddle_drop = band_thickness / 2 + saddle_r - sqrt(max(0, saddle_inner_r ^ 2 - (plate_across / 2) ^ 2));
plate_tiles_up = max(plate_tiles_up_min, ceil(saddle_drop / oc_pitch));
plate_up = plate_tiles_up * oc_pitch;

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

plate_thickness = slot_depth + wall_thickness;

// The entry ramp sits below the seat by the slide, and off to the nub side
ramp_x = -(oc_ramp_clearance + slot_middle);
ramp_top = flange_top - oc_slide;

// Ahead of this, every part of the slot is a plain run along y: the track's
// dovetail and the ramp's straight sides, side by side. That stretch is built
// as one extrusion, so the slot's end face belongs to a single solid and the
// pieces behind it never meet in a shared plane there
front_split = seat_bottom - oc_slide;

// How far one slot's cut reaches from its cell centre: toward the nub side to
// the ramp's far edge, the other way to the flange bevel's edge at the slot
// floor, and from the seat down to the end of the track
slot_reach_nub = oc_ramp_clearance + slot_middle - ramp_x + flange_w / 2;
slot_reach_side = flange_w / 2 + slot_bottom;
slot_reach_up = flange_top;
slot_reach_down = -track_end;

// As many slots as fit on the plate keeping wall_thickness clear all round,
// with the whole grid of cuts centred on it
slot_columns = floor((plate_across - 2 * wall_thickness - slot_reach_nub - slot_reach_side) / oc_pitch) + 1;
slot_rows = floor((plate_up - 2 * wall_thickness - slot_reach_up - slot_reach_down) / oc_pitch) + 1;
slot_first_across = (plate_across - (slot_columns - 1) * oc_pitch - slot_reach_nub - slot_reach_side) / 2 + slot_reach_nub;
slot_first_up = (plate_up - (slot_rows - 1) * oc_pitch - slot_reach_up - slot_reach_down) / 2 + slot_reach_down;

// The saddle's crown sits half a band below the plate's top edge, so the two
// cross rather than touch, and the arc is centred on the plate
saddle_centre_up = plate_up - band_thickness / 2 - saddle_r;

// Where the wings end at the plate's edges: the angle each face of the saddle
// reaches from the top, which is the steepest it hangs as printed, and the
// lowest point of the saddle, on its inner face at the wing tips
wing_outer_angle = asin(plate_across / 2 / saddle_r);
wing_inner_angle = asin(min(1, plate_across / 2 / saddle_inner_r));
saddle_low = saddle_centre_up + sqrt(max(0, saddle_inner_r ^ 2 - (plate_across / 2) ^ 2));

$fa = 2;
$fs = 0.25;
eps = 0.01;

// ===== SANITY CHECKS =====

assert(coil_inner_d > 0 && coil_thickness > 0);
assert(saddle_clearance >= 0 && depth_clearance >= 0);
assert(band_thickness >= 2 && lip_thickness >= 1.2 && lip_height > 0, "Saddle or lip too thin to print");
assert(wall_thickness >= 1.2, "Walls under 1.2 mm are three lines or fewer");

// The inner face hangs steepest, at the upper wing tip as printed. It reaches
// the angle whose sine is half the plate width over the inner radius, so this
// is the 45 deg rule written on the two numbers that set it
assert(plate_tiles_across >= 1, "Coil too small for even a one-tile plate: the wing tips would hang past 45 deg — reduce saddle_clearance or band_thickness");
assert(plate_across / 2 <= saddle_inner_r * sin(45), "Wing tips hang past 45 deg");
assert(saddle_low >= 0, "Saddle hangs below the back plate");
assert(slot_columns >= 1 && slot_rows >= 1, "Plate is too small for a single openConnect slot");
assert(track_end < front_split && front_split < ramp_top - flange_chamfer, "Front of the slot is no longer a plain run");
assert(flange_w / 2 - flange_chamfer - oc_ramp_peak > 0, "Ramp peak overruns its own top");

echo(str("Saddle: ", saddle_r, " mm radius, ", band_thickness, " mm band, coil hangs in a ", channel_depth, " mm channel"));
echo(str("Wing tips as printed: saddle face ", wing_outer_angle, " deg, inner face ", wing_inner_angle, " deg from vertical"));
echo(str("Locks on ", lock_every_slot ? "every slot" : "the corner slots"));
echo(str("Lip: ", lip_height, " mm above the saddle, ", lip_thickness, " mm thick"));
echo(str("Plate: ", plate_tiles_across, " x ", plate_tiles_up, " tiles (", plate_across, " x ", plate_up, " x ", plate_thickness, " mm), slots ", slot_columns, " x ", slot_rows, plate_tiles_across < plate_tiles_fit ? str(", capped from ", plate_tiles_fit, " across") : ""));
echo(str("Reaches ", plate_thickness + channel_depth + lip_thickness, " mm out from the wall; stands ", plate_across, " mm tall as printed"));

// ===== openConnect SLOT =====
// Built in slot coordinates: x across, y the direction the head slides into
// its seat (up the wall), z out of the wall. z = 0 is the floor of the slot
// and z = slot_depth is the back face; excess carries the cut past it. The nub
// side is -x, which is down as printed

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


// Where the widened mouth's edge on the side away from the nub takes over from
// the taper. Out from here to the back face that edge is a ceiling as printed,
// so it is cut back at 45 deg instead. See DEPARTURES, above
mouth_side_z = slot_bottom + min(slot_middle, flange_w / 2 - mouth_x1);

// The departures as outlines. The flange layer's floor is the flange outline
// widened on the side away from the nub by the flange layer's depth, so the
// side face runs from there to the taper at 45 deg; the mouth at the back face
// is widened the same way by its own depth past mouth_side_z. Each keeps its
// chamfer on the same line, so the faces between outlines stay planar
function widened(x0, x1, y0, y1, cl, cr, by) =
  top_chamfered(x0, x1 + by, y0, y1, cl, cr + by);

// Everything ahead of front_split as one extrusion along y, through the
// outline of the track, ramp and mouth together, worked out by hand so that
// no union is needed. The ramp always reaches further to the nub side than
// the track, and the track further to the other side than the ramp, until it
// narrows past the mouth's widened edge
module front_block(top, departures) {
  taper_top = slot_bottom + slot_middle;
  side = departures ? [
    [flange_w / 2 + slot_bottom, 0],
    [mouth_x1, mouth_side_z],
    [mouth_x1 + top - mouth_side_z, top]
  ] : [
    [flange_w / 2, 0],
    [flange_w / 2, slot_bottom],
    [mouth_x1, mouth_side_z],
    [mouth_x1, top]
  ];
  outline = concat([
    [ramp_l, 0]
  ], side, [
    [ramp_l - slot_middle, top],
    [ramp_l - slot_middle, taper_top],
    [ramp_l, slot_bottom]
  ]);
  stack([outline, outline], [-front_split, -track_end], axis = "y");
}

// departures = false builds the slot exactly as the library does, which is
// what to compare against the reference generator
module openconnect_slot(lock = true, excess = 1, departures = true) {
  top = slot_depth + excess;
  taper_top = slot_bottom + slot_middle;
  floor_outline = departures ? widened(-flange_w / 2, flange_w / 2, track_end, flange_top, flange_chamfer, flange_chamfer, slot_bottom) : deep_outline;
  flared_mouth = departures ? widened(mouth_x0, mouth_x1, track_end, mouth_top, mouth_chamfer_nub, mouth_chamfer_side, top - mouth_side_z) : mouth_outline;
  front_block(top, departures);
  // Every piece runs the whole track, ends level with one another, and is
  // then cut back to front_split in one operation. The front block meets that
  // single cut face with an identical outline
  intersection() {
    union() {
      difference() {
        union() {
          // The dovetail: flange, 45 deg taper, neck
          stack([floor_outline, deep_outline, neck_outline, neck_outline], [0, slot_bottom, taper_top, top]);
          // The ramp, leaning toward the nub side through the taper
          stack([ramp_outline, ramp_outline, shifted(ramp_outline, -slot_middle), shifted(ramp_outline, -slot_middle)], [0, slot_bottom, taper_top, top]);
        }
        if (lock)
          lock_nub();
      }
      // The widened mouth goes on after the nub is cut, as in the library, so
      // where the two cross the mouth wins
      stack([mouth_outline, mouth_outline, flared_mouth], [slot_bottom, mouth_side_z, top]);
    }
    translate([-oc_pitch, front_split, -1])
      cube([2 * oc_pitch, 2 * oc_pitch, top + 2]);
  }
}

// ===== GEOMETRY =====
// Modelled in print orientation, on its side: z across the wall, x up the
// wall, back face in the plane y = 0 and the saddle toward -y

// An annular sector in the wall's plane, across by up from the arc's centre,
// wide enough that its ends run past the plate's edges to be trimmed there
module sector_2d(r_out, r_in) {
  a = asin((plate_across / 2 + 1) / r_in);
  n = ceil(2 * a / 1);
  polygon(concat([
    for (k = [0:n])
      let (t = -a + 2 * a * k / n)
        r_out * [sin(t), cos(t)]
  ], [
    for (k = [n:-1:0])
      let (t = -a + 2 * a * k / n)
        r_in * [sin(t), cos(t)]
  ]));
}

// Sweep a wall-plane shape out from the wall, from y0 to y0 + length
module swept(y0, length) {
  multmatrix([
    [0, 1, 0, saddle_centre_up],
    [0, 0, 1, y0],
    [1, 0, 0, plate_across / 2]
  ])
    linear_extrude(length)
      children();
}

// The saddle and lip as one solid: a band as tall as the lip, running from
// the front out to 1 mm inside the plate, with the coil's channel cut out of
// it behind the lip. Built as one rather than as a band and a lip unioned, so
// the saddle's underside runs unbroken to the front
module saddle() {
  y_front = -(plate_thickness + channel_depth + lip_thickness);
  y_back = -plate_thickness + 1;
  difference() {
    swept(y_front, y_back - y_front)
      sector_2d(saddle_r + lip_height, saddle_inner_r);
    swept(y_front + lip_thickness, y_back - y_front)
      sector_2d(saddle_r + lip_height + 1, saddle_r);
  }
}

module plate() {
  translate([0, -plate_thickness, -1])
    cube([plate_up, plate_thickness, plate_across + 2]);
}

// Slot coordinates onto the back face: slot y runs up the wall (+x), slot z
// out of the back face (+y), and slot x across (+z), so the nub side is down
// as printed
module slot_grid() {
  for(i = [0:slot_columns - 1], j = [0:slot_rows - 1]) {
    corner = (i == 0 || i == slot_columns - 1) && (j == 0 || j == slot_rows - 1);
    multmatrix([
      [0, 1, 0, slot_first_up + j * oc_pitch],
      [0, 0, 1, -slot_depth],
      [1, 0, 0, slot_first_across + i * oc_pitch]
    ])
      openconnect_slot(lock = lock_every_slot || corner);
  }
}

// Everything is built running past the plate's two edges and trimmed to them
// in one cut, so each edge is a single face: the one on the plate as printed
// and the one on top
intersection() {
  difference() {
    union() {
      plate();
      saddle();
    }
    slot_grid();
  }
  translate([-plate_up, -2 * (plate_thickness + channel_depth + lip_thickness), 0])
    cube([4 * plate_up + 2 * (saddle_r + lip_height), 4 * (plate_thickness + channel_depth + lip_thickness), plate_across]);
}
