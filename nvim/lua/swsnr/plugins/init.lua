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

-- Plugin module.
--
-- Keeps my TODO list, and stuff that doesn't fit anything else.

-- TODO:
--
-- Steal all cool things from https://github.com/folke/LazyVim
--
-- Plugins:
-- https://github.com/chentoast/marks.nvim
-- https://github.com/toppair/reach.nvim
-- Multiple cursors plugin: https://github.com/mg979/vim-visual-multi
-- https://github.com/folke/neoconf.nvim
-- https://github.com/norcalli/nvim-colorizer.lua
-- https://github.com/petertriho/nvim-scrollbar
--
-- Language servers:
-- https://github.com/latex-lsp/texlab

return {
  {
    "jghauser/mkdir.nvim",
    event = "VeryLazy",
  },
}
