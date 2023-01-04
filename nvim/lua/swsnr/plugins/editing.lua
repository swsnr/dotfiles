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
    "kylechui/nvim-surround",
    config = true,
  },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = true,
  },
  {
    "ethanholz/nvim-lastplace",
    event = "BufReadPre",
  },
  {
    "axelf4/vim-strip-trailing-whitespace",
    event = "BufReadPre",
  },
  {
    "windwp/nvim-autopairs",
    event = "VeryLazy",
    config = true,
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
}
