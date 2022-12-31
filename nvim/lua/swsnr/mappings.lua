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

local wk = require("which-key")
local telescope = require("telescope")
local tools = require("swsnr.tools")

local M = {}

function M.setup()
  -- Back to normal mode the fast way.
  vim.keymap.set("i", "jk", "<ESC>", { noremap = true })

  -- Move windows with Alt and resize with shift
  vim.keymap.set("n", "<A-left>", "<C-w>h")
  vim.keymap.set("n", "<A-down>", "<C-w>j")
  vim.keymap.set("n", "<A-up>", "<C-w>k")
  vim.keymap.set("n", "<A-right>", "<C-w>l")
  vim.keymap.set("n", "<S-Up>", "<cmd>resize +2<CR>")
  vim.keymap.set("n", "<S-Down>", "<cmd>resize -2<CR>")
  vim.keymap.set("n", "<S-Left>", "<cmd>vertical resize -2<CR>")
  vim.keymap.set("n", "<S-Right>", "<cmd>vertical resize +2<CR>")

  -- Paste in a new line before/after
  vim.keymap.set("n", "[p", ":pu!<cr>")
  vim.keymap.set("n", "]p", ":pu<cr>")

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

  wk.register({
    ["g"] = { name = "+goto" },
    ["[d"] = { vim.diagnostic.goto_prev, "Previous diagnostic" },
    ["]d"] = { vim.diagnostic.goto_next, "Next diagnostic" },
    ["gnn"] = { "Init selection" },
    ["grn"] = { "Increase by node" },
    ["grc"] = { "Increase by scope" },
    ["grm"] = { "Decrease by node" },
  })

  -- Leader bindings
  wk.register({
    [" "] = { "<cmd>Telescope commands<cr>", "Commands" },
    ["?"] = { "<cmd>Telescope<cr>", "Pickers" },
    -- Buffers
    ["b"] = { name = "+buffers" },
    ["bb"] = { "<cmd>Telescope buffers<cr>", "List buffers" },
    -- Editing
    ["e"] = { name = "+edit" },
    ["er"] = { "<cmd>Telescope registers<cr>", "Paste register" },
    ["ed"] = { tools.iso_utc_to_register, "ISO UTC timestamp to register a" },
    ["es"] = { "<cmd>Telescope symbols<cr>", "Insert symbol" },
    ["eu"] = { "<cmd>Telescope undo<cr>", "Undo" },
    -- Files
    ["f"] = { name = "+files" },
    ["ff"] = { "<cmd>Telescope find_files<cr>", "Find files" },
    ["fc"] = { telescope.extensions.zoxide.list, "Change directory" },
    ["ft"] = { "<cmd>NvimTreeFindFileToggle<cr>", "Show current file in tree" },
    ["fT"] = { "<cmd>NvimTreeFocus<cr>", "Open file explorer" },
    -- Git
    ["g"] = { name = "+git" },
    ["gf"] = { "<cmd>Telescope git_files<cr>", "Git files" },
    ["gg"] = { "<cmd>Neogit<cr>", "Git status" },
    ["gc"] = { "<cmd>Neogit commit<cr>", "Git commit" },
    -- Help
    ["h"] = { name = "+help" },
    ["hh"] = { "<cmd>Telescope help_tags<cr>", "Tags" },
    ["hk"] = { "<cmd>Telescope keymaps<cr>", "Keys" },
    ["hm"] = { "<cmd>Telescope man_pages<cr>", "Man pages" },
    -- Jumping
    ["j"] = { name = "+jump" },
    ["jj"] = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
    ["jj"] = { "<cmd>Telescope jumplist<cr>", "Jumplist" },
    ["jl"] = { "<cmd>Telescope loclist<cr>", "Location list" },
    ["jq"] = { "<cmd>Telescope quickfix<cr>", "Quickfix list" },
    ["jm"] = { "<cmd>Telescope marks<cr>", "Marks" },
    -- Lists
    ["l"] = { name = "+lists" },
    ["lx"] = { "<cmd>TroubleToggle<cr>", "Toggle diagnostics list" },
    ["lw"] = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Toggle workspace diagnostics" },
    ["ld"] = { "<cmd>TroubleToggle document_diagnostics<cr>", "Toggle document diagnostics" },
    ["lq"] = { "<cmd>TroubleToggle quickfix<cr>", "Toggle quickfix list" },
    ["ll"] = { "<cmd>TroubleToggle loclist<cr>", "Toggle location list" },
    ["lr"] = { "<cmd>TroubleToggle lsp_references<cr>", "Toggle references list" },
    ["lL"] = { "<cmd>Lazy<cr>", "Plugins" },
    -- Search
    ["s"] = { name = "+search" },
    ["sg"] = { "<cmd>Telescope live_grep<cr>", "Live grep" },
    ["sc"] = { "<cmd>Telescope grep_string<cr>", "Grep under cursor" },
    -- Windows
    ["w"] = { name = "+windows" },
    ["w/"] = { "<cmd>vsplit<cr>", "Split vertical" },
    ["w-"] = { "<cmd>split<cr>", "Split horizontal" },
    ["wo"] = { "<cmd>only<cr>", "Only current window" },
    ["wq"] = { "<cmd>q<cr>", "Quit" },
    -- Execute things
    ["x"] = { name = "+execute" },
  }, {
    prefix = "<leader>",
  })
