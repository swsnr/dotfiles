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
    "jose-elias-alvarez/typescript.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "jose-elias-alvarez/null-ls.nvim",
    },
    ft = "typescript",
    opts = {
      disable_commands = true,
      server = {},
    },
    config = function(_, opts)
      opts.server.on_attach = require("swsnr.lsp").lsp_attach
      require("typescript").setup(opts)
      -- Register typescript code actions
      require("null-ls").register(require("typescript.extensions.null-ls.code-actions"))
    end,
  },
}
