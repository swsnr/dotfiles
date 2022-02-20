local wezterm = require 'wezterm';

-- Check whether the given file exists
function file_exists(name)
   local f = io.open(name, "r")
   if f ~= nil then io.close(f) return true else return false end
end

-- Determine what to set $TERM to
local term
if file_exists(os.getenv('HOME') .. '/.terminfo/w/wezterm') then
  term = 'wezterm'
else
  term = 'xterm-256color'
end

return {
  term = term,
  color_scheme = "Dracula",
  font = wezterm.font('PragmataPro Liga'),
  font_size = 12.0,
  -- Default initial window size
  initial_rows = 40,
  initial_cols = 120,
  -- Run on native wayland by default
  enable_wayland = true,
  -- Scrollback
  scrollback_lines = 10000,
  enable_scroll_bar = true,
  -- Give us the latest unicode, to make emojis work well on my local systems.
  -- Probably breaks SSH'ing into some old servers but then again these likely
  -- won't use emojis anyway.
  unicode_version = 14,
  -- Don't beep
  audible_bell = 'Disabled',
  visual_bell = {
    fade_in_function = "EaseIn",
    fade_in_duration_ms = 150,
    fade_out_function = "EaseOut",
    fade_out_duration_ms = 150,
  },
}
