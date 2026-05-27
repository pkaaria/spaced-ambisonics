# EMI Sensor Build

Instructions for building the electromagnetic pickup sensors used with the spaced tetrahedral array. One sensor per channel; you need four for a complete array.

These sensors are search coils: loops of wire wound around posts on a triangular former that respond to changing magnetic fields. Connected to a balanced transformer and XLR output, they plug directly into a standard mic preamp input. No phantom power needed or wanted.

The 3D printed parts in this folder attach the finished sensor to the threaded rod of either array design. See the main [hardware README](../../README.md) for array assembly.

---

## What you are building

A **triangular search coil** with a 1:1 audio transformer and balanced XLR output. The former has ten winding posts arranged in a triangular grid: one post at each corner of the triangle, two posts along each side between the corners, and one post at the centre. Each post gets 40 turns of wire, wound in a continuous run from the first corner post through to the centre.

Four of these, mounted at the tetrahedral vertices of a spaced array and encoded with the plugin, produce a head-trackable spatial representation of the electromagnetic environment — the same rotate, decode, and binauralise workflow you would use with acoustic ambisonics.

![photo of the Alt-Azimuth array](images/EMI.png)

---

## Materials

| Part | Notes |
| ---- | ----- |
| Enamel coated copper wire, 0.2 mm | [Example: Amazon DE round copper magnetic wire 0.2 mm](https://www.amazon.de/-/en/Enamel-Round-Copper-Magnetic-0-2mm/dp/B0868H4Q8K) |
| ETAL P1200 transformer | 1:1, 600 Ω line matching transformer. Available from Farnell, Mouser, Newark. |
| XLR connector, male | Standard 3-pin |
| 3D printed former (front) | `EMI_Front.stl` from this folder |
| 3D printed back plate | `EMI_Back.stl` from this folder |
| Double-sided tape | To bond front and back pieces |
| M6 rubber nut | To attach back piece to threaded rod (same hardware as rest of array) |
| Soldering iron and solder | — |
| Heat shrink or electrical tape | For insulation on joins |

---

## The winding former

`EMI_Front.stl` is a roughly triangular plate with ten cylindrical posts. Looking at the front face:

```
         [C1]
       [S1a] [S1b]
     [C2] [M] [C3]
   [S2a] [S2b] [S3a] [S3b]

  (not to scale — triangle with 3 corners,
   2 side posts per side, 1 centre post)
```

More precisely, the ten posts are:

| Post | Position |
| ---- | -------- |
| C1 | Corner 1 |
| S1a, S1b | Two posts along the side between C1 and C2 |
| C2 | Corner 2 |
| S2a, S2b | Two posts along the side between C2 and C3 |
| C3 | Corner 3 |
| S3a, S3b | Two posts along the side between C3 and C1 |
| M | Centre post |

---

## Winding the coil

Use a single continuous length of 0.2 mm enamel copper wire for the whole coil.

**Leave a 5 cm tail of wire free at the start.** This becomes one lead; you will solder it to the transformer at the end. Hold or tape the tail to the back of the former to keep it out of the way while winding.

Wind each post in order, 40 turns clockwise, moving clockwise around the perimeter:

1. **C1** (first corner) — 40 turns clockwise
2. **S1a** — 40 turns clockwise
3. **S1b** — 40 turns clockwise
4. **C2** (next corner, clockwise) — 40 turns clockwise
5. **S2a** — 40 turns clockwise
6. **S2b** — 40 turns clockwise
7. **C3** (next corner) — 40 turns clockwise
8. **S3a** — 40 turns clockwise
9. **S3b** — 40 turns clockwise
10. **M** (centre post) — 40 turns clockwise

After the centre post, leave another 5 cm tail free. This is the second lead.

Keep winding tension consistent and the turns tight and even. 0.2 mm wire is fragile; do not pull hard enough to stretch or kink it. Pass the wire between posts along the back face of the former to keep the front face clear.

---

## Assembly: front and back pieces

`EMI_Back.stl` is a flat back plate that covers and protects the windings and carries the M6 rubber nut mount for attaching to the threaded rod.

1. Route both wire leads through the holes in the front piece to the back side.
2. Attach the back piece to the front using **double-sided tape**. Press firmly and allow to seat.
3. Both wire leads exit from the back, where you have room to work.

---

## Transformer wiring

The ETAL P1200 converts the coil's output to a balanced signal suitable for a mic preamp.

**Coil side (primary):**
- Solder one wire lead to one primary terminal.
- Solder the other wire lead to the other primary terminal.
- Polarity determines phase; as long as all four sensors in the array are wired the same way, absolute polarity does not matter. Be consistent.

**XLR side (secondary):**

| Transformer secondary | XLR pin |
| --------------------- | ------- |
| Terminal A | Pin 2 |
| Terminal B | Pin 3 |
| Shield / screen | Pin 1 (XLR end only) |

The transformer secondary **floats at the transformer end** — do not connect the shield to the transformer body or secondary winding. Shield connects to pin 1 at the XLR plug only. This keeps hum out of the signal path.

---

## Connecting to the array

Thread the M6 rubber nut on the back plate onto the M6 rod at the appropriate vertex position, following the array preset layout in the plugin [README](../../../../README.md).

Channel assignment follows the same mic numbering as the acoustic version:

| Array position | Interface channel | Plugin channel |
| -------------- | ----------------- | -------------- |
| Mic 1 | Ch 1 | Ch 1 |
| Mic 2 | Ch 2 | Ch 2 |
| Mic 3 | Ch 3 | Ch 3 |
| Mic 4 | Ch 4 | Ch 4 |

Use the per-channel trim controls in the plugin to compensate for level differences between sensors.

---

## Gain and interface settings

EMI search coils produce a low-level signal, roughly in the range of a passive dynamic microphone. Use a clean mic preamp input with phantom power **off**. Phantom power will not damage the P1200 transformer but is unnecessary and adds noise risk.

If signal is too low even at maximum gain, increase turn count on the next build (more turns = higher output voltage). If clipping, reduce turns or add a pad.

---

## Sensor orientation

The sensor is most sensitive to magnetic fields **perpendicular to the face of the former** (passing straight through it). Fields parallel to the face produce little response. In the tetrahedral array the four sensors face different directions, so the plugin can encode the field directionality spatially.

---

## Version one notes

These are hand-wound prototype sensors. Consistency between the four sensors matters; winding the same number of turns at the same tension keeps the four channels well matched. Use the per-channel trims in the plugin to compensate for any remaining differences.

A v2 design with a more repeatable winding former and integrated transformer housing is on the roadmap.

---

## Contributing variations

If you experiment with different turn counts, wire gauges, former sizes, or transformers and get results worth sharing, open a pull request with your notes added to this file. Include what changed and what effect it had on output level, frequency response, or noise floor.
