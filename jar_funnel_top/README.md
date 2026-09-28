<!--
SPDX-FileCopyrightText: 2026 Todd Sayre
SPDX-License-Identifier: CC-BY-4.0
-->

# Jar funnel top

A printed funnel that screws onto a wide-mouth plastic jar in place of its lid,
turning the jar into a benchtop bin for the printer bench: purge poop, brims,
support scraps, trimmed filament ends. It replaces an orange juice bottle with
its top cut off. Not yet modelled — this file holds the design decisions, how to
work out the thread, and the measurements still to take.

The rim is meant to stand a little proud of the jar's neck, or to run out flush
with the jar body, so the cap reads as a finished part of the jar rather than
something wedged into it.

## The jar

The candidate is the Amazon Grocery 40 oz Mini Twist Pretzels canister: clear
PET, a short threaded neck, a black screw cap. Its listing gives 7.07 × 7.07 ×
11.78 in (about 180 × 180 × 299 mm) overall, which is the jar's widest point
and its height with the cap on. It says nothing about the neck.

**Working assumption: a 110-400 neck finish.** Similar 40 oz snack canisters are
sold with 110-400 lids, and 110-400 is the usual finish on PET canisters this
size. That is a guess from similar products, not a measurement, and the model
does not start until the jar confirms it (see below).

## Neck finishes, and why this is not guess and check

Plastic jar necks are nearly all built to the GPI/SPI neck-finish standard, and
the lid is made to fit the standard, not the jar. A finish is named
`<T>-<style>`:

- **T** is the outside diameter across the thread crests, in millimetres —
  `110-400` is nominally 110 mm across.
- **The style** fixes the thread form and how much of it there is. `400` is the
  common jar finish: a single start, roughly one full turn, with a shallow
  modified-buttress profile. `410` and `415` are taller finishes with more
  turns.

So the job is to identify the finish, then take the dimensions calipers cannot
reach from a published chart rather than measuring them. Guess and check is
reserved for the one thing a chart cannot tell you: how much clearance this
printer needs around the thread.

### Identifying it

1. **Look for markings** inside the cap, on the jar's base, and on the neck.
   Molders often stamp the finish, or at least the size.
2. **Measure T** across the thread crests. It should land within about 1 mm of
   a standard size — 83, 89, 100, 110, 120 and so on.
3. **Measure the pitch.** Use a thread gauge if one is to hand. Otherwise lay a
   rule along the neck and count crests over 25 mm, or roll the neck over
   masking tape and measure the impressions. Wide-mouth finishes are coarse, so
   expect somewhere around 5 or 6 threads per inch; the chart has the exact
   figure.
4. **Count the thread starts** at the top edge of the neck. One is the `400`
   family. Two to four short threads is a lug or multi-start finish, which this
   design does not cover — pick a different jar rather than model one.
5. **Look the finish up in a GPI chart.** Container suppliers publish them. It
   gives the root diameter **E**, which calipers cannot reach from outside the
   thread, and the neck height **H** and thread start **S**, along with the
   thread profile.

T and the pitch are the two numbers that identify the finish; everything else
comes from the chart. That is this repository's caliper rule applied as usual —
never ask for a dimension inside a solid, derive it.

### Tuning the fit

The model will carry a radial clearance knob and a test mode that prints only
the threaded collar, 10–12 mm tall, in about 20 minutes. Print the ring, screw
it on, adjust the clearance, and reprint until it runs on smoothly without
rocking. On an A1 expect somewhere around 0.3–0.5 mm. Only then print the full
funnel.

## Measurements needed

- [ ] Markings on the cap, base, or neck
- [ ] **T**, outside diameter across the thread crests — 6 in caliper
- [ ] Pitch, as threads per 25 mm or per inch — thread gauge or rule
- [ ] Number of thread starts — by eye
- [ ] Neck bore, the clear opening at the lip — 6 in caliper, inside jaws
- [ ] Lip to shoulder, the height the cap skirt can use — 6 in caliper,
      depth rod
- [ ] Jar body outside diameter just below the shoulder — 8 in caliper. Only
      needed if the rim is to run out flush with the jar body.

## Fitting the A1

The A1's build volume is 256 × 256 × 256 mm. The thread is small against that;
the funnel is what grows.

**The flare is capped at 45° from vertical**, like every sloped face here. A
funnel printed the way it is used, widening upward, is one continuous overhang,
so its angle is fixed by construction rather than chosen: the rim diameter grows
by twice the flare height. That makes the arithmetic simple:

```text
rim_d = base_d + 2 * flare_h
```

Here `base_d` is the diameter the flare starts from, the outside of the cap
skirt.

Assuming a 110-400 neck, a cap skirt of about 118 mm outside, and a rim flush
with the 180 mm jar body, the flare rises about 31 mm. Even a rim near the bed
limit, about 230 mm, needs only about 56 mm of flare. The whole part stays well
under 100 mm tall and fits the bed with room to spare, so the jar size is not
limited by the printer. A 1-gallon canister with a 120-400 neck would fit too.

## Design constraints to carry into the model

- **Print orientation:** as used, skirt down on the plate and funnel flaring
  upward. It needs no supports if the next three points hold.
- **Flare** at 45°, written so the radial run equals the rise, with a wall of
  constant thickness. That makes the inside and the outside of the cone equally
  self-supporting.
- **Internal thread** with its downward-facing flank at 45° or steeper. The
  standard `400` profile is close to that already, and modelling it exactly at
  45° costs nothing in fit.
- **The seat on the neck lip** is where the funnel's cone meets the skirt, and
  it must not become a flat ring bridging from the skirt's inside down to the
  throat. Carry the cone down to the lip at 45° so the cap seats on a conical
  shoulder.
- **Throat** no smaller than the neck bore, so nothing hangs up where the funnel
  meets the jar.
- **Rim** chamfered rather than rounded, and a knob for how far it stands proud
  of the skirt — from a slight lip up to flush with the jar body.
- **One source, one body.** The cap and the funnel are one printed part.

## Open questions

- Whether the rim should stand just proud of the neck or run out flush with the
  jar body. Flush reads as more finished, but a larger rim is more to print.
- Whether the throat wants a lip or a slight inward roll to stop a full jar
  from spilling back out when it is carried. That would be an overhang, so if
  it is wanted it has to be designed at 45° too.
