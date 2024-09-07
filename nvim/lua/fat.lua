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

  -----------------------
  -- Telescope extensions
  {
    "ahmedkhalf/project.nvim",
    enabled = true,
    event = "VeryLazy",
    cmd = 'ProjectRoot',
    opts = {
      -- run :ProjectRoot to register a project
      manual_mode = true,
      detection_methods = { 'pattern' },
      patterns = { '.git' }
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
      pcall(require('telescope').load_extension, 'projects')
    end
  },
  {
    "AckslD/nvim-neoclip.lua",
    config = function()
      require("neoclip").setup({})
      pcall(require('telescope').load_extension, 'neoclip')
    end
  },
  {
    'debugloop/telescope-undo.nvim',
    config = function()
      pcall(require('telescope').load_extension, 'undo')
    end
  },
  {
    "ryanmsnyder/toggleterm-manager.nvim",
    dependencies = {
      "akinsho/nvim-toggleterm.lua",
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim"
    },
    config = true
  },

  --------------------
  -- unsorted plugins
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
        javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },
  {
    'stevearc/aerial.nvim',
    config = function()
      require('aerial').setup()

      local aerialLualine = false
      local lua_statusbar_c = {}
      vim.api.nvim_create_user_command("AerialLualineToggle", function()
        aerialLualine = not aerialLualine
        if aerialLualine then
          lua_statusbar_c = { { 'filename' }, { 'aerial' } }
        else
          lua_statusbar_c = { { 'filename' } }
        end
        require('lualine').setup({ sections = { lualine_c = lua_statusbar_c } })
      end, {})

      vim.keymap.set("n", '<leader>ia', '<cmd>AerialLualineToggle<CR>', { desc = 'Toggle aerial lualine context' })

      pcall(require('telescope').load_extension, 'aerial')
    end
  },
  {
    "SmiteshP/nvim-navic",
    dependencies = {
      { "SmiteshP/nvim-navbuddy" },
    },
    lazy = true,
    init = function()
      local navicLualine = false
      local lua_winbar_c = {}
      local navic_config = {
        "navic",
        color_correction = nil,
        navic_opts = {
          separator = " ⇢ ",
          highlight = true,
          depth_limit = 9,
        }
      }

      vim.api.nvim_create_user_command("NavicLualineToggle", function()
        navicLualine = not navicLualine
        if navicLualine then
          lua_winbar_c = { navic_config }
        else
          lua_winbar_c = {}
        end
        require('lualine').setup({ winbar = { lualine_c = lua_winbar_c } })
      end, {})

      vim.keymap.set("n", '<leader>in', '<cmd>NavicLualineToggle<CR>', { desc = 'Toggle navic winbar context' })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("navic-lspattach", { clear = true }),
        callback = function(args)
          require("nvim-navic").setup({
            lazy_update_context = true
          })

          local buffer = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          if client and client.supports_method("textDocument/documentSymbol") then
            require("nvim-navic").attach(client, buffer)
            require('nvim-navbuddy').attach(client, buffer)
          end
        end,
      })
    end,
  },
  { 'rktjmp/lush.nvim' },
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
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({
        winopts = {
          height = 0.95,
          width = 0.95,
          preview = {
            horizontal = "right:40%"
          }
        }
      })

      local fzfleader = "<leader>z"

      vim.keymap.set("n", fzfleader .. 'z', "<cmd>FzfLua<CR>", { desc = 'Builtins' })
      vim.keymap.set("n", fzfleader .. 'f', "<cmd>FzfLua files<CR>", { desc = 'Find files' })
      vim.keymap.set("n", fzfleader .. 'g', "<cmd>FzfLua live_grep_glob<CR>", { desc = 'Live grep with glob pattern' })
    end,
  },
  {
    'MagicDuck/grug-far.nvim',
    config = function()
      require('grug-far').setup({})
    end
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
  {
    'max397574/better-escape.nvim',
    event = "InsertCharPre",
    config = function()
      require('better_escape').setup({
        default_mappings = false,
        mappings = {
          i = {
            j = {
              k = "<Esc>",
              j = "<Esc>",
            },
          },
        }
      })
    end
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({
        fast_wrap = {
          map = '<M-e>',
          chars = { '{', '[', '(', '"', "'" },
          pattern = [=[[%'%"%>%]%)%}%,]]=],
          end_key = '$',
          before_key = 'h',
          after_key = 'l',
          cursor_pos_before = true,
          keys = 'qwertyuiopzxcvbnmasdfghjkl',
          manual_position = true,
          highlight = 'Search',
          highlight_grey='Comment'
        },
      })

      vim.keymap.set("n", "<leader>eat", function()
        require("nvim-autopairs").toggle()
      end, { desc = 'Toggle autopairs' })
    end
  }
}

return plugins
