---------------
-- UI settings

-- general settings
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true

-- default split locations - impacts help placement
vim.opt.splitright = true
vim.opt.splitbelow = true

-- show at most 10 items in the completion menu
vim.opt.pumheight = 10

-------------------
-- Editor settings

-- indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

-- wrapped lines are indented
vim.opt.breakindent = true
vim.opt.wrap = false

-- no backup file clutter
vim.opt.swapfile = false
vim.opt.undofile = false
vim.opt.backup = false
vim.opt.writebackup = false
-- vim.opt.shadafile = 'NONE'

-- reduce Esc keycode delay
vim.opt.ttimeoutlen = 50

-- time to complete a keymap sequence
vim.opt.timeoutlen = 900

-- time before the word under cursor is highlighted
vim.opt.updatetime = 350

-- show whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', precedes = '<', extends = '>' }
vim.opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

-- keep some rows/columns visible when moving cursor at the edges of the screen
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 3

-- search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- preview substitutions live
vim.opt.hlsearch = true
vim.opt.inccommand = 'split'

-- new files have unix format by default
vim.opt.fileformats = { 'unix', 'dos', 'mac' }

-- disable auto insertion of comments
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('noautocomment-bufenter', { clear = true }),
  callback = function()
    vim.opt.formatoptions:remove({ 'c' })
    vim.opt.formatoptions:remove({ 'r' })
    vim.opt.formatoptions:remove({ 'o' })
  end
})

-- hightlight for a split second when yanking
vim.g.HighlightOnYank = true
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-textyankpost', { clear = true }),
  callback = function()
    if vim.g.HighlightOnYank then
      vim.highlight.on_yank()
    end
  end,
})

--------------
-- Statusline

-- single statusline across all windows
vim.opt.laststatus = 3

local sl = ''
sl = sl .. "%1*"                  -- switch to User1 highlight
sl = sl .. "%n"                   -- buffer number
sl = sl .. "%1*"
sl = sl .. "%{'/'.bufnr('$')} "   -- total buffers
sl = sl .. "%2*"                  -- switch to User2 hightlight
sl = sl .. "%<%1.200F"            -- filename
sl = sl .. "%3*"                  -- switch to User3 highlight
sl = sl .. " %y%h%w"              -- filetype, help, example flags
sl = sl .. "%3*"
sl = sl .. "%r%m"                 -- read-only, modified flags
sl = sl .. "%3*"
sl = sl .. "%= "                  -- indent right
sl = sl .. "%1*"
sl = sl .. "%l"                   -- line number
sl = sl .. "%1*"
sl = sl .. "/%{line('$')}"        -- total lines
sl = sl .. "%1*"
sl = sl .. ","                    -- ,
sl = sl .. "%1*"
sl = sl .. "%c%V"                 -- [virtual] column numberV
sl = sl .. "%3*"
sl = sl .. " "                    -- [ ]
sl = sl .. "%3*"
sl = sl .. "%<%P"                 -- percent

vim.opt.statusline = sl

------------
-- Mappings

vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- copy-paste with CTRL-C CTRL-V
vim.keymap.set({ 'n', 'v'}, '<C-c>', '"+y', { desc = 'Copy with CTRL-C' })
vim.keymap.set({'n', 'v'}, '<C-v>', 'P', { desc = 'Paste with CTRL-V' })

vim.keymap.set('c', '<C-v>', '<C-r>+', { desc = 'Paste in command mode' })
vim.keymap.set('i', '<C-v>', '<C-r>+', { desc = 'Paste in insert mode' })

vim.keymap.set('v', '<C-x>', '"+x', { desc = 'Cut in visual mode' })

-- cut with CTRL-X, empty lines go the black hole registry
vim.keymap.set('n', '<C-x>', function()
  if vim.fn.match(vim.fn.getline('.'), '^\\s*$') == -1 then
    vim.cmd('normal 0"+d$')
  else
    vim.cmd('normal "_dd')
  end
end, { desc = 'Cut in normal mode' })

-- use CTRL-Q instead of CTRL-V to start visual block
vim.keymap.set('n', '<C-q>', '<C-v>', { desc = 'Start visual block mode' })

-- awesome keyboard scrolling
vim.keymap.set('n', '<C-j>', '3j3<C-e>', { desc = 'Scroll up' })
vim.keymap.set('n', '<C-k>', '3k3<C-y>', { desc = 'Scroll down' })

-- better movement in command line
vim.keymap.set('c', '<C-h>', '<Left>', { desc = 'Move left in command line' })
vim.keymap.set('c', '<C-l>', '<Right>', { desc = 'Move right in command line' })
vim.keymap.set('c', '<C-a>', '<Home>', { desc = 'Move at the beginning of the command line' })
vim.keymap.set('c', '<C-e>', '<End>', { desc = 'Move to the end of the command line' })

-- mappings for copying file name and path
vim.keymap.set('n', '<leader>ff', function() vim.cmd('let @+=expand("%:p")') end,
  { desc = 'Copy full file path' })
vim.keymap.set('n', '<leader>fn', function() vim.cmd('let @+=expand("%:t")') end,
  { desc = 'Copy file name' })
vim.keymap.set('n', '<leader>fd', function() vim.cmd('let @+=expand("%:p:h")') end,
  { desc = 'Copy directory path for current file' })

-- open Windows Explorer
if vim.fn.has("win32") == 1 then
  vim.keymap.set('n', '<leader>fx', function() vim.cmd('silent r! explorer .') end,
    { desc = 'Open Windows Explorer' })
end

-- move things in visual mode
-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Move text down' })
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Move text up' })

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

vim.keymap.set('n', 'yH', '<cmd>YankCycleHist<CR>', { desc = 'Paste from yank history' })

------------------------
-- Fancy command propmt

function FancyCmd(type)
  if not type then type = 'cmd' end

  local buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_get_option(buf, 'filetype') == 'fancycmd' then
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

vim.keymap.set('n', ':', function() FancyCmd('cmd') end, { desc = 'Fancy command prompt' })
vim.keymap.set('n', '/', function() FancyCmd('search') end, { desc = 'Fancy search' })
vim.keymap.set('n', '<leader>:', ':', { desc = 'Command prompt' })
vim.keymap.set('n', '<leader>/', '/', { desc = 'Search' })

----------------
-- Transparency

local hiBgData = {
  on = false,
  vals = {},
  groups = { 'Normal', 'NormalNC', 'NonText', 'FoldColumn', 'SignColumn' }
}

-- toggle transparency
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

-----------
-- Plugins

require("lazysetup")
