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

-- Get the basename of a Unix path
function basename(str)
  local name = string.gsub(str, "(.*/)(.*)", "%2")
  return name
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
  return file_exists(os.getenv("HOME") .. "/.terminfo/w/wezterm")
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
    return "tokyonight"
  else
    return "tokyonight-day"
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

function wrap_in_systemd_scope(cmd)
  local env = cmd.set_environment_variables
  local ident = ""
  if env.WEZTERM_UNIX_SOCKET then
    ident = "wezterm-pane-" .. env.WEZTERM_PANE .. "-on-" .. basename(env.WEZTERM_UNIX_SOCKET)
  else
    -- Sometimes there's no wezterm socket; in this case let's use a random string.
    ident = "wezterm-pane-" .. env.WEZTERM_PANE .. "-" .. random_string(10)
  end

  local wrapped = {
    "/usr/bin/systemd-run",
    "--user",
    "--scope",
    "--description=Shell started by wezterm",
    "--same-dir",
    "--collect",
    "--unit=" .. ident,
  }

  for _, arg in ipairs(cmd.args or { os.getenv("SHELL") }) do
    table.insert(wrapped, arg)
  end

  cmd.args = wrapped

  return cmd
end

return {
  term = determine_term_value(),
  default_prog = { "/usr/bin/fish" },
  exec_domains = {
    wezterm.exec_domain("scoped", wrap_in_systemd_scope),
  },
  default_domain = "scoped",
  -- Use fish as standard interactive shell
  color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
  font = wezterm.font("JetBrains Mono"),
  font_size = 11.0,
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
  keys = {
    { key = "_", mods = "CMD|SHIFT", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
    { key = "|", mods = "CMD|SHIFT", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
    { key = "UpArrow", mods = "CMD|SHIFT", action = wezterm.action({ ScrollToPrompt = -1 }) },
    { key = "DownArrow", mods = "CMD|SHIFT", action = wezterm.action({ ScrollToPrompt = 1 }) },
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
