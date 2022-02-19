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

function map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend('force', {noremap = true, silent = true}, opts or {})
  vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

function buf_map(bufnr, mode, lhs, rhs, opts)
  opts = vim.tbl_extend('force', {noremap = true, silent = true}, opts or {})
  vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
end

-- TODO: Plugins to try:
--
-- - https://github.com/romgrk/barbar.nvim
-- - https://github.com/akinsho/bufferline.nvim
-- - https://github.com/kyazdani42/nvim-tree.lua
-- - https://github.com/ms-jpq/coq_nvim
-- - https://github.com/kosayoda/nvim-lightbulb
-- - https://github.com/simrat39/rust-tools.nvim
-- - https://github.com/Saecki/crates.nvim
-- - https://github.com/glepnir/lspsaga.nvim
-- - https://github.com/nvim-lualine/lualine.nvim
-- - https://github.com/scalameta/nvim-metals
-- - https://github.com/nvim-telescope/telescope-symbols.nvim
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
      map('n', '<leader> ', '<cmd>Telescope commands<cr>')
      map('n', '<leader>tb', '<cmd>Telescope buffers<cr>')
      map('n', '<leader>tc', '<cmd>Telescope commands<cr>')
      map('n', '<leader>tf', '<cmd>Telescope find_files<cr>')
      map('n', '<leader>tg', '<cmd>Telescope git_files<cr>')
      map('n', '<leader>th', '<cmd>Telescope help_tags<cr>')
      map('n', '<leader>tj', '<cmd>Telescope jumplist<cr>')
      map('n', '<leader>tk', '<cmd>Telescope keymaps<cr>')
      map('n', '<leader>tl', '<cmd>Telescope loclist<cr>')
      map('n', '<leader>tm', '<cmd>Telescope man_pages<cr>')
      map('n', '<leader>tq', '<cmd>Telescope quickfix<cr>')
      map('n', '<leader>tr', '<cmd>Telescope registers<cr>')
      map('n', '<leader>ts', '<cmd>Telescope grep_string<cr>')
      map('n', '<leader>tS', '<cmd>Telescope live_grep<cr>')
      map('n', '<leader>tt', '<cmd>Telescope treesitter<cr>')

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
            goto_next_start = {[']a'] = '@parameter.inner', [']f'] = '@function.outer'},
            goto_next_end = {[']A'] = '@parameter.inner', [']F'] = '@function.outer'},
            goto_previous_start = {['[a'] = '@parameter.inner', ['[f'] = '@function.outer'},
            goto_previous_end = {['[A'] = '@parameter.inner', ['[F'] = '@function.outer'},
          },
          -- TODO: Check out https://github.com/nvim-treesitter/nvim-treesitter-textobjects#textobjects-lsp-interop after configuring LSP
        },
      }
    end
  }
  -- Text objects for treesitter, configured above, see https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  use { 'nvim-treesitter/nvim-treesitter-textobjects' }

  -- LSP: https://github.com/neovim/nvim-lspconfig
  use {
    'neovim/nvim-lspconfig',
    config = function()
      -- Navigate diagnostics.
      map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
      map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')

      local function on_attach(client, bufnr)
        -- Make omnicomplete use LSP completions
        vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'

        local function map(mode, lhs, rhs, opt)
          buf_map(bufnr, mode, lhs, rhs, opt)
        end

        -- Define some direct keybindings for LSP
        map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
        map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
        map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')
        map('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
        map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
        map('n', '<localleader>lf', '<cmd>lua vim.lsp.buf.formatting()<cr>')
        map('n', '<localleader>lr', '<cmd>lua vim.lsp.buf.rename()<cr>')
        -- Telescope bindings in LSP buffers
        map('n', '<localleader>ta', '<cmd>Telescope lsp_code_actions<cr>')
        map('n', '<localleader>td', '<cmd>Telescope lsp_definitions<cr>')
        map('n', '<localleader>tD', '<cmd>Telescope lsp_diagnostics<cr>')
        map('n', '<localleader>ti', '<cmd>Telescope lsp_implementations<cr>')
        map('n', '<localleader>tr', '<cmd>Telescope lsp_references<cr>')
        map('n', '<localleader>ts', '<cmd>Telescope lsp_document_symbols<cr>')
        map('n', '<localleader>tS', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>')
        map('n', '<localleader>tt', '<cmd>Telescope lsp_type_definitions<cr>')
      end

      local servers = { 'rust_analyzer' }
      for _, lsp in pairs(servers) do
        require('lspconfig')[lsp].setup {
          on_attach = on_attach,
          flags = {
            debounce_text_changes = 150
          }
        }
      end
    end
  }

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

  -- Git signs: https://github.com/lewis6991/gitsigns.nvim
  use {
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup {
        on_attach = function(bufnr)
          local function map(mode, lhs, rhs, opts)
            return buf_map(bufnr, mode, lhs, rhs, opts)
          end

          -- Navigation
          map('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", {expr=true})
          map('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", {expr=true})

          -- Actions
          map('n', '<localleader>gs', '<cmd>Gitsigns stage_hunk<CR>')
          map('v', '<localleader>gs', '<cmd>Gitsigns stage_hunk<CR>')
          map('n', '<localleader>gr', '<cmd>Gitsigns reset_hunk<CR>')
          map('v', '<localleader>gr', '<cmd>Gitsigns reset_hunk<CR>')
          map('n', '<localleader>gS', '<cmd>Gitsigns stage_buffer<CR>')
          map('n', '<localleader>gu', '<cmd>Gitsigns undo_stage_hunk<CR>')
          map('n', '<localleader>gR', '<cmd>Gitsigns reset_buffer<CR>')
          map('n', '<localleader>gp', '<cmd>Gitsigns preview_hunk<CR>')
          map('n', '<localleader>gB', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
          map('n', '<localleader>gb', '<cmd>Gitsigns toggle_current_line_blame<CR>')
          map('n', '<localleader>gd', '<cmd>Gitsigns diffthis<CR>')
          map('n', '<localleader>gD', '<cmd>lua require"gitsigns".diffthis("~")<CR>')
          map('n', '<localleader>gd', '<cmd>Gitsigns toggle_deleted<CR>')

          -- Text object
          map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
          map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end
      }
    end
  }

  -- Indent guides: https://github.com/lukas-reineke/indent-blankline.nvim
  use {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require("indent_blankline").setup {
        use_treesitter = true,
        show_current_context = true,
        show_current_context_start = true,
      }
    end
  }

  -- Automatically setup configuration after cloning packer
  if packer_bootstrap then
    require('packer').sync()
  end
end)
