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
    config = true,
  },
  {
    "samoshkin/vim-mergetool",
    cmd = { "MergetoolStart", "MergetoolToggle" },
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
}
