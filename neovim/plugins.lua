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

local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  print("packer installed, close and reopen Neovim...")
end

-- Error out if packer's not working
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end


-- TODO: Plugins to try:
--
-- - https://github.com/lukas-reineke/indent-blankline.nvim
-- - https://github.com/romgrk/barbar.nvim
-- - https://github.com/akinsho/bufferline.nvim
-- - https://github.com/kyazdani42/nvim-tree.lua
-- - https://github.com/ms-jpq/coq_nvim
-- - https://github.com/kosayoda/nvim-lightbulb
-- - https://github.com/lewis6991/gitsigns.nvim
-- - https://github.com/neovim/nvim-lspconfig
-- - https://github.com/simrat39/rust-tools.nvim
-- - https://github.com/glepnir/lspsaga.nvim
-- - https://github.com/nvim-lualine/lualine.nvim
-- - https://github.com/scalameta/nvim-metals
--
-- https://github.com/rockerBOO/awesome-neovim is a great source of inspiration.

return packer.startup(function(use)
  -- This package manager: https://github.com/wbthomason/packer.nvim
  use 'wbthomason/packer.nvim'

  -- Fuzzy finder: https://github.com/nvim-telescope/telescope.nvim
  use {
    'nvim-telescope/telescope.nvim',
    requires = {'nvim-lua/plenary.nvim'},
    config = function()
      require('telescope').setup{
        mappings = {
          i = {
            ['jk'] = '<ESC>',
          }
        }
      }
    end
  }
  -- Redirect vim's ui select to telescope
  -- https://github.com/nvim-telescope/telescope-ui-select.nvim
  use {
    'nvim-telescope/telescope-ui-select.nvim',
    requires = {'nvim-telescope/telescope.nvim'},
    config = function()
      require('telescope').load_extension('ui-select')
    end
  }

  -- Modern syntax highlighting: https://github.com/nvim-treesitter/nvim-treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    -- Make sure parsers are up to date
    run = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        -- Install all maintained parsers
        ensure_installed = 'maintained',
        -- Enable tree sitter highlighting
        highlight = {enable = true},
        -- Enable incremental selection
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
              ['aa'] = '@parameter.outer', ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer', ['if'] = '@function.inner',
              ['ac'] = '@class.outer', ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            goto_next_start = {[']a'] = '@parameter.inner', [']f'] = '@function.outer', [']c'] = '@class.outer'},
            goto_next_end = {[']A'] = '@parameter.inner', [']F'] = '@function.outer', [']C'] = '@class.outer'},
            goto_previous_start = {['[a'] = '@parameter.inner', ['[f'] = '@function.outer', ['[c'] = '@class.outer'},
            goto_previous_end = {['[A'] = '@parameter.inner', ['[F'] = '@function.outer', ['[C'] = '@class.outer'},
          },
          -- TODO: Check out https://github.com/nvim-treesitter/nvim-treesitter-textobjects#textobjects-lsp-interop after configuring LSP
        },
      }
    end
  }
  -- Text objects for treesitter, configured above, see https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  use { 'nvim-treesitter/nvim-treesitter-textobjects' }

  -- Dracula colour scheme: https://github.com/Mofiqul/dracula.nvim
  use {
    'Mofiqul/dracula.nvim',
    config = function()
      vim.g.dracula_italic_comment = true
      vim.cmd('colorscheme dracula')
    end
  }

  -- Very convenient and fast motions: https://github.com/ggandor/lightspeed.nvim
  use { 'ggandor/lightspeed.nvim' }

  -- Automatically setup configuration after cloning packer
  if packer_bootstrap then
    require('packer').sync()
  end
end)
