# Hardware

3D printable mounts for spaced tetrahedral arrays, plus notes on assembly and the components you'll need to source separately.

These files are licensed under [CC-BY 4.0](../LICENSE-CC-BY-4.0). For the plugin itself, see the main [README](../README.md).

## Contents

```
hardware/
├── README.md           this file
└── stl/
    ├── alt-azimuth/    radial array, stand-mounted from the central hub
    ├── stand-mount/    open tetrahedron, stand-mounted via the Mic 3 piece
    └── grippers/
        ├── clippy-em272z1/    for acoustic recording with Clippy EM272Z1 capsules
        └── emi-mic/           for electromagnetic field recording
```

A detailed print and build guide will be added here later. Until then this README covers enough to get a working array on a stand.

---

## The two array designs

Both designs mount on a standard microphone stand, but the geometries and use cases are different.

### Alt-Azimuth (radial, outside-array only)

A central 3D printed hub piece sits on top of the stand. Four M6 threaded rods thread into the hub and radiate outward in the right-hand-rule tetrahedral pattern. Each rod terminates in a gripper that holds a capsule.

- **Use case:** recording the space around the array. The array sits in the room and looks outward at the scene.
- **Source mode in plugin:** `Normal`.
- **Robustness:** the load is distributed across four rods meeting at a solid hub. Sturdier than the Stand-Mount design and the more forgiving choice for travel or field work.
- **Limitation:** the radial layout fills the centre of the array, so there is no usable interior space. This design cannot be used for inside-array (inverse) recording.
- **Array spacing:** determined by the length of the threaded rods. Cut them to your desired spacing. A length-adjustable redesign (so spacing can be changed without cutting new rods) is planned for v2.

### Stand-Mount (open tetrahedron, inside or outside)

The Mic 3 piece sits at the bottom of the assembly and carries the stand-mount thread. The tetrahedron *builds upward* from the Mic 3 piece: aluminium rods connect the Mic 3 vertex to three upper vertex pieces, and additional rods connect the upper vertices to each other, forming the three upper edges of the tetrahedron. Mics 1, 2, and 4 sit on the upper vertices following the right-hand-rule layout (back/left, forward, and back/right respectively).

The interior of the tetrahedron is hollow, which is what makes the inverse use case physically possible: you can place a source (a person, an instrument, a vibrating object) inside the array and record from four surrounding directions at once.

- **Use case:** either recording the space around the array (outside-array) *or* recording a source placed inside the array (inside-array).
- **Source mode in plugin:** `Normal` for outside-array, `Inverse` for inside-array.
- **Robustness:** the tetrahedron is held together at the vertices by relatively thin aluminium rods, so this design is more fragile than the Alt-Azimuth and needs more care in handling.
- **Array spacing:** determined by the length of the aluminium tube sections. A design that allows easy spacing adjustment without cutting new tubes is planned for v2.

---

## Microphone options

The gripper end pieces are separable from the rod-mount pieces, so the same array geometry can be used with different sensors. Two gripper variants are currently included.

### Acoustic recording: Clippy EM272Z1

The default acoustic option. Grippers are sized for the **Clippy EM272Z1**, the small omnidirectional Primo capsule used in Micbooster's Clippy XLR series, including their 4-matched set. Omnis are a natural fit for spaced ambisonic capture because directional information comes from inter-capsule time and level differences rather than from the capsules' own directivity.

STLs are in [`stl/grippers/clippy-em272z1/`](stl/grippers/clippy-em272z1/).

### Electromagnetic recording: EMI sensors

The same array geometries can be used with electromagnetic interference (EMI) sensors in place of acoustic capsules. STLs for EMI sensor grippers are in [`stl/grippers/emi-mic/`](stl/grippers/emi-mic/).

This opens the technique to **spatial electromagnetic field recording**: encoding the directionality of EM fields into ambisonic B-format, then rotating, decoding, or binauralising the result with the same plugin chain you'd use for acoustic ambisonics. The encoder doesn't care whether the four input signals come from pressure capsules or EM pickups; the geometry-driven encoding works identically either way.

Practical uses include capturing the EM signatures of electronics, motors, power infrastructure, and architectural spaces as spatial, head-trackable recordings rather than mono curiosities. To the project's knowledge this is the first published spatial EMI recording workflow built around an ambisonic pipeline.

### Other microphones

