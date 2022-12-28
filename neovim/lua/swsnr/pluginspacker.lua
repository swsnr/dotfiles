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
