local M = {}

-----------------
-- Yank overhaul

-- yankleader setup
local yankleader = 'y'

-- delete and paste keys do not yank unless prefixed by yankleader
local function setupYankLeader()
  -- inspired by tenxsoydev/karen-yank.nvim
  local clipKeys = {
    delete = {
      d = "Delete text",
      D = "Delete rest of line",
      c = "Change text",
      C = "Change rest of line",
      x = "Delete next character",
      X = "Delete previous character",
      S = "Substitute Rest of Line",
    },
    paste = {
      p = "Paste after",
      P = "Paste before",
    }
  }

  for key, desc in pairs(clipKeys.delete) do
    vim.keymap.set({ "n", "v" }, key, function()
      if vim.v.register:match('%w') then return key end
      return '"_' .. key
    end, { expr = true, desc = desc })

    vim.keymap.set({ "n", "v" }, yankleader .. key, function()
      return key
    end, { expr = true, desc = desc .. " into register" })
  end

  for key, desc in pairs(clipKeys.paste) do
    vim.keymap.set("v", key, function()
      return 'P'
    end, { desc = desc .. " and delete selection", expr = true })
    vim.keymap.set("v", yankleader .. key, function()
      return 'p'
    end, { desc = desc .. " and yank selection into register", expr = true })
  end
end

setupYankLeader()

-- yank ring implementation
local yankHistory = {}
local yankIndex = 0
local yankIndexReset = true

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('yankcycle-textyankpost', { clear = true }),
  callback = function()
    if not (vim.v.register:match("%d+") or vim.v.register == "+" or vim.v.register == '"') then return end

    local yankedText = vim.fn.getreg(vim.v.register, 1)
    table.insert(yankHistory, 1, yankedText)

    local yankHistoryMaxSize = 100
    for i = #yankHistory, yankHistoryMaxSize + 1, -1 do
      table.remove(yankHistory, i)
    end
  end,
})

local function putText(text)
  if not text then return end

  local currentLine = vim.fn.line(".")
  local currentCol = vim.fn.col(".")

  yankIndexReset = false

  if string.sub(text, -1) == "\n" then
    local lines = vim.fn.split(text, "\n")
    vim.api.nvim_buf_set_lines(0, currentLine, currentLine, false, lines)
  else
    local lines = vim.fn.split(text, "\n")
    vim.api.nvim_buf_set_text(0, currentLine - 1, currentCol - 1, currentLine - 1, currentCol - 1, lines)
  end
end

vim.api.nvim_create_user_command("YankCycleHist", function()
  vim.ui.select(yankHistory,
    {
      prompt = "Yank history",
      format_item = function(item)
        return item and item:gsub("\n", "\\n") or ""
      end,
    }, function(choice)
      putText(choice)
    end)
end, {})

vim.api.nvim_create_user_command("YankCycleClear", function()
  yankHistory = {}
  yankIndex = 0
end, {})