Because the gripper is a separate part, supporting a new microphone only requires designing a new gripper, not a new array. If you have CAD experience and a microphone you want to use, contributions are welcome. See [Swappable gripper concept](#swappable-gripper-concept) below.

---

## What you'll need to source separately

### Alt-Azimuth array

| Part | Purpose | Reference |
| ---- | ------- | --------- |
| M6 threaded rod, cut to length | Spokes from hub to capsule grippers | Any hardware store |
| Rubber nut set M6 | Secure the rods and grippers | [Motonet DZ Hardware M6 6-pack](https://www.motonet.fi/tuote/dz-hardware-kumimutterisarja-m6-6kpl?product=38-1504) |
| KM 217 5/8" to 3/8" thread adapter | Mic stand connection | [Thomann KM 217](https://www.thomann.de/fi/km_217_reduziergewinde.htm) |
| Clippy EM272Z1 capsules or EMI sensors | Audio/EM capture | — |
| 4 channel audio interface | Recording | — |

### Stand-Mount array

| Part | Purpose | Reference |
| ---- | ------- | --------- |
| Aluminium tube 8 × 1 mm, cut to length | Tetrahedron edges | [Puuilo Warma anodised aluminium tube 8×1mm 2m](https://www.puuilo.fi/warma-alumiiniputki-anodisoitu-8x1mm-2m) |
| M6 threaded rod, short sections | Holder to gripper connection | Any hardware store |
| Rubber nut set M6 | Secure connections | [Motonet DZ Hardware M6 6-pack](https://www.motonet.fi/tuote/dz-hardware-kumimutterisarja-m6-6kpl?product=38-1504) |
| KM 217 5/8" to 3/8" thread adapter | Mic stand connection | [Thomann KM 217](https://www.thomann.de/fi/km_217_reduziergewinde.htm) |
| Clippy EM272Z1 capsules or EMI sensors | Audio/EM capture | — |
| 4 channel audio interface | Recording | — |

The reference links above are Finnish suppliers; equivalent parts are available from any hardware or music equipment supplier.

---

## Print settings

The reference build was printed on a **Flashforge Finder 2.0** (14 × 14 × 14 cm build volume). Anything that size or larger will fit the parts.

Material and starting settings:

- **Filament:** PETG. PLA will print but is more brittle in thin sections; ABS or ASA would be more durable but introduce shrinkage and warp.
- **Layer height:** 0.2 mm is a reasonable starting point.
- **Walls / perimeters:** 4 minimum on the gripper and hub parts. These pieces carry the structural load.
- **Infill:** 30 to 50 percent.
- **Supports:** depends on part orientation in your slicer. Most pieces can be oriented to avoid supports entirely.

These are starting points, not final tuned settings. If you find a configuration that prints reliably and survives field use, please open a pull request adding your notes to this README.

---

## Version one caveat

These mounts are proof of concept parts. They work, they have been used in real sessions, and they are good enough to start recording with. They are *not* finished objects.

- Wall thicknesses and stress relief are not yet tuned. Even in PETG, small drops can crack the parts.
- The Stand-Mount design especially relies on thin connecting rods and should be handled gently.
- Array spacing currently requires cutting rods or tubes to length. A length-adjustable design for both arrays is on the roadmap for v2.
- A v2 redesign focused on durability, assembly ergonomics, and easier spacing adjustment is planned.

Treat the current parts as a starting point. If you build with them, please feed back what breaks and how, so the v2 designs can address real failure modes rather than guessed ones.

---

## Swappable gripper concept

The piece that holds the sensor is separable from the piece that mounts to the rod or hub. This means a different sensor can be supported by designing only a new gripper, without redesigning the rest of the structure. The Clippy EM272Z1 and EMI sensor grippers in this repository are the first two examples.

If you have CAD experience and a different sensor you want to use, contributions are welcome. Open a pull request with:

- The new gripper STL (and source file if you can share it).
- A short note in this README listing which sensor the gripper fits.
- Photos of the printed and assembled part if possible.

The aim is to make the array geometries usable across whatever capsules or sensors people already own, rather than requiring everyone to converge on one specific microphone.

---

## Coming later

- STLs for 8 capsule and 16 capsule spaced arrays (second and third order).
- v2 redesigns of both current arrays with easier spacing adjustment.
- Reference build guide with photos, full bill of materials, and tuned print settings.
- A small community library of gripper end pieces for additional capsules and sensors.
