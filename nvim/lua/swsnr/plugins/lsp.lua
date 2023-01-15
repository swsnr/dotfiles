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

-- lspconfig and LSP-related tools.

return {
  { "zbirenbaum/neodim", event = "LspAttach" },
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      -- Progress messages for LSP
      { "j-hui/fidget.nvim", config = true },
      -- Code action indicators
      { "kosayoda/nvim-lightbulb", opts = { autocmd = { enabled = true } } },
      -- Automatically format on save
      { "lukas-reineke/lsp-format.nvim", config = true },
      -- Signature help while typing
      "ray-x/lsp_signature.nvim",
      -- Auto-completion
      "hrsh7th/cmp-nvim-lsp",
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
              extra_args = function(params)
                -- Derive shfmt parameters from buffer settings
                local indent = 0
                if vim.api.nvim_buf_get_option(params.bufnr, "expandtab") then
                  indent = vim.api.nvim_buf_get_option(params.bufnr, "shiftwidth")
                end
                return { "-i", tostring(indent) }
              end,
            }),
            -- Auto-formatting for Lua
            null_ls.builtins.formatting.stylua,
            -- Warnings about trailing space
            null_ls.builtins.diagnostics.trail_space,
            -- Formatting/linting for XML
            null_ls.builtins.formatting.xmllint,
            -- Formatting for the Javascript ecosystem
            null_ls.builtins.formatting.prettier,
          }
          null_ls.setup({
            sources = sources,
            on_attach = require("swsnr.lsp").lsp_attach,
          })
        end,
      },
    },
    config = function()
      -- Setup auto-completion
      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
      local servers = { "pyright", "texlab" }
      for _, lsp in pairs(servers) do
        require("lspconfig")[lsp].setup({
          capabilities = capabilities,
          on_attach = require("swsnr.lsp").lsp_attach,
          flags = {
            debounce_text_changes = 150,
          },
          settings = {
            texlab = {
              build = {
                -- The rest of latexmk arguments get set in my latexmkrc
                args = { "%f" },
                executable = "latexmk",
                forwardSearchAfter = true,
                onSave = true,
              },
              chktex = {
                onOpenAndSave = true,
              },
            },
          },
        })
      end

      -- Configure vim diagnostic display
      for name, icon in pairs(require("swsnr.icons").diagnostics) do
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end
      vim.diagnostic.config({
        underline = true,
        -- This must be false, as long as update_in_insert is enabled for
        -- neodim (default), see https://github.com/zbirenbaum/neodim#update_in_insert
        update_in_insert = false,
        virtual_text = { spacing = 4, prefix = "●" },
        severity_sort = true,
      })
    end,
  },
}
