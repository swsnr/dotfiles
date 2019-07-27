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

" TODO: Notable plugins:
" 'vim-airline/vim-airline' " Better status line (plus themes)
" 'vim-airline/vim-airline-themes'
" 'Shougo/denite.nvim' " Quick jump
" 'padde/jump.vim' " Autojump for Vim
" 'justinmk/vim-sneak' " A fast / for quick motion to char sequences
" 'Shougo/deoplete.nvim' " Completion
" 'scrooloose/nerdcommenter' " Commenting and uncommenting
" 'wellle/targets.vim' " Additional text objects and motions
" 'jiangmiao/auto-pairs' " Auto-insert closing pairs
" 'mhinz/vim-grepper' " Better grepping for vim
" 'airblade/vim-gitgutter' " Highlight changed hunks in editor
" 'antoyo/vim-licenses' " Insert licenses in buffers
" 'neomake/neomake' " Asychronously compile/check buffers
" 'sbdchd/neoformat' " Format files

" {{{ User interface
" If we've got information about terminal background (see colors.fish) use it to
" adapt the color scheme to the terminal background.
if $LY_TERM_BACKGROUND == 'light'
  set background=light
else
  set background=dark
end
if $TERM !~ 'screen'
  " Unless in screen/tmux assume a modern terminal and enable true color
  " support, to make solarized use the real solarized palette.
  set termguicolors
end
let g:solarized_term_italics=1 " Enable italics in color scheme
colorscheme solarized8
" Use light background in GUIs
autocmd guienter * set background=light
" }}}

" {{{ Text editing
" Line numbers relative to current line
set number " Line numbers…
set relativenumber " …relative to current line
set textwidth=80
set colorcolumn=+1
set expandtab " No tabs
set shiftwidth=2 " Indent by two spaces
let g:better_whitespace_enabled=1
let g:strip_whitespace_on_save=1
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

" Git
nnoremap <leader>gA :Gwrite<cr>
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>gg :GitGutterToggle<cr>
nnoremap <leader>gl :Glog<cr>
nnoremap <leader>gm :Gmove<cr>
nnoremap <leader>gP :Gpull<cr>
nnoremap <leader>gp :Gpush<cr>
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gX :Gremove<cr>

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
nnoremap <leader>xw :StripWhitespace<cr>
" }}}
" }}}

" {{{ Version control
augroup vc_git
  au!
  " Prevent flooding with fugitive buffers
  autocmd BufReadPost fugitive://* set bufhidden=delete
  " Automatically start insert mode in a new first line in Git commit messages,
  " to that I can start typing my message right away without having to press i
  " first
  autocmd BufRead COMMIT_EDITMSG execute "normal! gg" | execute "normal! O" | startinsert
augroup END
" }}}

" {{{ File types
" {{{ Fish
augroup fish
  au!
  autocmd filetype fish setlocal foldmethod=expr shiftwidth=4
  autocmd filetype fish compiler fish
augroup END
" }}}

" {{{ Rust
let g:rustfmt_autosave = 1
augroup rust
  au!
  au filetype rust map <buffer> <localleader>b :silent make build <Bar> cwindow 25<cr>
  au filetype rust map <buffer> <localleader>c :silent make check <Bar> cwindow 25<cr>
augroup END
" }}}

" {{{ Scala
let g:scala_scaladoc_indent=1 " Scaladoc indent for doc comments
let g:scala_sort_across_groups=1 " Sort imports into groups
augroup scala
  au!
  " Use scala filetype for SBT files, as it works better
  au BufRead,BufNewFile *.sbt set filetype=scala
augroup END
" }}}

" {{{ Python
augroup python
  au!
  au filetype python setlocal formatprg=autopep8\ -
augroup END
" }}}

" {{{ Groovy (mostly Jenkinsfile)
augroup groovy
  au!
  au BufRead,BufNewFile *Jenkinsfile set filetype=groovy
  au filetype groovy setlocal foldmethod=expr shiftwidth=4
augroup END
" }}}
" }}}

" vim: fdm=marker
