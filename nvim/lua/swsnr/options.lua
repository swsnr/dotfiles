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

-- Options.

-- neovide settings
vim.g.neovide_cursor_vfx_mode = "pixiedust"
vim.g.neovide_remember_window_size = true
-- Gui settings: JetBrains Mono as standard font, and Noto for emojis
vim.opt.guifont = "JetBrains Mono,Noto Color Emoji:h11"
vim.opt.mouse = "a" -- Enable mouse in all modes
if vim.g["neovide"] then
  -- In neovide use a light background by default
  vim.opt.background = "light"
end

-- Terminal options
-- Enable 24bit RGB colours for terminals; this enables perfect color theme
-- colours, but requires a modern terminal.  But then again we're using a modern
-- neovim, so we'll also have a modern terminal 8)
vim.opt.termguicolors = true

-- Options for the general user interface
vim.opt.updatetime = 300 -- Update faster
vim.opt.showmode = false -- Don't show mode message in message line
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.timeoutlen = 500 -- Key timeout after 500, for which key
-- Always keep some context
vim.opt.sidescrolloff = 8
vim.opt.scrolloff = 8

-- Options for files and buffers
vim.opt.autowrite = true
vim.opt.hidden = true

-- Completion: Always show a menu even if there's just one candidate, never
-- insert automatically and never preselect an entry in the completion menuselect.
vim.opt.completeopt = { "menuone", "noinsert", "noselect" }
vim.opt.shortmess:append({ c = true })

-- Options for text editing
vim.opt.wrap = false -- Don't wrap long lines
vim.opt.number = true -- Enable line numbers…
vim.opt.relativenumber = true -- … relative to the current line.
vim.opt.textwidth = 80 -- 80 characters per line by default
vim.opt.colorcolumn = "+1" -- Add marker for overlong lines
vim.opt.expandtab = true -- No tabs
vim.opt.shiftwidth = 2 -- Indent with two spaces by default
vim.opt.cursorline = true -- Highlight line of cursor
vim.opt.conceallevel = 3 -- Hide * markup for bold and italic
vim.opt.formatoptions = "jcroqlnt"

-- Folding
vim.opt.foldmethod = "indent" -- Fold by indentation by default
vim.opt.foldlevelstart = 10 -- Fold deeply nested indents automatically

-- Options for buffers and windows
vim.opt.splitright = true -- vsplit rightwards
vim.opt.splitbelow = true -- split downwards

-- Options for searching
vim.opt.ignorecase = true -- Ignore case when searching…
vim.opt.smartcase = true -- …for all lowercase patterns
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

-- Avoid xdg-open
vim.g.netrw_browsex_viewer = "gio open"
