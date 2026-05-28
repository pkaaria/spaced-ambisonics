-- SpacedAmbisonics_Setup.lua
-- One-click session setup for Spaced Ambisonics recording in Reaper.
--
-- Creates 4 named input tracks and an ambisonics bus track, sets channel
-- counts, routes each input to the correct channel on the bus, disables
-- master send on input tracks, assigns hardware inputs 1-4 as mono, and
-- adds SpacedTetraEncoder to the bus.
--
-- Install: copy to your Reaper Scripts folder, then add via
--   Actions > Show action list > New action > Load ReaScript

-- -----------------------------------------------------------------------
-- JSFX plugin name — must match the desc: line in the .jsfx file exactly
-- -----------------------------------------------------------------------
local PLUGIN_NAME = "Spaced Tetrahedral Ambisonic Encoder 10oA"

-- -----------------------------------------------------------------------
-- Reaper mono input encoding: mono input N (1-indexed) = (N-1) | 1024
-- -----------------------------------------------------------------------
local function mono_input(n)
  return (n - 1) | 1024
end

-- -----------------------------------------------------------------------
-- Step 1: Order
-- -----------------------------------------------------------------------
local retval1, order_str = reaper.GetUserInputs(
  "Spaced Ambisonics Setup (1/2)  |  1=4ch  2=9ch  3=16ch  4=25ch  5=36ch  6=49ch  7=64ch",
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
-- Step 2: Arm input tracks
-- -----------------------------------------------------------------------
local retval2, arm_str = reaper.GetUserInputs(
  "Spaced Ambisonics Setup (2/2)",
  1,
  "Arm tracks? (1=No 2=Yes):,extrakeywords",
  "1"
)
if not retval2 then return end

local arm_num = tonumber(arm_str)
if not arm_num or (arm_num ~= 1 and arm_num ~= 2) then
  reaper.ShowMessageBox("Please enter 1 (No) or 2 (Yes).", "Invalid", 0)
  return
end

local arm_tracks = arm_num == 2

-- -----------------------------------------------------------------------
-- Build the session
-- -----------------------------------------------------------------------
reaper.Undo_BeginBlock()

local project  = 0
local ins_base = reaper.CountTracks(project)

-- 4 input tracks, each recording hardware mono input N
local input_tracks = {}
for i = 1, 4 do
  reaper.InsertTrackAtIndex(ins_base + i - 1, true)
  local track = reaper.GetTrack(project, ins_base + i - 1)

  reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "Mic " .. i, true)

  -- 2 channels (Reaper minimum; each track records a single mono source)
  reaper.SetMediaTrackInfo_Value(track, "I_NCHAN", 2)

  -- Assign hardware input i as mono
  -- mono_input(1)=1024, mono_input(2)=1025, mono_input(3)=1026, mono_input(4)=1027
  reaper.SetMediaTrackInfo_Value(track, "I_RECINPUT", mono_input(i))

  -- Record mode 1 = record input
  reaper.SetMediaTrackInfo_Value(track, "I_RECMODE", 1)

  -- Arm if requested
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
  string.format("Ambisonics Bus  |  %doA  |  %d ch", order, num_channels),
  true)
reaper.SetMediaTrackInfo_Value(ambi_track, "I_NCHAN", num_channels)

-- Route each input track to its channel on the bus
-- Mic 1 -> channel 1, Mic 2 -> channel 2, etc.
for i = 1, 4 do
  local send_idx = reaper.CreateTrackSend(input_tracks[i], ambi_track)
  reaper.SetTrackSendInfo_Value(input_tracks[i], 0, send_idx, "I_SRCCHAN", 0)
  reaper.SetTrackSendInfo_Value(input_tracks[i], 0, send_idx, "I_DSTCHAN", i - 1)
  reaper.SetTrackSendInfo_Value(input_tracks[i], 0, send_idx, "D_VOL", 1.0)
end

-- Master track channel count
local master = reaper.GetMasterTrack(project)
reaper.SetMediaTrackInfo_Value(master, "I_NCHAN", num_channels)

-- -----------------------------------------------------------------------
-- Add SpacedTetraEncoder to the ambisonics bus and open its window
-- -----------------------------------------------------------------------
local fx_idx = reaper.TrackFX_AddByName(ambi_track, PLUGIN_NAME, false, -1)
if fx_idx >= 0 then
  reaper.TrackFX_Show(ambi_track, fx_idx, 3)
end

reaper.Undo_EndBlock("Spaced Ambisonics Setup", -1)
reaper.UpdateArrange()
reaper.TrackList_AdjustWindows(false)

-- -----------------------------------------------------------------------
-- Summary
-- -----------------------------------------------------------------------
local plugin_line = fx_idx >= 0
  and "SpacedTetraEncoder added — configure preset and source mode in the plugin window."
  or  "Plugin not found — install SpacedTetraEncoder.jsfx and add manually."

reaper.ShowMessageBox(
  string.format(
    "Setup complete.\n\n"..
    "Order:   %doA  (%d channels)\n"..
    "Plugin:  %s\n\n"..
    "Input tracks are assigned to hardware mono inputs 1-4.\n"..
    "If your interface uses different channel numbers, click the\n"..
    "input selector on each Mic track to reassign.\n\n"..
    "Remaining steps:\n\n"..
    "1. Add a decoder after the bus or on the master:\n"..
    "   IEM AllRADecoder (speakers) or SPARTA AmbiBIN (binaural)\n\n"..
    "2. Set that decoder track to %d channels.\n"..
    "   Left-click the channel count shown next to the track name.",
    order, num_channels, plugin_line, num_channels),
  "Spaced Ambisonics — Done",
  0
)
