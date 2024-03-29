vim.g.mapleader = ','
vim.g.maplocalleader = ','

vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus'

-- wrapped lines are indented
vim.opt.breakindent = true
vim.opt.wrap = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.number = true
vim.opt.signcolumn = 'yes'

vim.opt.swapfile = false
vim.opt.undofile = false

-- reduce Esc keycode delay
vim.opt.ttimeoutlen = 50

-- time to complete a keymap sequence
vim.opt.timeoutlen = 800

-- split below and to the right by default - useful for help window
vim.opt.splitright = true
vim.opt.splitbelow = true

-- show whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- preview substitutions live
vim.opt.hlsearch = true
vim.opt.inccommand = 'split'

vim.opt.hlsearch = true

-- new files have unix format by default
vim.opt.fileformats = {'unix', 'dos' ,'mac' }

-- delete without yanking
vim.keymap.set('n', '<leader>d', '"_d', { desc = 'Delete without copying' })

-- disable auto insertion of comments
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('no-auto-comments', { clear = true }),
  callback = function()
    vim.opt.formatoptions:remove({'c'})
    vim.opt.formatoptions:remove({'r'})
    vim.opt.formatoptions:remove({'o'})
  end
})

-- hightlight for a split second when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

require("lazysetup")
