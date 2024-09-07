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
vim.opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:,diff: ]]

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

-- reselect pasted text
vim.keymap.set('n', 'gV',  '`[v`]', { desc = 'Reselect last paste in VISUAL mode' })

-- awesome keyboard scrolling
vim.keymap.set('n', '<C-j>', '3j3<C-e>', { desc = 'Scroll up' })
vim.keymap.set('n', '<C-k>', '3k3<C-y>', { desc = 'Scroll down' })
vim.keymap.set('n', '<C-l>', '3zl3l', { desc = 'Scroll right' })
vim.keymap.set('n', '<C-h>', '3zh3h', { desc = 'Scroll left' })

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

-- disable some default mappings
vim.keymap.set('n', 'Q', '<nop>')
vim.keymap.set('n', 'ZZ', '<nop>')

-- move things in visual mode
-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Move text down' })
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Move text up' })

-- exit terminal mode with esc
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-----------
-- Plugins

-- lazy.nvim setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local lazyopts = {
  install = { missing = false },
  checker = { enabled = false },
  change_detection = { enabled = false },
  performance = { reset_packpath = false },
}

local plugins = {}

plugins = vim.list_extend(plugins, require('core'))
plugins = vim.list_extend(plugins, require('slim'))
plugins = vim.list_extend(plugins, require('fat'))
plugins = vim.list_extend(plugins, require('dead'))

require("lazy").setup(plugins, lazyopts)