vim.api.nvim_create_user_command("YankCycleNext", function()
  if #yankHistory == 0 then return end

  if yankIndex >= 1 then
    vim.cmd('silent normal! u')
  end

  yankIndex = (yankIndex % #yankHistory) + 1
  local nextPut = yankHistory[yankIndex]
  putText(nextPut)
end, {})

vim.api.nvim_create_user_command("YankCyclePrev", function()
  if #yankHistory == 0 then return end

  if yankIndex >= 1 then
    vim.cmd('silent normal! u')
  end

  yankIndex = #yankHistory - (#yankHistory - (yankIndex - 1)) % #yankHistory
  local prevPut = yankHistory[yankIndex]
  putText(prevPut)
end, {})

vim.api.nvim_create_autocmd('CursorMoved', {
  group = vim.api.nvim_create_augroup('yankcycle-cursormoved', { clear = true }),
  callback = function()
    if yankIndexReset then yankIndex = 0 else yankIndexReset = true end
  end
})

vim.keymap.set('n', '<C-p>', '<cmd>YankCycleNext<CR>', { desc = 'Paste next yank' })
vim.keymap.set('n', '<C-n>', '<cmd>YankCyclePrev<CR>', { desc = 'Paste previous yank' })

vim.keymap.set('n', 'yp', '<cmd>YankCycleHist<CR>', { desc = 'Paste from yank history' })

------------------------
-- Custom paste handler

-- prevents register pollution when pasting over a visual selection
vim.paste = (function(overridden)
  local mode = ''
  local stored_regs = {}
  local affected_regs = { "*", "+", '"', "-" }

  return function(lines, phase)
    if phase == 1 then
      mode = vim.api.nvim_get_mode()["mode"]

      if mode == 'v' or mode == 'V' then
        -- backup potentially affected regs
        for _, reg in ipairs(affected_regs) do
          stored_regs[reg] = vim.fn.getreg(reg)
        end
      end
    end

    overridden(lines, phase)

    if phase == 3 and (mode == 'v' or mode == 'V') then
      vim.defer_fn(function()
        -- restore potentially affected regs
        for _, reg in ipairs(affected_regs) do
          vim.fn.setreg(reg, stored_regs[reg])
        end
        stored_regs = {}
      end, 10)
    end
  end
end)(vim.paste)

--------------
-- OSC52 yank

local function setup_osc52()
  if vim.fn.has('win32') == 1 then return end
  if vim.env.TMUX then return end
  -- don't check for has('clipboard'), neovim bugs out
  if vim.g.clipboard ~= nil then return end

  local function osc52_send(s)
    local b64 = vim.fn.system("base64", s):gsub("%s+$","")
    local osc = "\x1b]52;c;" .. b64 .. "\x07"

    local ok = pcall(function()
      -- write to TTY so it reaches the terminal even in cooked modes
      local f = io.open("/dev/tty", "w")
      if f then
        f:write(osc)
        f:flush()
        f:close()
      else
        -- falls back to stdout if no /dev/tty.
        io.write(osc)
      end
    end)

    return ok
  end

  local last = {["+"] = {lines={}, regtype="v"}, ["*"] = {lines={}, regtype="v"}}

  local function copy_osc52(which)
    return function(lines, regtype)
      local text = table.concat(lines, "\n")
      osc52_send(text)
      last[which].lines = vim.deepcopy(lines)
      last[which].regtype = regtype
    end
  end

  local function paste_memory(which)
    return function()
      return vim.deepcopy(last[which].lines), last[which].regtype
    end
  end

  vim.g.clipboard = {
    name = "osc52",
    copy  = { ["+"] = copy_osc52("+"), ["*"] = copy_osc52("*") },
    paste = { ["+"] = paste_memory("+"), ["*"] = paste_memory("*") },
    cache_enabled = true,
  }
end

setup_osc52()

----------------------
-- Session management

vim.o.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions'

local sesdir = vim.fs.joinpath(vim.fn.stdpath('state'), 'sessions')
vim.fn.mkdir(sesdir, "p")

-- save sessions automatically every ~5 minutes with a small jitter
local sesinterval = 5 * 60 + os.time() % 30

function SesFileName(scope)
  local ses_filename = scope

  if scope == 'tmux' then
    if not (vim.env.TMUX and vim.env.TMUX_PANE) then
      print("Not in a tmux session")
      return nil
    end

    local tmux_session = vim.fn.systemlist("tmux display -pt " .. vim.env.TMUX_PANE .. " '#{session_name}'")[1]
    local tmux_window = vim.fn.systemlist("tmux display -pt " .. vim.env.TMUX_PANE .. " '#{window_index}'")[1]
    local tmux_pane = vim.fn.systemlist("tmux display -pt " .. vim.env.TMUX_PANE .. " '#{pane_index}'")[1]

    if tmux_session and tmux_window and tmux_pane then
      ses_filename = ses_filename .. "%%" .. tmux_session .. "%%" .. tmux_window .. "%%" .. tmux_pane
    end
  elseif scope == 'global' then
    ses_filename = ses_filename .. "%%" .. "session"
  elseif scope == 'project' then
    local root = vim.fn.getcwd()

    local toplevel = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
    if vim.v.shell_error == 0 and toplevel and #toplevel > 0 then
      root = toplevel
    end

    ses_filename = ses_filename .. root:gsub("[\\/:]+", "%%%%")

    local branch = vim.fn.systemlist("git branch --show-current")[1]
    if vim.v.shell_error == 0 and branch and #branch > 0 then
      ses_filename = ses_filename .. "%%" .. branch
    end
  end

  return vim.fs.joinpath(sesdir, ses_filename .. ".vim")
end

local function get_default_session_scope()
  if vim.env.TMUX then return "tmux" end
  return "global"
end

function SesSave(scope)
  scope = scope or get_default_session_scope()

  local file = SesFileName(scope)
  if not file then return end

  vim.cmd("mks! " .. vim.fn.fnameescape(file))
end

function SesLoad(scope)
  scope = scope or get_default_session_scope()

  local file = SesFileName(scope)

  if file and vim.fn.filereadable(file) ~= 0 then
    vim.cmd("silent! source " .. vim.fn.fnameescape(file))
  end
end

vim.api.nvim_create_user_command("SesSave", function(opts)
  local scope = opts.args and opts.args ~= '' and opts.args or nil
  SesSave(scope)
end, {
  nargs = "?",
  complete = function()
    return {"tmux", "project", "global"}
  end
})
vim.api.nvim_create_user_command("SesLoad", function(opts)
  local scope = opts.args and opts.args ~= '' and opts.args or nil
  SesLoad(scope)
end, {
  nargs = "?",
  complete = function()
    return {"tmux", "project", "global"}
  end
})

local autosave_timer = vim.uv.new_timer()
if autosave_timer then
  autosave_timer:start(sesinterval * 1000, sesinterval * 1000, vim.schedule_wrap(function()
    SesSave()
  end))
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("session-vimleavepre", { clear = true }),
  callback = function()
    SesSave()

    if autosave_timer then
      pcall(function()
        autosave_timer:stop()
        autosave_timer:close()
      end)
    end
  end,
})

-----------------------
-- Toggle transparency

local hiBgData = {
  on = false,
  vals = {},
  groups = { 'Normal', 'NormalNC', 'NonText', 'FoldColumn', 'SignColumn' }
}

