" ~/.vimrc
" ref: http://dougblack.io/words/a-good-vimrc.html

syntax enable
set tabstop=4
set softtabstop=4
"set expandtab       " tabs are spaces

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
