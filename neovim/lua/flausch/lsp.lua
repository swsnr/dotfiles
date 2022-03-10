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
  -- Make omnicomplete use LSP completions
  vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'

  require('which-key').register({
    ['gD'] = {'<cmd>Telescope lsp_type_definitions<cr>', 'Goto type definition'},
    ['gd'] = {'<cmd>Telescope lsp_definitions<cr>', 'Goto definition'},
    ['gi'] = {'<cmd>Telescope lsp_implementations<cr>', 'Goto implementation'},
    ['<C-k>'] = {'<cmd>lua vim.lsp.buf.signature_help()<cr>', 'Signature help'},
    ['K'] = {'<cmd>lua vim.lsp.buf.hover()<cr>', 'Hover'},
    ['<leader>ea'] = {'<cmd>Telescope lsp_code_actions<cr>', 'Code action'},
    ['<leader>ef'] = {'<cmd>lua vim.lsp.buf.formatting()<cr>', 'Format'},
    ['<leader>eR'] = {'<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol'},
    ['<leader>jS'] = {'<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', 'Jump to workspace symbol'},
    ['<leader>js'] = {'<cmd>Telescope lsp_document_symbols<cr>', 'Jump to document symbol'},
    ['<leader>jr'] = {'<cmd>Telescope lsp_references<cr>', 'Jump to reference'},
    ['<leader>jd'] = {'<cmd>Telescope diagnostics<cr>', 'Jump to diagnostic'},
  }, {buffer = bufnr})
end

return M
