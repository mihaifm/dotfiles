""""""""""
" bufstop

let g:BufstopSplit = "topleft"
let g:BufstopKeys = "1234asfcvzx5qwertyuiopbnm67890ABCEFGHIJKLMNOPQRSTUVZ"
let g:BufstopShowUnlisted = 0
let g:BufstopFileSymbolFunc = 'MyGetFileTypeSymbol'

map <leader>b :Bufstop<CR>
map <leader>a :BufstopModeFast<CR>
map <leader>w :BufstopPreview<CR>

" close(wipe) the current buffer without closing the window
map <leader>d :BufstopBack<CR>:bw! #<CR>

autocmd BufWinEnter --Bufstop-- call matchadd('bufstopIcon1', '\v' . '|||')
autocmd BufWinEnter --Bufstop-- call matchadd('bufstopIcon2', '\v' . '|')
autocmd BufEnter --Bufstop-- setlocal statusline=%1*BUFSTOP\ %2*

autocmd ColorScheme * exe 'highlight! bufstopIcon1 ' . g:fourcolors#warmFg
autocmd ColorScheme * exe 'highlight! bufstopIcon2 ' . g:fourcolors#chillFg

"""""""""""
" vimpanel

cabbrev ss VimpanelSessionMake
cabbrev sl VimpanelSessionLoad
cabbrev vp Vimpanel
cabbrev vl VimpanelLoad
cabbrev vc VimpanelCreate
cabbrev ve VimpanelEdit
cabbrev vo VimpanelOpen
cabbrev vr VimpanelRemove

function! g:VimpanelCallback()
  if executable('rg')
    let g:MyGlobalSearchPath = ''
    for root in g:VimpanelRoots
      let g:MyGlobalSearchPath = g:MyGlobalSearchPath . ' ' . root
    endfor
  endif
endfunction

"""""""""""""""""""""
" vim-tmux-navigator

if exists("g:loaded_tmux_navigator")
  nnoremap <silent> <C-w>h :TmuxNavigateLeft<CR>
  nnoremap <silent> <C-w>j :TmuxNavigateDown<CR>
  nnoremap <silent> <C-w>k :TmuxNavigateUp<CR>
  nnoremap <silent> <C-w>l :TmuxNavigateRight<CR>
  nnoremap <silent> <C-w><C-h> :TmuxNavigateLeft<CR>
  nnoremap <silent> <C-w><C-j> :TmuxNavigateDown<CR>
  nnoremap <silent> <C-w><C-k> :TmuxNavigateUp<CR>
  nnoremap <silent> <C-w><C-l> :TmuxNavigateRight<CR>
endif

""""""""""""""
" Easymotion

if exists("g:EasyMotion_loaded")
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
endif

let g:EasyMotion_startofline = 0
let g:EasyMotion_keys = 'asdghkqwertyuiopzxcvbnmfjl'

""""""""""
" 4colors

autocmd ColorScheme * exe 'hi User1 ' . g:fourcolors#darkFg . g:fourcolors#chillBg
autocmd ColorScheme * exe 'hi User2 ' . g:fourcolors#whiteFg . g:fourcolors#darkBg
autocmd ColorScheme * exe 'hi User3 ' . g:fourcolors#grayFg . g:fourcolors#darkBg
autocmd ColorScheme * exe 'hi User4 ' . g:fourcolors#darkFg . g:fourcolors#grayBg
autocmd ColorScheme * exe 'hi User5 ' . g:fourcolors#darkFg . g:fourcolors#whiteBg
autocmd ColorScheme * exe 'hi User6 ' . g:fourcolors#blackFg . g:fourcolors#hotBg
autocmd ColorScheme * exe 'hi User7 ' . g:fourcolors#darkFg . g:fourcolors#coldBg

if !empty(globpath(&rtp, 'colors/4colors.vim'))
  colorscheme 4colors
endif
