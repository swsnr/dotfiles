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

-- TODO:
--
-- Steal all cool things from https://github.com/folke/LazyVim
--
-- Plugins:
-- https://github.com/L3MON4D3/LuaSnip
-- https://github.com/rafamadriz/friendly-snippets (for the above)
-- https://github.com/hrsh7th/nvim-cmp and https://github.com/folke/dot/blob/master/config/nvim/lua/config/plugins/cmp.lua
-- https://github.com/nvim-pack/nvim-spectre
-- https://github.com/chentoast/marks.nvim
-- https://github.com/toppair/reach.nvim
-- Replace nvim-tree with neo-tree?
-- Multiple cursors plugin: https://github.com/mg979/vim-visual-multi
-- https://github.com/folke/neoconf.nvim
-- https://github.com/RRethy/vim-illuminate
--
-- Language servers:
-- https://github.com/latex-lsp/texlab

return {
  { "folke/lazy.nvim", lazy = false },
  -- Color scheme
  {
    "folke/tokyonight.nvim",
    -- Make sure we load at startup, first of all
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
      })
      -- load the colorscheme here
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
  {
    "folke/which-key.nvim",
    lazy = true,
    config = {
      -- show_help = false,
      plugins = { spelling = true },
      key_labels = { ["<leader>"] = "SPC" },
    },
  },
  {
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
    config = function()
      local t = require("telescope")
      local trouble = require("trouble.providers.telescope")
      t.setup({
        defaults = {
          mappings = {
            i = { ["<c-t>"] = trouble.open_with_trouble },
            n = { ["<c-t>"] = trouble.open_with_trouble },
          },
        },
      })

      -- Redirect vim's ui select to telescope
      t.load_extension("zoxide")
      t.load_extension("undo")
    end,
  },
  {
    "kyazdani42/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeFindFileToggle", "NvimTreeFocus" },
    config = {
      system_open = {
        cmd = "gio",
        args = { "open" },
      },
    },
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "TroubleToggle",
    config = {
      use_diagnostic_signs = true,
    },
  },
  {},
  {
    "samoshkin/vim-mergetool",
    cmd = { "MergetoolStart", "MergetoolToggle" },
  },
  {
    "jghauser/mkdir.nvim",
    event = "VeryLazy",
  },
  {
    "akinsho/toggleterm.nvim",
    config = {
      shell = "/usr/bin/fish",
      open_mapping = [[<C-\>]],
      on_open = function(term)
        vim.keymap.set("n", "q", "<cmd>close<CR>", { silent = true, buffer = term.bufnr })
      end,
    },
  },
}
