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

-- Neovim initialization in Lua, because VimL is a nightmare.
--
-- See https://learnxinyminutes.com/docs/lua/ for a very nice and brief intro to
-- Lua, and https://github.com/medwatt/Notes/blob/main/Lua/Lua_Quick_Guide.ipynb
-- and https://github.com/nanotee/nvim-lua-guide for info about Lua in Neovim.

-- Load plugins
require('user.plugins')

-- neovide settings
vim.g.neovide_cursor_vfx_mode = 'pixiedust'
vim.g.neovide_remember_window_size = true

-- Enable lua filetypes
vim.g.do_filetype_lua = 1

-- Gui settings: Pragmata Pro as standard font, and Noto for emojis
vim.opt.guifont = 'PragmataPro Liga,Note Color Emoji:h10'
vim.opt.mouse = 'nv' -- Enable mouse in normal and visual mode

-- Options for the general user interface
vim.opt.showmode = false -- Don't show mode message in message line
vim.opt.signcolumn = 'yes' -- Always show sign column
-- Always keep some context
vim.opt.sidescrolloff = 8
vim.opt.scrolloff = 8

-- Completion: Always show a menu even if there's just one candidate, never
-- insert automatically and never preselect an entry in the completion menuselect.
vim.opt.completeopt = {'menuone', 'noinsert', 'noselect'}
vim.opt.shortmess:append({ c = true })

-- Options for text editing
vim.opt.number = true -- Enable line numbers…
vim.opt.relativenumber = true -- … relative to the current line.
vim.opt.textwidth = 80
vim.opt.colorcolumn = '+1'
vim.opt.expandtab = true -- No tabs
vim.opt.shiftwidth = 2
vim.opt.cursorline = true

-- Options for buffers and windows
vim.opt.splitright = true -- vsplit rightwards
vim.opt.splitbelow = true -- split downwards

-- Options for searching
vim.opt.ignorecase = true -- Ignore case when searching…
vim.opt.smartcase = true -- …for all lowercase patterns

-- Bindings
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

function inoremap(lhs, rhs)
  vim.api.nvim_set_keymap('i', lhs, rhs, {noremap = true})
end

function nnoremap(lhs, rhs)
  vim.api.nvim_set_keymap('n', lhs, rhs, {noremap = true})
end

inoremap('jk', '<ESC>')

-- Buffer and window bindings
nnoremap('<leader>w/', '<cmd>vsplit<cr>')
nnoremap('<leader>w-', '<cmd>split<cr>')
nnoremap('<leader>wq', '<cmd>q<cr>')

-- Global autocommands
vim.cmd[[
augroup global
  au!
  " Highlight yanked text, see https://github.com/neovim/neovim/pull/12279#issuecomment-879142040
  au TextYankPost * silent! lua vim.highlight.on_yank()
augroup END
]]

--Language specific autocommands
vim.cmd[[
augroup vc_git
  au!
  " Automatically start insert mode in a new first line in Git commit messages,
  " to that I can start typing my message right away without having to press i
  " first
  autocmd BufRead COMMIT_EDITMSG execute "normal! gg" | execute "normal! O" | startinsert
augroup END
]]
