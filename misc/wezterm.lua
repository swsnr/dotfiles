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
  -- color_scheme = "Dracula",
  color_scheme = 'Builtin Solarized Light',
  font = wezterm.font('JetBrains Mono'),
  font_size = 11.0,
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
  keys = {
    {key='_', mods='CMD', action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
    {key='|', mods='CMD', action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
  },
  hyperlink_rules = {
    -- Linkify things that look like URLs
    -- This is actually the default if you don't specify any hyperlink_rules
    {
      regex = "\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b",
      format = "$0",
    },

    -- linkify email addresses
    {
      regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
      format = "mailto:$0",
    },

    -- file:// URI
    {
      regex = "\\bfile://\\S*\\b",
      format = "$0",
    },
  }
}
