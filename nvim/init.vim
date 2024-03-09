""""""""""""
" Behaviour

" ignore case when searching
set ignorecase
" case sensitive search only if uppercase characters are used
set smartcase

" EOL settings
set ffs=unix,dos,mac

" no backups
set nobackup
set nowb
set noswapfile

" allow modified/unsaved buffers
set hid

" backspace and cursor keys wrap to previous/next line
set backspace=indent,eol,start whichwrap+=<,>,[,]

" disable auto insertion of comments
autocmd BufEnter * set formatoptions-=cro

set viminfo=

" disable annoying formatting for html (help html.vim)
let html_no_rendering=1

" splitting a window will put it below the current one.
set splitbelow
" splitting a window will put it to the right of the current one.
set splitright

"""""""""""
" GUI setup

" highlight with gui colors when running in terminal
set termguicolors

" load colorscheme
set background=dark
colorscheme 4colors

" fill vertical bar with dots
set fillchars+=vert:.

"""""""""""""""
" Key mappings

" setup leader
let mapleader = ","
let g:mapleader = ","
let maplocalleader = ","

if has("clipboard")
  vmap <C-x> "+x
  smap <C-x> <C-g>"+x
  nmap <silent> <C-X> :call CutNonEmptyLineToClipboard()<CR>
else
  vmap <C-x> "cx
  smap <C-x> <C-g>"cx
  nmap <silent> <C-X> :call CutNonEmptyLineToCReg()<CR>
endif

" If the current line is non-empty cut it to the clipboard
" An empty line is put into the black hole registry
function! CutNonEmptyLineToClipboard()
    if match(getline('.'), '^\s*$') == -1
        normal 0"+d$
    else
        normal "_dd
    endif
endfunction

function! CutNonEmptyLineToCReg()
    if match(getline('.'), '^\s*$') == -1
        normal 0"cd$
    else
        normal "_dd
    endif
endfunction

if has("clipboard")
  " CTRL-C is copy, CTRL-V paste is enabled by default
  vmap <C-C> "+y
endif

" paste over a visual selection yanks previous selection rather than selected text
xnoremap p pgvy

" Use CTRL-Q to do what CTRL-V used to do - enabled by default in nvim
" noremap <C-Q>   <C-V>

" close(wipe) the current buffer without closing the window
map <leader>d :BufstopBack<CR>:bw! #<CR>

noremap <leader>ff :let @+=expand("%:p")<CR>
noremap <leader>fn :let @+=expand("%")<CR>
noremap <leader>fp :let @+=expand("%:p:h")<CR>

noremap <leader>v :vs<CR>:Bufstop<CR>

map <leader>e :silent r! explorer .<CR>

map <leader>b :Bufstop<CR>
map <leader>a :BufstopModeFast<CR>
map <leader>w :BufstopPreview<CR>

nmap <leader>z :let &scrolloff=999-&scrolloff<CR>

" awesome keyboard scrolling
nmap <C-j> 3j3<C-e>
nmap <C-k> 3k3<C-y>

" change current dir
nmap <leader>cd :cd\ %:p:h<CR>

""""""""""""""""
" Abbreviations

cabbrev ss VimpanelSessionMake
cabbrev sl VimpanelSessionLoad
cabbrev vp Vimpanel
cabbrev vl VimpanelLoad
cabbrev vc VimpanelCreate
cabbrev ve VimpanelEdit
cabbrev vo VimpanelOpen
cabbrev vr VimpanelRemove

""""""""""""""
" Indentation

set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2

" long lines don't break at screen end
set nowrap

" long lines are market with > and < at end of screen
set listchars+=precedes:<,extends:>

""""""""""""""
" Status line

set laststatus=2
set statusline=
set statusline+=%1*                   "switch to User1 highlight
set statusline+=%n                    " buffer number
set statusline+=%1*
set statusline+=%{'/'.bufnr('$')}\    " total buffers
set statusline+=%2*
set statusline+=%<%1.200F              " filename
set statusline+=%3*
set statusline+=\ %y%h%w              " filetype, help, example flags
set statusline+=%3*
set statusline+=%r%m                  " read-only, modified flags
set statusline+=%3*
set statusline+=%=\                   " indent right
set statusline+=%1*
set statusline+=%l                    " line number
set statusline+=%1*
set statusline+=/%{line('$')}         " total lines
set statusline+=%1*
set statusline+=,                     " ,
set statusline+=%1*
set statusline+=%c%V                  " [virtual] column numberV
set statusline+=%3*
set statusline+=\                     " [ ]
set statusline+=%3*
set statusline+=%<%P                  " percent

""""""""""
" Plugins