vim.api.nvim_create_user_command('Transparent', function()
  if not hiBgData.on then
    for _, v in pairs(hiBgData.groups) do
      hiBgData.vals[v] = vim.api.nvim_get_hl(0, { name = v })
      vim.api.nvim_set_hl(0, v, { bg='NONE', ctermbg='NONE' })
    end
    hiBgData.on = true
  else
    for _, v in pairs(hiBgData.groups) do
      vim.api.nvim_set_hl(0, v, hiBgData.vals[v])
    end
    hiBgData.on = false
  end
end, {})

-------------
-- FormatCsv

function FormatCsv()
  local function parseCsv(line)
    local out = {}
    local state = "begin"

    local ele = ""

    for i = 1, #line do
      local c = line:sub(i, i)
      if state == 'begin' then
        ele = ""
        if c == '"' then
          state = 'quotedel'
        else
          state = 'element'
          ele = ele .. c
        end
      elseif state == 'element' then
        if c == ',' then
          state = 'begin'
          table.insert(out, ele)
        else
          ele = ele .. c
        end
      elseif state == 'quotedel' then
        if c == '"' then
          state = 'quote'
        else
          ele = ele .. c
        end
      elseif state == 'quote' then
        if c == '"' then
          ele = ele .. c
          state = 'quotedel'
        elseif c == ',' then
          state = 'begin'
          table.insert(out, ele)
        else
          state = 'ignore'
          table.insert(out.ele)
        end
      elseif state == 'ignore' then
        if c == ',' then
          state = 'begin'
        end
      end
    end

    if string.len(ele) > 0 then
      table.insert(out, ele)
    end
    return out
  end

  if vim.opt_local.modifiable == false then
    vim.opt_local.modifiable = true
  end

  local output = {}
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  local sizes = {}
  local beautyData = {}
  for _, line in pairs(lines) do
    if #string.gsub(line, "^%s*(.-)%s*$", "%1") ~= 0 then
      local lineData = parseCsv(line)
      table.insert(beautyData, lineData)
      for k, v in pairs(lineData) do
        local utf8len = vim.str_utfindex(v, "utf-8")
        if not sizes[k] then sizes[k] = utf8len
        else sizes[k] = math.max(sizes[k], utf8len)
        end
      end
    end
  end

  local top = "╭"
  for k, v in pairs(sizes) do
    top = top .. string.rep("─", v + 2)
    if k == #sizes then top = top .. "╮"
    else top = top .. "┬"
    end
  end
  table.insert(output, top)

  for i, lineData in pairs(beautyData) do
    local beauty = ""
    for k, _ in pairs(sizes) do
      if not lineData[k] then lineData[k] = "" end

      if k == 1 then beauty = "│ " end

      local utf8len = vim.str_utfindex(lineData[k], "utf-8")
      lineData[k] = lineData[k] .. string.rep(" ", sizes[k] - utf8len)
      beauty = beauty .. lineData[k] .. " │ "
    end
    table.insert(output, beauty)

    if i == 1 then
      local middle = "├"
      for k, v in pairs(sizes) do
        middle = middle .. string.rep("─", v + 2)
        if k == #sizes then middle = middle .. "┤"
        else middle = middle .. "┼"
        end
      end
      table.insert(output, middle)
    end
  end

  local bottom = "╰"
  for k, v in pairs(sizes) do
    bottom = bottom .. string.rep("─", v + 2)
    if k == #sizes then bottom = bottom .. "╯"
    else bottom = bottom .. "┴"
    end
  end
  table.insert(output, bottom)

  vim.api.nvim_buf_set_lines(0, 0, -1, true, output)
end

vim.api.nvim_create_user_command('FormatCsv', FormatCsv, {})

------------------------
-- Fancy command propmt

