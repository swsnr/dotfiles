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
    opts = {
      -- Allow jumping back to exited snippets, and only clean up when text
      -- has changed
      history = true,
      delete_check_events = "TextChanged",
    },
    config = function(_, opts)
      require("luasnip").setup(opts)
      -- Load snippets from friendly-snippets, see https://github.com/L3MON4D3/LuaSnip#add-snippets
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-emoji",
      "saadparwaiz1/cmp_luasnip",
      "mtoohey31/cmp-fish",
      "hrsh7th/cmp-nvim-lua",
      {
        "petertriho/cmp-git",
        opts = { filetypes = { "gitcommit", "NeogitCommitMessage" } },
      },
    },
    opts = {
      completion = {
        completeopt = "menu,menuone,noinsert,noselect",
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      formatting = {
        format = function(_, item)
          local icons = require("swsnr.icons").kinds
          if icons[item.kind] then
            item.kind = icons[item.kind] .. item.kind
          end
          return item
        end,
      },
    },
    config = function(_, opts)
      local cmp = require("cmp")
      local opts = vim.tbl_extend("error", opts, {
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "fish" },
          { name = "nvim_lua" },
          { name = "git" },
        }, {
          { name = "luasnip" },
          { name = "path", option = { trailing_slash = true } },
          { name = "emoji" },
        }, {
          { name = "buffer" },
        }),
      })
      cmp.setup(opts)
    end,
  },
}
