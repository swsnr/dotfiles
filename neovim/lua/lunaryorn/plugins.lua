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
-- - https://github.com/ms-jpq/coq_nvim
-- - https://github.com/nvim-telescope/telescope-symbols.nvim
-- - https://github.com/airblade/vim-rooter
--
-- https://github.com/rockerBOO/awesome-neovim is a great source of inspiration.

return packer.startup(function(use)
  -- This package manager: https://github.com/wbthomason/packer.nvim
  use 'wbthomason/packer.nvim'

  -- Documented keybindings: https://github.com/folke/which-key.nvim
  use {
    "folke/which-key.nvim",
    config = function()
      local wk = require("which-key")
      wk.setup()
      wk.register{
        ['[d'] = {vim.diagnostic.goto_prev, 'Previous diagnostic'},
        [']d'] = {vim.diagnostic.goto_next, 'Next diagnostic'},
        -- Global bindings
        ['<leader> '] = {'<cmd>Telescope commands<cr>', 'Commands'},
        ['<leader>?'] = {'<cmd>Telescope<cr>', 'Pickers'},
        -- Buffers
        ['<leader>b'] = {name='+buffers'},
        ['<leader>bb'] = {'<cmd>Telescope buffers<cr>', 'List buffers'},
        -- Editing
        ['<leader>e'] = {name='+edit'},
        ['<leader>er'] = {'<cmd>Telescope registers<cr>', 'Paste register'},
        -- Files
        ['<leader>f'] = {name='+files'},
        ['<leader>ff'] = {'<cmd>Telescope find_files<cr>', 'Find files'},
        -- Git
        ['<leader>g'] = {name='+git'},
        ['<leader>gf'] = {'<cmd>Telescope git_files<cr>', 'Git files'},
        -- Help
        ['<leader>h'] = {name='+help'},
        ['<leader>hh'] = {'<cmd>Telescope help_tags<cr>', 'Tags'},
        ['<leader>hk'] = {'<cmd>Telescope keymaps<cr>', 'Keys'},
        ['<leader>hm'] = {'<cmd>Telescope man_pages<cr>', 'Man pages'},
        -- Jumping
        ['<leader>j'] = {name='+jump'},
        ['<leader>jj'] = {'<cmd>Telescope jumplist<cr>', 'Jumplist'},
        ['<leader>jl'] = {'<cmd>Telescope loclist<cr>', 'Location list'},
        ['<leader>jq'] = {'<cmd>Telescope quickfix<cr>', 'Quickfix list'},
        ['<leader>jm'] = {'<cmd>Telescope marks<cr>', 'Marks'},
        -- Lists
        ['<leader>l'] = {name='+lists'},
        -- Search
        ['<leader>s'] = {name='+search'},
        ['<leader>sg'] = {'<cmd>Telescope live_grep<cr>', 'Live grep'},
        ['<leader>sc'] = {'<cmd>Telescope grep_string<cr>', 'Grep under cursor'},
        -- Windows
        ['<leader>w'] = {name='+windows'},
        ['<leader>w/'] = {'<cmd>vsplit<cr>', 'Split vertical'},
        ['<leader>w-'] = {'<cmd>split<cr>', 'Split horizontal'},
        ['<leader>wo'] = {'<cmd>only<cr>', 'Only current window'},
        ['<leader>wq'] = {'<cmd>q<cr>', 'Quit'},
        -- Execute things
        ['<leader>x'] = {name='+execute'},
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

  -- Solarized light color schema: https://github.com/ishan9299/nvim-solarized-lua
  --[[ use {
    'ishan9299/nvim-solarized-lua',
    config = function()
      vim.cmd('colorscheme solarized')
    end

  } ]]

  use {
    'folke/tokyonight.nvim',
    config = function()
      vim.cmd[[colorscheme tokyonight]]
    end
  }

  -- Dracula colour scheme: https://github.com/Mofiqul/dracula.nvim
  --[[ use {
    'Mofiqul/dracula.nvim',
    config = function()
      vim.g.dracula_italic_comment = true
      vim.cmd('colorscheme dracula')
    end
  } ]]

  -- Lualine: https://github.com/nvim-lualine/lualine.nvim
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', 'SmiteshP/nvim-gps' },
    config = function()
      local gps = require('nvim-gps')
      require('lualine').setup {
        theme = 'tokyonight',
        sections = {
          lualine_c = {
            'filename',
            { gps.get_location, cond = gps.is_available },
          },
        }
      }
    end
  }

  -- Autopairs: https://github.com/windwp/nvim-autopairs
  use {
    'windwp/nvim-autopairs',
    config = function() require('nvim-autopairs').setup() end
  }

  -- Edit pairs: https://github.com/machakann/vim-sandwich
  use {
    'machakann/vim-sandwich',
    config = function()
      -- Use vim-surround mappings for sandwich to avoid conflicts with
      -- lightspeed:
      -- https://github.com/machakann/vim-sandwich/wiki/Introduce-vim-surround-keymappings
      -- https://github.com/ggandor/lightspeed.nvim/discussions/60
      vim.cmd('runtime macros/sandwich/keymap/surround.vim')
    end
  }

  -- Modern syntax highlighting: https://github.com/nvim-treesitter/nvim-treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    -- Require a few extra plugins and extensions for treesitter
    requires = {
      -- Text objects for treesitter, configured above, see https://github.com/nvim-treesitter/nvim-treesitter-textobjects
      'nvim-treesitter/nvim-treesitter-textobjects',
      -- Automatically change comment string according to current context
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    -- Make sure parsers are up to date
    run = ':TSUpdate',
    config = function()
      -- Use treesitter folding
      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

      require('nvim-treesitter.configs').setup {
        -- Install all maintained parsers
        ensure_installed = {
          'bash',
          'bibtex',
          'c',
          'comment',
          'css',
          'dockerfile',
          'dot',
          'graphql',
          'hocon',
          'javascript',
          'json',
          'json5',
          'latex',
          'lua',
          'rust',
          'scala',
          'toml',
          'typescript',
          'vim',
          'yaml',
        },
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
        -- Automatically update comment string
        context_commentstring = { enable = true },
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
        },
      }

      require('which-key').register{
        ['gnn'] = 'Init selection',
        ['grn'] = 'Increase selection by node',
        ['grc'] = 'Increase selection by scope',
        ['grm'] = 'Decrement selection by node',
        [']a'] = 'Next start of parameter',
        [']A'] = 'Next end of parameter',
        [']f'] = 'Next start of function',
        [']F'] = 'Next end of function',
        ['[a'] = 'Previous start of parameter',
        ['[A'] = 'Previous end of parameter',
        ['[f'] = 'Previous start of function',
        ['[F'] = 'Previous end of function',
      }
    end
  }

  -- Treesitter for the status line: https://github.com/SmiteshP/nvim-gps
  use {
    'SmiteshP/nvim-gps',
    requires = "nvim-treesitter/nvim-treesitter",
    config = function()
      require('nvim-gps').setup()
    end
  }

  -- LSP: https://github.com/neovim/nvim-lspconfig
  use {
    'neovim/nvim-lspconfig',
    config = function()
      local servers = {}
      for _, lsp in pairs(servers) do
        require('lspconfig')[lsp].setup {
          on_attach = require('lunaryorn.lsp').lsp_attach,
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
        on_attach = require('lunaryorn.lsp').lsp_attach,
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
      vim.cmd [[
      augroup lightbulb
        au!
        autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()
      augroup END
      ]]
    end
  }

  -- Very convenient and fast motions: https://github.com/ggandor/lightspeed.nvim
  use { 'ggandor/lightspeed.nvim' }

  -- Strip trailing whitespace the clever way: https://github.com/axelf4/vim-strip-trailing-whitespace
  use { 'axelf4/vim-strip-trailing-whitespace' }

  -- Commenting: https://github.com/b3nj5m1n/kommentary
  use {
    'b3nj5m1n/kommentary',
    config = function()
      require('which-key').register{
        ['gc'] = {name='+comment'},
        ['gcc'] = 'Toggle line',
      }
    end
  }

  -- Rust helpers: https://github.com/simrat39/rust-tools.nvim
  use {
    'simrat39/rust-tools.nvim',
    config = function()
      local function rust_attach(client, bufnr)
        -- Default setup for LSP buffers
        require('lunaryorn.lsp').lsp_attach(client, bufnr)

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

  -- Git signs: https://github.com/lewis6991/gitsigns.nvim
  use {
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup {
        on_attach = function(bufnr)
          local wk = require('which-key')
          wk.register({
            [']c'] = {"&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", 'Next git hunk', expr=true},
            ['[c'] = {"&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", 'Previous git hunk', expr=true},
            ['<leader>gb'] = {function() require('gitsigns').blame_line{full=true} end, 'Blame current line'},
            ['<leader>gd'] = {'<cmd>Gitsigns diffthis<cr>', 'Diff against index'},
            ['<leader>gD'] = {'<cmd>Gitsigns toggle_deleted<cr>', 'Toggle deleted lines'},
            ['<leader>gp'] = {'<cmd>Gitsigns preview_hunk<cr>', 'Preview hunk' },
            ['<leader>gR'] = {'<cmd>Gitsigns reset_buffer<cr>', 'Reset buffer to staged' },
            ['<leader>gr'] = {'<cmd>Gitsigns reset_hunk<cr>', 'Reset hunk to staged' },
            ['<leader>gS'] = {'<cmd>Gitsigns stage_buffer<cr>', 'Stage buffer' },
            ['<leader>gs'] = {'<cmd>Gitsigns stage_hunk<cr>', 'Stage hunk' },
            ['<leader>gu'] = {'<cmd>Gitsigns undo_stage_hunk<cr>', 'Undo staged hunk' },
          }, {buffer = bufnr})

          wk.register({
            ['<leader>gr'] = {'<cmd>Gitsigns reset_hunk<cr>', 'Reset hunk to staged' },
            ['<leader>gs'] = {'<cmd>Gitsigns stage_hunk<cr>', 'Stage hunk' },
          }, {buffer = bufnr, mode = 'v'})

          -- Text object; TODO: Migrate to which-key
          --map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
          --map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end
      }
    end
  }

  -- Merging with vim: https://github.com/samoshkin/vim-mergetool
  use {
    'https://github.com/samoshkin/vim-mergetool',
    opt = true,
    cmd = {'MergetoolStart', 'MergetoolToggle'}
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

  -- File explorer sidebar: https://github.com/kyazdani42/nvim-tree.lua
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
      require'nvim-tree'.setup {}

      require('which-key').register {
        ['<leader>ft'] = {'<cmd>NvimTreeFindFileToggle<cr>', 'Show current file in tre,e'},
        ['<leader>fT'] = {'<cmd>NvimTreeFocus<cr>', 'Open file explorer'},
      }
    end
  }

  -- Fuzzy finder: https://github.com/nvim-telescope/telescope.nvim
  use {
    'nvim-telescope/telescope.nvim',
    requires = {'nvim-lua/plenary.nvim'},
    config = function()
      local trouble = require("trouble.providers.telescope")
      require('telescope').setup {
        defaults = {
          mappings = {
            i = { ["<c-t>"] = trouble.open_with_trouble },
            n = { ["<c-t>"] = trouble.open_with_trouble },
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

  -- Automatically setup configuration after cloning packer
  if packer_bootstrap then
    require('packer').sync()
  end
end)
