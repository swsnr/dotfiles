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

-- Extra vim tools, i.e. things outside an editing buffer.

return {
  {
    "nvim-pack/nvim-spectre",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>ss", "<cmd>lua require('spectre').open()<cr>", desc = "Search" },
      { "<leader>ss", "<cmd>lua require('spectre').open_visual()<cr>", desc = "Search", mode = "v" },
      { "<leader>sw", "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", desc = "Current word" },
      { "<leader>sf", "<cmd>lua require('spectre').open_file_search()<cr>", desc = "Current file" },
    },
    config = true,
  },
  {
    "samoshkin/vim-mergetool",
    cmd = { "MergetoolStart", "MergetoolToggle" },
  },
  {
    "akinsho/toggleterm.nvim",
event = "VeryLazy",
    config = function()
      require("toggleterm").setup({
        shell = "/usr/bin/fish",
        open_mapping = [[<C-\>]],
        on_open = function(term)
          vim.keymap.set("n", "q", "<cmd>close<CR>", { silent = true, buffer = term.bufnr })
        end,
      })

      local floatterm = require("toggleterm.terminal").Terminal:new({
        cmd = "/usr/bin/fish",
        direction = "float",
        float_opts = {
          border = "double",
        },
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.keymap.set("n", "q", "<cmd>close<CR>", { silent = true, buffer = term.bufnr })
        end,
        on_close = function(term)
          vim.cmd("startinsert!")
        end,
      })
      vim.keymap.set("n", "<leader>t", function()
        floatterm:toggle()
      end, { desc = "Float term" })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    -- Load neo-tree right away to make sure the netrw hijack takes effect.
    -- TODO: Make it lazy and only load if vim opens a directory initially.
    lazy = false,
    -- cmd = "Neotree",
    init = function()
      vim.g.neo_tree_remove_legacy_commands = 1
    end,
    keys = {
      { "<leader>ft", "<cmd>Neotree reveal<cr>", desc = "Reveal in file explorer" },
      { "<leader>fT", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
    },
    config = {
      filesystem = {
        -- Focus current file in tree when switching buffers.
        follow_current_file = true,
        -- Opening a directory with neovim opens the directory in the tree.
        hijack_netrw_behavior = "open_current",
      },
    },
  },
}
