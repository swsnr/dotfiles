" Copyright 2018-2019 Sebastian Wiesner <sebastian@swsnr.de>
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

" TODO: Try these plugins:
"
" https://github.com/autozimu/LanguageClient-neovim (lang server for neovim)

" {{{Install plugins
call plug#begin('~/.local/share/nvim/plugged')

" UI plugins
Plug 'dracula/vim', { 'as': 'dracula' } " Color scheme
Plug 'vim-airline/vim-airline' " Better status line (plus themes)
Plug 'vim-airline/vim-airline-themes'
Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' } " Quick jump
Plug 'padde/jump.vim' " Autojump for Vim
" Navigation & motion plugins
Plug 'justinmk/vim-sneak' " A fast / for quick motion to char sequences
" Editing plugins
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' } " Completion
Plug 'ntpeters/vim-better-whitespace' " Highlight and cleanup whitespace
Plug 'scrooloose/nerdcommenter' " Commenting and uncommenting
Plug 'tpope/vim-surround' " Surround text with quotes, tags and parens
Plug 'wellle/targets.vim' " Additional text objects and motions
Plug 'jiangmiao/auto-pairs' " Auto-insert closing pairs
" Search
Plug 'mhinz/vim-grepper' " Better grepping for vim
" Git
Plug 'airblade/vim-gitgutter' " Highlight changed hunks in editor
Plug 'tpope/vim-fugitive' " A great Git frontend
" Utilities
Plug 'antoyo/vim-licenses' " Insert licenses in buffers
Plug 'neomake/neomake' " Asychronously compile/check buffers
Plug 'sbdchd/neoformat' " Format files

" Initialize plugin system
call plug#end()
" }}}

" {{{ UI settings
" Use Solarized Light, with all font styles, and enable full true colors on TTYs
Plug 'vim-airline/vim-airline' " Better status line
Plug 'vim-airline/vim-airline' " Better status line
" to use the real solarized palette regardless of the TTY colours.
set termguicolors
" Solarized light
colorscheme dracula

" Use solarized light for Airline as well, and some fancy unicode separators
let g:airline_theme = 'solarized'
let g:airline_solarized_bg = 'light'
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_left_sep = '❫'
let g:airline_right_sep = '❪'

set visualbell " Don't beep, please
" Hybrid line numbers: Show the absolute line number on the current line, and
" relative numbers before and after
set number
set relativenumber

" Enable mouse in TUI, see https://github.com/neovim/neovim/pull/6022
set mouse=a
" }}}

" {{{ Windows and buffers
" Open splits below and to the right which is more natural imho
set splitbelow
set splitright
set hidden " Hide buffers instead of closing them

augroup windows_and_buffers
  au!
  " Autosave current buffer when going to normal mode or switching to another
  " buffer.
  autocmd InsertLeave * silent! write
  autocmd BufLeave * silent! write
augroup END
" }}}

" {{{ Files
set autoread " Automatically reload on changes

function! s:RevealInFinder()
  let l:command = "open -R " . shellescape("%")
  execute ":silent! !" . l:command
endfunction
command! RevealInFinder :call <SID>RevealInFinder()

" Add custom source to find files from Git
call denite#custom#alias('source', 'file_rec/git', 'file_rec')
call denite#custom#var('file_rec/git', 'command',
      \ ['git', 'ls-files', '-co', '--exclude-standard'])

" Configure netrw
let g:sneak#map_netrw = 0 " Sneak, please don't touch s in netrw buffers
let g:netrw_home = '~/.local/share/nvim' " Move netrw history to proper place
let g:netrw_liststyle = 1 " Long listings in netrw
" }}}

" {{{ Search
set ignorecase " Ignore case when searching or matching…
set smartcase " …but only if the pattern is all lowercase

" Use rg for :grep
if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
" }}}

" {{{ Editing settings
set textwidth=80 " Wrap text at 80 characters
set colorcolumn=+1 " Color the column after the maximum column
set formatoptions-=t " Do not wrap text outside of comments by default
set scrolloff=5 " Keep some lines around cursor for better context
set expandtab " Indent with spaces by default
set shiftwidth=2 " Shift by two spaces
set softtabstop=2 " Move by two spaces on TAB
set foldmethod=marker " Fold with manual fold markers
set spell " Enable spell checking
" Automatically remove excess whitespace when saving buffers
autocmd BufEnter * EnableStripWhitespaceOnSave

let g:hardtime_default_on = 1 " Prevent repetition of hjkl
let g:deoplete#enable_at_startup = 1 " Enable completion with deoplete

" Comments with NerdCommenter: Add spaces after delimiters, allow to comment
" empty lines and automatically trim trailing whitespaces when uncommenting
let g:NERDSpaceDelims = 1
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
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

" {{{ Utilities
" Insert licenses into buffers
let g:licenses_copyright_holders_name = 'Sebastian Wiesner <sebastian@swsnr.de>'
let g:licenses_authors_name = 'Sebastian Wiesner'
let g:licenses_default_commands = ['gpl', 'mit', 'apache']