function FancyCmd(type)
  if not type then type = 'cmd' end

  local buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(buffers) do
    if vim.api.nvim_get_option_value('filetype', { buf = buf }) == 'fancycmd' then
      return
    end
  end

  -- save window handler and cursor position
  local winid = vim.api.nvim_get_current_win()
  local cursorPos = vim.api.nvim_win_get_cursor(0)
  local guicursor = vim.o.guicursor

  -- buffer settings
  local prompt_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[prompt_buf].swapfile = false
  vim.bo[prompt_buf].bufhidden = "wipe"
  vim.bo[prompt_buf].filetype = "fancycmd"

  -- options
  local title = ' Command '
  local icon = ' '
  local colorSetup = 'Normal:Constant,FloatTitle:Constant,Search:Constant,CurSearch:Constant'
  if type == 'search' then
    title = ' Search '
    icon = ' '
    colorSetup = 'Normal:Identifier,FloatTitle:Identifier,Search:Identifier,CurSearch:Identifier'
  end

  -- ui settings
  local prompt_win = vim.api.nvim_open_win(prompt_buf, true, {
    relative = "editor",
    width = 60,
    height = 1,
    row = vim.o.lines * 0.9,
    col = vim.o.columns * 0.5 - 30,
    focusable = true,
    zindex = 50,
    style = "minimal",
    border = "rounded",
    noautocmd = true,
    title = title,
    title_pos = "center"
  })

  vim.cmd("setlocal guicursor=i:block")
  vim.cmd('file --fancycmd--')
  vim.cmd('set winhl=' .. colorSetup)
  vim.cmd("setlocal scl=yes:2")
  vim.cmd('sign define prompt text=\\ ' .. icon)
  vim.cmd('sign place 1 line=1 name=prompt file=--fancycmd--')
  vim.cmd('startinsert!')

  local timer = vim.loop.new_timer()

  -- dismiss and confirm keys
  local command = nil
  local function do_confirm()
    command = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]
  end

  local function do_close()
    vim.api.nvim_win_close(prompt_win, true)
    vim.o.guicursor = guicursor
    timer:stop()
    timer:close()
    vim.cmd("stopinsert")
  end

  vim.keymap.set({"n", "i"}, "<Esc>", function()
    do_close()
    if type == 'search' then vim.cmd('noh') end
  end, { buffer = prompt_buf })

  vim.keymap.set("i", "<CR>", function()
    do_confirm()
    do_close()
    vim.api.nvim_set_current_win(winid)
    if command then
      vim.defer_fn(function()
        vim.fn.histadd('cmd', command)
        if type == 'cmd' then
          -- directly calling vim.cmd(command) is not working properly, 
          -- see https://github.com/neovim/neovim/issues/28562
          -- use a hack instead
          local escaped_command = string.gsub(command, '\\', '\\\\')
          escaped_command = string.gsub(escaped_command, '"', '\\"')
          escaped_command = string.gsub(escaped_command, "'", "''")
          local hack = 'exe "' .. "call feedkeys('\\<cmd>" .. escaped_command .. "\\n')" .. '"'
          vim.cmd(hack)
        end
        command = nil
      end, 10)
    end
  end, { buffer = prompt_buf })

  -- completion
  vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-n>"
    else
      return "<C-x><C-u>"
    end
  end, { buffer = prompt_buf, expr = true })

  vim.bo[prompt_buf].completefunc = "v:lua.FancyCmdComplete"
  vim.bo[prompt_buf].omnifunc = "v:lua.FancyCmdComplete"

  local origTxt = ''
  function FancyCmdComplete(findstart, _)
    if findstart == 1 then
      origTxt = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]
      local index = origTxt:reverse():find(" ")
      if index then return #origTxt - index + 1 end
      return 0
    end
    local _, result = pcall(vim.fn.getcompletion, origTxt, 'cmdline')
    return result
  end

  local function set_input(text)
    vim.api.nvim_buf_set_lines(0, 0, 1, true, { text })
    vim.api.nvim_win_set_cursor(0, { 1, vim.api.nvim_strwidth(text) })
  end

  -- history
  local history_idx = 0
  local history_prev = function()
    history_idx = history_idx - 1
    set_input(vim.fn.histget('cmd', history_idx))
    vim.cmd('sign place 1 line=1 name=prompt file=--fancycmd--')
  end
  local history_next = function()
    history_idx = history_idx + 1
    set_input(vim.fn.histget('cmd', history_idx))
    vim.cmd('sign place 1 line=1 name=prompt file=--fancycmd--')
  end

  vim.keymap.set('i', '<C-p>', history_prev, { buffer = prompt_buf, remap = false })
  vim.keymap.set('i', '<C-n>', history_next, { buffer = prompt_buf, remap = false })

  -- search highlight
  local prevText = ''
  if type == 'search' then
    timer:start(0, 20, vim.schedule_wrap(function()
      if not vim.api.nvim_win_is_valid(winid) then return end
      if vim.api.nvim_get_current_win() ~= prompt_win then return end

      local search_term = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]
      if search_term ~= prevText then
        if string.len(search_term) > 0 then
          vim.api.nvim_set_current_win(winid)
          vim.api.nvim_win_set_cursor(winid, cursorPos)
          vim.fn.setreg('/', search_term)
          vim.cmd('try | exe "silent normal! n" | catch | endtry')
          if vim.api.nvim_win_is_valid(prompt_win) then
            vim.api.nvim_set_current_win(prompt_win)
          end
        end
        prevText = search_term
      end
    end))
  end
end

if vim.g.FancyCmdTakeover then
  vim.keymap.set('n', ':', function() FancyCmd('cmd') end, { desc = 'Fancy command prompt' })
  vim.keymap.set('n', '/', function() FancyCmd('search') end, { desc = 'Fancy search' })
  vim.keymap.set('n', '<leader>:', ':', { desc = 'Command prompt' })
  vim.keymap.set('n', '<leader>/', '/', { desc = 'Search' })
else
  vim.keymap.set('n', '<leader>:', function() FancyCmd('cmd') end, { desc = 'Fancy command prompt' })
  vim.keymap.set('n', '<leader>/', function() FancyCmd('search') end, { desc = 'Fancy search' })
end

--------------
-- Statusline

local expand_statusline_path = false
local show_statusline_diagnostics = true

