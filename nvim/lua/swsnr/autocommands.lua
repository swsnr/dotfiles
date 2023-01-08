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

local v = vim.api
local ly_group = v.nvim_create_augroup("swsnr", { clear = true })

-- Highlight yanked text, see https://github.com/neovim/neovim/pull/12279#issuecomment-879142040
v.nvim_create_autocmd({ "TextYankPost" }, {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = ly_group,
})
-- Automatically start insert mode in a new first line in Git commit messages,
-- to that I can start typing my message right away without having to press i
-- first
v.nvim_create_autocmd({ "BufRead" }, {
  pattern = "COMMIT_EDITMSG",
  command = 'execute "normal! gg" | execute "normal! O" | startinsert',
  group = ly_group,
})

-- Close some file types with q
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {
    "qf",
    "help",
    "man",
    "notify",
    "lspinfo",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "PlenaryTestPopup",
    "fugitive",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Update indentation settings for fish shell and bash
v.nvim_create_autocmd({ "FileType" }, {
  pattern = { "fish", "sh" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.formatoptions:remove("t")
  end,
  group = ly_group,
})
-- Local markdown settings
v.nvim_create_autocmd({ "FileType" }, {
  pattern = { "markdown" },
  callback = function()
    -- Disable text wrapping
    vim.opt_local.textwidth = 0
    vim.opt_local.formatoptions:remove("t")
    -- But enable line wrapping
    vim.opt_local.wrap = false
  end,
  group = ly_group,
})
