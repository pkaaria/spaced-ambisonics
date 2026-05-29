-- SpacedAmbisonics_Setup.lua
-- One-click session setup for Spaced Ambisonics recording in Reaper.
--
-- Creates 4 named input tracks and an ambisonics bus track, sets channel
-- counts, routes each input to the correct channel on the bus, disables
-- master send on input tracks, assigns hardware inputs 1-4 as mono, adds
-- SpacedTetraEncoder to the bus, and configures it to match your choices.
--
-- Install: copy to your Reaper Scripts folder, then add via
--   Actions > Show action list > New action > Load ReaScript

-- -----------------------------------------------------------------------
-- JSFX plugin name — must match the desc: line in the .jsfx file exactly
-- -----------------------------------------------------------------------
local PLUGIN_NAME = "Spaced Tetrahedral Ambisonic Encoder 10oA"

-- -----------------------------------------------------------------------
-- Parameter indices (JSFX sliders exposed in order, skipped numbers
-- do not create gaps in the param list)
-- slider1  s_order  -> param 0
-- slider2  s_invert -> param 1
-- slider3  s_norm   -> param 2
-- slider4  s_array  -> param 3
-- -----------------------------------------------------------------------
local PARAM_ORDER  = 0
local PARAM_INVERT = 1
local PARAM_ARRAY  = 3

-- -----------------------------------------------------------------------
-- Reaper mono input encoding: mono input N (1-indexed) = (N-1) | 1024
-- -----------------------------------------------------------------------
local function mono_input(n)
  return (n - 1) | 1024
end

-- -----------------------------------------------------------------------
-- Mic names per preset (0=Pyramid, 1=Star)
-- -----------------------------------------------------------------------
local MIC_NAMES = {
  [0] = {  -- Pyramid
    "Mic 1  |  Thumb   |  Back-Left-Up",
    "Mic 2  |  Index   |  Forward-Up",
    "Mic 3  |  Middle  |  Straight Down  (stand mount)",
    "Mic 4  |  Ring    |  Back-Right-Up",
  },
  [1] = {  -- Star
    "Mic 1  |  Thumb   |  Back-Up",
    "Mic 2  |  Index   |  Forward-Up",
    "Mic 3  |  Middle  |  Right-Down",
    "Mic 4  |  Ring    |  Left-Down",
  },
}

-- -----------------------------------------------------------------------
-- Step 1: Order
-- -----------------------------------------------------------------------
local retval1, order_str = reaper.GetUserInputs(
  " -: Spaced Ambisonics Setup (1/3) :- |  1=4ch  2=9ch  3=16ch  4=25ch  5=36ch  6=49ch  7=64ch",
  1,
  "Order (1-7):,extrakeywords",
  "3"
)
if not retval1 then return end

local order = tonumber(order_str)
if not order or order < 1 or order > 7 or math.floor(order) ~= order then
  reaper.ShowMessageBox("Please enter a whole number between 1 and 7.", "Invalid", 0)
  return
end

local num_channels = (order + 1) * (order + 1)

-- -----------------------------------------------------------------------
-- Step 2: Preset and source mode
-- -----------------------------------------------------------------------
local retval2, csv = reaper.GetUserInputs(
  "-: Spaced Ambisonics Setup (2/3) :-",
  2,
  "Preset  (1=Pyramid  2=Star):,Source  (1=Normal  2=Inverse):,extrakeywords",
  "1,1"
)
if not retval2 then return end

local preset_str, mode_str = csv:match("^([^,]+),(.+)$")
local preset_num = tonumber(preset_str)
local mode_num   = tonumber(mode_str)

if not preset_num or (preset_num ~= 1 and preset_num ~= 2) then
  reaper.ShowMessageBox("Preset must be 1 (Pyramid) or 2 (Star).", "Invalid", 0)
  return
end
if not mode_num or (mode_num ~= 1 and mode_num ~= 2) then
  reaper.ShowMessageBox("Source mode must be 1 (Normal) or 2 (Inverse).", "Invalid", 0)
  return
end

-- Convert to 0-indexed values matching the JSFX slider ranges
-- JSFX s_array: 0=Stand-Mount(Pyramid), 1=Alt-Azimuth(Star)
local array_idx    = preset_num - 1
local invert_val   = mode_num - 1
local mic_names    = MIC_NAMES[array_idx]
local preset_label = array_idx == 0 and "Pyramid" or "Star"
local mode_label   = invert_val == 0 and "Normal" or "Inverse"

-- -----------------------------------------------------------------------
-- Step 3: Arm input tracks
-- -----------------------------------------------------------------------
local retval3, arm_str = reaper.GetUserInputs(
  "-: Spaced Ambisonics Setup (3/3) :-",
  1,
  "Arm tracks?  (1=Yes  2=No):,extrakeywords",
  "2"
)
if not retval3 then return end

