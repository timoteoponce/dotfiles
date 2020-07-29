" set leader key to comma
let mapleader = ","

"escape key to jj
imap jj <Esc>¬
"ignore common things on nerdtree
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$\|\.hg$\|\.svn$\|\.yardoc$|target$|build$',
  \ 'file': '\.exe$\|\.so$\|\.dat$|\.jar$|\.class$|\.orig$'
  \ }

""let g:buffergator_viewport_split_policy="T"
"yank and paste shortcuts
noremap <Leader>y "*y
noremap <Leader>p "*p
noremap <Leader>Y "+y
noremap <Leader>P "+p

"highlight current line
set cursorline
hi cursorline cterm=none term=none
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
highlight CursorLine guibg=#303000 ctermbg=234

"remove swap files
set noswapfile

" enable mouse resize on panes
set mouse=n
" default for line breaks
set wrap
set linebreak
