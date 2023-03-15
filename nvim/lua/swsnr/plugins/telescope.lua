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

-- Telescope setup.

function open_with_trouble(...)
  -- Lazy-load trouble from telescope
  require("trouble.providers.telescope").open_with_trouble(...)
end

local M = {
  "nvim-telescope/telescope.nvim",
  -- Load telescope right away so that the ui-select replacement kicks in, and
  -- we'll likely use telescope anyway.
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- Telescope extensions we set up right away
    "jvgrootveld/telescope-zoxide",
    "nvim-telescope/telescope-symbols.nvim",
    "debugloop/telescope-undo.nvim",
  },
  cmd = { "Telescope" },
  keys = {
    ["g"] = { name = "+goto" },
    { "<leader> ", "<cmd>Telescope commands<cr>", desc = "Commands" },
    { "<leader>?", "<cmd>Telescope</cr>", desc = "Pickers" },
    { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "List buffers" },
    { "<leader>ep", "<cmd>Telescope registers<cr>", desc = "Paste register" },
    { "<leader>es", "<cmd>Telescope symbols<cr>", desc = "Insert symbol" },
    { "<leader>eu", "<cmd>Telescope undo<cr>", desc = "Undo" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Git files" },
    {
      "<leader>fc",
      function()
        require("telescope").extensions.zoxide.list()
      end,
      desc = "Change directory",
    },
    { "<leader>ha", "<cmd>Telescope autocommands<cr>", desc = "Autocommands" },
    { "<leader>hh", "<cmd>Telescope help_tags<cr>", desc = "Tags" },
    { "<leader>hk", "<cmd>Telescope keymaps<cr>", desc = "Keys" },
    {
      "<leader>hm",
      function()
        require("telescope.builtin").man_pages({ sections = { "1", "5", "7", "8" } })
      end,
      desc = "Man pages (1,5,7,8)",
    },
    { "<leader>ho", "<cmd>Telescope vim_options<cr>", desc = "Options" },
    { "<leader>jj", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    { "<leader>jj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
    { "<leader>jl", "<cmd>Telescope loclist<cr>", desc = "Location list" },
    { "<leader>jq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix list" },
    { "<leader>jm", "<cmd>Telescope marks<cr>", desc = "Marks" },
    { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>sc", "<cmd>Telescope grep_string<cr>", desc = "Grep under cursor" },
  },
}

function M.config()
  local t = require("telescope")

  t.setup({
    defaults = {
      mappings = {
        i = { ["<c-t>"] = open_with_trouble },
        n = { ["<c-t>"] = open_with_trouble },
      },
    },
  })

  -- Redirect vim's ui select to telescope
  t.load_extension("zoxide")
  t.load_extension("undo")
end

return M