local arm_num = tonumber(arm_str)
if not arm_num or (arm_num ~= 1 and arm_num ~= 2) then
  reaper.ShowMessageBox("Please enter 1 (No) or 2 (Yes).", "Invalid", 0)
  return
end

local arm_tracks = arm_num == 1

-- -----------------------------------------------------------------------
-- Build the session
-- -----------------------------------------------------------------------
reaper.Undo_BeginBlock()

local project  = 0
local ins_base = reaper.CountTracks(project)

-- 4 input tracks
local input_tracks = {}
for i = 1, 4 do
  reaper.InsertTrackAtIndex(ins_base + i - 1, true)
  local track = reaper.GetTrack(project, ins_base + i - 1)

  reaper.GetSetMediaTrackInfo_String(track, "P_NAME", mic_names[i], true)
  reaper.SetMediaTrackInfo_Value(track, "I_NCHAN", 2)
  reaper.SetMediaTrackInfo_Value(track, "I_RECINPUT", mono_input(i))
  reaper.SetMediaTrackInfo_Value(track, "I_RECMODE", 1)

  if arm_tracks then
    reaper.SetMediaTrackInfo_Value(track, "I_RECARM", 1)
  end

  -- No send to master; these tracks feed the ambi bus only
  reaper.SetMediaTrackInfo_Value(track, "B_MAINSEND", 0)

  input_tracks[i] = track
end

-- Ambisonics bus track
local bus_pos = ins_base + 4
reaper.InsertTrackAtIndex(bus_pos, true)
local ambi_track = reaper.GetTrack(project, bus_pos)

reaper.GetSetMediaTrackInfo_String(ambi_track, "P_NAME",
  string.format("Ambisonics Bus  |  %doA  |  %d ch  |  %s  |  %s",
    order, num_channels, preset_label, mode_label),
  true)
reaper.SetMediaTrackInfo_Value(ambi_track, "I_NCHAN", num_channels)

-- Route each input track ch 1/2 to a single mono channel on the bus
-- I_SRCCHAN = 0 (stereo pair 1/2 from source track)
-- I_DSTCHAN = (i-1) + 1024 (mono destination channel, 1024 = mono flag)
for i = 1, 4 do
  local send_idx = reaper.CreateTrackSend(input_tracks[i], ambi_track)
  reaper.SetTrackSendInfo_Value(input_tracks[i], 0, send_idx, "I_SRCCHAN", 0)
  reaper.SetTrackSendInfo_Value(input_tracks[i], 0, send_idx, "I_DSTCHAN", (i - 1) + 1024)
  reaper.SetTrackSendInfo_Value(input_tracks[i], 0, send_idx, "D_VOL", 1.0)
end

-- Master track channel count
local master = reaper.GetMasterTrack(project)
reaper.SetMediaTrackInfo_Value(master, "I_NCHAN", num_channels)

-- -----------------------------------------------------------------------
-- Add and configure SpacedTetraEncoder on the ambisonics bus
-- -----------------------------------------------------------------------
local fx_idx = reaper.TrackFX_AddByName(ambi_track, PLUGIN_NAME, false, -1)

if fx_idx >= 0 then
  reaper.TrackFX_SetParam(ambi_track, fx_idx, PARAM_ORDER,  order - 1)
  reaper.TrackFX_SetParam(ambi_track, fx_idx, PARAM_ARRAY,  array_idx)
  reaper.TrackFX_SetParam(ambi_track, fx_idx, PARAM_INVERT, invert_val)
  reaper.TrackFX_Show(ambi_track, fx_idx, 3)
end

reaper.Undo_EndBlock("Spaced Ambisonics Setup", -1)
reaper.UpdateArrange()
reaper.TrackList_AdjustWindows(false)

-- -----------------------------------------------------------------------
-- Summary
-- -----------------------------------------------------------------------
local plugin_line = fx_idx >= 0
  and "SpacedTetraEncoder added and configured."
  or  "Plugin not found — install SpacedTetraEncoder.jsfx and add manually."

reaper.ShowMessageBox(
  string.format(
    "Setup complete.\n\n"..
    "Order:        %doA  (%d channels)\n"..
    "Preset:       %s\n"..
    "Source mode:  %s\n"..
    "Plugin:       %s\n\n"..
    "Input tracks are assigned to hardware mono inputs 1-4.\n"..
    "If your interface uses different channel numbers, click\n"..
    "the input selector on each Mic track to reassign.\n\n"..
    "Remaining steps:\n\n"..
    "1. Add a decoder after the bus or on the master:\n"..
    "   IEM AllRADecoder (speakers) or SPARTA AmbiBIN (binaural)\n\n"..
    "2. Set that decoder track to %d channels.\n"..
    "   Left-click the channel count shown next to the track name.",
    order, num_channels, preset_label, mode_label, plugin_line, num_channels),
  "Spaced Ambisonics — Done",
  0
)
