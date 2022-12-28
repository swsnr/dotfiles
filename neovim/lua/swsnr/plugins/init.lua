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
  -- Color scheme
  {
    "folke/tokyonight.nvim",
    -- Make sure we load at startup, first of all
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night"
      })
      -- load the colorscheme here
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
  { 
    'folke/which-key.nvim',
    lazy = true,
    config = {
      -- show_help = false,
      plugins = { spelling = true },
      key_labels = { ["<leader>"] = "SPC" },  
    }
  },
  {
    'nvim-telescope/telescope.nvim',
    -- Load telescope right away so that the ui-select replacement kicks in, and
    -- we'll likely use telescope anyway.
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Telescope extensions we set up right away
      'nvim-telescope/telescope-ui-select.nvim',
      'jvgrootveld/telescope-zoxide'
    },
    config = function()
      local t = require('telescope')
      local trouble = require("trouble.providers.telescope")
      t.setup {
        defaults = {
          mappings = {
            i = { ["<c-t>"] = trouble.open_with_trouble },
            n = { ["<c-t>"] = trouble.open_with_trouble },
          }
        }
      }

      -- Redirect vim's ui select to telescope
      t.load_extension('ui-select')
      t.load_extension('zoxide')
    end
  },
  {
    'kyazdani42/nvim-tree.lua',
    cmd = { 'NvimTreeFindFileToggle', 'NvimTreeFocus' },
    config = {
      system_open = {
        cmd = 'gio',
        args = {'open'},
      }
    }
  },
  {
    'lewis6991/gitsigns.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'BufReadPre',
    config = {
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
  },
  {
    'folke/trouble.nvim',
    cmd = 'TroubleToggle',
    config = {
      icons = false,
      fold_open = "v",
      fold_closed = ">",
      indent_lines = true,
      signs = {
        error = "error",
        warning = "warn",
        hint = "hint",
        information = "info"
      },
      use_diagnostic_signs = true
    }
  },
  {
    'samoshkin/vim-mergetool',
    cmd = {'MergetoolStart', 'MergetoolToggle'},
  },
  {
    'ggandor/leap.nvim',
    event = 'VeryLazy',
    -- TODO: Test this
    -- dependencies = {
    --   { "ggandor/flit.nvim", config = { labeled_modes = "nv" } },
    -- },
    config = function()
      require('leap').add_default_mappings()
    end
  },
  {
    'windwp/nvim-autopairs',
    event = 'VeryLazy',
    config = true,
  },
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    config = true,
  },
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    config = true,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufReadPre',
    config = {
      use_treesitter = true,
      show_current_context = true,
      show_current_context_start = true,
    }
  },
  {
    'axelf4/vim-strip-trailing-whitespace',
    event = 'BufReadPre',
  }
}