end

function M.lsp_attach(buffer)
  local tb = require("telescope.builtin")
  wk.register({
    ["gD"] = { tb.lsp_type_definitions, "Goto type definition" },
    ["gd"] = { tb.lsp_definitions, "Goto definition" },
    ["gi"] = { tb.lsp_implementations, "Goto implementation" },
    ["<C-k>"] = { vim.lsp.buf.signature_help, "Signature help" },
    ["K"] = { vim.lsp.buf.hover, "Hover" },
    ["<leader>ea"] = { vim.lsp.buf.code_action, "Code action" },
    ["<leader>ef"] = {
      function()
        vim.lsp.buf.format({ async = true })
      end,
      "Format",
    },
    ["<leader>eR"] = { vim.lsp.buf.rename, "Rename symbol" },
    ["<leader>jS"] = { tb.lsp_dynamic_workspace_symbols, "Jump to workspace symbol" },
    ["<leader>js"] = { tb.lsp_document_symbols, "Jump to document symbol" },
    ["<leader>jr"] = { tb.lsp_references, "Jump to reference" },
    ["<leader>jd"] = { tb.diagnostics, "Jump to diagnostic" },
  }, { buffer = bufnr })
end

function M.git_signs_attach(buffer)
  wk.register({
    ["]c"] = { "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", "Next git hunk", expr = true },
    ["[c"] = { "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", "Previous git hunk", expr = true },
    ["<leader>gb"] = {
      function()
        require("gitsigns").blame_line({ full = true })
      end,
      "Blame current line",
    },
    ["<leader>gd"] = { "<cmd>Gitsigns diffthis<cr>", "Diff against index" },
    ["<leader>gD"] = { "<cmd>Gitsigns toggle_deleted<cr>", "Toggle deleted lines" },
    ["<leader>gp"] = { "<cmd>Gitsigns preview_hunk<cr>", "Preview hunk" },
    ["<leader>gR"] = { "<cmd>Gitsigns reset_buffer<cr>", "Reset buffer to staged" },
    ["<leader>gr"] = { "<cmd>Gitsigns reset_hunk<cr>", "Reset hunk to staged" },
    ["<leader>gS"] = { "<cmd>Gitsigns stage_buffer<cr>", "Stage buffer" },
    ["<leader>gs"] = { "<cmd>Gitsigns stage_hunk<cr>", "Stage hunk" },
    ["<leader>gu"] = { "<cmd>Gitsigns undo_stage_hunk<cr>", "Undo staged hunk" },
  }, { buffer = buffer })

  wk.register({
    ["<leader>gr"] = { "<cmd>Gitsigns reset_hunk<cr>", "Reset hunk to staged" },
    ["<leader>gs"] = { "<cmd>Gitsigns stage_hunk<cr>", "Stage hunk" },
  }, { buffer = buffer, mode = "v" })

  -- Text object; TODO: Migrate to which-key
  --map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  --map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
end

return M
