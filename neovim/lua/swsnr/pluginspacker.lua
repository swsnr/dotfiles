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
-- UI:
--
-- - https://github.com/romgrk/barbar.nvim
-- - https://github.com/akinsho/bufferline.nvim
--
-- Other languages:
--
-- - https://github.com/scalameta/nvim-metals
--
-- Misc:
--
-- - https://github.com/hrsh7th/nvim-cmp
-- - https://github.com/nvim-telescope/telescope-symbols.nvim
-- - https://github.com/airblade/vim-rooter
--
-- https://github.com/rockerBOO/awesome-neovim is a great source of inspiration.

return packer.startup(function(use)
  -- Fuzzy finder: https://github.com/nvim-telescope/telescope.nvim
  --
  -- Depends on plenary for the UI, and we also add all extensions we use as
  -- dependencies so that we can set up telescope here, in a single place.
  --
  -- https://github.com/nvim-telescope/telescope-ui-select.nvim
  -- https://github.com/jvgrootveld/telescope-zoxide
  use {
    '',
    requires = {
    },
    config = function()
      local trouble = require("trouble.providers.telescope")

      telescope.setup {
        defaults = {
          mappings = {
            i = { ["<c-t>"] = trouble.open_with_trouble },
            n = { ["<c-t>"] = trouble.open_with_trouble },
          }
        }
      }
    end
  }

  -- A few extra mappings: https://github.com/tpope/vim-unimpaired
  use {
    'tpope/vim-unimpaired',
    config = function()
      -- Document all of unimpaired bindings
      require('which-key').register({
        ['yo'] = 'Toggle option',
        ['[ '] = 'Blank line up',
        ['] '] = 'Blank line down',
        ['[B'] = 'First buffer',
        [']B'] = 'Last buffer',
        ['[b'] = 'Previous buffer',
        [']b'] = 'Next buffer',
        ['[C'] = 'Encode C string',
        [']C'] = 'Decode C string',
        ['[e'] = 'Move line up',
        [']e'] = 'Move line down',
        ['[f'] = 'Previous file in directory',
        [']f'] = 'Next file in directory',
        ['[L'] = 'First location',
        [']L'] = 'Last location',
        ['[l'] = 'Previous location',
        ['[<C-L>'] = 'Location in previous file',
        [']<C-L>'] = 'Location in next file',
        [']l'] = 'Next location',
        ['[n'] = 'Previous conflict marker',
        [']n'] = 'Next conflict marker',
        ['[o'] = 'Enable option',
        [']o'] = 'Disable option',
        ['[q'] = 'Previous error',
        [']q'] = 'Next error',
        ['[Q'] = 'First error',
        [']Q'] = 'Last error',
        ['[<C-Q>'] = 'Error in previous file',
        [']<C-Q>'] = 'Error in next file',
        ['[t'] = 'Previous tag',
        [']t'] = 'Next tag',
        ['[T'] = 'First tag',
        [']T'] = 'Last tag',
        ['[<C-T>'] = 'Tag in previous file',
        [']<C-T>'] = 'Tag in next file',
        ['[u'] = 'URL encode',
        [']u'] = 'URL decode',
        ['[x'] = 'XML encode',
        [']x'] = 'XML decode',
        ['[y'] = 'Encode C string',
        [']y'] = 'Decode C string',
      })
    end
  }

  -- LSP: https://github.com/neovim/nvim-lspconfig
  use {
    'neovim/nvim-lspconfig',
    config = function()
      local servers = {'pyright'}
      for _, lsp in pairs(servers) do
        require('lspconfig')[lsp].setup {
          on_attach = require('swsnr.lsp').lsp_attach,
          flags = {
            debounce_text_changes = 150
          }
        }
      end
    end
  }

  -- LSP progress messages: https://github.com/j-hui/fidget.nvim
  use {
    'j-hui/fidget.nvim',
    config = function()
      require('fidget').setup()
    end
  }

  -- Dummy language server for a bunch of local tools:
  -- https://github.com/jose-elias-alvarez/null-ls.nvim
  use {
    'jose-elias-alvarez/null-ls.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config =  function()
      local null_ls = require('null-ls')
      local sources = {
        -- Auto-formatting for fish
        null_ls.builtins.formatting.fish_indent,
        -- Linting and formatting for Bash
        null_ls.builtins.diagnostics.shellcheck,
        null_ls.builtins.formatting.shfmt.with {
          -- Indent bash with four spaces
          extra_args = {'-i', '4'}
        }
      }
      null_ls.setup {
        sources = sources,
        on_attach = require('swsnr.lsp').lsp_attach,
      }
    end
  }

  -- Pretty diagnostics list: https://github.com/folke/trouble.nvim
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup()

      require('which-key').register{
        ['<leader>lx'] = {'<cmd>TroubleToggle<cr>', 'Toggle diagnostics list'},
        ['<leader>lw'] = {'<cmd>TroubleToggle workspace_diagnostics<cr>', 'Toggle workspace diagnostics'},
        ['<leader>ld'] = {'<cmd>TroubleToggle document_diagnostics<cr>', 'Toggle document diagnostics'},
        ['<leader>lq'] = {'<cmd>TroubleToggle quickfix<cr>', 'Toggle quickfix list'},
        ['<leader>ll'] = {'<cmd>TroubleToggle loclist<cr>', 'Toggle location list'},
        ['<leader>lr'] = {'<cmd>TroubleToggle lsp_references<cr>', 'Toggle references list'},
      }
    end
  }

  -- Indicators for LSP code actions: https://github.com/kosayoda/nvim-lightbulb
  use {
    'kosayoda/nvim-lightbulb',
    config = function()
      local lb = require('nvim-lightbulb')
      local group = vim.api.nvim_create_augroup('lightbulb', { clear = true })
      vim.api.nvim_create_autocmd({'CursorHold', 'CursorHoldI'}, {
        callback = lb.update_lightbulb,
        group = group
      })
    end
  }

  -- Strip trailing whitespace the clever way: https://github.com/axelf4/vim-strip-trailing-whitespace
  use { }

  -- Rust helpers: https://github.com/simrat39/rust-tools.nvim
  use {
    'simrat39/rust-tools.nvim',
    config = function()
      local function rust_attach(client, bufnr)
        -- Default setup for LSP buffers
        require('swsnr.lsp').lsp_attach(client, bufnr)

        -- And some Rust extras
        require('which-key').register({
          ['<leader>xr'] = {'<cmd>RustRunnables<cr>', 'Run rust'},
          ['<leader>xd'] = {'<cmd>RustDebuggables<cr>', 'Debug rust'},
          ['<leader>jp'] = {'<cmd>RustParentModule<cr>', 'Jump to parent rust module'},
          ['<leader>fc'] = {'<cmd>RustOpenCargo<cr>', 'Open Cargo.toml'},
          ['<leader>eJ'] = {'<cmd>RustJoinLines<cr>', 'Join rust lines'},
          ['<leader>ej'] = {'<cmd>RustMoveItemDown<cr>', 'Move Rust item down'},
          ['<leader>ek'] = {'<cmd>RustMoveItemUp<cr>', 'Move Rust item up'},
          ['<leader>ex'] = {'<cmd>RustExpandMacro<cr>', 'Expand Rust macro'},
          -- Is this a good idea?
          ['J'] = {'<cmd>RustJoinLines<cr>', 'Join rust lines'}
        }, {buffer=bufnr})
      end

      require('rust-tools').setup({
        server = {
          on_attach = rust_attach,
          settings = {
            -- See https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
            ["rust-analyzer"] = {
                -- Run clippy on save
                checkOnSave = {
                    command = "clippy"
                },
            }
          },
          flags = {
            debounce_text_changes = 150
          }
        }
      })
    end
  }

  -- Manage crates in Cargo.toml: https://github.co/Saecki/crates.nvim
  use {
    'Saecki/crates.nvim',
    -- Load lazily when visiting cargo files
    event = { "BufRead Cargo.toml" },
    config = function()
      require('crates').setup()
    end
  }

  -- Fugitive: https://github.com/tpope/vim-fugitive
  use {
    'tpope/vim-fugitive',
    opt = true,
    cmd = {'Git', 'Gvdiffsplit', 'Ghdiffsplit', 'Gdiffsplit'},
    setup = function()
      require('which-key').register {
        ['<leader>gc'] = {'<cmd>Git commit<cr>', 'Git commit'},
        ['<leader>gg'] = {'<cmd>Git<cr>', 'Git status'}
      }
    end
  }
end)
