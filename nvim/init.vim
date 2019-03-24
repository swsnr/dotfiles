" Copyright 2019 Sebastian Wiesner <sebastian@swsnr.de>
"
" Licensed under the Apache License, Version 2.0 (the "License"); you may not
" use this file except in compliance with the License. You may obtain a copy of
" the License at
"
"     http://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
" WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
" License for the specific language governing permissions and limitations under
" the License.

" Enable 256 colours in terminal
set termguicolors
" Adapt background color, see colors.fish
if $LY_TERM_BACKGROUND == 'light'
  set background=light
else
  set background=dark
end
let g:solarized_term_italics=1
colorscheme solarized8
" Use light background in GUIs
autocmd guienter * set background=light

" Line numbers relative to current line
set number " Line numbers…
set relativenumber " …relative to current line
set textwidth=80
set colorcolumn=+1
set expandtab " No tabs
set shiftwidth=2 " Indent by two spaces
set spell " Spell checking
set splitright " Make vsplit split to the right instead of left
set splitbelow " Make split split below instead of above
let g:better_whitespace_enabled=1
let g:strip_whitespace_on_save=1

" Leader settings
let mapleader = ' '
let maplocalleader = ','

inoremap fd <Esc>

" Simpler navigation for splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Format current paragraph/selection easily
nnoremap Q gqip
vnoremap Q gq

" Applications & tools
nnoremap <leader>at :split <bar> :resize 15 <bar> :terminal<cr>

" Buffers
nnoremap <leader>bn :bnext<cr>
nnoremap <leader>bp :bprevious<cr>
nnoremap <leader>bq :bdelete<cr>

" Errors (Quickfix list)
nnoremap <leader>ee :cc!<cr>
nnoremap <leader>en :cnext<cr>
nnoremap <leader>eo :copen<cr>
nnoremap <leader>ep :cprevious<cr>

" File commands
nnoremap <leader>fi :e ~/.config/nvim/init.vim<cr>

" Locations
nnoremap <leader>ll :ll!<cr>
nnoremap <leader>lo :lopen<cr>
nnoremap <leader>ln :lnext<cr>
nnoremap <leader>lp :lprevious<cr>

" Commands for windows and splits
nnoremap <leader>w/ :vsplit<cr>
nnoremap <leader>w- :split<cr>
nnoremap <leader>wq :q<cr>

" Text commands
nnoremap <leader>xw :StripWhitespace<cr>

augroup fish
  au!
  autocmd filetype fish setlocal foldmethod=expr shiftwidth=4
  autocmd filetype fish compiler fish
augroup END
