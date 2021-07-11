local wezterm = require 'wezterm';

return {
  -- color_scheme = "Builtin Tango Light",
  -- color_scheme = "OneHalfLight",
  color_scheme = "Tomorrow",
  font = wezterm.font_with_fallback({
      "PragmataPro Mono Liga",
      "Noto Color Emoji"
  }),
  font_size = 11.0,
  initial_rows = 40,
  initial_cols = 120,
  enable_wayland = true,
}
