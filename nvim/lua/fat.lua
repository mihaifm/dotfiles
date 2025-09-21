local function is_plugin_loaded(plugin)
  local lc = require("lazy.core.config")
  return lc.plugins[plugin] and lc.plugins[plugin]._.loaded
end

local function is_ft_loaded(ft)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == ft then
      return true
    end
  end
  return false
end

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
    event = "User LazyColorScheme"
  },
  {
    "maxmx03/fluoromachine.nvim",
    event = "User LazyColorScheme"
  },
  {
    'Mofiqul/dracula.nvim',
    event = "User LazyColorScheme"
  },
  {
    'AstroNvim/astrotheme',
    opts = { palette = "astrojupiter" },
    event = "User LazyColorScheme"
  },
  {
    "catppuccin/nvim",
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
    event = "User LazyColorScheme"
  },
  {
    'projekt0n/github-nvim-theme',
    event = "User LazyColorScheme"
  },
  {
    "ellisonleao/gruvbox.nvim",
    event = "User LazyColorScheme",
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
  {
    "savq/melange-nvim",
    event = "User LazyColorScheme"
  },
  {
    'ramojus/mellifluous.nvim',
    event = "User LazyColorScheme"
  },
  {
    'mellow-theme/mellow.nvim',
    event = "User LazyColorScheme"
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {},
    event = "User LazyColorScheme"
  },
  {
    "EdenEast/nightfox.nvim",
    event = "User LazyColorScheme"
  },
  {
    "olivercederborg/poimandres.nvim",
    opts = {},
    event = "User LazyColorScheme"
  },

  -----------------------
  -- vimscript survivors

  {
    "tpope/vim-fugitive",
    cmd = "Git"
  },
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 1
    end
  },
  {
    "azabiong/vim-highlighter",
    keys = {
      { "f<CR>", desc = 'Highlighter set' },
      { "f<BS>", desc = 'Highlighter erase' },
      { "f<Tab", desc = 'Highlighter find' },
      { "f<C-L>", desc = 'Highlighter clear' },
      { "t<CR>", desc = 'Highlighter set positional' }
    }
  },
  { "wsdjeg/vim-fetch" },
  {
    'bfrg/vim-cpp-modern',
    ft = { "c", "cpp" }
  },

  -----------------------
  -- Telescope extensions
  {
    "ahmedkhalf/project.nvim",
    enabled = true,
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
    event = 'User LazyTelescope',
    config = function()
      require("neoclip").setup({})
      pcall(require('telescope').load_extension, 'neoclip')
    end
  },
  {
    'debugloop/telescope-undo.nvim',
    event = 'User LazyTelescope',
    config = function()
      pcall(require('telescope').load_extension, 'undo')
    end
  },
  {
    "ryanmsnyder/toggleterm-manager.nvim",
    event = 'User LazyTelescope',
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
    cmd = 'ZenMode',
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
    cmd = { "Trouble" },
    opts = {},
    init = function()
      local has_wk, wk = pcall(require, 'which-key')
      if has_wk then
        wk.add({ { "<leader>x", group = "Trouble" } })
      end
    end
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
    cmd = "FormatCode",
    keys = {
      { mode = {'n', 'x'}, '<space>f', ':FormatCode<CR>', desc = 'Format code' }
    },
    config = function()
      vim.api.nvim_create_user_command("FormatCode", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            ["start"] = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format({ async = true, lsp_format = "fallback", range = range })
      end, { range = true })
    end
  },
  {
    'stevearc/aerial.nvim',
    cmd = { 'AerialToggle' },
    config = function()
      require('aerial').setup()
      pcall(require('telescope').load_extension, 'aerial')
    end
  },
  {
    "SmiteshP/nvim-navic",
    event = 'LspAttach',
    dependencies = {
      { "SmiteshP/nvim-navbuddy" },
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("navic-lspattach", { clear = true }),
        callback = function(args)
          require("nvim-navic").setup({
            lazy_update_context = true
          })

          local buffer = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          if client and client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, buffer)
            require('nvim-navbuddy').attach(client, buffer)
          end
        end,
      })
    end,
  },
  {
    'rktjmp/lush.nvim',
    cmd = { "Lushify", "LushRunTutorial", "LushImport" }
  },
  {
    'echasnovski/mini.files',
    keys = {
      {
        '<leader>fc', function()
          require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
        end, desc = 'MiniFiles open directory of current files'
      },
      {
        '<leader>fo', function()
          require('mini.files').open(vim.uv.cwd(), true)
        end, desc = 'MiniFiles open current directory'
      },
    },
    version = false,
  },
  {
    'echasnovski/mini.splitjoin',
    version = false,
    keys = {
      { 'gS', desc = 'Toggle arguments' }
    },
    opts = {}
  },
  {
    'echasnovski/mini.visits',
    version = false,
    config = function()
      require('mini.visits').setup({})

      local has_wk, wk = pcall(require, 'which-key')
      if has_wk then
        wk.add({ { '<leader>ev', group = 'MiniVisits' } })
      end

      local map_vis = function(keys, call, desc)
        local rhs = '<Cmd>lua MiniVisits.' .. call .. '<CR>'
        vim.keymap.set('n', '<Leader>e' .. keys, rhs, { desc = desc })
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
    cmd = { 'ToggleTabline', 'BufferLinePick' },
    keys = {
      { '<leader>ub', '<cmd>ToggleTabline<CR>', desc = 'Toggle tabline/bufferline' },
      { '<leader>up', '<cmd>BufferLinePick<CR>', desc = 'Bufferline pick' }
    },
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('bufferline').setup({})
      vim.cmd('set showtabline=0')

      vim.api.nvim_create_user_command('ToggleTabline', function()
        if vim.o.showtabline ~= 2 then
          vim.cmd('set showtabline=2')
        else
          vim.cmd('set showtabline=0')
        end
      end, {})
    end
  },
  {
    "ggandor/leap.nvim",
    enabled = true,
    keys = {
      { '<M-s>', '<Plug>(leap)', desc = 'Leap' }
    },
  },
  {
    "hedyhli/outline.nvim",
    cmd = "Outline",
    opts = {}
  },
  {
    'norcalli/nvim-colorizer.lua',
    keys = {
      { '<leader>uc', '<cmd>ColorizerToggle<CR>', desc = 'Colorizer' }
    },
    config = function()
      require('colorizer').setup({
        '*'
      })
    end
  },
  {
    'nmac427/guess-indent.nvim',
    cmd = 'GuessIndent',
    opts = {
      auto_cmd = false
    }
  },
  {
    -- NOTE requires the nnn external binary
    "luukvbaal/nnn.nvim",
    cmd = { 'NnnExplorer', 'NnnPicker' },
    cond = function () return vim.fn.has("win32") == 0 end,
    opts = {}
  },
  {
    "uga-rosa/ccc.nvim",
    cmd = { "CccPick", "CccConvert", "CccHighlighterEnable", "CccHighlighterDisable", "CccHighlighterToggle" },
    opts = {
      highlighter = {
        auto_enable = false,
        lsp = true,
      },
    },
    config = function(_, opts)
      require("ccc").setup(opts)
      if opts.highlighter and opts.highlighter.auto_enable then vim.cmd.CccHighlighterEnable() end
    end,
  },
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {}
  },
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
    "folke/snacks.nvim",
    cond = function()
      return vim.fn.executable("lazygit") == 1
    end,
    keys = {
      { "<leader>gg", function() require("snacks.lazygit").open() end, desc = "LazyGit (root dir)" },
      { "<leader>gG", function() require("snacks.lazygit").open({ cwd = vim.fn.expand("%:p:h") }) end, desc = "LazyGit (cwd)" },
    },
    opts = {
      lazygit = { enabled = true },
    },
    init = function()
      local has_wk, wk = pcall(require, 'which-key')
      if has_wk then
        wk.add({ { '<leader>g', group = 'Git' } })
      end

      table.insert(ClearFunctions, function()
        -- clear the remote tab created by lazygit
        -- open file in the previous tab
        local tabnr    = vim.fn.tabpagenr()
        local tabcount = vim.fn.tabpagenr('$')

        if tabcount <= 1 then
          return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local name  = vim.api.nvim_buf_get_name(bufnr)

        local target = (tabnr > 1) and (tabnr - 1) or (tabnr + 1)

        vim.cmd("tabclose")

        if vim.fn.tabpagenr() ~= target then
          vim.cmd("tabnext " .. target)
        end

        if name ~= "" then
          vim.cmd("edit " .. vim.fn.fnameescape(name))
        else
          -- unnamed or scratch buffer: try to show it by bufnr
          if vim.api.nvim_buf_is_loaded(bufnr) then
            pcall(vim.api.nvim_set_current_buf, bufnr)
          end
        end
      end)
    end,
  },
  {
    "chrisbra/csv.vim",
    ft = { "csv" },
    init = function()
      vim.g.csv_no_conceal = 1
    end
  },
  {
    'chrisgrieser/nvim-various-textobjs',
    keys = {
      { mode = { "o", "x" }, "a_", '<cmd>lua require("various-textobjs").subword("outer")<CR>' },
      { mode = { "o", "x" }, "i_", '<cmd>lua require("various-textobjs").subword("inner")<CR>' }
    },
    config = function()
      require("various-textobjs").setup ({ useDefaultKeymaps = false })
    end
  },
  {
    'karb94/neoscroll.nvim',
    cmd = 'ToggleNeoscroll',
    keys = {
      { '<leader>us', '<cmd>ToggleNeoscroll<CR>', desc = 'Toggle smooth scrolling' }
    },
    config = function()
      require('neoscroll').setup({ mappings = {} })

      local neoscrollToggled = false

      vim.api.nvim_create_user_command("ToggleNeoscroll", function()
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

          vim.keymap.set("n", "<C-j>", function()
            require('neoscroll').scroll(3, { move_cursor = true, duration = 30 })
          end, { desc = 'Scroll up' })
          vim.keymap.set("n", "<C-k>", function()
            require('neoscroll').scroll(-3, { move_cursor = true, duration = 30 })
          end, { desc = 'Scroll down' })
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
      end, {})
    end
  },
  { "lewis6991/satellite.nvim", opts = {} },
  {
    "monaqa/dial.nvim",
    keys = {
      {
        "<C-a>", function()
          require("dial.map").manipulate("increment", "normal")
        end, { desc = 'Increment' }
      },
      {
        "<C-x>", function()
          require("dial.map").manipulate("decrement", "normal")
        end, { desc = 'Decrement' }
      },
      {
        "g<C-a>", function()
          require("dial.map").manipulate("increment", "gnormal")
        end, { desc = 'Increment each line' }
      },
      {
        "g<C-x>", function()
          require("dial.map").manipulate("decrement", "gnormal")
        end, { desc = 'Decrement each line' }
      },
      {
        mode = 'v', "<C-a>", function()
          require("dial.map").manipulate("increment", "visual")
        end, { desc = 'Increment' }
      },
      {
        mode = "v", "<C-x>", function()
          require("dial.map").manipulate("decrement", "visual")
        end, { desc = 'Decrement' }
      },
      {
        mode = "v", "g<C-a>", function()
          require("dial.map").manipulate("increment", "gvisual")
        end, { desc = 'Increment each line' }
      },
      {
        mode = "v", "g<C-x>", function()
          require("dial.map").manipulate("decrement", "gvisual")
        end, { desc = 'Decrement each line' }
      },
    },
    config = function()
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
    cmd = 'FzfLua',
    keys = function()
      local fzfleader = "<leader>z"

      local has_wk, wk = pcall(require, 'which-key')
      if has_wk then
        wk.add({ { fzfleader, group = "Fzf" } })
      end

      return {
        { fzfleader .. 'z', "<cmd>FzfLua<CR>", { desc = 'Builtins' } },
        { fzfleader .. 'f', "<cmd>FzfLua files<CR>", { desc = 'Find files' } },
        { fzfleader .. 'g', "<cmd>FzfLua live_grep<CR>", { desc = 'Live grep with glob pattern' } }
      }
    end,
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
    end,
  },
  {
    'MagicDuck/grug-far.nvim',
    cmd = 'GrugFar',
    config = function()
      require('grug-far').setup({})
    end
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = 'markdown',
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
    cmd = { 'ToggleAutopairs' },
    keys = {
      { '<leader>eat', desc = 'Toggle autopairs' }
    },
    init = function()
      local has_wk, wk = pcall(require, 'which-key')
      if has_wk then
        wk.add({ { "<leader>ea", group = "Autopairs" } })
      end
    end,
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

      require("nvim-autopairs").disable()

      vim.keymap.set("n", "<leader>eat", function()
        require("nvim-autopairs").toggle()
      end, { desc = 'Toggle autopairs' })

      vim.api.nvim_create_user_command('ToggleAutopairs', function()
        require("nvim-autopairs").toggle()
      end, {})
    end
  },
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
    cmd = "Copilot",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },
  {
    "mihaifm/megatoggler",
    config = function()
      vim.keymap.set("n", "<leader>m", function() vim.cmd("MegaToggler") end, { desc = 'MegaToggler' })

      require("megatoggler").setup({
        persist_file = "~/dotfiles/.nvimsettings.json",
        ui = {
          title = ""
        },
        tabs = {
          {
            id = "Globals",
            items = {
              {
                id = 'Tabstop',
                label = 'Tabstop      ',
                get = function() return vim.opt_global.tabstop:get() end,
                on_set = function(v) vim.opt_global.tabstop = v end,
                edit_size = 3
              },
              {
                id = 'Shift Width',
                label = 'Shift Width  ',
                get = function() return vim.opt_global.shiftwidth:get() end,
                on_set = function(v) vim.opt_global.shiftwidth = v end,
                edit_size = 3
              },
              {
                id = "Expand Tab",
                get = function() return vim.opt_global.expandtab:get() end,
                on_toggle = function(on) vim.opt_global.expandtab = on end,
              },
              {
                id = "Ignore Case",
                get = function() return vim.o.ignorecase end,
                on_toggle = function(on) vim.o.ignorecase = on end,
              },
              {
                id = "Smart Case",
                get = function() return vim.o.smartcase end,
                on_toggle = function(on) vim.o.smartcase = on end,
              },
              {
                id = "Line Numbers",
                get = function() return vim.opt_global.number:get() end,
                on_toggle = function(on) vim.opt_global.number = on end,
              },
              {
                id = "Relative Numbers",
                get = function() return vim.opt_global.relativenumber:get() end,
                on_toggle = function(on) vim.opt_global.relativenumber = on end,
              },
              {
                id = "Path",
                label = 'Path         ',
                get = function() return table.concat(vim.opt_global.path:get(), ",") end,
                on_set = function(v) vim.opt_global.path = v end
              },
              {
                id = "Inc Command",
                label = 'Inc Command  ',
                get = function() return vim.o.inccommand end,
                on_set = function(v) vim.o.inccommand = v end,
                edit_size = 10
              },
            }
          },
          {
            id = "local",
            label = "Local",
            items = {
              {
                id = 'Tabstop',
                label = 'Tabstop      ',
                persist = false,
                get = function() return vim.bo.tabstop end,
                on_set = function(v) vim.bo.tabstop = v end
              },
              {
                id = 'Shift Width',
                label = 'Shift Width  ',
                persist = false,
                get = function() return vim.bo.shiftwidth end,
                on_set = function(v) vim.bo.shiftwidth = v end
              },
              {
                id = "Expand Tab",
                persist = false,
                get = function() return vim.bo.expandtab end,
                on_toggle = function(on) vim.bo.expandtab = on end,
              },
              {
                id = 'spell',
                label = 'Spell',
                persist = false,
                get = function() return vim.wo.spell end,
                on_toggle = function(on) vim.wo.spell = on end
              },
              {
                id = 'Wrap',
                persist = false,
                get = function() return vim.wo.wrap end,
                on_toggle = function(on) vim.wo.wrap = on end
              },
              {
                id = "Path",
                label = 'Path         ',
                persist = false,
                get = function() return table.concat(vim.opt.path:get(), ",") end,
                on_set = function(v) vim.opt.path = v end
              },
            },
          },
          {
            id = "Editor",
            items = {
              {
                id = "Folds",
                get = function() return vim.o.foldenable end,
                on_toggle = function() vim.cmd("ToggleFolds") end
              },
              {
                id = "Autopairs",
                get = function()
                  if not is_plugin_loaded('nvim-autopairs') then return false end
                  return not require("nvim-autopairs").state.disabled
                end,
                on_toggle = function(on)
                  if on == false and not is_plugin_loaded('nvim-autopairs') then return end
                  if on then
                    require("nvim-autopairs").enable()
                  else
                    require("nvim-autopairs").disable()
                  end
                end
              },
              {
                id = 'Highlight Color Codes',
                persist = false,
                get = function()
                  return require('ccc.highlighter').attached_buffer[vim.api.nvim_get_current_buf()] == true
                end,
                on_toggle = function()
                  vim.cmd("CccHighlighterToggle")
                end
              },
              {
                id = "Smooth scrolling",
                persist = false,
                get = function() return true end,
                on_toggle = function() vim.cmd("ToggleNeoscroll") end,
                icons = { checked = "", unchecked = "" },
              },
              {
                id = 'Cmd Height',
                get = function() return vim.o.cmdheight end,
                on_set = function(v) vim.o.cmdheight = v end
              },
            },
          },
          {
            id = "context",
            label = "Context",
            items = {
              {
                id = "Virtual Text Context",
                persist = false,
                get = function() return true end,
                on_toggle = function() vim.cmd("NvimContextVtToggle") end,
                icons = { checked = "", unchecked = "" },
              },
              {
                id = "Treesitter Context",
                persist = false,
                get = function()
                  if not is_plugin_loaded('nvim-treesitter-context') then
                    return false
                  end
                  return require('treesitter-context').enabled() end,
                  on_toggle = function() vim.cmd("ToggleContext") end,
                },
                {
                  id = "Ghost Text",
                  get = function() return require('cmp.config').get().experimental.ghost_text end,
                  on_toggle = function() vim.cmd("ToggleGhostText") end
                },
                {
                  id = "IBL: Indent Guides",
                  get = function()
                    if not is_plugin_loaded('indent-blankline.nvim') then return false end
                    return require('ibl.config').config and require('ibl.config').config.enabled
                  end,
                  on_toggle = function(on)
                    if on == false and not is_plugin_loaded('indent-blankline.nvim') then return end
                    vim.cmd("ToggleIBL")
                  end,
                },
                {
                  id = "IBL: Rainbow Indent",
                  get = function()
                    if not is_plugin_loaded('indent-rainbowline.nvim') then return false end
                    return require('ibl.config').config.indent.highlight ~= "IblIndent"
                  end,
                  on_toggle = function(on)
                    if on == false and not is_plugin_loaded('indent-rainbowline.nvim') then return end
                    vim.cmd("ToggleIBLRainbow")
                  end,
                  padding = 2
                },
                {
                  id = "IBL: Scope Highlight",
                  get = function()
                    if not is_plugin_loaded('indent-blankline.nvim') then return false end
                    return
                      require('ibl.config').config and
                      require('ibl.config').config.enabled and
                      require('ibl.config').config.scope and
                      require('ibl.config').config.scope.enabled
                  end,
                  on_toggle = function(on)
                    if on == false and not is_plugin_loaded('indent-blankline.nvim') then return end
                    if on == true and not is_plugin_loaded('indent-blankline.nvim') then
                      vim.cmd("ToggleIBL")
                    end
                    vim.cmd("ToggleIBLScope")
                  end,
                  padding = 2
                },
                {
                  id = "Indent Scope Guide",
                  get = function()
                    if not is_plugin_loaded('mini.indentscope') then return false end
                    return not vim.g.miniindentscope_disable
                  end,
                  on_toggle = function(on)
                    vim.g.miniindentscope_disable = not on

                    if on == false and not is_plugin_loaded('mini.indentscope') then return end
                    if on == true and not is_plugin_loaded('mini.indentscope') then
                      require("mini.indentscope")
                    end

                    vim.schedule(function()
                      vim.cmd("hi! link MiniIndentscopeSymbol @keyword.function")
                    end)
                  end,
                }
              }
            },
          {
            id = "Interface",
            items = {
              {
                id = 'Tabline',
                get = function() return vim.o.showtabline == 2 end,
                on_toggle = function(on)
                  if not is_plugin_loaded('bufferline.nvim') then
                    if on == true then vim.cmd("ToggleTabline") end
                    return
                  end
                  if on then
                    vim.o.showtabline = 2
                  else
                    vim.o.showtabline = 0
                  end
                end
              },
              {
                id = 'Statusline Full Path',
                get = function() return require('slim').getStatuslineState().expand_path end,
                on_toggle = function(on)
                  if on then vim.cmd("ToggleStlFullPath on") else vim.cmd("ToggleStlFullPath off") end
                end
              },
              {
                id = 'Statusline Diagnostics',
                get = function() return require('slim').getStatuslineState().show_diagnostics end,
                on_toggle = function(on)
                  if on then vim.cmd("ToggleStlDiagnostics on") else vim.cmd("ToggleStlDiagnostics off") end
                end
              },
              {
                id = 'Aerial',
                get = function()
                  return is_ft_loaded('aerial')
                end,
                on_toggle = function()
                  vim.cmd("AerialToggle")
                end
              },
              {
                id = 'Neotree',
                get = function()
                  return is_ft_loaded('neo-tree')
                end,
                on_toggle = function()
                  vim.cmd("Neotree toggle")
                end
              },
              {
                id = 'Terminal',
                get = function() return is_ft_loaded('terminal') end,
                on_toggle = function() vim.cmd("ToggleTerminal") end
              },
            },
          },
          {
            id = "Lang",
            items = {
              {
                id = 'render-markdown',
                label = 'Render Markdown',
                get = function() return require('render-markdown').get() end,
                on_toggle = function() require('render-markdown').toggle() end,
              },
            },
          },
          {
            id = "Git",
            items = {
              {
                id = "Gitsigns: Current Line Blame",
                get = function()
                  local ok, cfgmod = pcall(require, "gitsigns.config")
                  return ok and cfgmod.config.current_line_blame == true or false
                end,
                on_toggle = function(on)
                  require("gitsigns").toggle_current_line_blame(on)
                end,
              },
              {
                id = "Gitsigns: NumHL",
                get = function()
                  local ok, cfgmod = pcall(require, "gitsigns.config")
                  return ok and cfgmod.config.numhl == true or false
                end,
                on_toggle = function(on)
                  require("gitsigns").toggle_numhl(on)
                end,
              },
              {
                id = "Gitsigns: LineHL",
                get = function()
                  local ok, cfgmod = pcall(require, "gitsigns.config")
                  return ok and cfgmod.config.linehl == true or false
                end,
                on_toggle = function(on)
                  require("gitsigns").toggle_linehl(on)
                end,
              },
              {
                id = "Gitsigns: Deleted",
                get = function()
                  local ok, cfgmod = pcall(require, "gitsigns.config")
                  return ok and cfgmod.config.show_deleted == true or false
                end,
                on_toggle = function(on)
                  ---@diagnostic disable-next-line: deprecated
                  require("gitsigns").toggle_deleted(on)
                end,
              },
              {
                id = "Gitsigns: Word Diff",
                get = function()
                  local ok, cfgmod = pcall(require, "gitsigns.config")
                  return ok and cfgmod.config.word_diff == true or false
                end,
                on_toggle = function(on)
                  require("gitsigns").toggle_word_diff(on)
                end,
              },
              {
                id = "Gitsigns: Signs",
                get = function()
                  local ok, cfgmod = pcall(require, "gitsigns.config")
                  return ok and cfgmod.config.signcolumn ~= false or false
                end,
                on_toggle = function(on)
                  require("gitsigns").toggle_signs(on)
                end,
              },
            },
          }
        },
      })
    end,
  }
}

return plugins
