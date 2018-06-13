" ~/.vimrc
" ref: http://dougblack.io/words/a-good-vimrc.html

syntax enable

" Linux kernel style
" see: https://kernelnewbies.org/FirstKernelPatch
set tabstop=8
set softtabstop=8
set shiftwidth=8
set noexpandtab

set number
set showcmd             " show command in bottom bar
"set cursorline          " highlight current line
set autoindent

set wildmenu            " visual autocomplete for command menu
set showmatch           " highlight matching [{()}]

set incsearch           " search as characters are entered
set hlsearch            " highlight matches
" turn off search highlight
nnoremap <leader><space> :nohlsearch<CR>
colorscheme zellner

