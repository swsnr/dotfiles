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

return {
  {
    "Saecki/crates.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
    event = "BufReadPre Cargo.toml",
    opts = {
      null_ls = { enabled = true },
    },
  },
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    opts = {
      server = {
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
    config = function(_, opts)
      local function rust_attach(client, bufnr)
        -- Default setup for LSP buffers
        require("swsnr.lsp").lsp_attach(client, bufnr)

        -- And some Rust extras
        require("which-key").register({
          ["<leader>xr"] = { "<cmd>RustRunnables<cr>", "Run rust" },
          ["<leader>xd"] = { "<cmd>RustDebuggables<cr>", "Debug rust" },
          ["<leader>jp"] = { "<cmd>RustParentModule<cr>", "Jump to parent rust module" },
          ["<leader>fc"] = { "<cmd>RustOpenCargo<cr>", "Open Cargo.toml" },
          ["<leader>eJ"] = { "<cmd>RustJoinLines<cr>", "Join rust lines" },
          ["<leader>ej"] = { "<cmd>RustMoveItemDown<cr>", "Move Rust item down" },
          ["<leader>ek"] = { "<cmd>RustMoveItemUp<cr>", "Move Rust item up" },
          ["<leader>ex"] = { "<cmd>RustExpandMacro<cr>", "Expand Rust macro" },
          -- Is this a good idea?
          ["J"] = { "<cmd>RustJoinLines<cr>", "Join rust lines" },
        }, { buffer = bufnr })
      end

      opts.server.on_attach = rust_attach
      require("rust-tools").setup(opts)
    end,
  },
}
