-- Copyright Sebastian Wiesner <sebastian@swsnr.de>
--
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not
-- use this file except in compliance with the License. You may obtain a copy of
-- the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
-- WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
-- License for the specific language governing permissions and limitations under
-- the License.

-- My wezterm configuration. See https://wezfurlong.org/wezterm/ for docs

local wezterm = require("wezterm")

local charset = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890"
math.randomseed(os.time())

function random_string(length)
  local ret = {}
  local r
  for i = 1, length do
    r = math.random(1, #charset)
    table.insert(ret, charset:sub(r, r))
  end
  return table.concat(ret)
end

-- Check whether the given file exists
function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function wezterm_terminfo_installed()
  return file_exists(os.getenv("HOME") .. "/.terminfo/w/wezterm") or file_exists("/usr/share/terminfo/w/wezterm")
end

-- Determine what to set $TERM to
function determine_term_value()
  if wezterm_terminfo_installed() then
    return "wezterm"
  end
  return "xterm-256color"
end

function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "OneHalfDark"
  else
    return "OneHalfLight"
  end
end

-- Automatically switch colour scheme if dark mode settings change, see
-- https://wezfurlong.org/wezterm/config/lua/window/get_appearance.html
wezterm.on("window-config-reloaded", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local appearance = window:get_appearance()
  local scheme = scheme_for_appearance(appearance)
  overrides.color_scheme = scheme
  window:set_config_overrides(overrides)
end)

return {
  -- Remove extra redundant title bar added by the compositor, and embed the
  -- tabbar into our own decorations
  window_decorations = "INTEGRATED_BUTTONS|RESIZE",
  -- Configure TERM
  term = determine_term_value(),
  -- Use fish as standard interactive shell, but scoped in a separate systemd unit
  -- to prevent runaway processes from taking down the entire terminal.
  default_prog = { "systemd-run-fish" },
  color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
  font = wezterm.font("JetBrains Mono"),
  font_size = 10.0,
  -- Default initial window size
  initial_rows = 40,
  initial_cols = 120,
  -- Scrollback
  scrollback_lines = 10000,
  enable_scroll_bar = true,
  -- Give us the latest unicode, to make emojis work well on my local systems.
  -- Probably breaks SSH'ing into some old servers but then again these likely
  -- won't use emojis anyway.
  unicode_version = 14,
  -- Don't beep
  audible_bell = "Disabled",
  visual_bell = {
    fade_in_function = "EaseIn",
    fade_in_duration_ms = 150,
    fade_out_function = "EaseOut",
    fade_out_duration_ms = 150,
  },
  -- Allow client application to request enhanced keyboard support, see
  -- https://wezfurlong.org/wezterm/config/lua/config/enable_kitty_keyboard.html and
  -- https://wezfurlong.org/wezterm/config/key-encoding.html
  enable_kitty_keyboard = true,
  keys = {
    { key = "_", mods = "ALT|SHIFT", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
    { key = "|", mods = "ALT|SHIFT", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
    { key = "UpArrow", mods = "ALT|SHIFT", action = wezterm.action({ ScrollToPrompt = -1 }) },
    { key = "DownArrow", mods = "ALT|SHIFT", action = wezterm.action({ ScrollToPrompt = 1 }) },
  },
  mouse_bindings = {
    {
      event = { Down = { streak = 3, button = "Left" } },
      action = { SelectTextAtMouseCursor = "SemanticZone" },
      mods = "NONE",
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
  },
}