M.statusline = function()
  function StlFileName()
    if expand_statusline_path then
      return vim.fn.expand('%:p') == '' and '[No Name]' or vim.fn.expand('%:p')
    end
    return vim.fn.expand('%:t') == '' and '[No Name]' or vim.fn.expand('%:t')
  end

  function StlFileType()
    return vim.fn.winwidth(0) > 70 and (vim.o.filetype == '' and 'no ft' or vim.o.filetype) or ''
  end

  local status_bg = 'none'

  function StlFileIcon()
    local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
    if not has_devicons then
      return
    end

    local icon, color = devicons.get_icon_color_by_filetype(vim.o.filetype)
    if icon then
      vim.cmd('hi StlIconColor guibg=' .. status_bg .. ' guifg=' .. color)
      return icon
    end
    return ''
  end

  function StlBranchName()
    return vim.b.branch_name
  end

  function StlFileFormat()
    return vim.o.fileformat == 'dos' and '· crlf ' or ''
  end

  function StlDiagError()
    if package.loaded["vim.diagnostic"] and show_statusline_diagnostics then
      local counts = vim.diagnostic.count(0)
      return  counts[vim.diagnostic.severity.ERROR] and '󰀩 ' .. counts[vim.diagnostic.severity.ERROR] .. ' ' or ""
    end
    return ""
  end

  function StlDiagWarn()
    if package.loaded["vim.diagnostic"] and show_statusline_diagnostics then
      local counts = vim.diagnostic.count(0)
      return  counts[vim.diagnostic.severity.WARN] and '󰀦 ' .. counts[vim.diagnostic.severity.WARN] .. ' ' or ""
    end
    return ""
  end

  function StlDiagInfo()
    if package.loaded["vim.diagnostic"] and show_statusline_diagnostics then
      local counts = vim.diagnostic.count(0)
      return  counts[vim.diagnostic.severity.INFO] and '󰀧 ' .. counts[vim.diagnostic.severity.INFO] .. ' ' or ""
    end
    return ""
  end

  function StlDiagHint()
    if package.loaded["vim.diagnostic"] and show_statusline_diagnostics then
      local counts = vim.diagnostic.count(0)
      return  counts[vim.diagnostic.severity.HINT] and '󱇎 ' .. counts[vim.diagnostic.severity.HINT] .. ' ' or ""
    end
    return ""
  end

  vim.cmd([[
  let stl_mode_map = { 'n': 'NORMAL', 'i': 'INSERT', 'R': 'REPLACE', 'v': 'VISUAL', 'V': 'V-LINE', "\<C-v>": 'V-BLOCK',
  \ 'c': 'COMMAND', 's': 'SELECT', 'S': 'S-LINE', "\<C-s>": 'S-BLOCK', 't': 'TERMINAL' }

  let stl_mode_colors = { 'n': '%#StlModeNormal#', 'i': '%#StlModeInsert#', 'R': '%#StlModeReplace#', 'v': '%#StlModeVisual#', 
  \'V': '%#StlModeVLine#', "\<C-v>": '%#StlModeVBlock#', 'c': '%#StlModeCommand#', 's': '%#StlModeSelect#', 
  \'S': '%#StlModeSLine#', "\<C-s>": '%#StlModeSBlock#', 't': '%#StlModeTerminal#' }

  let stl_alt_colors = { 'n': '%#StlAltNormal#', 'i': '%#StlAltInsert#', 'R': '%#StlAltReplace#', 'v': '%#StlAltVisual#', 
  \'V': '%#StlAltVLine#', "\<C-v>": '%#StlAltVBlock#', 'c': '%#StlAltCommand#', 's': '%#StlAltSelect#', 
  \'S': '%#StlAltSLine#', "\<C-s>": '%#StlAltSBlock#', 't': '%#StlAltTerminal#' }

  let stl_sep1_colors = { 'n': '%#StlSep1Normal#', 'i': '%#StlSep1Insert#', 'R': '%#StlSep1Replace#', 'v': '%#StlSep1Visual#', 
  \'V': '%#StlSep1VLine#', "\<C-v>": '%#StlSep1VBlock#', 'c': '%#StlSep1Command#', 's': '%#StlSep1Select#', 
  \'S': '%#StlSep1SLine#', "\<C-s>": '%#StlSep1SBlock#', 't': '%#StlSep1Terminal#' }

  let stl_sep2_colors = { 'n': '%#StlSep2Normal#', 'i': '%#StlSep2Insert#', 'R': '%#StlSep2Replace#', 'v': '%#StlSep2Visual#', 
  \'V': '%#StlSep2VLine#', "\<C-v>": '%#StlSep2VBlock#', 'c': '%#StlSep2Command#', 's': '%#StlSep2Select#', 
  \'S': '%#StlSep2SLine#', "\<C-s>": '%#StlSep2SBlock#', 't': '%#StlSep2Terminal#' }


  set laststatus=3

  set statusline=%{%get(stl_mode_colors,mode(),'%1*')%} " get the hl group for current mode and switch to it
  set statusline+=\ %{get(stl_mode_map,mode(),'')}\      " mode
  set statusline+=%{%get(stl_sep1_colors,mode(),'%1*')%}
  set statusline+=
  set statusline+=%{%get(stl_alt_colors,mode(),'%1*')%}  " switch to the alternative hl group for the current mode
  set statusline+=%{v:lua.StlBranchName()}               " branch name
  set statusline+=%{%get(stl_sep2_colors,mode(),'%1*')%}
  set statusline+=
  set statusline+=%#StatusLine#                          " switch to the StatusLine hightlight group
  set statusline+=\ %{v:lua.StlFileName()}               " filename
  set statusline+=\ %r%m                                 " read-only, modified flags
  set statusline+=%=\                                    " switch to right alignment
  set statusline+=%#DiagnosticVirtualTextError#
  set statusline+=%{v:lua.StlDiagError()}                " diagnostics
  set statusline+=%#DiagnosticVirtualTextWarn#
  set statusline+=%{v:lua.StlDiagWarn()}                 " diagnostics
  set statusline+=%#DiagnosticVirtualTextInfo#
  set statusline+=%{v:lua.StlDiagInfo()}                 " diagnostics
  set statusline+=%#DiagnosticVirtualTextHint#
  set statusline+=%{v:lua.StlDiagHint()}                 " diagnostics
  set statusline+=%#StlIconColor#                        " switch to a custom StlIconColor hightlight group
  set statusline+=%{v:lua.StlFileIcon()}\                " file icon
  set statusline+=%#StatusLine#                          " switch to the StatusLine hightlight group
  set statusline+=%{v:lua.StlFileType()}\                " filetype
  set statusline+=%{v:lua.StlFileFormat()}               " file format
  set statusline+=%{%get(stl_sep2_colors,mode(),'%1*')%}
  set statusline+=
  set statusline+=%{%get(stl_alt_colors,mode(),'%1*')%}  " switch to the alternative hl group for the current mode
  set statusline+=\ %<%P\                                " percent
  set statusline+=%{%get(stl_sep1_colors,mode(),'%1*')%}
  set statusline+=
  set statusline+=%{%get(stl_mode_colors,mode(),'%1*')%}
  set statusline+=\ %l                                   " line number
  set statusline+=:                                      " :
  set statusline+=%c\                                    " column number
  ]])

  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('statusline-colorscheme', { clear = true }),
    callback = function()
      local getColor = function(group, part)
        local hl = vim.api.nvim_get_hl(0, {name = group, link = false})
        if hl and hl.reverse then
          if part == 'bg' then part = 'fg'
          elseif part == 'fg' then part = 'bg'
          end
        end

        if hl and hl[part] then
          return string.format('#%06x', hl[part])
        end
        return 'none'
      end

      local normal_bg = getColor('Function', 'fg')
      local normal_fg = getColor('Normal', 'bg')
      local insert_bg = getColor('String', 'fg')
      local replace_bg = getColor('Constant', 'fg')
      local visual_bg = getColor('Visual', 'bg')
      local visual_fg = getColor('Normal', 'fg')
      local command_bg = getColor('Constant', 'fg')
      local terminal_bg = getColor('Identifier', 'fg')

      vim.cmd('hi! StlModeNormal guifg=' .. normal_fg .. ' guibg=' .. normal_bg)
      vim.cmd('hi! StlModeInsert guifg=' .. normal_fg .. ' guibg=' .. insert_bg)
      vim.cmd('hi! StlModeReplace guifg=' .. normal_fg .. ' guibg=' .. replace_bg)
      vim.cmd('hi! StlModeCommand guifg=' .. normal_fg .. ' guibg=' .. command_bg)
      vim.cmd('hi! StlModeTerminal guifg=' .. normal_fg .. ' guibg=' .. terminal_bg)
      vim.cmd('hi! StlModeVisual guifg=' .. visual_fg .. ' guibg=' .. visual_bg)
      vim.cmd('hi! StlModeVLine guifg=' .. visual_fg .. ' guibg=' .. visual_bg)
      vim.cmd('hi! StlModeVBlock guifg=' .. visual_fg .. ' guibg=' .. visual_bg)
      vim.cmd('hi! StlModeSelect guifg=' .. visual_fg .. ' guibg=' .. visual_bg)
      vim.cmd('hi! StlModeSLine guifg=' .. visual_fg .. ' guibg=' .. visual_bg)
      vim.cmd('hi! StlModeSBlock guifg=' .. visual_fg .. ' guibg=' .. visual_bg)

      local alt_bg = getColor('Visual', 'bg')

      vim.cmd('hi! StlAltNormal guifg=' .. normal_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlAltInsert guifg=' .. insert_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlAltReplace guifg=' .. replace_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlAltCommand guifg=' .. command_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlAltTerminal guifg=' .. terminal_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlAltVisual guifg=' .. visual_fg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlAltVLine guifg=' .. visual_fg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlAltVBlock guifg=' .. visual_fg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlAltSelect guifg=' .. visual_fg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlAltSLine guifg=' .. visual_fg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlAltSBlock guifg=' .. visual_fg .. ' guibg=' .. alt_bg)

      vim.cmd('hi! StlSep1Normal guifg=' .. normal_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlSep1Insert guifg=' .. insert_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlSep1Replace guifg=' .. replace_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlSep1Command guifg=' .. command_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlSep1Terminal guifg=' .. terminal_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlSep1Visual guifg=' .. visual_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlSep1VLine guifg=' .. visual_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlSep1VBlock guifg=' .. visual_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlSep1Select guifg=' .. visual_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlSep1SLine guifg=' .. visual_bg .. ' guibg=' .. alt_bg)
      vim.cmd('hi! StlSep1SBlock guifg=' .. visual_bg .. ' guibg=' .. alt_bg)

      status_bg = getColor('StatusLine', 'bg')

      vim.cmd('hi! StlSep2Normal guifg=' .. visual_bg .. ' guibg=' .. status_bg)
      vim.cmd('hi! StlSep2Insert guifg=' .. visual_bg .. ' guibg=' .. status_bg)
      vim.cmd('hi! StlSep2Replace guifg=' .. visual_bg .. ' guibg=' .. status_bg)
      vim.cmd('hi! StlSep2Command guifg=' .. visual_bg .. ' guibg=' .. status_bg)
      vim.cmd('hi! StlSep2Terminal guifg=' .. visual_bg .. ' guibg=' .. status_bg)
      vim.cmd('hi! StlSep2Visual guifg=' .. visual_bg .. ' guibg=' .. status_bg)
      vim.cmd('hi! StlSep2VLine guifg=' .. visual_bg .. ' guibg=' .. status_bg)
      vim.cmd('hi! StlSep2VBlock guifg=' .. visual_bg .. ' guibg=' .. status_bg)
      vim.cmd('hi! StlSep2Select guifg=' .. visual_bg .. ' guibg=' .. status_bg)
      vim.cmd('hi! StlSep2SLine guifg=' .. visual_bg .. ' guibg=' .. status_bg)
      vim.cmd('hi! StlSep2SBlock guifg=' .. visual_bg .. ' guibg=' .. status_bg)

      vim.cmd('hi! link User1 Function')
    end
  })

  local has_git = vim.fn.executable('git')

  vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "FocusGained" }, {
    desc = "keep branch and buffer name variables updated",
    group = vim.api.nvim_create_augroup('statusline-focusgained', { clear = true }),
    callback = function()
      if has_git == 0 then
        vim.b.branch_name = ''
        return
      end

      local branch_cmd = vim.system({ "git", "branch", "--show-current" }):wait()
      if branch_cmd.stdout == "" or branch_cmd.code ~= 0 then
        vim.b.branch_name = ''
        return
      end

      local branch_name, _ = branch_cmd.stdout:gsub("\n", "")
      vim.b.branch_name = ' 󰘬 ' .. branch_name .. ' '
    end,
  })

  vim.api.nvim_create_user_command('ToggleStlFullPath', function(opts)
    local subcommand = opts.args and opts.args ~= '' and opts.args or nil

    if subcommand == 'on' then
      expand_statusline_path = true
    elseif subcommand == 'off' then
      expand_statusline_path = false
    else
      expand_statusline_path = not expand_statusline_path
    end

    vim.cmd.redrawstatus()
  end, { nargs = '?', complete = function() return { 'on', 'off' } end })

  vim.api.nvim_create_user_command('ToggleStlDiagnostics', function(opts)
    local subcommand = opts.args and opts.args ~= '' and opts.args or nil

    if subcommand == 'on' then
      show_statusline_diagnostics = true
    elseif subcommand == 'off' then
      show_statusline_diagnostics = false
    else
      show_statusline_diagnostics = not show_statusline_diagnostics
    end

    vim.cmd.redrawstatus()
  end, { nargs = '?', complete = function() return { 'on', 'off' } end })

  vim.keymap.set('n', '<leader>ul', '<cmd>ToggleStlFullPath<cr>', { desc = 'Toggle statusline full path' })
  vim.keymap.set('n', '<leader>ud', '<cmd>ToggleStlDiagnostics<cr>', { desc = 'Toggle statusline diagnostics' })

  M.getStatuslineState = function()
    return {
      expand_path = expand_statusline_path,
      show_diagnostics = show_statusline_diagnostics
    }
  end
