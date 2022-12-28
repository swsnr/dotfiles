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

local wk = require('which-key')
local telescope = require('telescope')
local tools = require('swsnr.tools')

-- Back to normal mode the fast way.
vim.api.nvim_set_keymap('i', 'jk', '<ESC>', {noremap = true})

wk.register({
  ['g'] = {name="+goto"},
  ['[d'] = {vim.diagnostic.goto_prev, 'Previous diagnostic'},
  [']d'] = {vim.diagnostic.goto_next, 'Next diagnostic'},
  ["gnn"] = {'Init selection'},
  ["grn"] = {'Increase by node'},
  ["grc"] = {'Increase by scope'},
  ["grm"] = {'Decrease by node'},
})

-- Leader bindings
wk.register({
  [' '] = {'<cmd>Telescope commands<cr>', 'Commands'},
  ['?'] = {'<cmd>Telescope<cr>', 'Pickers'},
  -- Buffers
  ['b'] = {name='+buffers'},
  ['bb'] = {'<cmd>Telescope buffers<cr>', 'List buffers'},
  -- Editing
  ['e'] = {name='+edit'},
  ['er'] = {'<cmd>Telescope registers<cr>', 'Paste register'},
  ['ed'] = {tools.iso_utc_to_register, 'ISO UTC timestamp to register a'},
  -- Files
  ['f'] = {name='+files'},
  ['ff'] = {'<cmd>Telescope find_files<cr>', 'Find files'},
  ['fc'] = {telescope.extensions.zoxide.list, 'Change directory'},
  ['ft'] = {'<cmd>NvimTreeFindFileToggle<cr>', 'Show current file in tree'},
  ['fT'] = {'<cmd>NvimTreeFocus<cr>', 'Open file explorer'},
  -- Git
  ['g'] = {name='+git'},
  ['gf'] = {'<cmd>Telescope git_files<cr>', 'Git files'},
  -- Help
  ['h'] = {name='+help'},
  ['hh'] = {'<cmd>Telescope help_tags<cr>', 'Tags'},
  ['hk'] = {'<cmd>Telescope keymaps<cr>', 'Keys'},
  ['hm'] = {'<cmd>Telescope man_pages<cr>', 'Man pages'},
  -- Jumping
  ['j'] = {name='+jump'},
  ['jj'] = {'<cmd>Telescope jumplist<cr>', 'Jumplist'},
  ['jl'] = {'<cmd>Telescope loclist<cr>', 'Location list'},
  ['jq'] = {'<cmd>Telescope quickfix<cr>', 'Quickfix list'},
  ['jm'] = {'<cmd>Telescope marks<cr>', 'Marks'},
  -- Lists
  ['l'] = {name='+lists'},
  -- Search
  ['s'] = {name='+search'},
  ['sg'] = {'<cmd>Telescope live_grep<cr>', 'Live grep'},
  ['sc'] = {'<cmd>Telescope grep_string<cr>', 'Grep under cursor'},
  -- Windows
  ['w'] = {name='+windows'},
  ['w/'] = {'<cmd>vsplit<cr>', 'Split vertical'},
  ['w-'] = {'<cmd>split<cr>', 'Split horizontal'},
  ['wo'] = {'<cmd>only<cr>', 'Only current window'},
  ['wq'] = {'<cmd>q<cr>', 'Quit'},
  -- Execute things
  ['x'] = {name='+execute'},
}, {
  prefix = '<leader>'
})

