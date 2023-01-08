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

local M = {}

-- Common setup for  LSP client buffers.
function M.lsp_attach(client, bufnr)
  local format = require("lsp-format")

  -- Setup formatting and signature help
  format.on_attach(client)
  require("lsp_signature").on_attach({}, bufnr)

  -- Setup status line indicator, if the server supports symbols
  if client.server_capabilities.documentSymbolProvider then
    require("nvim-navic").attach(client, bufnr)
  end

  -- Make omnicomplete use LSP completions
  vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"

  -- Extra mappings
  function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = bufnr })
  end

  local tb = require("telescope.builtin")
  map("n", "gD", tb.lsp_type_definitions, "Goto type definition")
  map("n", "gd", tb.lsp_definitions, "Goto definition")
  map("n", "gi", tb.lsp_implementations, "Goto implementation")
  map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
  map("n", "K", vim.lsp.buf.hover, "Hover")
  map("n", "<leader>ea", vim.lsp.buf.code_action, "Code action")
  map("n", "<leader>eF", function()
    vim.lsp.buf.format({ async = true })
  end, "Force format")
  map("n", "<leader>ef", function()
    format.toggle({ args = vim.bo.filetype })
  end, "Toggle autoformatting for filetype")
  map("n", "<leader>eR", vim.lsp.buf.rename, "Rename symbol")
  map("n", "<leader>jS", tb.lsp_dynamic_workspace_symbols, "Jump to workspace symbol")
  map("n", "<leader>js", tb.lsp_document_symbols, "Jump to document symbol")
  map("n", "<leader>jr", tb.lsp_references, "Jump to reference")
  map("n", "<leader>jd", tb.diagnostics, "Jump to diagnostic")
end

return M