filetype plugin indent on

" Easy motion
nmap ss <Plug>(easymotion-s2)
nmap st <Plug>(easymotion-t2)
map sl <Plug>(easymotion-lineforward)
map sj <Plug>(easymotion-j)
map sk <Plug>(easymotion-k)
map sh <Plug>(easymotion-linebackward)
map  s/ <Plug>(easymotion-sn)
omap s/ <Plug>(easymotion-tn)
map  sn <Plug>(easymotion-next)
map  sN <Plug>(easymotion-prev)
map sw <Plug>(easymotion-w)
map sb <Plug>(easymotion-bd-w)
map se <Plug>(easymotion-e)

let g:EasyMotion_startofline = 0
let g:EasyMotion_keys = 'asdghkqwertyuiopzxcvbnmfjl'

" bufstop
let g:BufstopAutoSpeedToggle = 1
let g:BufstopSplit = "topleft"
let g:BufstopKeys = "1234asfcvzx5qwertyuiopbnm67890ABCEFGHIJKLMNOPQRSTUVZ"
let g:BufstopShowUnlisted = 1

" lightline
set noshowmode
let g:lightline = {
  \ 'inactive': { 'left': [['imode'], ['filename']] },
  \ 'component' : { 'imode': 'INACT' },
  \ 'component_function': { 
    \ 'filename': 'LightFilename', 'modified': 'LightModified', 'mode': 'LightMode',
    \ 'fileformat': 'LightFileformat', 'filetype': 'LightFiletype' },
  \ 'colorscheme': '4colors' }

function! LightFilename()
  if expand('%:t') ==# '--Bufstop--'
    return ''
  endif
  if winwidth(0) > 70
    return MyGetFileTypeSymbol(expand('%:t')) . expand('%:t')
  else
    return expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  endif
endfunction

function! LightMode()
  return expand('%:t') ==# '--Bufstop--' ? 'BUFSTOP' : lightline#mode()
endfunction

function! LightModified()
  if expand('%:t') ==# '--Bufstop--'
    return ''
  endif
  return &modified ? '+' : &modifiable ? '' : '-' 
endfunction

function! LightFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

" devicons for Bufstop
let g:BufstopFileSymbolFunc = 'MyGetFileTypeSymbol'
exe 'highlight! bufstopIcon1 ' . g:fourcolors#warmFg
exe 'highlight! bufstopIcon2 ' . g:fourcolors#chillFg

""""""""""
" Commands

" show highlight group
command! Hgroup :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . "> "
                  \ . "trans<". synIDattr(synID(line("."),col("."),0),"name") . "> "
                  \ . "lo<". synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"

" find text in all open buffers
function! Findb(text)
    exe "cex [] | silent! bufdo vimgrepa /" . a:text . "/ %"
    :copen
endfunction
command! -nargs=1 Findo call Findo(<q-args>)

"""""""""""""""""""""
" File type settings

autocmd FileType markdown setlocal tabstop=4|set shiftwidth=4|set expandtab
highlight link markdownError Normal
autocmd FileType vim setlocal iskeyword-=#
autocmd FileType * setlocal iskeyword-=:
autocmd FileType css,scss,html,eruby setlocal iskeyword +=-

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
