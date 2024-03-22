set encoding=utf8
scriptencoding utf-8

fun! TrySource(script)
  if filereadable(expand(a:script))
    exe 'source '.a:script
  endif
endf

"""""""""""""""
" s:hideMarkup

" hide some highlight groups using the highlight scheme background

function! s:hideMarkup()
  redir => group_details
  exe "silent hi Normal"
  redir END

  " resolve linked groups to find the root highlighting scheme
  while group_details =~ "links to"
    let index = stridx(group_details, "links to") + len("links to")
    let linked_group =  strpart(linked_group, index + 1)
    redir => linked_group
    exe "silent hi " . linked_group
    redir END
  endwhile

  " extract the highlighting details (the bit after "xxx")
  let match_groups = matchlist(group_details, '\<xxx\>\s\+\(.*\)')
  let existing_highlight = match_groups[1]

  " check whether there's an existing guibg= block
  let match_groups = matchlist(existing_highlight, '\vguibg\=\s*(\S+)')
  if match_groups != []
    let bg_color = match_groups[1]

    exe "hi VimpanelPart guifg=" . bg_color . " guibg=" . bg_color
    exe "hi VimpanelOpenable guifg=" . bg_color . " guibg=" . bg_color
    exe "hi VimpanelClosable guifg=" . bg_color . " guibg=" . bg_color
    exe "hi VimpanelPartFile guifg=" . bg_color . " guibg=" . bg_color
    exe "hi VimpanelEndSlash guifg=" . bg_color . " guibg=" . bg_color
  endif
endfunction

""""""""""""""""""
" Nerd Font icons

let s:file_node_extensions = {
  \ 'styl'     : '',
  \ 'sass'     : '',
  \ 'scss'     : '',
  \ 'htm'      : '',
  \ 'html'     : '',
  \ 'slim'     : '',
  \ 'haml'     : '',
  \ 'ejs'      : '',
  \ 'css'      : '',
  \ 'less'     : '',
  \ 'md'       : '',
  \ 'mdx'      : '',
  \ 'markdown' : '',
  \ 'rmd'      : '',
  \ 'json'     : '',
  \ 'webmanifest' : '',
  \ 'js'       : '',
  \ 'mjs'      : '',
  \ 'jsx'      : '',
  \ 'rb'       : '',
  \ 'gemspec'  : '',
  \ 'rake'     : '',
  \ 'php'      : '',
  \ 'py'       : '',
  \ 'pyc'      : '',
  \ 'pyo'      : '',
  \ 'pyd'      : '',
  \ 'coffee'   : '',
  \ 'mustache' : '',
  \ 'hbs'      : '',
  \ 'conf'     : '',
  \ 'ini'      : '',
  \ 'yml'      : '',
  \ 'yaml'     : '',
  \ 'toml'     : '',
  \ 'bat'      : '',
  \ 'mk'       : '',
  \ 'jpg'      : '',
  \ 'jpeg'     : '',
  \ 'bmp'      : '',
  \ 'png'      : '',
  \ 'webp'     : '',
  \ 'gif'      : '',
  \ 'ico'      : '',
  \ 'twig'     : '',
  \ 'cpp'      : '',
  \ 'c++'      : '',
  \ 'cxx'      : '',
  \ 'cc'       : '',
  \ 'cp'       : '',
  \ 'c'        : '',
  \ 'cs'       : '',
  \ 'h'        : '',
  \ 'hh'       : '',
  \ 'hpp'      : '',
  \ 'hxx'      : '',
  \ 'hs'       : '',
  \ 'lhs'      : '',
  \ 'nix'      : '',
  \ 'lua'      : '',
  \ 'java'     : '',
  \ 'sh'       : '',
  \ 'fish'     : '',
  \ 'bash'     : '',
  \ 'zsh'      : '',
  \ 'ksh'      : '',
  \ 'csh'      : '',
  \ 'awk'      : '',
  \ 'ps1'      : '',
  \ 'ml'       : 'λ',
  \ 'mli'      : 'λ',
  \ 'diff'     : '',
  \ 'db'       : '',
  \ 'sql'      : '',
  \ 'dump'     : '',
  \ 'clj'      : '',
  \ 'cljc'     : '',
  \ 'cljs'     : '',
  \ 'edn'      : '',
  \ 'scala'    : '',
  \ 'go'       : '',
  \ 'dart'     : '',
  \ 'xul'      : '',
  \ 'sln'      : '',
  \ 'suo'      : '',
  \ 'pl'       : '',
  \ 'pm'       : '',
  \ 't'        : '',
  \ 'rss'      : '',
  \ 'f#'       : '',
  \ 'fsscript' : '',
  \ 'fsx'      : '',
  \ 'fs'       : '',
  \ 'fsi'      : '',
  \ 'rs'       : '',
  \ 'rlib'     : '',
  \ 'd'        : '',
  \ 'erl'      : '',
  \ 'hrl'      : '',
  \ 'ex'       : '',
  \ 'exs'      : '',
  \ 'eex'      : '',
  \ 'leex'     : '',
  \ 'heex'     : '',
  \ 'vim'      : '',
  \ 'ai'       : '',
  \ 'psd'      : '',
  \ 'psb'      : '',
  \ 'ts'       : '',
  \ 'tsx'      : '',
  \ 'jl'       : '',
  \ 'pp'       : '',
  \ 'vue'      : '﵂',
  \ 'elm'      : '',
  \ 'swift'    : '',
  \ 'xcplayground' : '',
  \ 'tex'      : 'ﭨ',
  \ 'r'        : 'ﳒ',
  \ 'rproj'    : '鉶',
  \ 'sol'      : 'ﲹ',
  \ 'pem'      : ''
  \}

let s:file_node_exact_matches = {
  \ 'exact-match-case-sensitive-1.txt' : '1',
  \ 'exact-match-case-sensitive-2'     : '2',
  \ 'gruntfile.coffee'                 : '',
  \ 'gruntfile.js'                     : '',
  \ 'gruntfile.ls'                     : '',
  \ 'gulpfile.coffee'                  : '',
  \ 'gulpfile.js'                      : '',
  \ 'gulpfile.ls'                      : '',
  \ 'mix.lock'                         : '',
  \ 'dropbox'                          : '',
  \ '.ds_store'                        : '',
  \ '.gitconfig'                       : '',
  \ '.gitignore'                       : '',
  \ '.gitattributes'                   : '',
  \ '.gitlab-ci.yml'                   : '',
  \ '.bashrc'                          : '',
  \ '.zshrc'                           : '',
  \ '.zshenv'                          : '',
  \ '.zprofile'                        : '',
  \ '.vimrc'                           : '',
  \ '.gvimrc'                          : '',
  \ '_vimrc'                           : '',
  \ '_gvimrc'                          : '',
  \ '.bashprofile'                     : '',
  \ 'favicon.ico'                      : '',
  \ 'license'                          : '',
  \ 'node_modules'                     : '',
  \ 'react.jsx'                        : '',
  \ 'procfile'                         : '',
  \ 'dockerfile'                       : '',
  \ 'docker-compose.yml'               : '',
  \ 'rakefile'                         : '',
  \ 'config.ru'                        : '',
  \ 'gemfile'                          : '',
  \ 'makefile'                         : '',
  \ 'cmakelists.txt'                   : '',
  \ 'robots.txt'                       : 'ﮧ'
  \}

let s:file_node_pattern_matches = {
  \ '.*jquery.*\.js$'       : '',
  \ '.*angular.*\.js$'      : '',
  \ '.*backbone.*\.js$'     : '',
  \ '.*require.*\.js$'      : '',
  \ '.*materialize.*\.js$'  : '',
  \ '.*materialize.*\.css$' : '',
  \ '.*mootools.*\.js$'     : '',
  \ '.*vimrc.*'             : '',
  \ 'Vagrantfile$'          : ''
\}

let s:default_symbol = ''

function! MyGetFileTypeSymbol(...) abort
  let symbol = s:default_symbol
  let fileNodeExtension = fnamemodify(a:1, ':e')
  let fileNode = fnamemodify(a:1, ':t')

  let fileNodeExtension = tolower(fileNodeExtension)
  let fileNode = tolower(fileNode)

  for [pattern, glyph] in items(s:file_node_pattern_matches)
    if match(fileNode, pattern) != -1
      let symbol = glyph
      break
    endif
  endfor

  if symbol == s:default_symbol
    if has_key(s:file_node_exact_matches, fileNode)
      let symbol = s:file_node_exact_matches[fileNode]
    elseif has_key(s:file_node_extensions, fileNodeExtension)
      let symbol = s:file_node_extensions[fileNodeExtension]
    endif
  endif

  return symbol . ' '
endfunction

autocmd BufWinEnter --Bufstop-- call matchadd('bufstopIcon1', '\v' . '|||')
autocmd BufWinEnter --Bufstop-- call matchadd('bufstopIcon2', '\v' . '|')

let g:termdebug_config = {
  \ 'command' : ['gdb', '-ex', 'set history save on'],
  \ 'sign' : "󰯯",
  \ 'wide' : 1
  \ }
