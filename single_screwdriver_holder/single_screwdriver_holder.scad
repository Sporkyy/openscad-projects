// SPDX-License-Identifier: CC-BY-4.0
// Example dimensions only: measure your screwdriver and hanger before printing.
// Print as modelled, socket up and mounting slot down. All dimensions are mm.

// Measured inputs — example values, not Wall Control specifications
shaft_d = 8; // Maximum shaft width — 6 in caliper
handle_d = 32; // Maximum width over the captured handle length — 6 in caliper
bolster_d = 14; // Maximum width across hex corners — 6 in caliper
bolster_l = 10; // Length projecting below handle — 6 in caliper
hanger_thickness = 2; // Strip thickness including coating — 6 in caliper
hanger_wall_gap = 8; // Clear gap behind strip — 6 in caliper
hanger_height = 40; // Strip top to bottom — 6 in caliper

// Tuning knobs
middle_bore = true;
handle_depth = 12;
diameter_clearance = 0.6; // Added to diameters and front slot width
bolster_end_clearance = 0.5;
hanger_clearance = 0.5; // Added to mounting slot thickness
wall_clearance = 0.5;
wall = 5;
bottom_thickness = 4;
rear_lip = 3;
hanger_engagement = 18; // Slot depth at its lowest roof edge
roof_meat = 4;
minimum_seat = 2; // Minimum radial shoulder under handle
$fn = 128;

// Derived values
shaft_bore_d = shaft_d + diameter_clearance;
handle_bore_d = handle_d + diameter_clearance;
middle_bore_d = middle_bore ? bolster_d + diameter_clearance : shaft_bore_d;
middle_depth = middle_bore ? bolster_l + bolster_end_clearance : 0;
handle_floor = bottom_thickness + middle_depth;
body_h = max(handle_floor + handle_depth, hanger_engagement + hanger_thickness + hanger_clearance + roof_meat);
socket_floor = body_h - handle_depth;
mount_gap = hanger_thickness + hanger_clearance;
body_w = handle_bore_d + 2 * wall;
bore_y = rear_lip + mount_gap + wall + handle_bore_d / 2;
body_d = bore_y + handle_bore_d / 2 + wall;
eps = 0.02;

assert(shaft_d > 0 && handle_d > 0 && hanger_thickness > 0 && hanger_height > 0);
assert(diameter_clearance >= 0 && hanger_clearance >= 0 && wall_clearance >= 0);
assert(handle_depth > 0 && wall >= 3 && bottom_thickness >= 3 && rear_lip >= 3 && roof_meat >= 3);
assert(hanger_engagement > 0 && hanger_engagement <= hanger_height, "Mount engagement must fit the strip height");
assert(rear_lip + wall_clearance <= hanger_wall_gap, "Rear lip does not fit behind hanger");
assert(minimum_seat >= 2 && handle_bore_d - middle_bore_d >= 2 * minimum_seat, "Leave a shoulder beneath the handle");
assert(!middle_bore || (bolster_d >= shaft_d && bolster_l > 0 && bolster_end_clearance >= 0), "Bolster must clear shaft and have positive length");
assert(socket_floor - middle_depth >= bottom_thickness, "Middle pocket reaches bottom shoulder");
echo(body_width = body_w, body_depth = body_d, body_height = body_h);
echo(handle_bore = handle_bore_d, handle_capture_depth = handle_depth, middle_bore = middle_bore_d, middle_depth = middle_depth, shaft_bore_and_slot = shaft_bore_d);
echo(mount_slot_width = mount_gap, mount_engagement = hanger_engagement, rear_lip = rear_lip, handle_seat_radial_width = (handle_bore_d - middle_bore_d) / 2);

// Constant-width mounting channel, open below and at both sides. Its roof
// rises by exactly the channel width: 45 degrees, with no flat bridge.
module mounting_channel() {
  translate([-body_w / 2 - eps, 0, 0])
    rotate([90, 0, 90])
      linear_extrude(body_w + 2 * eps)
        polygon([
          [rear_lip, -eps],
          [rear_lip + mount_gap, -eps],
          [rear_lip + mount_gap, hanger_engagement + mount_gap],
          [rear_lip, hanger_engagement],
        ]);
}

difference() {
  translate([-body_w / 2, 0, 0])
    cube([body_w, body_d, body_h]);
  mounting_channel();
  translate([0, bore_y, -eps])
    cylinder(d = shaft_bore_d, h = body_h + 2 * eps);
  translate([0, bore_y, socket_floor])
    cylinder(d = handle_bore_d, h = handle_depth + eps);
  if (middle_bore)
    translate([0, bore_y, socket_floor - middle_depth])
      cylinder(d = middle_bore_d, h = middle_depth + handle_depth + eps);
  // One cut through the whole height guarantees the same opening at every tier.
  translate([-shaft_bore_d / 2, bore_y, -eps])
    cube([shaft_bore_d, body_d - bore_y + eps, body_h + 2 * eps]);
}
