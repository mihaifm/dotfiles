local plugins = {
  { "tpope/vim-sleuth", enabled = false },
  { "tpope/vim-surround", enabled = false },
  {
    'vimpostor/vim-tpipeline',
    enabled = false,
    init = function()
      vim.g.tpipeline_restore = 1
    end
  },
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
    'echasnovski/mini.surround',
    enabled = false,
    opts = {}
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
        if vim.opt.showtabline == 0 then
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
  {
    "anuvyklack/hydra.nvim",
    enabled = false,
    config = function()
      local Hydra = require("hydra")

      local has_wk, wk = pcall(require, 'which-key')
      if has_wk then
        wk.add({ { "<leader>eh", desc = "Hydra Options" } })
      end

      local hint =
        " ^ ^        Options \n" ..
        " ^ \n" ..
        " _i_ %{list} list characters   \n" ..
        " _s_ %{spell} spell \n" ..
        " _w_ %{wrap} wrap \n" ..
        " _c_ %{cul} cursor line \n" ..
        " _n_ %{nu} number \n" ..
        " _r_ %{rnu} relative number \n" ..
        " ^ \n" ..
        " ^^^^                _<Esc>_"

      Hydra({
        name = 'Options',
        hint = hint,
        config = {
          color = 'amaranth',
          invoke_on_body = true,
          hint = {
            border = 'rounded',
            position = 'middle'
          }
        },
        mode = {'n','x'},
        body = '<leader>eh',
        heads = {
          {
            'n', function()
              if vim.o.number == true then
                vim.o.number = false
              else
                vim.o.number = true
              end
            end, { desc = 'number' }
          },
          {
            'r', function()
              if vim.o.relativenumber == true then
                vim.o.relativenumber = false
              else
                vim.o.number = true
                vim.o.relativenumber = true
              end
            end, { desc = 'relativenumber' }
          },
          {
            'i', function()
              if vim.o.list == true then
                vim.o.list = false
              else
                vim.o.list = true
              end
            end, { desc = 'list characters' }
          },
          {
            's', function()
              if vim.o.spell == true then
                vim.o.spell = false
              else
                vim.o.spell = true
              end
            end, { exit = true, desc = 'spell' }
          },
          {
            'w', function()
              if vim.o.wrap ~= true then
                vim.o.wrap = true
              else
                vim.o.wrap = false
              end
            end, { desc = 'wrap' }
          },
          {
            'c', function()
              if vim.o.cursorline == true then
                vim.o.cursorline = false
              else
                vim.o.cursorline = true
              end
            end, { desc = 'cursor line' }
          },
          { '<Esc>', nil, { exit = true } }
        }
      })
    end
  },
  { 'folke/neoconf.nvim', cmd = 'Neoconf' },
  {
    'NeogitOrg/neogit',
    enabled = false, -- alpha software
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim"
    },
    opts = {
      signs = {
        section = { "", "" },
        item = { "", "" }
      }
    },
    config = function(_, opts)
      require('neogit').setup(opts)
    end
  },
  {
    "arsham/indent-tools.nvim",
    enabled = false,
    keys = { "]i", "[i", { mode = "v", "ii" }, { mode = "o", "ii" } },
    dependencies = { "arsham/arshlib.nvim" },
    config = function()
      require("indent-tools").config {
        normal = { repeatable = false }
      }
    end
  },
  {
    'chentoast/marks.nvim',
    enabled = false,
    opts = {}
  },
  {
    'rcarriga/nvim-notify',
    enabled = false,
    opts = {
      stages = 'fade_in_slide_out'
    },
    init = function()
      table.insert(ClearFunctions, function()
        require('notify').dismiss({ silent = true, pending = true })
      end)
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    enabled = false,
    config = function()
      vim.opt.statusline = ' '

      require('lualine').setup({
        options = {
          section_separators = { left = '', right = '' },
          component_separators = { left = '·', right = '·' },
        },
        sections = {
          lualine_b = {
            { 'branch', icon = '󰘬' }
          },
          lualine_c = {
            {
              'filename'
            },
          },
          lualine_x = {
            { 'filetype' },
            {
              'encoding',
              cond = function() return (vim.opt.fileencoding:get() ~= 'utf-8') end
            },
            {
              'fileformat',
              cond = function() return (vim.opt.fileformat:get() ~= 'unix') end,
              symbols = { unix = 'lf', dos = 'crlf', mac = 'cr' }
            }
          }
        },
      })

      local lualineFullPath = false
      vim.api.nvim_create_user_command("ToggleLualineFullPath", function()
        lualineFullPath = not lualineFullPath
        local lualine_c = {}

        if lualineFullPath then
          lualine_c = { 'filename', path = 2 }
        else
          lualine_c = { 'filename', path = 0 }
        end
        require('lualine').setup({ sections = { lualine_c = { lualine_c } } })
      end, {})

      vim.keymap.set("n", '<leader>ul', '<cmd>ToggleLualineFullPath<CR>', { desc = 'Toggle lualine full path' })
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    enabled = false,
    version = "*",
    cmd = 'ToggleTerm',
    keys = function()
      local togleader = '<leader>et'

      local has_wk, wk = pcall(require, 'which-key')
      if has_wk then
        wk.add({ { togleader, group = "ToggleTerm" } })
      end

      return {
        { [[<C-\>]], desc = 'ToggleTerm' },
        { togleader .. 'f', "<Cmd>ToggleTerm direction=float<CR>", desc = "ToggleTerm float" },
        { togleader .. 'h', "<Cmd>ToggleTerm size=10 direction=horizontal<CR>", desc = "ToggleTerm horizontal split" },
        { togleader .. 'v', "<Cmd>ToggleTerm size=80 direction=vertical<CR>", desc = "ToggleTerm vertical split" }
      }
    end,
    opts = {
      open_mapping = [[<c-\>]],
      shading_factor = 2,
      on_open = function()
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.signcolumn = "no"
      end
    }
  },
}

return plugins
