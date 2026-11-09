-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- macOS-style deletion. Terminals use their normal shell editing chords.
local function mac_delete_is_terminal()
  local window = hl.get_active_window()
  for _, tag in ipairs(window and window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then return true end
  end
  return false
end

-- Explicit press/release avoids send_shortcut's synthetic-key repeat issue.
local function mac_delete_send(sequence, index)
  index = index or 1
  local chord = sequence[index]
  if not chord then return end
  hl.dispatch(hl.dsp.send_key_state({ mods = chord[1], key = chord[2], state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = chord[1], key = chord[2], state = "up" }))
    mac_delete_send(sequence, index + 1)
  end, { timeout = 20, type = "oneshot" })
end

o.bind("ALT + BACKSPACE", "Delete previous word", function()
  if mac_delete_is_terminal() then
    mac_delete_send({ { "CTRL", "W" } })
  else
    mac_delete_send({ { "CTRL", "BackSpace" } })
  end
end)

-- Replaces Omarchy's toggle-window-transparency shortcut.
o.rebind("SUPER + BACKSPACE", "Delete to start of line", function()
  if mac_delete_is_terminal() then
    mac_delete_send({ { "CTRL", "U" } })
  else
    mac_delete_send({ { "SHIFT", "Home" }, { "", "BackSpace" } })
  end
end)

-- macOS-style horizontal navigation, including Shift to select.
-- SUPER arrows previously focused windows; SUPER SHIFT arrows swapped them.
for _, direction in ipairs({
  { key = "LEFT", word = "Left", line = "Home", label = "start" },
  { key = "RIGHT", word = "Right", line = "End", label = "end" },
}) do
  for _, selecting in ipairs({ false, true }) do
    local shift = selecting and "SHIFT + " or ""
    local action = selecting and "Select to " or "Move to "
    local word_mods = selecting and "CTRL SHIFT" or "CTRL"
    local line_mods = selecting and "SHIFT" or ""
    local word_key, line_key = direction.word, direction.line
    o.rebind("ALT + " .. shift .. direction.key,
      action .. direction.label .. " of word", function()
        mac_delete_send({ { word_mods, word_key } })
      end, { repeating = true })
    o.rebind("SUPER + " .. shift .. direction.key,
      action .. direction.label .. " of line", function()
        mac_delete_send({ { line_mods, line_key } })
      end, { repeating = true })
  end
end

-- Two quick Space taps insert a period and a trailing space.
-- Ordinary spaces pass through; explicit down/up pairs avoid stuck keys.
local mac_space_time = nil
local mac_space_now = 0
local mac_space_generation = 0
local function mac_space_reset()
  mac_space_time = nil
  mac_space_generation = mac_space_generation + 1
end
hl.on("input.keyboard.key", function(keycode, time_ms, state)
  if state ~= 1 then return end
  mac_space_now = time_ms
  if keycode ~= 65 then mac_space_reset() end -- XKB Space
end)
hl.on("window.active", mac_space_reset)
o.bind("SPACE", "Double space: period", function()
  local previous = mac_space_time
  mac_space_time = mac_space_now
  if not previous or mac_space_now - previous < 0
      or mac_space_now - previous > 300 then return end
  mac_space_reset()
  local generation = mac_space_generation
  -- Let the second physical space reach the application before replacing it.
  hl.timer(function()
    if generation ~= mac_space_generation then return end
    for _, key in ipairs({ "BackSpace", "BackSpace", "period", "space" }) do
      hl.dispatch(hl.dsp.send_key_state({ mods = "", key = key, state = "down" }))
      hl.dispatch(hl.dsp.send_key_state({ mods = "", key = key, state = "up" }))
    end
  end, { timeout = 1, type = "oneshot" })
end, { non_consuming = true })

-- Physical Caps Lock (XKB keycode 66): Control while held, Escape when
-- released alone. Track combinations explicitly: a release binding alone
-- does not reliably suppress Escape after keys handled by layer-shell menus.
local caps_held = false
local caps_used = false
local caps_other_keys = {}
hl.on("input.keyboard.key", function(keycode, time_ms, state)
  if keycode == 66 then
    if state == 1 then
      caps_held = true
      caps_used = next(caps_other_keys) ~= nil
    else
      caps_held = false
      -- Keep caps_used until the next press; the release bind runs next.
    end
  elseif state == 1 then
    caps_other_keys[keycode] = true
    if caps_held then caps_used = true end
  else
    caps_other_keys[keycode] = nil
  end
end)

-- Cover the modifier mask before/after the Control key release, without
-- matching the regular Control keys or combos with additional modifiers.
for _, keys in ipairs({ "code:66", "CTRL + code:66" }) do
  hl.bind(keys, function()
    if caps_used then return end
    -- send_shortcut inherits the triggering release and would send only
    -- Escape-up. Panels require Escape-down, so send both states explicitly.
    hl.dispatch(hl.dsp.send_key_state({ mods = "", key = "Escape", state = "down" }))
    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = "", key = "Escape", state = "up" }))
    end, { timeout = 20, type = "oneshot" })
  end, {
    release = true,
    non_consuming = true,
    description = "Caps Lock alone: Escape",
  })
end

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })
