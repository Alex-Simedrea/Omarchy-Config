-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

hl.config({
  input = {
    accel_profile = "adaptive",
    -- Apple ISO: extra key beside left Shift acts as Shift; ± becomes ` / ~.
    kb_layout = "apple_iso_ansi",
    kb_variant = "",
    -- Caps acts as Control; bindings.lua sends Escape on an unused release.
    kb_options = "ctrl:nocaps",
  },
})

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
-- hl.config({
--   input = {
--     -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt.
--     kb_layout = "us,dk,eu",
--     kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
--
--     -- Use a specific keyboard variant if needed (e.g. intl for international keyboards).
--     kb_variant = "intl",
--
--     -- Change speed of keyboard repeat.
--     repeat_rate = 40,
--     repeat_delay = 250,
--
--     -- Start with numlock on by default.
--     numlock_by_default = true,
--
--     -- Increase sensitivity for mouse/trackpad (default: 0).
--     sensitivity = 0.35,
--
--     -- Turn off mouse acceleration (default: adaptive).
--     accel_profile = "flat",
--
--     touchpad = {
--       -- Use natural (inverse) scrolling.
--       natural_scroll = true,
--
--       -- Use two-finger clicks for right-click instead of lower-right corner.
--       clickfinger_behavior = true,
--
--       -- Control the speed of your scrolling.
--       scroll_factor = 0.4,
--
--       -- Enable the touchpad while typing.
--       disable_while_typing = false,
--
--       -- Left-click-and-drag with three fingers.
--       drag_3fg = 1,
--     },
--   },
-- })

-- App-specific touchpad scroll speeds.
-- Bring Files closer to Chromium's scroll travel without changing Chromium.
o.window("org.gnome.Nautilus", { scroll_touchpad = 0.0125 })
-- Chromium at UI scale 0.85: slow scrolling independently of interface size.
-- set_prop supports our small calibrated factor; window-rule floats have a
-- 0.01 minimum, which is already faster than the global 0.0081 factor.
local function chromium_scroll_speed(window)
  if not window or window.class ~= "chromium" then return end
  hl.dispatch(hl.dsp.window.set_prop({
    prop = "scroll_touchpad",
    value = "0.006885",
    window = "address:" .. window.address,
  }))
end
hl.on("window.open", chromium_scroll_speed)
hl.on("config.reloaded", function()
  for _, window in ipairs(hl.get_windows({ class = "chromium", mapped = true })) do
    chromium_scroll_speed(window)
  end
end)

-- Foot scrolls whole rows. Replace Omarchy's 2.0 override with a gentler
-- factor; libinput's global progressive scroll curve still applies first.
o.window("foot", { scroll_touchpad = 0.1 })
o.window({ class = "(org\\.omarchy\\..*|TUI\\..*)", initial_title = "foot" }, { scroll_touchpad = 0.1 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.0125 })
o.window({ class = "(org\\.omarchy\\..*|TUI\\..*)", initial_title = "Ghostty" }, { scroll_touchpad = 0.0125 })
-- o.window("(Alacritty|kitty)", { scroll_touchpad = 1.5 })
-- o.window("foot", { scroll_touchpad = 2.0 })
-- o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Three-finger horizontal swipes slide the window tape in scrolling layout.
hl.gesture({ fingers = 3, direction = "horizontal", action = "scroll_move" })

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })
