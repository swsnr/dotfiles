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
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    keys = {
      {
        "<tab>",
        function()
          return require("luasnip").expand_or_jumpable() and "<Plug>luasnip-expand-or-jump" or "<tab>"
        end,
        expr = true,
        silent = true,
        mode = "i",
        remap = true,
        desc = "Tab",
      },
      {
        "<tab>",
        function()
          require("luasnip").jump(1)
        end,
        silent = true,
        desc = "Jump forward in snippet",
        mode = "s",
      },
      {
        "<S-tab>",
        function()
          require("luasnip").jump(-1)
        end,
        silent = true,
        desc = "Jump back in snippet",
        mode = { "i", "s" },
      },
    },
    config = function()
      -- require("luasnip").setup({
      --   -- Allow jumping back to exited snippets, and only clean up when text
      --   -- has changed
      --   history = true,
      --   delete_check_events = "TextChanged",
      -- })

      -- Load snippets from friendly-snippets, see https://github.com/L3MON4D3/LuaSnip#add-snippets
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
