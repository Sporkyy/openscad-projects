# Shelf tube dogbone

[![Shelf tube dogbone preview](shelf_tube_dogbone.png)](shelf_tube_dogbone.stl)

[View or download STL](shelf_tube_dogbone.stl) · [OpenSCAD source](shelf_tube_dogbone.scad)

The same rigidity as the [brace](../shelf_tube_coupler/README.md#shelf-tube-brace),
reached by gripping all four posts at one level instead of triangulating. A plate pinned to two posts on a unit cannot rotate
relative to it, so a plate holding two posts on each unit locks the pair
together.

Whole, that plate is about 286 mm long on the measured 200 mm `post_clear_gap`,
past what a 256 mm bed takes; it prints as two halves bolted together at
mid-depth with two M4 bolts, which is what keeps deeper units and smaller beds
printable too. Both halves come out of one source and one `.stl`, because every
dimension they share has to match for them to assemble.

**Four round holes would not go on.** Four holes on four posts dictates the
front-to-back post spacing of both units simultaneously, and two units that
disagree would leave the plate bridging nothing. So the front pair locates and
the back pair are slots running front to back. The round holes fix position, the
slots absorb whatever the units disagree about, and rotation stays fully
constrained because each slot is elongated along the line to its own round hole.
Nothing is left to friction.

That is also why this one tolerates a rough measurement where the brace does
not — it is the reason to reach for this instead. `slot_travel` is the whole tolerance budget, 30 mm by default, and the
render echoes the window of `post_clear_gap` it covers.

**Measuring.** The same three as the brace, same caliper sizes:

| Parameter | Measure | Caliper |
| --- | --- | --- |
| `tube_od` | Outside jaws on a vertical tube post | 6 in |
| `tube_to_edge` | A tube's outer surface out to the facing edge of its own shelf — must match what the couplers were printed with | 6 in |
| `post_clear_gap` | Inside jaws into the open space between one unit's front and back tube, at any shelf level | 12 in |

`post_clear_gap` only has to land inside the slot window, so a reading to the
nearest millimetre is plenty — the shipped 200 came off a 200.3 gap.

**Printing.** PETG, no supports. Both halves print flat with the lap face down —
the step down to the lap is a drop in height, not an overhang. The two bodies are
exported clear of each other; let the slicer arrange them. Assemble with two M4
bolts, the front half as printed and **the back half turned over**, so its lap
sits on top of the front's and the finished plate is one thickness throughout.
`bed_size` and the per-edge `bed_margin` check the back half's bounding rectangle
at 0° and 45°, counting **both** its length and width — checking the length alone
passes a half too wide for the bed, which is what a wider `shelf_gap` or a
shallower unit produces. The rectangle is a conservative stand-in for an outline
that is narrower than that everywhere along the tail, and the echoed bed
placement gives the chosen angle. One dogbone makes a pair of units rigid,
whatever the stack height.
