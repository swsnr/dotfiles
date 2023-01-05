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

return {
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
    config = function()
      local navic = require("nvim-navic")
      require("lualine").setup({
        theme = "auto",
        extensions = {
          "toggleterm",
          "nvim-tree",
          "neo-tree",
          "man",
          "fugitive",
        },
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
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = { fg = "#ff9e64" },
            },
          },
        },
      })
    end,
  },
  -- bufferline
  {
    "akinsho/nvim-bufferline.lua",
    event = "BufAdd",
    config = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = require("swsnr.icons").diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
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
    config = {
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
}
