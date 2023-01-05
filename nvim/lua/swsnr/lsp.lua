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
  -- Setup formatting and signature help
  require("lsp-format").on_attach(client)
  require("lsp_signature").on_attach({}, bufnr)

  -- Setup status line indicator, if the server supports symbols
  if client.server_capabilities.documentSymbolProvider then
    require("nvim-navic").attach(client, bufnr)
  end

  -- Make omnicomplete use LSP completions
  vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"

  -- Add my LSP mappings
  require("swsnr.mappings").lsp_attach(bufnr)
end

return M
