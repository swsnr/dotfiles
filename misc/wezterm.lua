local wezterm = require 'wezterm';

-- A helper function for my fallback fonts
function font_with_fallback(name, params)
  local names = {name, "Noto Color Emoji"}
  return wezterm.font_with_fallback(names, params)
end

return {
  -- color_scheme = "Builtin Tango Light",
  -- color_scheme = "OneHalfLight",
  color_scheme = "Tomorrow",
  font = font_with_fallback('PragmataPro Mono Liga'),
  -- For some reason we need to explicitly and unambiguously specify variants
  -- of PragmataPro Mono Liga here; wezterm fails to find the italic and bold
  -- variants properly.
  font_rules = {
    {
      italic = false,
      intensity = "Normal",
      font = font_with_fallback('PragmataProMonoLiga-Regular')
    },
    {
      italic = false,
      intensity = "Normal",
      font = font_with_fallback('PragmataProMonoLiga-Regular')
    },
    {
      italic = true,
      intensity = "Normal",
      font = font_with_fallback('PragmataProMonoLiga-Italic')
    },
    {
      italic = true,
      intensity = "Half",
      font = font_with_fallback('PragmataProMonoLiga-Italic')
    },
    {
      italic = true,
      intensity = "Bold",
      font = font_with_fallback('PragmataProMonoLiga-BoldItalic')
    }
  },
  font_size = 11.0,
  initial_rows = 40,
  initial_cols = 120,
  enable_wayland = true,
  -- Subpixel rendering!
  freetype_load_target = "HorizontalLcd",
  freetype_render_target = "HorizontalLcd",
}
