// SPDX-License-Identifier: CC-BY-4.0
// SPDX-FileCopyrightText: 2026 Todd Sayre

// MARK: Dimensions

// Cable slot and working length above the saddle
cable_gap = 10.5; // mm
post_length = 25; // mm

// MARK: Tuning

saddle_radius = 1; // mm, inside corners under the cable
thread_radial_clearance = 0.20; // mm, from the existing male thread envelope
shoe_bed_chamfer = 0.35; // mm, first-layer relief for the dovetail heel

/* [Hidden] */

// MARK: Ring Nut Interface

// Right-hand thread measured from the mating ring and clamp meshes
thread_pitch = 2.5;
thread_crest_radius = 10.65;
thread_root_radius = 9.05;
thread_crest_width = 0.14;
thread_flank_angle = 60;

// MARK: Snap Interface

// Matching shoe and retainer coordinates
shoe_half_width = 3;
shoe_depth = 2;
shoe_end_x = 8;
screw_x = 1.5;
screw_shank_r = 1.7;
screw_head_r = 3.15;

// MARK: Derived

saddle_height = 4;
base_radius = 11.2;
bed_x = -5.2;
top_z = saddle_height + post_length;
crest_r = thread_crest_radius - thread_radial_clearance;
lead_in = crest_r - thread_root_radius;
head_depth = screw_head_r - screw_shank_r;
thread_step_count = 120;
thread_root_overlap = 0.06;
thread_foot_width = thread_crest_width / 2 + (crest_r - thread_root_radius + thread_root_overlap) / tan(thread_flank_angle);
thread_start = saddle_height - thread_pitch;
thread_steps = ceil((top_z + thread_pitch - thread_start) / thread_pitch) * thread_step_count;

$fn = thread_step_count;
eps = 0.01;

// MARK: Checks

assert(cable_gap / 2 > screw_head_r + saddle_radius, "Leave space for the retaining screw inside the saddle");
assert(cable_gap / 2 < thread_root_radius - 2, "Keep at least 2 mm of material behind each thread");
assert(saddle_radius >= 0.5 && saddle_radius < saddle_height, "Saddle radius outside the fillet limits");
assert(thread_radial_clearance >= 0.1 && lead_in >= 0.8, "Thread clearance leaves the crest too high or too shallow");
assert(post_length > 2 * lead_in + thread_pitch, "Leave at least one full thread between the lead-ins");
assert(thread_foot_width < thread_pitch / 2, "Adjacent turns of the helix overlap");
assert(shoe_bed_chamfer >= 0 && shoe_bed_chamfer < shoe_depth / 2, "Keep the relief within the dovetail heel");

echo(str("Cable gap: ", cable_gap, " mm, post length: ", post_length, " mm"));
echo(str("Thread: ", 2 * crest_r, " mm crest diameter, ", thread_pitch, " mm pitch, right hand"));

// MARK: Thread

// Trapezoidal ridge swept along a right-hand helix, with triangulated flanks
module thread_ridge() {
  profile = [
    [thread_root_radius - thread_root_overlap, -thread_foot_width],
    [crest_r, -thread_crest_width / 2],
    [crest_r, thread_crest_width / 2],
    [thread_root_radius - thread_root_overlap, thread_foot_width],
  ];
  points = [
    for (i = [0:thread_steps], p = profile)
      let (a = i * 360 / thread_step_count)
        [p[0] * cos(a), p[0] * sin(a), thread_start + i * thread_pitch / thread_step_count + p[1]]
  ];
  faces = concat([
    [3, 2, 1, 0]
  ], [
    for (i = [0:thread_steps - 1], j = [0:3])
      let (a = 4 * i + j, b = 4 * i + (j + 1) % 4)
        each [
          [a, b + 4, a + 4],
          [a, b, b + 4]
        ]
  ], [
    [4 * thread_steps, 4 * thread_steps + 1, 4 * thread_steps + 2, 4 * thread_steps + 3]
  ]);
  polyhedron(points, faces, convexity = 8);
}

module threaded_blank() {
  intersection() {
    union() {
      translate([0, 0, saddle_height - eps])
        cylinder(r = thread_root_radius, h = post_length + eps);
      thread_ridge();
    }
    rotate_extrude()
      polygon([
        [0, saddle_height - eps],
        [thread_root_radius + eps, saddle_height - eps],
        [crest_r + eps, saddle_height + lead_in],
        [crest_r + eps, top_z - lead_in],
        [thread_root_radius + eps, top_z],
        [0, top_z],
      ]);
  }
}

// MARK: Geometry

// Channel in the assembled YZ plane, with circular relief at the post roots
module cable_cut() {
  w = cable_gap / 2;
  r = saddle_radius;
  translate([bed_x - eps, 0, 0])
    rotate([90, 0, 90])
      linear_extrude(height = 2 * base_radius)
        polygon(concat([
          [-w, top_z + eps]
        ], [
          for (a = [180:5:270])
            [-w + r + r * cos(a), saddle_height + r + r * sin(a)]
        ], [
          for (a = [270:5:360])
            [w - r + r * cos(a), saddle_height + r + r * sin(a)]
        ], [
          [w, top_z + eps]
        ]));
}

// Dovetail section with equal depth and flare on each side
module shoe_section(inset) {
  offset(delta = -inset)
    polygon([
      [-shoe_half_width, eps],
      [-shoe_half_width - shoe_depth, -shoe_depth],
      [shoe_half_width + shoe_depth, -shoe_depth],
      [shoe_half_width, eps],
    ]);
}

module shoe() {
  translate([bed_x, 0, 0])
    rotate([90, 0, 90])
      hull() {
        linear_extrude(height = eps)
          shoe_section(shoe_bed_chamfer);
        translate([0, 0, shoe_bed_chamfer + eps])
          linear_extrude(height = shoe_end_x - bed_x - shoe_bed_chamfer - eps)
            shoe_section(0);
      }
}

// Teardrop roof with equal rise and run in the print orientation
module screw_profile(r) {
  polygon(concat([
    [r * sqrt(2), 0]
  ], [
    for (a = [45:360 / $fn:315])
      [r * cos(a), r * sin(a)]
  ]));
}

module retaining_screw_cut() {
  translate([screw_x, 0, -shoe_depth - eps])
    linear_extrude(height = saddle_height + shoe_depth + 2 * eps)
      screw_profile(screw_shank_r);
  translate([screw_x, 0, saddle_height - head_depth])
    linear_extrude(height = head_depth + eps, scale = (screw_head_r + eps) / screw_shank_r)
      screw_profile(screw_shank_r);
}

module fork() {
  intersection() {
    difference() {
      union() {
        cylinder(r = base_radius, h = saddle_height + eps);
        threaded_blank();
        shoe();
      }
      cable_cut();
      retaining_screw_cut();
    }
    // Bed flat through the heel, saddle and both posts
    translate([bed_x, -base_radius - eps, -shoe_depth - eps])
      cube([2 * base_radius, 2 * (base_radius + eps), top_z + shoe_depth + 2 * eps]);
  }
}

// Sideways print with the threaded axis parallel to the plate
translate([0, 0, -bed_x])
  rotate([0, -90, 0])
    fork();