end

-------------------
-- Terminal toggle

local terminal_state = {
  buf = nil,
  win = nil,
  direction = 'horizontal'
}

local function setup_terminal_buffer(buf)
  vim.api.nvim_set_option_value('foldcolumn', '0', { win = 0 })
  vim.api.nvim_set_option_value('signcolumn', 'no', { win = 0 })

  if vim.api.nvim_buf_line_count(buf) == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == '' then
    vim.fn.jobstart(vim.o.shell, { term = true })
  end

  vim.cmd('startinsert')
end

local function create_terminal_window(direction, size)
  local width = vim.o.columns
  local height = vim.o.lines

  if direction == 'float' then
    local win_width = math.floor(width * 0.8)
    local win_height = math.floor(height * 0.8)
    local row = math.floor((height - win_height) / 2)
    local col = math.floor((width - win_width) / 2)

    return vim.api.nvim_open_win(terminal_state.buf, true, {
      relative = 'editor',
      width = win_width,
      height = win_height,
      row = row,
      col = col,
      style = 'minimal',
      border = 'rounded'
    })
  elseif direction == 'horizontal' then
    vim.cmd('botright ' .. (size or 10) .. 'split')
    vim.api.nvim_set_current_buf(terminal_state.buf)
    return vim.api.nvim_get_current_win()
  elseif direction == 'vertical' then
    vim.cmd('botright ' .. (size or 80) .. 'vsplit')
    vim.api.nvim_set_current_buf(terminal_state.buf)
    return vim.api.nvim_get_current_win()
  end
