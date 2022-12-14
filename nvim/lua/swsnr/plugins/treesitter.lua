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

-- Treesitter and its dependencies.

local M = {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    -- Text objects for treesitter, configured above, see https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    "nvim-treesitter/nvim-treesitter-textobjects",
    -- Automatically change comment string according to current context
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  event = "BufReadPost",
  build = ":TSUpdate",
}

M.opts = {
  -- Install all maintained parsers
  ensure_installed = {
    "bash",
    "bibtex",
    "c",
    "cmake",
    "comment",
    "css",
    "diff",
    "dockerfile",
    "dot",
    "fish",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
    "graphql",
    "help",
    "hocon",
    "html",
    "java",
    "javascript",
    "jq",
    "json",
    "json5",
    "jsonc",
    "latex",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "meson",
    "ninja",
    "proto",
    "python",
    "qmljs",
    "rst",
    "ruby",
    "rust",
    "scala",
    "scss",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "yaml",
  },
  -- Enable tree sitter highlighting and indentation
  highlight = { enable = true },
  indent = { enable = true },
  -- Automatically update comment string
  context_commentstring = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  -- Configure text objects
  textobjects = {
    select = {
      enable = true,
      -- Selecting text objects
      keymaps = {
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
    move = {
      enable = true,
      goto_next_start = { ["]a"] = "@parameter.inner", ["]f"] = "@function.outer" },
      goto_next_end = { ["]A"] = "@parameter.inner", ["]F"] = "@function.outer" },
      goto_previous_start = { ["[a"] = "@parameter.inner", ["[f"] = "@function.outer" },
      goto_previous_end = { ["[A"] = "@parameter.inner", ["[F"] = "@function.outer" },
    },
  },
}

function M.config(_, opts)
  -- Use treesitter folding.  Note that folds are initially broken for all files
  -- opened with telescope, see https://github.com/nvim-telescope/telescope.nvim/issues/699
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

  require("nvim-treesitter.configs").setup(opts)
end

return M
