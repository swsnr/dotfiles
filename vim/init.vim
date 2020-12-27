" Copyright 2020 Sebastian Wiesner <sebastian@swsnr.de>
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

" {{{ User interface
" If we've got information about terminal background (see config.fish) use it to
" adapt the color scheme to the terminal background.
if $LY_TERM_BACKGROUND == 'light'
  set background=light
else
  set background=dark
end
" }}}

" {{{ Text editing
" Line numbers relative to current line
set number " Line numbers…
set relativenumber " …relative to current line
set textwidth=80
set colorcolumn=+1
set expandtab " No tabs
set shiftwidth=2 " Indent by two spaces
" }}}

" {{{ Buffers and windows
set hidden " Hide abandoned buffers
set autoread " Auto-reload unchanged buffers
set autowrite " Write files before make
set splitright " Make vsplit split to the right instead of left
set splitbelow " Make split split below instead of above
" }}}

" {{{ Search
set ignorecase " Ignore case when searching…
set smartcase " …for all-lowercase patterns

if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
" }}}

" {{{ Key bindings
" Leader settings
let mapleader = ' '
let maplocalleader = ','

inoremap jk <Esc>

" Simpler navigation for splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
" Format current paragraph/selection easily
nnoremap Q gqip
vnoremap Q gq

" {{{ Leader bindings
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

" Make
nnoremap <leader>m :make

" Commands for windows and splits
nnoremap <leader>w/ :vsplit<cr>
nnoremap <leader>w- :split<cr>
nnoremap <leader>wq :q<cr>

" Text commands
nnoremap <leader>xf gggqG
nnoremap <leader>xi gg=qG
" }}}
" }}}

" {{{ Version control
augroup vc_git
  au!
  " Automatically start insert mode in a new first line in Git commit messages,
  " to that I can start typing my message right away without having to press i
  " first
  autocmd BufRead COMMIT_EDITMSG execute "normal! gg" | execute "normal! O" | startinsert
augroup END
" }}}
" vim: fdm=marker
