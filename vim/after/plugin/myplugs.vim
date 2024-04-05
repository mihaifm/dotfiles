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

" exe 'highlight! bufstopIcon1 ' . g:fourcolors#warmFg
" exe 'highlight! bufstopIcon2 ' . g:fourcolors#chillFg

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