end

local function toggle_terminal(direction, size)
  direction = direction or terminal_state.direction
  terminal_state.direction = direction

  -- Create terminal buffer if it doesn't exist
  if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
    terminal_state.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = terminal_state.buf })
    vim.api.nvim_set_option_value('filetype', 'terminal', { buf = terminal_state.buf })
  end

  -- Check if terminal window exists and is visible
  if terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
    vim.api.nvim_win_close(terminal_state.win, false)
    terminal_state.win = nil
    return
  end

  -- Create and show terminal window
  terminal_state.win = create_terminal_window(direction, size)
  setup_terminal_buffer(terminal_state.buf)
end

vim.keymap.set({'n', 't'}, [[<C-\>]], function() toggle_terminal() end, { desc = 'Toggle terminal' })
vim.keymap.set('n', '<leader>etf', function() toggle_terminal('float') end, { desc = 'Toggle float terminal' })
vim.keymap.set('n', '<leader>eth', function() toggle_terminal('horizontal', 10) end, { desc = 'Toggle horizontal terminal' })
vim.keymap.set('n', '<leader>etv', function() toggle_terminal('vertical', 80) end, { desc = 'Toggle vertical terminal' })

vim.api.nvim_create_user_command('ToggleTerminal', function(opts)
  local subcommand = opts.args and opts.args ~= '' and opts.args or nil

  if subcommand == 'float' then
    toggle_terminal('float')
  elseif subcommand == 'horizontal' then
    toggle_terminal('horizontal', 10)
  elseif subcommand == 'vertical' then
    toggle_terminal('vertical', 80)
  else
    toggle_terminal()
  end
end, {
  nargs = '?',
  complete = function()
    return {'float', 'horizontal', 'vertical'}
  end
})

