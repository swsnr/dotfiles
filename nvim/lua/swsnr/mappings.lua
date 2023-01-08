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

local tools = require("swsnr.tools")

-- Back to normal mode the fast way.
vim.keymap.set("i", "jk", "<ESC>", { desc = "Normal mode" })
-- Back to normal mode in terminals; since we have C-\ bound to toggle term
-- this is actually the only way to go back to normal mode.
vim.keymap.set("t", "jk", [[<C-\><C-n>]], { desc = "Normal mode" })

-- Move windows with Alt and resize with shift
vim.keymap.set("n", "<A-left>", "<C-w>h", { desc = "To left window" })
vim.keymap.set("n", "<A-down>", "<C-w>j", { desc = "To bottom window" })
vim.keymap.set("n", "<A-up>", "<C-w>k", { desc = "To top window" })
vim.keymap.set("n", "<A-right>", "<C-w>l", { desc = "To right window" })
vim.keymap.set("n", "<S-Up>", "<cmd>resize +2<CR>", { desc = "Increase height" })
vim.keymap.set("n", "<S-Down>", "<cmd>resize -2<CR>", { desc = "Decrease height" })
vim.keymap.set("n", "<S-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease width" })
vim.keymap.set("n", "<S-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase width" })

-- Switch buffers with <ctrl>
vim.keymap.set("n", "<C-Left>", "<cmd>bprevious<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<C-Right>", "<cmd>bnext<cr>", { desc = "Previous buffer" })

-- Paste in a new line before/after
vim.keymap.set("n", "[p", ":pu!<cr>", { desc = "Paste line before" })
vim.keymap.set("n", "]p", ":pu<cr>", { desc = "Paste line after" })

-- Make n and N consistent: n always goes forward, regardless of whether ? or
-- / was used for searching
vim.keymap.set("n", "n", "'Nn'[v:searchforward]", { expr = true })
vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true })
vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true })
vim.keymap.set("n", "N", "'nN'[v:searchforward]", { expr = true })
vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true })
vim.keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true })

-- Restore selection when indenting in visual mode
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Navigate diagnostics
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Leader bindings
vim.keymap.set("n", "<leader>ed", tools.iso_utc_to_register, { desc = "ISO UTC timestamp to register a" })
vim.keymap.set("n", "<leader>lL", "<cmd>Lazy<cr>", { desc = "Plugins" })
vim.keymap.set("n", "<leader>Q", "<cmd>quit<cr>", { desc = "Quit" })
vim.keymap.set("n", "<leader>w/", "<cmd>vsplit<cr>", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>w-", "<cmd>split<cr>", { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>wh", "<cmd>split<cr>", { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>w-", "<cmd>split<cr>", { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>wo", "<cmd>only<cr>", { desc = "Only current window" })
vim.keymap.set("n", "<leader>wq", "<cmd>q<cr>", { desc = "Quit" })
