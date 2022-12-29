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
  -- Setup formatting
  require("lsp-format").on_attach(client)

  -- Make omnicomplete use LSP completions
  vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'

  local tb = require('telescope.builtin')
  require('which-key').register({
    ['gD'] = {tb.lsp_type_definitions, 'Goto type definition'},
    ['gd'] = {tb.lsp_definitions, 'Goto definition'},
    ['gi'] = {tb.lsp_implementations, 'Goto implementation'},
    ['<C-k>'] = {vim.lsp.buf.signature_help, 'Signature help'},
    ['K'] = {vim.lsp.buf.hover, 'Hover'},
    ['<leader>ea'] = {vim.lsp.buf.code_action, 'Code action'},
    ['<leader>ef'] = {function() vim.lsp.buf.format{async = true} end, 'Format'},
    ['<leader>eR'] = {vim.lsp.buf.rename, 'Rename symbol'},
    ['<leader>jS'] = {tb.lsp_dynamic_workspace_symbols, 'Jump to workspace symbol'},
    ['<leader>js'] = {tb.lsp_document_symbols, 'Jump to document symbol'},
    ['<leader>jr'] = {tb.lsp_references, 'Jump to reference'},
    ['<leader>jd'] = {tb.diagnostics, 'Jump to diagnostic'},
  }, {buffer = bufnr})
end

return M