------------------
-- Project picker

local function get_tracking_file()
  local data_path = vim.fn.stdpath('data')
  return data_path .. '/git_folders.txt'
end

local function is_git_repo(path)
  local git_dir = path .. '/.git'
  return vim.fn.isdirectory(git_dir) == 1
end

local function load_folders()
  local file_path = get_tracking_file()
  local folders = {}

  local file = io.open(file_path, 'r')
  if not file then
    return folders
  end

  for line in file:lines() do
    line = vim.trim(line)
    if line ~= '' then
      -- ordered list
      table.insert(folders, line)
    end
  end
  file:close()

  return folders
end

local function save_folders(folders)
  local file_path = get_tracking_file()

  local file = io.open(file_path, 'w')
  if not file then
    return
  end

  for _, folder in ipairs(folders) do
    file:write(folder .. '\n')
  end
  file:close()
end

local function add_folder(path)
  path = vim.fn.fnamemodify(path, ':p:h')

  if not is_git_repo(path) then
    return
  end

  local folders = load_folders()

  -- remove the path if it already exists
  local new_folders = {}
  for _, folder in ipairs(folders) do
    if folder ~= path then
      table.insert(new_folders, folder)
    end
  end

  -- add the path to the beginning (most recent)
  table.insert(new_folders, 1, path)

  save_folders(new_folders)
end

function TrackFolders()
  local current_dir = vim.fn.getcwd()
  add_folder(current_dir)

  vim.api.nvim_create_augroup('GitFolderTracker', { clear = true })

  vim.api.nvim_create_autocmd('DirChanged', {
    group = 'GitFolderTracker',
    callback = function()
      local new_dir = vim.fn.getcwd()
      add_folder(new_dir)
    end
  })

  vim.api.nvim_create_autocmd('VimEnter', {
    group = 'GitFolderTracker',
    callback = function()
      local new_dir = vim.fn.getcwd()
      add_folder(new_dir)
    end
  })
end

function TrackCurrentFolder()
  -- manually add current directory
  add_folder(vim.fn.getcwd())
end

function ClearTrackedFolders()
  local file_path = get_tracking_file()
  local file = io.open(file_path, 'w')

  if not file then
    return
  end

  file:close()
  print('Cleared all tracked git folders')
end

function PickFolder()
  local folders = load_folders()

  if #folders == 0 then
    print('No tracked Git folders found')
    return
  end

  local items = {}
  for _, folder in ipairs(folders) do
    -- create display label with folder name and full path
    local name = vim.fn.fnamemodify(folder, ':t')
    local parent = vim.fn.fnamemodify(folder, ':h:t')
    local display = name
    if parent and parent ~= '' and parent ~= '/' then
      display = parent .. '/' .. name
    end
    table.insert(items, {
      label = display .. ' (' .. folder .. ')',
      value = folder
    })
  end

  vim.ui.select(items, {
    prompt = 'Select project folder:',
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice then
      vim.cmd('cd ' .. vim.fn.fnameescape(choice.value))
      print('Changed to: ' .. choice.value)
    end
  end)
end

TrackFolders()
vim.api.nvim_create_user_command('PickFolder', PickFolder, {})

return M
