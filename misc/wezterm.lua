local wezterm = require 'wezterm';

-- A helper function for my fallback fonts
function font_with_fallback(name, params)
  local names = {name, "Noto Color Emoji"}
  return wezterm.font_with_fallback(names, params)
end

return {
  color_scheme = "Dracula",
  font = font_with_fallback('PragmataPro Liga'),
  font_size = 12.0,
  initial_rows = 40,
  initial_cols = 120,
  enable_wayland = true,
  -- Scrollback
  scrollback_lines = 10000,
  enable_scroll_bar = true,
}
