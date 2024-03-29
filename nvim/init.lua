---------------
-- UI settings

vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'

-- split below and to the right by default
-- also impacts help placement
vim.opt.splitright = true
vim.opt.splitbelow = true

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

-- reduce Esc keycode delay
vim.opt.ttimeoutlen = 50

-- time to complete a keymap sequence
vim.opt.timeoutlen = 900

-- show whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

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
  group = vim.api.nvim_create_augroup('no-auto-comments', { clear = true }),
  callback = function()
    vim.opt.formatoptions:remove({ 'c' })
    vim.opt.formatoptions:remove({ 'r' })
    vim.opt.formatoptions:remove({ 'o' })
  end
})

-- hightlight for a split second when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

------------
-- Mappings

vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- delete without yanking
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d', { desc = 'Delete without yanking' })

-- Copy-paste with CTRL-C CTRL-V
vim.keymap.set({ 'n', 'v' }, '<C-c>', '"+y', { desc = 'Copy with CTRL-C' })
vim.keymap.set('n', '<C-v>', '"+gP', { desc = 'Paste with CTRL-V' })
vim.keymap.set('c', '<C-v>', '<C-r>+', { desc = 'Paste in command mode' })
vim.keymap.set('i', '<C-v>', '<C-r>+', { desc = 'Paste in insert mode' })

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
vim.keymap.set('n', '<leader>fp', function() vim.cmd('let @+=expand("%:p:h")') end,
  { desc = 'Copy directory path for current file' })

-- open Windows Explorer
if vim.fn.has("win32") then
  vim.keymap.set('n', '<leader>e', function() vim.cmd('silent r! explorer .') end,
    { desc = 'Open Windows Explorer' })
end

-----------
-- Plugins

require("lazysetup")