" Automatically check code on save
augroup make
  au!
  autocmd BufWritePost * Neomake
augroup END

" Add a preliminary scala formatter
let g:neoformat_scala_scalafmt = {
  \ 'exe': 'scalafmt',
  \ 'args': ['--stdin', '--assume-filename', '%:p'],
  \ 'stdin': 1,
  \ }

" let g:neoformat_enabled_scala = ['scalafmt']
" }}}

" {{{ Bindings
" Leader settings
let mapleader = ' '
let maplocalleader = ','

" Easily get back into command mode
inoremap fd <Esc>

" Simpler navigation for splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
" This binding doesn't work in terminal with neovim 0.1.7 or older, see
" https://github.com/neovim/neovim/wiki/FAQ#my-ctrl-h-mapping-doesnt-work
nnoremap <C-H> <C-W><C-H>

" Format current paragraph/selection easily
nnoremap Q gqip
vnoremap Q gq

" Use TAB to navigate popup menus
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" {{{ Leader bindings
" Applications & tools
nnoremap <leader>at :split <bar> :resize 15 <bar> :terminal<cr>

" Buffers
nnoremap <leader>bb :Denite buffer<cr>
nnoremap <leader>bn :bnext<cr>
nnoremap <leader>bp :bprevious<cr>
nnoremap <leader>bq :bdelete<cr>

" <leader>c is occupied by NerdCommenter!

" Errors (Quickfix list)
nnoremap <leader>ee :cc!<cr>
nnoremap <leader>en :cnext<cr>
nnoremap <leader>eo :copen<cr>
nnoremap <leader>ep :cprevious<cr>

" File commands
" Find files, in Git, if in a Git repository, or with the standard file_rec
" source otherwise
nnoremap <leader>fc :Denite directory_rec<cr>
nnoremap <leader>ff :Denite
      \ `finddir('.git', ';') != '' ? 'file_rec/git' : 'file_rec'`<cr>
nnoremap <leader>fi :e ~/.config/nvim/init.vim<cr>
nnoremap <leader>fj :Explore<cr>
nnoremap <leader>fr :RevealInFinder<cr>

" Git commands
nnoremap <leader>gA :Gwrite<cr>
nmap <leader>ga <Plug>GitGutterStageHunk
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>gg :GitGutterToggle<cr>
nnoremap <leader>gl :Glog<cr>
nnoremap <leader>gm :Gmove<cr>
nnoremap <leader>gP :Gpull<cr>
nnoremap <leader>gp :Gpush<cr>
nmap <leader>gr <Plug>GitGutterUndoHunk
nnoremap <leader>gs :Gstatus<cr>
nmap <leader>gv <Plug>GitGutterPreviewHunk
nnoremap <leader>gX :Gremove<cr>

" Locations
nnoremap <leader>ll :ll!<cr>
nnoremap <leader>lo :lopen<cr>
nnoremap <leader>ln :lnext<cr>
nnoremap <leader>lp :lprevious<cr>

" Make
nnoremap <leader>m :Neomake!<cr>
nnoremap <leader>M :Neomake!

" Projects
nnoremap <leader>pf :Denite file_rec/git<cr>

" Search
nnoremap <leader>ss :Grepper -tool rg<cr>
nnoremap <leader>s* :Grepper -tool rg -cword -noprompt<cr>

" Commands for windows and splits
nnoremap <leader>w/ :vsplit<cr>
nnoremap <leader>w- :split<cr>
nnoremap <leader>wq :q<cr>

" Commands on text
nnoremap <leader>xf :Neoformat<cr>
nnoremap <leader>xw :StripWhitespace<cr>

" }}}

" }}}

" {{{ Languages
" {{{ Git config
augroup gitconfig
  au!
  " git config files are indented with tabs
  autocmd FileType gitconfig setlocal noexpandtab tabstop=8 shiftwidth=8
" }}}

" {{{ Fish
augroup fish
  au!
  " Fish wants four spaces for indentation
  autocmd FileType fish setlocal shiftwidth=4 softtabstop=4
augroup END
" }}}

" {{{ LaTeX
let g:vimtex_fold_enabled = 1 " Enable folding
" Configure the latexmk compiler to use a custom set of options. In particular,
" remove -pdf from the default options so that vimtex doesn't override my global
" lualatex choice.  Also disable callback, see
" https://github.com/lervag/vimtex/issues/250
let g:vimtex_compiler_latexmk = {
      \ 'options': ['-verbose', '-file-line-error', '-synctex=1', '-interaction=nonstopmode'],
      \ 'callback': 0,
      \ }
" See https://github.com/lervag/vimtex/issues/767
let g:vimtex_quickfix_latexlog = {'fix_paths':0}
" View output with Skim
let g:vimtex_view_general_viewer
      \ = '/Applications/Skim.app/Contents/SharedSupport/displayline'
let g:vimtex_view_general_options = '-r @line @pdf @tex'
" }}}

" }}}
