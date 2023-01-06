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

function open_with_trouble()
  -- Lazy-load trouble from telescope
  require("trouble.providers.telescope").open_with_trouble()
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
