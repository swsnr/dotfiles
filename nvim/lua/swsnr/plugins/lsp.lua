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
  "neovim/nvim-lspconfig",
  event = "BufReadPre",
  dependencies = {
    -- Progress messages for LSP
    { "j-hui/fidget.nvim", config = true },
    -- Code action indicators
    {
      "kosayoda/nvim-lightbulb",
      config = {
        autocmd = { enabled = true },
      },
    },
    -- Automatically format on save
    {
      "lukas-reineke/lsp-format.nvim",
      config = true,
    },
    {
      "jose-elias-alvarez/null-ls.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        local null_ls = require("null-ls")
        local sources = {
          -- Auto-formatting for fish
          null_ls.builtins.formatting.fish_indent,
          -- Linting and formatting for Bash
          null_ls.builtins.diagnostics.shellcheck,
          null_ls.builtins.formatting.shfmt.with({
            -- Indent bash with four spaces
            extra_args = { "-i", "4" },
          }),
          -- Auto-formatting for Lua
          null_ls.builtins.formatting.stylua,
          -- Warnings about trailing space
          null_ls.builtins.diagnostics.trail_space,
          -- Formatting/linting for XML
          null_ls.builtins.formatting.xmllint,
        }
        null_ls.setup({
          sources = sources,
          on_attach = require("swsnr.lsp").lsp_attach,
        })
      end,
    },
  },
}

function M.config()
  local servers = { "pyright" }
  for _, lsp in pairs(servers) do
    require("lspconfig")[lsp].setup({
      on_attach = require("swsnr.lsp").lsp_attach,
      flags = {
        debounce_text_changes = 150,
      },
    })
  end
end

return M
