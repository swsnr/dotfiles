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

local M = {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = {
    { "SmiteshP/nvim-gps", config = true },
    { "nvim-tree/nvim-web-devicons" },
  },
}

function M.config()
  local gps = require("nvim-gps")
  require("lualine").setup({
    theme = "auto",
    sections = {
      lualine_c = {
        "filename",
        { gps.get_location, cond = gps.is_available },
      },
      -- TODO: Add lazy update indicator
    },
  })
end

return M
