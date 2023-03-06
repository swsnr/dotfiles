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

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup("swsnr.plugins", {
  defaults = { lazy = true },
  install = {
    -- Do not install plugins automatically; I restore when I find the time
    missing = false,
    -- Try to load my preferred colour scheme during installation
    colorscheme = { "tokyonight", "habamax" },
  },
  -- Try to load my preferred colour scheme during installation
  -- Automatically check for plugin updates, but don't notify; just refresh the
  -- status indicator.
  checker = { enabled = true, notify = false },
  performance = {
    -- Disable a bunch of built-in plugins which I definitely don't use
    disabled_plugins = {
      "tohtml",
      "tutor",
    },
  },
})
