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

-- Load plugins
require('user.plugins')

-- Enable lua filetypes
vim.g.do_filetype_lua = 1

-- Options for the general user interface
vim.opt.showmode = false -- Don't show mode message in message line
vim.opt.signcolumn = 'yes' -- Always show sign column

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

function inoremap(lhs, rhs)
  vim.api.nvim_set_keymap('i', lhs, rhs, {noremap = true})
end

function nnoremap(lhs, rhs)
  vim.api.nvim_set_keymap('n', lhs, rhs, {noremap = true})
end

inoremap('jk', '<ESC>')
nnoremap('<leader> ', ':Telescope commands<cr>')

-- Files and finding
nnoremap('<leader>fR', ':source $MYVIMRC<cr>')
nnoremap('<leader>fh', ':Telescope help_tags<cr>')

-- Buffer and window bindings
nnoremap('<leader>bb', ':Telescope buffers<cr>')
nnoremap('<leader>w/', ':vsplit<cr>')
nnoremap('<leader>w-', ':split<cr>')
nnoremap('<leader>wq', ':q<cr>')
