# Plugins

This folder contains the Reaper JSFX encoder and the Reaper session setup script. More plugins will be added here as the project develops.

## Contents

- [SpacedTetraEncoder](#spacedtetraencoder)
  - [What it does](#what-it-does)
  - [Install](#install)
  - [Plugin controls](#plugin-controls)
  - [Workflow in Reaper](#workflow-in-reaper)
  - [Technical notes](#technical-notes)
  - [Limitations](#limitations)

---

## SpacedTetraEncoder

`SpacedTetraEncoder.jsfx`

![screenshot of the plugin GUI](../images/Plugin.png)

### What it does

Takes four input channels (one per capsule of a spaced tetrahedral array), applies the array geometry you select, and outputs AmbiX conformant B-format from first through tenth order. Source mode flips the convention so the same array can be used either pointing outward at a scene or surrounding the listener and pointing inward.

The tenth order ceiling is intentional. Common ambisonic toolchains today (IEM, SPARTA) cap at seventh order, which is more than enough for most production work and storage budgets. The plugin supports up to tenth so the underlying technique is not the bottleneck if and when other tools catch up.

---

### Install

Drop `SpacedTetraEncoder.jsfx` into your Reaper effects folder:

- **macOS:** `~/Library/Application Support/REAPER/Effects/`
- **Windows:** `%APPDATA%\REAPER\Effects\`
- **Linux:** `~/.config/REAPER/Effects/`

In Reaper: Options > Show REAPER resource path in explorer/finder, then open the `Effects` folder.

The plugin appears in the FX browser under JS as `SpacedTetraEncoder`. Place it on a track that carries the four capsule signals on channels 1 through 4.

---

### Plugin controls

| Control | Description |
| ------- | ----------- |
| **Order** | Ambisonic order of the output. 1 through 10; channel count follows `(N+1)²`. |
| **Source Mode** | `Normal` for recording the space around the array (array points outward at the scene). `Inverse` for recording from inside the array (array surrounds the scene and points inward). |
| **Normalization** | SN3D (AmbiX default), N3D, or FuMa. Match this to the convention used by your downstream decoder. |
| **Array Preset** | Stand-Mount, Alt-Azimuth, or Custom. See [Array presets](../README.md#array-presets-and-capsule-placement) in the main README. |
| **Array Yaw / Pitch / Roll** | Pre-encoding rotation of the array. Use to correct mounting orientation so "forward" in the encoded field matches the intended forward direction. Applied before encoding, so this is geometry compensation, not head-tracking. |
| **Master Gain** | Output trim. |
| **Channel Trims (1 to 4)** | Per-capsule gain. Use to compensate for unmatched mics or pad capsules that are clipping. |
| **Channel Mutes (1 to 4)** | Per-capsule mute, useful for diagnosis. |
| **Custom AZ + EL (1 to 4)** | Capsule azimuth and elevation, only active when Array Preset is set to Custom. |

For head-tracking, place a separate rotator plugin after the encoder (IEM SceneRotator is a good reference). The pre-encoding rotation in this plugin is for fixed array orientation compensation only.

---

### Workflow in Reaper

#### Quick setup with the Lua script

`SpacedAmbisonics_Setup.lua` automates the session scaffolding. It creates four named mono input tracks routed to an ambisonics bus, sets all channel counts, adds the encoder to the bus, and opens the plugin window.

**Install the script:**

1. Copy `SpacedAmbisonics_Setup.lua` to your Reaper scripts folder:
   - **macOS:** `~/Library/Application Support/REAPER/Scripts/`
   - **Windows:** `%APPDATA%\REAPER\Scripts\`
   - **Linux:** `~/.config/REAPER/Scripts/`
2. In Reaper: Actions > Show action list > New action > Load ReaScript, then select the file.
3. Optionally assign it to a toolbar button or keyboard shortcut.

**Running the script** opens two dialogs:

1. Ambisonic order (1 through 7 for practical use; up to 10 supported).
2. Whether to arm the input tracks for recording.

The script creates:

- Four mono input tracks named **Mic 1** through **Mic 4**, assigned to hardware mono inputs 1 through 4.
- An **Ambisonics Bus** track with the correct channel count for your chosen order.
- Sends from each input track to the corresponding channel on the bus (Mic 1 to ch 1, Mic 2 to ch 2, and so on).
- Master send disabled on all input tracks.
- `SpacedTetraEncoder` added to the bus with its window open for you to set Array Preset and Source Mode.

After the script runs:

- If your interface uses different input numbers, click the input selector on each Mic track to reassign.
- Set **Array Preset** and **Source Mode** in the encoder window to match your physical setup.
- Add any per-capsule processing (EQ, high-pass, trim) to the input tracks. Keep each track mono and apply the same chain to all four.
- Add a decoder and set it to the same channel count as the bus.

#### Manual session setup

If you prefer to build the session by hand:

1. Create four mono input tracks, one per capsule. Assign each to its interface input channel and record-arm.
2. Add any input processing: EQ, high-pass filter, preamp trim, or other effects. Two rules: keep each track **mono** (no stereo wideners or mid-side processing), and apply **identical settings to all four tracks** so the spatial encoding stays coherent. Use Reaper's track templates or the SWS FX snapshot to copy the chain.
3. **Disable Master send on all four input tracks.** Right-click the master send button on each track and turn it off, or go to track routing and uncheck Master mix. Raw capsule signals sent to the master will play back as unencoded mono channels alongside the decoded output.
4. Create a track for the ambisonics bus. Set its channel count to match your target order: 4 for 1oA, 9 for 2oA, 16 for 3oA, and so on up to 121 for 10oA.
5. Route all four input tracks to the bus via track routing.
6. Insert `SpacedTetraEncoder` on the bus track.
7. Set **Array Preset** and **Source Mode** to match how you recorded.
8. Use per-channel trims or mutes as needed.
9. Route the bus to a decoder on a downstream track or the master. IEM AllRADecoder and SPARTA AmbiBIN are good starting points for speaker and binaural decoding respectively. Set the decoder track to the same channel count as the bus.

![screenshot of an example Reaper session](../images/Reaper_Session.png)

---

### Technical notes

- **Channel ordering:** ACN (AmbiX).
- **Normalisation:** SN3D by default, with N3D and FuMa selectable. FuMa is only meaningful at first order and is provided for compatibility with legacy material.
- **Maximum order:** 10. Channel counts per order follow `(N+1)²`: 4, 9, 16, 25, 36, 49, 64, 81, 100, 121 for orders 1 through 10. In current production toolchains 7 (64 channels) is the practical ceiling.
- **Sample rate:** any rate Reaper supports.
- **Latency:** zero processing latency. Encoding is sample-by-sample with no internal buffering.

---

### Limitations

- Reaper only for now. VST3, AU, and CLAP are on the roadmap.
- No internal head-tracking; pair with a downstream rotator plugin.
- No HRTF binaural rendering inside the plugin; route the encoded B-format to an external binaural decoder (IEM BinauralDecoder, SPARTA Ambi Bin, etc.).
- Formal localisation testing against coincident reference encoders is pending.
- At wider capsule spacings the spatial aliasing frequency drops; choose your array size with this in mind.
