local wezterm = require 'wezterm';

-- Check whether the given file exists
function file_exists(name)
   local f = io.open(name, "r")
   if f ~= nil then io.close(f) return true else return false end
end

function wezterm_terminfo_installed()
  return file_exists(os.getenv('HOME') .. '/.terminfo/w/wezterm')
end

-- Determine what to set $TERM to
function determine_term_value()
  if wezterm_terminfo_installed() then
    return 'wezterm'
  end
  return 'xterm-256color'
end

function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

-- Query UI color on Gnome, see
-- https://wezfurlong.org/wezterm/config/lua/window/get_appearance.html
function query_appearance_gnome()
  local success, stdout = wezterm.run_child_process(
    {"gsettings", "get", "org.gnome.desktop.interface", "color-scheme"}
  )
  stdout = stdout:lower():gsub("%s+", "")
  -- lowercase and remove whitespace
  if stdout == "'prefer-dark'" then
     return "Dark"
  end
  return "Light"
end

function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "Builtin Tango Dark"
  else
    return "Builtin Tango Light"
  end
end

-- Hook into right status polling to switch UI theme if the desktop theme
-- changed, see https://wezfurlong.org/wezterm/config/lua/window/get_appearance.html
wezterm.on("update-right-status", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local appearance = query_appearance_gnome()
  local scheme = scheme_for_appearance(appearance)
  if overrides.color_scheme ~= scheme then
    overrides.color_scheme = scheme
    window:set_config_overrides(overrides)
  end
end)

return {
  term = determine_term_value(),
  -- Use fish as standard interactive shell
  default_prog = { os.getenv('HOME') .. '/.local/bin/systemd-run-fish' },
  color_scheme = 'Builtin Solarized Light',
  -- This doesn't work well with Solarized; it just makes all bold stuff grey :|
  bold_brightens_ansi_colors = false,
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
    {key='_', mods='CMD|SHIFT', action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
    {key='|', mods='CMD|SHIFT', action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
    {key="UpArrow", mods="SHIFT", action=wezterm.action{ScrollToPrompt=-1}},
    {key="DownArrow", mods="SHIFT", action=wezterm.action{ScrollToPrompt=1}},
  },
  mouse_bindings = {
    { event={Down={streak=3, button="Left"}},
      action={SelectTextAtMouseCursor="SemanticZone"},
      mods="NONE"
    },
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
