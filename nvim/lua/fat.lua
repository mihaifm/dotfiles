local plugins = {
  ----------------------
  -- colorscheme battle

  {
    "scottmckendry/cyberdream.nvim",
    opts = {
      transparent = true,
      italic_comments = true,
      -- hide_fillchars = true,
      terminal_colors = true,
    },
  },
  { "maxmx03/fluoromachine.nvim" },
  {
    "shaunsingh/nord.nvim",
    enabled = false,
    config = function()
      vim.g.nord_italic = false
      require("nord").set()
    end,
  },
  { 'Mofiqul/dracula.nvim' },
  {
    'AstroNvim/astrotheme',
    opts = { palette = "astrojupiter" }
  },
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      integrations = {
        aerial = true,
        cmp = true,
        dap = true,
        dap_ui = true,
        dashboard = true,
        flash = true,
        gitsigns = true,
        headlines = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        neotree = true,
        notify = true,
        semantic_tokens = true,
        symbols_outline = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        ufo = true,
        which_key = true,
        neogit = true,
      },
    },
  },
  { 'projekt0n/github-nvim-theme' },
  {
    "ellisonleao/gruvbox.nvim",
    config = function()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('gruvbox-colorscheme', { clear = true }),
        callback = function (args)
          if args.match == 'gruvbox' then
            vim.cmd('hi! link SignColumn Normal')
          end
        end
      })
    end
  },
  { "savq/melange-nvim" },
  { 'ramojus/mellifluous.nvim' },
  { 'mellow-theme/mellow.nvim' },
  { "rose-pine/neovim", name = "rose-pine", opts = {} },
  { "EdenEast/nightfox.nvim" },
  { "olivercederborg/poimandres.nvim", opts = {} },

  -----------------------
  -- vimscript survivors

  { "tpope/vim-fugitive" },
  { "tpope/vim-sleuth", enabled = false },
  { "tpope/vim-surround", enabled = false },

  { 'vimpostor/vim-tpipeline', enabled = false },
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 1
    end
  },
  { "azabiong/vim-highlighter", lazy = false },
  { "wsdjeg/vim-fetch" },
  { 'bfrg/vim-cpp-modern' },

  --------------------
  -- unsorted plugins
  {
    'folke/persistence.nvim',
    enabled = true,
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
    "folke/zen-mode.nvim",
    opts = {
      window = {
        options = {
          number = false,
          relativenumber = false,
          signcolumn = 'no'
        }
      },
      plugins = {
        options = {
          laststatus = 0
        }
      },
      gitsigns = { enabled = false },
      tmux = { enabled = false } -- doesn't seem to work with catppuccin
    }
  },
  {
    "folke/trouble.nvim",
    branch = "dev",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)"
      },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      {
        "<leader>xS",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP references/definitions (Trouble)",
      },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
    opts = {}
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        -- use a sub-list to run only the first available formatter
        javascript = { { "prettierd", "prettier" } },
      },
    },
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
  { 'stevearc/aerial.nvim', opts = {} },

  -- spectre requires rg, nvim-oxi and GNU sed
  { 'nvim-pack/nvim-spectre', opts = {} },
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
  { 'rktjmp/lush.nvim' },
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
    'echasnovski/mini.files',
    version = false,
    config = function ()
      local mf = require('mini.files')
      mf.setup({})
      vim.keymap.set( 'n', '<leader>fc', function()
        mf.open(vim.api.nvim_buf_get_name(0), true)
      end, { desc = 'MiniFiles open directory of current files' })

      vim.keymap.set('n', '<leader>fo', function()
        mf.open(vim.uv.cwd(), true)
      end, { desc = 'MiniFiles open current directory' })
    end
  },
  { 'echasnovski/mini.splitjoin', version = false, opts = {} },
  {
    'echasnovski/mini.visits',
    version = false,
    config = function()
      require('mini.visits').setup({})

      local map_vis = function(keys, call, desc)
        local rhs = '<Cmd>lua MiniVisits.' .. call .. '<CR>'
        vim.keymap.set('n', '<Leader>' .. keys, rhs, { desc = desc })
      end

      map_vis('vp', 'select_path()', 'Select path')
      map_vis('va', 'add_label()', 'Add label')
      map_vis('vr', 'remove_label()', 'Remove label')
      map_vis('vl', 'select_label("", "")', 'Select label (all)')
      map_vis('vw', 'select_label()', 'Select label (cwd)')
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
  {
    'akinsho/bufferline.nvim',
    enabled = true,
    event = 'VeryLazy',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('bufferline').setup({})
      vim.cmd('set showtabline=0')

      vim.api.nvim_create_user_command('ToggleTabline', function()
        if vim.opt.showtabline:get() ~= 2 then
          vim.cmd('set showtabline=2')
        else
          vim.cmd('set showtabline=0')
        end
      end, {})

      vim.keymap.set("n", '<leader>ub', '<cmd>ToggleTabline<CR>', { desc = 'Toggle tabline/bufferline' })
      vim.keymap.set("n", '<leader>up', '<cmd>BufferLinePick<CR>', { desc = 'BufferLine Pick' })
    end
  },
  {
    'rcarriga/nvim-notify',
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
    "ggandor/leap.nvim",
    enabled = true,
    config = function()
      vim.keymap.set('n', '<M-s>', '<Plug>(leap)')
    end
  },
  {
    "NStefan002/screenkey.nvim",
    enabled = false, -- doesn't work so well
    cmd = "Screenkey",
    version = "*",
    config = true,
  },
  {
    "hedyhli/outline.nvim",
    cmd = "Outline",
    opts = {}
  },
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup({
        '*'
      })
    end
  },
  {
    'nmac427/guess-indent.nvim',
    config = function()
      require('guess-indent').setup({ auto_cmd = false })
    end
  },
  {
    "luukvbaal/nnn.nvim",
    cond = function () return vim.fn.has("win32") == 0 end,
    opts = {}
  },
  {
    "uga-rosa/ccc.nvim",
    event = { "InsertEnter" },
    cmd = { "CccPick", "CccConvert", "CccHighlighterEnable", "CccHighlighterDisable", "CccHighlighterToggle" },
    opts = {
      highlighter = {
        auto_enable = true,
        lsp = true,
      },
    },
    config = function(_, opts)
      require("ccc").setup(opts)
      if opts.highlighter and opts.highlighter.auto_enable then vim.cmd.CccHighlighterEnable() end
    end,
  },
  { "kevinhwang91/nvim-bqf", ft = "qf", opts = {} },
  {
    'sindrets/diffview.nvim',
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { winbar_info = true },
        file_history = { winbar_info = true },
      },
    }
  },
  {
    'NeogitOrg/neogit',
    enalbed = false, -- alpha software
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
    dependencies = { "arsham/arshlib.nvim" },
    config = function()
      require("indent-tools").config {
        normal = { repeatable = false }
      }
    end
  },
  {
    "anuvyklack/hydra.nvim",
    config = function()
      local Hydra = require("hydra")

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
        body = '<leader>o',
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
  {
    "chrisbra/csv.vim",
    ft = { "csv" },
    init = function()
      vim.g.csv_no_conceal = 1
    end
  },
  { 'chentoast/marks.nvim', opts = {} },
  {
    'chrisgrieser/nvim-various-textobjs',
    config = function()
      require("various-textobjs").setup ({ useDefaultKeymaps = false })

      vim.keymap.set({ "o", "x" }, "a_", '<cmd>lua require("various-textobjs").subword("outer")<CR>')
      vim.keymap.set({ "o", "x" }, "i_", '<cmd>lua require("various-textobjs").subword("inner")<CR>')
    end
  },
  {
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup({ mappings = {} })

      local neoscrollToggled = false

      local function toggleNeoscroll()
        neoscrollToggled = not neoscrollToggled

        if neoscrollToggled then
          require("neoscroll").setup({
            mappings = {
              '<C-u>', '<C-d>',
              '<C-b>', '<C-f>',
              '<C-y>', '<C-e>',
              'zt', 'zz', 'zb',
            }
          })

          vim.keymap.set("n", "<C-j>", "<Cmd>lua require('neoscroll').scroll(3, true, 30)<CR>", { desc = 'Scroll up' })
          vim.keymap.set("n", "<C-k>", "<Cmd>lua require('neoscroll').scroll(-3, true, 30)<CR>", { desc = 'Scroll down' })
        else
          for _,v in pairs({
            '<C-u>', '<C-d>',
            '<C-b>', '<C-f>',
            '<C-y>', '<C-e>',
            'zt', 'zz', 'zb',
          }) do
            vim.cmd.unmap(v)
          end

          require('neoscroll').setup({ mappings = {} })

          vim.keymap.set('n', '<C-j>', '3j3<C-e>', { desc = 'Scroll up' })
          vim.keymap.set('n', '<C-k>', '3k3<C-y>', { desc = 'Scroll down' })
        end
      end

      vim.keymap.set("n", '<leader>us', toggleNeoscroll, { desc = 'Toggle smooth scrolling' })
    end
  },
  { "lewis6991/satellite.nvim", opts = {} },
  {
    "ryanmsnyder/toggleterm-manager.nvim",
    dependencies = {
      "akinsho/nvim-toggleterm.lua",
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim"
    },
    config = true
  },
  {
    "monaqa/dial.nvim",
    config = function()
      vim.keymap.set("n", "<C-a>", function()
        require("dial.map").manipulate("increment", "normal")
      end, { desc = 'Increment' })
      vim.keymap.set("n", "<C-x>", function()
        require("dial.map").manipulate("decrement", "normal")
      end, { desc = 'Decrement' })
      vim.keymap.set("n", "g<C-a>", function()
        require("dial.map").manipulate("increment", "gnormal")
      end, { desc = 'Increment each line' })
      vim.keymap.set("n", "g<C-x>", function()
        require("dial.map").manipulate("decrement", "gnormal")
      end, { desc = 'Decrement each line' })
      vim.keymap.set("v", "<C-a>", function()
        require("dial.map").manipulate("increment", "visual")
      end, { desc = 'Increment' })
      vim.keymap.set("v", "<C-x>", function()
        require("dial.map").manipulate("decrement", "visual")
      end, { desc = 'Decrement' })
      vim.keymap.set("v", "g<C-a>", function()
        require("dial.map").manipulate("increment", "gvisual")
      end, { desc = 'Increment each line' })
      vim.keymap.set("v", "g<C-x>", function()
        require("dial.map").manipulate("decrement", "gvisual")
      end, { desc = 'Decrement each line' })

      local augend = require "dial.augend"
      require('dial.config').augends:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.constant.alias.bool,
          augend.semver.alias.semver,
          augend.date.new {
            pattern = "%B", -- titlecased month names
            default_kind = "day",
          },
          augend.constant.new { elements = { "'", '"' }, word = false, cyclic = true },
          augend.constant.new { elements = { '(', '[', '{' }, word = false, cyclic = true },
          augend.constant.new { elements = { ')', ']', '}' }, word = false, cyclic = true }
        }
      })
    end
  },
}

return plugins
