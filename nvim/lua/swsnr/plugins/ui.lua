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

-- Plugins for the user interface, i.e. the colorscheme, lualine, bufferline,
-- etc.

return {
  {
    "folke/tokyonight.nvim",
    enabled = false,
    -- Make sure we load at startup, first of all
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
  {
    "ellisonleao/gruvbox.nvim",
    enabled = false,
    -- Make sure we load at startup, first of all
    lazy = false,
    priority = 1000,
    opts = {
      contrast = "soft",
      dim_inactive = true,
    },
    config = function(_, opts)
      require("gruvbox").setup(opts)
      vim.cmd([[colorscheme gruvbox]])
    end,
  },
  {
    "navarasu/onedark.nvim",
    -- Make sure we load at startup, first of all
    lazy = false,
    priority = 1000,
    opts = {
      style = "light",
    },
    config = function(_, opts)
      require("onedark").setup(opts)
      vim.cmd([[colorscheme onedark]])
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.register({
        mode = { "n", "v" },
        ["<leader>b"] = { name = "+buffers" },
        ["<leader>e"] = { name = "+edit" },
        ["<leader>f"] = { name = "+files" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>h"] = { name = "+help" },
        ["<leader>j"] = { name = "+jump" },
        ["<leader>l"] = { name = "+lists" },
        ["<leader>s"] = { name = "+search/replace" },
        ["<leader>w"] = { name = "+windows" },
        ["<leader>x"] = { name = "+execute" },
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      {
        "SmiteshP/nvim-navic",
        config = function()
          require("nvim-navic").setup({
            icons = require("swsnr.icons").kinds,
          })
        end,
      },
      { "nvim-tree/nvim-web-devicons" },
    },
    opts = {
      theme = "auto",
      extensions = {
        "toggleterm",
        "neo-tree",
        "man",
        "fugitive",
        "lazy",
        "trouble",
      },
    },
    config = function(_, opts)
      local navic = require("nvim-navic")
      local lazy = require("lazy.status")
      local sections = {
        sections = {
          lualine_c = {
            "filename",
            {
              "nvim_treesitter#statusline",
              cond = function()
                return not navic.is_available()
              end,
            },
            { navic.get_location, cond = navic.is_available },
          },
          lualine_z = {
            "location",
            { lazy.updates, cond = lazy.has_updates, color = { fg = "#ff9e64" } },
          },
        },
      }
      require("lualine").setup(vim.tbl_extend("error", opts, sections))
    end,
  },
  {
    "famiu/bufdelete.nvim",
    cmd = { "Bdelete", "Bwipeout" },
    keys = {

      { "<leader>q", "<cmd>Bdelete<cr>", desc = "Close current buffer" },
    },
  },
  -- bufferline
  {
    "akinsho/nvim-bufferline.lua",
    event = "BufAdd",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        close_command = function(bufnum)
          require("bufdelete").bufdelete(bufnum, true)
        end,
        middle_mouse_command = function(bufnum)
          require("bufdelete").bufdelete(bufnum, true)
        end,
        diagnostics_indicator = function(_, _, diag)
          local icons = require("swsnr.icons").diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPre",
    opts = {
      use_treesitter = true,
      show_current_context = true,
      show_current_context_start = true,
    },
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      -- Set as default notification function
      vim.notify = require("notify")
    end,
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = true,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "TroubleToggle",
    keys = {
      { "<leader>lx", "<cmd>TroubleToggle<cr>", desc = "Toggle diagnostics list" },
      { "<leader>lw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Toggle workspace diagnostics" },
      { "<leader>ld", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Toggle document diagnostics" },
      { "<leader>lq", "<cmd>TroubleToggle quickfix<cr>", desc = "Toggle quickfix list" },
      { "<leader>ll", "<cmd>TroubleToggle loclist<cr>", desc = "Toggle location list" },
      { "<leader>lr", "<cmd>TroubleToggle lsp_references<cr>", desc = "Toggle references list" },
    },
    opts = {
      use_diagnostic_signs = true,
    },
  },
  {
    "anuvyklack/windows.nvim",
    event = "WinNew",
    dependencies = {
      { "anuvyklack/middleclass" },
      { "anuvyklack/animation.nvim" },
    },
    keys = {
      { "<leader>wb", "<cmd>WindowsEqualize<cr>", desc = "Balance all windows" },
      { "<leader>wm", "<cmd>WindowsMaximize<cr>", desc = "Maximize current window" },
    },
    opts = {},
    config = function(_, opts)
      vim.o.winwidth = 10
      vim.o.winminwidth = 10
      vim.o.equalalways = false
      require("windows").setup(opts)
    end,
  },
}
