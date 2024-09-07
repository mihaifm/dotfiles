local plugins = {
  { "tpope/vim-sleuth", enabled = false },
  { "tpope/vim-surround", enabled = false },
  { 'vimpostor/vim-tpipeline', enabled = false },
  {
    "shaunsingh/nord.nvim",
    enabled = false,
    config = function()
      vim.g.nord_italic = false
      require("nord").set()
    end,
  },
  {
    "onsails/lspkind.nvim",
    enabled = false,
    config = function()
      require('cmp').setup({
        ---@diagnostic disable-next-line
        formatting = {
          fields = { 'abbr', 'kind', 'menu' },
          format = require('lspkind').cmp_format({
            mode = 'symbol_text',
            show_labelDetails = true,
            menu = {
              buffer = 'buf',
              nvim_lsp = 'LSP',
              tmux = 'tmux',
              rg = 'rg'
            }
          })
        },
      })
    end
  },
  {
    'folke/noice.nvim',
    enabled = false,
    event = "VeryLazy",
    opts = {
      views = {
        cmdline_popup = {
          position = {
            row = "95%",
            col = "50%",
          },
        }
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify"
    }
  },
  {
    'folke/persistence.nvim',
    enabled = false,
    config = function()
      local persistence = require('persistence')
      persistence.setup({})

      vim.keymap.set("n", "<leader>sd", function() persistence.load() end, { desc = 'Restore session from current directory' })
      vim.keymap.set("n", "<leader>sl", function() persistence.load({ last = true }) end, { desc = 'Restore last session' })
      vim.keymap.set("n", "<leader>sx", function() persistence.stop() end, { desc = 'Disable session on exit' })
      vim.keymap.set("n", "<leader>ss", function() persistence.start() end, { desc = 'Enable session in current directory' })

      vim.api.nvim_create_autocmd('DirChanged', {
        group = vim.api.nvim_create_augroup('persistence-dirchanged', { clear = true }),
        pattern = 'global',
        callback = function() persistence.start() end
      })

    end
  },
  {
    "nvimtools/none-ls.nvim",
    enabled = false,
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.black,
          null_ls.builtins.completion.spell,
        },
      })
    end,
  },
  { 'stevearc/dressing.nvim', enabled = false, opts = {} },
  {
    "NStefan002/screenkey.nvim",
    enabled = false, -- doesn't work so well
    cmd = "Screenkey",
    version = "*",
    config = true,
  },
  {
    'gelguy/wilder.nvim',
    enabled = false,
    config = function()
      local wilder = require('wilder')
      wilder.set_option('renderer', wilder.popupmenu_renderer({
        pumblend = 20,
        left = {' ', wilder.popupmenu_devicons()},
        right = {' ', wilder.popupmenu_scrollbar()},
      }))
      wilder.setup({modes = {':', '/', '?'}})
    end
  },
  {
    'echasnovski/mini.completion',
    enabled = false,
    version = false,
    config = function()
      require('mini.completion').setup({
        mappings = {
          force_twostep = '<space>m',
          force_fallback = '<space>a',
        }
      })
    end
  },
  {
    'romgrk/barbar.nvim',
    enabled = false,
    config = function()
      require('barbar').setup({})
      vim.cmd('BarbarDisable')
      vim.cmd('set showtabline=0')

      vim.api.nvim_create_user_command('ToggleTabline', function()
        if vim.opt.showtabline:get() == 0 then
          vim.cmd('BarbarEnable')
          vim.cmd('set showtabline=2')
        else
          vim.cmd('BarbarDisable')
          vim.cmd('set showtabline=0')
        end
        vim.cmd('normal jk')
      end, {})
    end
  },
}

return plugins
