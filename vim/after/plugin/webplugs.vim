"""""""""""""""""
" terminal-drawer 

tnoremap <Esc> <C-\><C-n>
autocmd TerminalOpen * set nonumber | set norelativenumber | set signcolumn=no

"""""""""""""""""""""
" vim-tmux-navigator

nnoremap <silent> <C-w>h :TmuxNavigateLeft<CR>
nnoremap <silent> <C-w>j :TmuxNavigateDown<CR>
nnoremap <silent> <C-w>k :TmuxNavigateUp<CR>
nnoremap <silent> <C-w>l :TmuxNavigateRight<CR>
nnoremap <silent> <C-w><C-h> :TmuxNavigateLeft<CR>
nnoremap <silent> <C-w><C-j> :TmuxNavigateDown<CR>
nnoremap <silent> <C-w><C-k> :TmuxNavigateUp<CR>
nnoremap <silent> <C-w><C-l> :TmuxNavigateRight<CR>

""""""""""""""
" Easy motion

nmap ss <Plug>(easymotion-s2)
nmap st <Plug>(easymotion-t2)
map sl <Plug>(easymotion-lineforward)
map sj <Plug>(easymotion-j)
map sk <Plug>(easymotion-k)
map sh <Plug>(easymotion-linebackward)
map s/ <Plug>(easymotion-sn)
omap s/ <Plug>(easymotion-tn)
map sn <Plug>(easymotion-next)
map sN <Plug>(easymotion-prev)
map sw <Plug>(easymotion-w)
map sb <Plug>(easymotion-bd-w)
map se <Plug>(easymotion-e)

let g:EasyMotion_startofline = 0
let g:EasyMotion_keys = 'asdghkqwertyuiopzxcvbnmfjl'

""""""""""""
" lightline

set noshowmode
let g:lightline = {
  \ 'inactive': { 'left': [['imode'], ['filename']] },
  \ 'component' : { 'imode': 'INACT' },
  \ 'component_function': { 
    \ 'readonly': 'LightReadOnly', 'filename': 'LightFilename', 'modified': 'LightModified', 'mode': 'LightMode',
    \ 'fileformat': 'LightFileformat', 'fileencoding': 'LightEncoding', 'filetype': 'LightFiletype',
    \ 'percent': 'LightPercent'},
  \ 'colorscheme': '4colors' }

func! LightReadOnly()
  if expand('%:t') =~# '^vimspector'
    return ''
  endif

  return &readonly ? 'RO' : ''
endfunc

func! LightFilename()
  if expand('%:t') ==# '--Bufstop--'
    return ''
  endif
  if winwidth(0) > 70
    return MyGetFileTypeSymbol(expand('%:t')) . expand('%:t')
  else
    return expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  endif
endfunc

funct! LightMode()
  return expand('%:t') ==# '--Bufstop--' ? 'BUFSTOP' : lightline#mode()
endfunc

func! LightModified()
  if expand('%:t') ==# '--Bufstop--'
    return ''
  endif
  if expand('%:t') =~# '^vimspector'
    return ''
  endif

  return &modified ? '+' : &modifiable ? '' : '-' 
endfunc

func! LightFileformat()
  if expand('%:t') =~# '^vimspector'
    return ''
  endif

  return winwidth(0) > 70 ? (&fileformat ==# 'unix' ? '' : &fileformat) : ''
endfunc

func! LightEncoding()
  if expand('%:t') =~# '^vimspector'
    return ''
  endif

  return &encoding ==# 'utf-8' ? '' : &encoding
endfunc

func! LightFiletype()
  if expand('%:t') =~# '^vimspector'
    return ''
  endif

  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunc

func! LightPercent()
  if expand('%:t') =~# '^vimspector'
    return ''
  endif

  return (line('.') * 100 / line('$') . '%')
endfunc

" fzf.vim

command! -bang -nargs=* Rga call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".<q-args>, 1, <bang>0)
