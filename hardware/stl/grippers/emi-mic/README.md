# EMI Sensor Build

Instructions for building the electromagnetic pickup sensors used with the spaced tetrahedral array. One sensor per channel; you need four for a complete array.

These sensors are search coils: loops of wire wound around a square former that respond to changing magnetic fields. Connected to a balanced transformer and XLR output, they plug directly into a standard mic preamp input. No phantom power needed or wanted.

The 3D printed parts in this folder (the gripper) attach the finished sensor to the threaded rod of either array design. See the main [hardware README](../../README.md) for array assembly.

---

## What you are building

A **square search coil** with a 1:1 audio transformer and balanced XLR output. The coil picks up changing electromagnetic fields in the plane of the square. Winding coils around each corner section and across the centre gives the sensor sensitivity to field variations across its face rather than just a single average.

Four of these, mounted at the tetrahedral vertices of a spaced array and encoded with the plugin, produce a head-trackable spatial representation of the electromagnetic environment — the same rotate, decode, and binauralise workflow you would use with acoustic ambisonics.

---

## Materials

| Part | Notes |
| ---- | ----- |
| Enamel coated copper wire, 0.2 mm | [Example: Amazon DE round copper magnetic wire 0.2 mm](https://www.amazon.de/-/en/Enamel-Round-Copper-Magnetic-0-2mm/dp/B0868H4Q8K) |
| Audio transformer 600:600 Ω | Reference: ETAL 600/600 or equivalent 1:1 600 Ω audio transformer |
| XLR connector, male | Standard 3-pin |
| The 3D printed former | `EMI_Front.stl` and `EMI_Back.stl` from this folder |
| Double-sided tape | To bond front and back pieces |
| M6 rubber nut | To attach back piece to threaded rod (same as rest of array) |
| Soldering iron and solder | — |
| Heat shrink or electrical tape | Insulation on joins |

---

## Winding the coil

The printed front piece (`EMI_Front.stl`) is the coil former. It has a square perimeter with defined corner sections and a centre post.

**Leave a 5 cm tail of wire free at the start.** This becomes one lead of the coil; you will solder it to the transformer at the end.

Wind each section as follows, working clockwise around the perimeter:

1. **Corner 1:** 40 turns clockwise around the corner section.
2. **Corner 2 (next clockwise corner):** 40 turns clockwise.
3. **Corner 3:** 40 turns clockwise.
4. **Corner 4:** 40 turns clockwise.
5. **Centre section:** 40 turns around the centre post.

Keep winding tension consistent and the turns tight and even. The wire is 0.2 mm so it is fragile; do not pull hard enough to stretch or kink it.

When done, leave another 5 cm tail free. This is the second lead.

You now have two leads coming from the coil: the starting tail and the finishing tail.

---

## Assembly: front and back pieces

The back piece (`EMI_Back.stl`) serves two purposes: it covers and protects the coil windings, and it carries the M6 rubber nut mount that attaches the sensor to the threaded rod.

1. Route both wire leads through the holes in the front piece to the back side.
2. Attach the back piece to the front using **double-sided tape**. Press firmly and allow to seat.
3. The two wire leads should now exit from the back, where you have room to work.

---

## Transformer wiring

The transformer converts the high-impedance unbalanced coil output to a balanced low-impedance signal suitable for a mic preamp input.

**Coil side (primary):**
- Solder one wire lead to one primary terminal.
- Solder the other wire lead to the other primary terminal.
- Polarity determines phase; as long as all four sensors in the array are wired the same way, absolute polarity does not matter.

**XLR side (secondary):**

| Transformer secondary | XLR pin |
| --------------------- | ------- |
| Terminal A            | Pin 2   |
| Terminal B            | Pin 3   |
| Shield / screen       | Pin 1 (XLR end only) |

The transformer secondary **floats at the transformer end** — do not connect the shield to the transformer chassis or secondary winding. The shield connects to pin 1 at the XLR connector only. This is standard practice for a balanced EMI pickup and keeps hum out of the signal path.

---

## Connection to the array

The back piece has the same M6 rubber nut attachment as the rest of the array hardware. Thread it onto the M6 rod at the appropriate vertex position following the array preset layout described in the main plugin [README](../../../../README.md).

Connect each sensor to one channel of your audio interface. Channel assignment follows the same mic numbering as the acoustic version:

| Array position | Interface channel | Plugin channel |
| -------------- | ----------------- | -------------- |
| Mic 1          | Ch 1              | Ch 1           |
| Mic 2          | Ch 2              | Ch 2           |
| Mic 3          | Ch 3              | Ch 3           |
| Mic 4          | Ch 4              | Ch 4           |

Set input gain to match signal levels across all four sensors. The channel trim controls in the plugin can compensate for small differences between sensors.

---

## Interface and gain settings

EMI search coils produce a low-level signal, typically in the range of a dynamic microphone or lower depending on field strength. Use a clean mic preamp input with no phantom power. Phantom power will not damage the transformer but it is unnecessary and adds noise risk through any wiring imperfection.

If the signal is too low even at maximum gain, you can increase the number of turns (more turns = higher output voltage, higher impedance). If it is too high and clipping, reduce turns or add a pad.

---

## Notes on sensor orientation

The sensor is most sensitive to magnetic fields **perpendicular to the plane of the coil** (passing through the face of the square). Fields parallel to the coil face produce little response. This is analogous to how a figure-eight microphone has a null axis.

In the tetrahedral array, the four sensors are oriented at the tetrahedral angles, so their sensitive axes point in four different directions. The plugin encodes the differences between them spatially, the same way it does for acoustic capsules.

---

## Version one notes

These are hand-wound prototype sensors. Winding consistency between sensors affects matching. If one channel is significantly louder or quieter than the others, use the per-channel trim in the plugin to compensate.

A v2 sensor design with a more repeatable winding former and a cleaner back-plate with integrated transformer mounting is on the roadmap.

---

## Contributing variations

If you experiment with different:

- Turn counts
- Wire gauges
- Former sizes
- Transformers

and get results worth sharing, open a pull request with your notes added to this file. Include what you changed and what effect it had on output level, frequency response, or noise floor if you measured them.
