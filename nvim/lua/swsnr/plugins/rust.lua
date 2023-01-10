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

-- Rust plugins.

function rust_attach(client, bufnr)
  -- Default setup for LSP buffers
  require("swsnr.lsp").lsp_attach(client, bufnr)

  -- Extra mappings for Rust
  function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = bufnr })
  end
  map({ "n", "<leader>xr", "<cmd>RustRunnables<cr>", "Run rust" })
  map({ "n", "<leader>xd", "<cmd>RustDebuggables<cr>", "Debug rust" })
  map({ "n", "<leader>jp", "<cmd>RustParentModule<cr>", "Jump to parent rust module" })
  map({ "n", "<leader>fc", "<cmd>RustOpenCargo<cr>", "Open Cargo.toml" })
  map({ "n", "<leader>eJ", "<cmd>RustJoinLines<cr>", "Join rust lines" })
  map({ "n", "<leader>ej", "<cmd>RustMoveItemDown<cr>", "Move Rust item down" })
  map({ "n", "<leader>ek", "<cmd>RustMoveItemUp<cr>", "Move Rust item up" })
  map({ "n", "<leader>ex", "<cmd>RustExpandMacro<cr>", "Expand Rust macro" })
  -- Is this a good idea?
  map({ "n", "J", "<cmd>RustJoinLines<cr>", "Join rust lines" })
end

return {
  {
    "Saecki/crates.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
    event = "BufReadPre Cargo.toml",
    -- TODO: Setup cmp source
    opts = {
      null_ls = { enabled = true },
    },
  },
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    opts = {
      server = {
        on_attach = rust_attach,
        settings = {
          -- See https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
          ["rust-analyzer"] = {
            -- Run clippy on save
            checkOnSave = {
              command = "clippy",
            },
          },
        },
        flags = {
          debounce_text_changes = 150,
        },
      },
    },
  },
}
