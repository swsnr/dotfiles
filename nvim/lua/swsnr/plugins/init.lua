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
-- https://github.com/chentoast/marks.nvim
-- https://github.com/toppair/reach.nvim
-- https://github.com/akinsho/toggleterm.nvim
-- Replace nvim-tree with neo-tree?
-- Replace surround with sandwich
-- Multiple cursors plugin
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
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPre",
    config = {
      on_attach = function(bufnr)
        require("swsnr.mappings").git_signs_attach(bufnr)
      end,
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
  {
    "samoshkin/vim-mergetool",
    cmd = { "MergetoolStart", "MergetoolToggle" },
  },
  {
    "ggandor/leap.nvim",
    event = "VeryLazy",
    -- TODO: Test this
    -- dependencies = {
    --   { "ggandor/flit.nvim", config = { labeled_modes = "nv" } },
    -- },
    config = function()
      require("leap").add_default_mappings()
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "VeryLazy",
    config = true,
  },
  {
    "kylechui/nvim-surround",
    config = true,
  },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = true,
  },
  {
    "axelf4/vim-strip-trailing-whitespace",
    event = "BufReadPre",
  },
  {
    "jghauser/mkdir.nvim",
    event = "VeryLazy",
  },
  {
    "ethanholz/nvim-lastplace",
    event = "BufReadPre",
  },
  {
    "TimUntersberger/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Neogit",
    config = true,
  },
}
