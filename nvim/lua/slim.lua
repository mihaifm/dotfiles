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

-- custom paste handler (called when pasting in the terminal with CTRL-V)
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

----------------------
-- Session management

local sesdir = vim.fn.stdpath("state") .. "/sessions/"
vim.fn.mkdir(sesdir, "p")

-- save sessions automatically every 5 minutes
local sesinterval = 5 * 60

function SesFileName()
  local name

  if vim.env.TMUX then
    local tmux_session = vim.fn.systemlist("tmux display -pt " .. vim.env.TMUX_PANE .. " '#{session_name}'")[1]
    local tmux_window = vim.fn.systemlist("tmux display -pt " .. vim.env.TMUX_PANE .. " '#{window_index}'")[1]
    local tmux_pane = vim.fn.systemlist("tmux display -pt " .. vim.env.TMUX_PANE .. " '#{pane_index}'")[1]

    if tmux_session and tmux_window and tmux_pane then
      name = tmux_session .. "%%" .. tmux_window .. "%%" .. tmux_pane
    end
  else
    name = vim.fn.getcwd():gsub("[\\/:]+", "%%")

    if vim.uv.fs_stat(".git") then
      local branch = vim.fn.systemlist("git branch --show-current")[1]
      if vim.v.shell_error == 0 then
        name = name .. "%%" .. branch
      end
    end
  end

  return sesdir .. name .. ".vim"
end

function SesSave()
  vim.cmd("mks! " .. vim.fn.fnameescape(SesFileName()))
end

function SesLoad(opts)
  opts = opts or {}
  local file
  if opts.last then
    local sessions = vim.fn.glob(sesdir .. "*.vim", true, true)
    table.sort(sessions, function(a, b)
      return vim.uv.fs_stat(a).mtime.sec > vim.uv.fs_stat(b).mtime.sec
    end)
    file = sessions[1]
  else
    file = SesFileName()
  end
  if file and vim.fn.filereadable(file) ~= 0 then
    vim.cmd("silent! source " .. vim.fn.fnameescape(file))
  end
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("session-vimleavepre", { clear = true }),
  callback = function()
    vim.cmd("mks! " .. vim.fn.fnameescape(SesFileName()))
  end,
})

vim.api.nvim_create_user_command('SesSave', SesSave, {})
vim.api.nvim_create_user_command('SesLoad', SesLoad, {})

local autosave_timer = vim.uv.new_timer()
autosave_timer:start(sesinterval * 1000, sesinterval * 1000, vim.schedule_wrap(function()
  SesSave()
end))

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

  if vim.opt_local.modifiable:get() == false then
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
        local utf8len = vim.str_utfindex(v)
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

      local utf8len = vim.str_utfindex(lineData[k])
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

return {}
