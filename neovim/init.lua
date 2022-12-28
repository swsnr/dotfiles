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

-- Set leader first, to make sure we always get the right bindings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- require('swsnr.pluginspacker')
require('swsnr.lazy')
require('swsnr.options')
require('swsnr.autocommands')

-- Back to normal mode the fast way.
vim.api.nvim_set_keymap('i', 'jk', '<ESC>', {noremap = true})
