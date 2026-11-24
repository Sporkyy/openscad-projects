<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# openConnect item holder

[![openConnect item holder preview](openconnect_item_holder.png)](openconnect_item_holder.stl)

[STL](openconnect_item_holder.stl) · [OpenSCAD source](openconnect_item_holder.scad) ·
[Parameter sets](openconnect_item_holder.json)

An open-topped box that hangs a device on an openGrid board. The device drops in from the top and
stands on a lip around a hole in the floor. The hole lets a cord out underneath, and the lip stops
the device sliding out through it. A cut down the front leaves the device's face and ports
reachable. It keeps a strip of wall at the bottom and at each side, so the device cannot tip out
forward. A cord slot runs from the floor hole out through the front, so the device can go in with
its cord already plugged in.

The back carries a grid of [openConnect](https://www.printables.com/model/1559478) slots, mitufy's
connector system for openGrid. Nothing here uses Multiboard, Multiconnect or Multipoint.

## Hanging it

Fit openConnect connectors to the board where the holder is to go. Hold the holder a little high so
the lower ends of its slots sit over the connectors, then push it flat against the board and slide
it down. The connectors run up their tracks into the seats at the top, and the corner slots click as
their lock nubs pass. Lift it to take it off.

Every slot holds whether or not it has a lock. The back carries as many slots as fit, which the
render echoes, but the holder only needs connectors under as many as its load calls for.

## Measure and tune

All dimensions are millimetres. The three inputs are outside dimensions of the device:

| Input         | Where to measure                                                   | Caliper |
| ------------- | ------------------------------------------------------------------ | ------- |
| `item_width`  | Side to side                                                       | 6 in    |
| `item_depth`  | Front to back, over rubber feet or anything else proud of the back | 6 in    |
| `item_height` | Bottom to top                                                      | 6 in    |

Close the jaws gently on rubber feet. They squash, and a firm reading comes out short.

`width_clearance` and `depth_clearance` are added to the measured width and depth to make the
pocket. They are totals, not per side. A pocket prints slightly under size, so zero is a press fit.
1 mm on both is a normal drop-in fit. Give the depth another millimetre for rubber feet on the back,
which grip the wall as the device slides in.

`rim_drop` lowers the walls below the top of the device. At zero the rim is level with its top.

`bottom_lip` is how far the floor reaches in from each wall around the hole. That ledge is what the
device stands on, so make it wider for a device with rounded bottom edges. `front_side_lip` and
`front_lip_height` are the strips of front wall left standing at the sides of the front opening and
below it. `front_rim_radius` rounds the two corners where the opening meets the rim, and assertions
keep it within `front_side_lip` and the opening's straight sides. `bottom_opening` and
`front_opening` turn either cut off.

`cord_slot` cuts a slot forward from the floor hole through the lip and the front wall, open all the
way up to the rim, so a cord can be threaded down it as the device goes in. `cord_slot_offset` moves
it toward +x, the right seen from the front. `cord_slot_radius` rounds the slot's four corners: two
where it meets the floor hole, so a cord pulled sideways bears on a curve rather than an edge, and
two where it meets the top of the front wall. It needs the floor hole, and assertions keep it,
rounding included, on the hole's straight front edge and the flat bottom of the front opening, and
keep the radius within `bottom_lip` and `front_lip_height`.

Every rounded corner here runs along a vertical edge or tops off a wall, so none of them hangs.

`lock_every_slot` puts a lock nub in every slot instead of only the corner ones. More locks hold
tighter and make the holder harder to fit. `slot_side_clearance` and `slot_depth_clearance` are the
openConnect slot's fit, as mitufy's generator ships it. Raise them if the slots are tight on your
printer.

`flare_for_two_connectors` widens the exterior toward the back just enough for two columns of
openConnect slots. The pocket and its clearances stay the same. A holder already wide enough for two
columns keeps its shape, and the slot grid can still fit more columns on wider holders.

The rest follows. The back wall is the 2.7 mm slot depth plus `wall_thickness`. The slot grid is as
many 28 mm cells as fit on the flat of the back, centred, keeping `wall_thickness` clear of the
edges and the rounded corners. The render `echo`s the pocket, body, floor opening and slot grid, and
assertions catch a lip that leaves no hole, an opening that leaves no wall, and a back too small for
one slot.

## Devices

The values in the source are whatever was printed last. Each device the holder has been sized for is
kept as a named parameter set in [`openconnect_item_holder.json`](openconnect_item_holder.json), so
switching devices means picking a name rather than retyping numbers:

- **SABRENT VOLTIK charging station**
  ([STL](openconnect_item_holder_sabrent_voltik_charging_station.stl),
  [preview](openconnect_item_holder_sabrent_voltik_charging_station.png)). Its rubber feet are why
  its depth clearance is 2 mm, and its 10 mm cord slot passes a flat cable.
- **Ezcoo EZ-EX50 USB extender** ([STL](openconnect_item_holder_ezcoo_ez_ex50_usb_extender.stl),
  [preview](openconnect_item_holder_ezcoo_ez_ex50_usb_extender.png)). The back flares for two
  side-by-side connectors. It has a cord plugged into the bottom at each side, so its 20 mm cord
  slot leaves room to work both through.
- **Apple TV (2026)** ([STL](openconnect_item_holder_apple_tv_2026.stl),
  [preview](openconnect_item_holder_apple_tv_2026.png)). Same lips, clearances and cord slot as the
  extender above.

In the OpenSCAD app, open the source and pick a set from the dropdown at the top of the Customizer
panel. The JSON has to sit beside the source with the same name for the app to find it. From the
command line, name the file and the set:

```sh
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o sabrent.stl \
  -p openconnect_item_holder/openconnect_item_holder.json -P "SABRENT VOLTIK charging station" \
  openconnect_item_holder/openconnect_item_holder.scad
```

A misspelled set name does not fail. OpenSCAD renders the source's own values without a word, so
check the echoed `Pocket` line against the device. A set holds only the values that differ between
devices; everything else comes from the source. To add a device, save a new set from the Customizer,
or add an entry to the JSON by hand. Values are quoted strings there, the way the app writes them.

The build exports every set as its own STL and preview, linked above, and fails if a set names a
parameter the source does not have or gives one a value of the wrong type. The STL and preview at
the top of this page are the source's own values. The source still renders on its own without the
JSON.

## The openConnect slot

The slot is not original work. It is rebuilt in plain OpenSCAD from mitufy's openConnect library,
`lib/openconnect_lib.scad` in [opengrid-projects](https://github.com/mitufy/opengrid-projects), CC
BY 4.0, so this file can stand alone like every other source here. The numbers in the source's
openConnect interface block are that standard, not tuning knobs. With both departures below turned
off, the rebuilt slot agrees with the generator's to 0.03 mm³ in 1,010. The holder body owes nothing
to mitufy's own holders, which are CC BY-SA 4.0. See [OPENGRID.md](../OPENGRID.md#openconnect-slots)
for the slot's dimensions, its licensing, and the check against the generator.

The slot stands upright in this part, and the library's slot then has two flat ceilings. Both are
changed, and neither change touches the connector:

- **The seat roof.** The pocket the connector's flange rests in is flat across the top between two
  45° chamfers, a 9 mm ceiling. Here the chamfers run on until they meet in a point. The flange then
  seats on the chamfers instead of the flat, 0.04 mm higher and centred by them.
- **The mouth lead-in.** Where the slot opens through the back face, the top edge of the opening is
  a flat ledge 0.8 mm deep and 7.4 mm wide. Here it is cut back at 45° toward the back face. The
  connector's neck never reaches that edge, and the 45° face the flange bears on below it is
  unchanged.

## Printing

Print as modelled: floor on the plate, opening up, no supports. The worst overhang is 45°, on the
slot chamfers, the seat roof and the mouth lead-in. Every other face is vertical or faces up. The
lip is part of the floor, so it prints flat on the plate.

**Load.** The device's weight goes from the floor lip into the side and back walls, and from the
back wall into whichever connectors are under its slots. The connectors are what limit a heavy
device, not the cord slot. The holder hangs out from the board, so its weight tries to tip the top
away from the wall: the top row of slots is pulled out of its connectors while the bottom of the
back presses against the board. For a heavy device, fit connectors under the top row at least, and
under every slot if you can. The cord slot costs little by comparison. It takes only its own width
out of a lip that runs right round the box. The lip is fused to the walls all along its length
rather than spanning between them, so losing a short stretch at the front does not weaken the rest.
What the slot does undo is the closed ring at the bottom of the box: the strip of front wall under
the opening no longer ties the two side walls together. The back wall still ties them along their
whole height, and that is what keeps them square.

Not yet printed. The rebuilt slot matches the generator's, but its fit on real connectors from your
printer is untested, and so is the wall behind the slots under the device's weight. A one-slot test
cup is quick to print and checks the slot alone:

```sh
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o slot-test.stl \
  -D item_width=32 -D item_depth=6 -D item_height=30 \
  -D bottom_opening=false -D front_opening=false -D cord_slot=false \
  openconnect_item_holder/openconnect_item_holder.scad
```

Rebuild the STL and preview after changing parameters:

```sh
scadformat openconnect_item_holder/openconnect_item_holder.scad
.venv/bin/python scripts/build.py openconnect_item_holder/openconnect_item_holder.scad
```
