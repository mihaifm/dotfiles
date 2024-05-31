-- neovide
vim.g.neovide_padding_left = 5
vim.g.neovide_padding_right = 5
vim.g.neovide_transparency = 0.96
vim.g.neovide_hide_mouse_when_typing = true

vim.g.termdebug_config = { wide = 1 }

vim.g.tpipeline_restore = 1

-- single key for clearing things on the screen
local clear_functions = {}
table.insert(clear_functions, function() vim.cmd.nohlsearch() end)

vim.keymap.set("n", "<leader>n", function()
  for _,fun in ipairs(clear_functions) do
    fun()
  end
end, { desc = "Clear things" })


return {

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
    "folke/tokyonight.nvim",
    enabled = true,
    config = function()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('tokyonight-colorscheme', { clear = true }),
        callback = function (args)
          if args.match == 'tokyonight' then
            vim.cmd('hi! link BufferCurrentSign Function')
            vim.cmd('hi! link BufferInactiveSign Function')
            vim.cmd('hi BufferCurrent gui=italic')
            vim.cmd('hi BufferInactive gui=italic')

            vim.cmd('hi! FloatBorder guibg=NONE')
            vim.cmd('hi! TelescopeBorder guibg=NONE')
            vim.cmd('hi! TelescopePreviewBorder guibg=NONE')
            vim.cmd('hi! TelescopePreviewBorder guibg=NONE')
            vim.cmd('hi! TelescopePromptBorder guibg=NONE')
            vim.cmd('hi! TelescopeResultsBorder guibg=NONE')
            vim.cmd('hi! TelescopeNormal guibg=NONE')
            vim.cmd('hi! link NormalSB Normal')
            vim.cmd('hi! link FoldColumn SignColumn')
          end
        end
      })

      vim.cmd.colorscheme("tokyonight")
    end,
  },
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
  {
    "rebelot/kanagawa.nvim",
    enabled = false
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

  {
    -- NOTE undotree requires diff utility (it normally comes with the vim91 distribution)
    "mbbill/undotree",
  },
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

  -------------
  -- telescope

  {
    -- NOTE telescope requires ripgrep for Live Grep
    "nvim-telescope/telescope.nvim",
    -- branch = '0.1.x',
    version = false,
    event = 'VimEnter',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-telescope/telescope-live-grep-args.nvim' },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = vim.fn.executable("make") == 1 and "make"
          or 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
      },
      {
        "ahmedkhalf/project.nvim",
        event = "VeryLazy",
        cmd = 'ProjectRoot',
        opts = {
          manual_mode = true,
          detection_methods = { 'pattern' },
          patterns = { '.git' }
        },
        config = function(_, opts)
          require("project_nvim").setup(opts)
        end
      },
      { 'nvim-telescope/telescope-file-browser.nvim' },
      { 'debugloop/telescope-undo.nvim' },
      { "AckslD/nvim-neoclip.lua", opts = {} },
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      local actions_generate = require('telescope.actions.generate')
      local lga_actions = require("telescope-live-grep-args.actions")

      local function flash(prompt_bufnr)
        require("flash").jump({
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
              end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-_>"] = actions_generate.which_key { keybind_width = 12 },
              ["<C-k><C-h>"] = { actions.select_horizontal, type = "action" },
              ["<C-k><C-v>"] = { actions.select_vertical, type = "action" },
              ["<C-v>"] = { "<cmd>i<C-R>+", type = "command" },
              ["<C-x>"] = false,
              ["<C-k><C-z>"] = { actions.to_fuzzy_refine, type = "action" },
              ["<C-s>"] = flash,
            },
            n = {
              ["?"] = actions_generate.which_key { keybind_width = 12 },
              ["<C-k><C-z>"] = { actions.to_fuzzy_refine, type = "action" },
              ["<C-k><C-h>"] = { actions.select_horizontal, type = "action" },
              ["<C-k><C-v>"] = { actions.select_vertical, type = "action" },
              ["<C-v>"] = { "<cmd><C-R>+", type = "command" },
              ["<C-x>"] = false,
              ["s"] = flash,
            },
          }
        },
        pickers = {
          live_grep = {
            layout_config = { width = 0.99 }
          },
        },
        extensions = {
          ['fzf'] = { },
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          ['live_grep_args'] = {
            auto_quoting = false,
            mappings = {
              i = {
                ['<C-k><C-k>'] = lga_actions.quote_prompt(),
                ['<C-k><C-c>'] = lga_actions.quote_prompt({ postfix = ' -t cpp'}),
                ['<C-k><C-h>'] = lga_actions.quote_prompt({ postfix = ' -t h'}),
              }
            },
            layout_config = { width = 0.99 }
          }
        }
      })

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'live_grep_args')
      pcall(require('telescope').load_extension, 'projects')
      pcall(require('telescope').load_extension, 'aerial')
      pcall(require('telescope').load_extension, 'file_browser')
      pcall(require('telescope').load_extension, 'undo')
      pcall(require('telescope').load_extension, 'neoclip')

      local builtin = require("telescope.builtin")

      local teleleader = "t"

      vim.keymap.set("n", teleleader .. 'f', function()
          builtin.find_files({ hidden = true, no_ignore = true })
        end, { desc = 'Find files' })

      vim.keymap.set("n", teleleader .. 'g', builtin.live_grep, { desc = 'Grep files' })
      vim.keymap.set("n", teleleader .. 't', builtin.git_files, { desc = 'Find git files' })
      vim.keymap.set("n", teleleader .. 'h', builtin.help_tags, { desc = 'Search help' })
      vim.keymap.set("n", teleleader .. 'k', builtin.keymaps, { desc = 'Search keymaps' })
      vim.keymap.set("n", teleleader .. 'u', builtin.builtin, { desc = 'Select Telescope builtin' })
      vim.keymap.set('n', teleleader .. 'w', builtin.grep_string, { desc = 'Search current word' })
      vim.keymap.set("n", teleleader .. 'd', builtin.diagnostics, { desc = 'Search diagnostics' })
      vim.keymap.set("n", teleleader .. 's', builtin.resume, { desc = 'Resume previous search' })
      vim.keymap.set("n", teleleader .. 'r', builtin.oldfiles, { desc = 'Find recent files' })
      vim.keymap.set("n", teleleader .. 'b', builtin.buffers, { desc = 'Find buffers' })

      vim.keymap.set('n', teleleader .. 'c', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = 'Search current buffer' })

      vim.keymap.set('n', teleleader .. 'o', function()
        builtin.live_grep { grep_open_files = true, prompt_title = 'Grep open files' }
      end, { desc = 'Search in open files' })

      vim.keymap.set('n', teleleader .. 'n', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = 'Search Neovim files' })

      vim.keymap.set("n", teleleader .. 'a', ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
        { desc = 'Grep with args' })

      vim.keymap.set('n', teleleader .. 'p', function() vim.cmd('Telescope projects') end, { desc = 'Projects' })
    end
  },

  --------------------
  -- unsorted plugins

  { "numToStr/Comment.nvim", opts = {} },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        changedelete = { text = '▎' },
      },
    },
    config = function(_, opts)
      local gitsigns = require("gitsigns")
      gitsigns.setup(opts)

      local function gs_toggle_diff(value)
        gitsigns.toggle_linehl(value)
        gitsigns.toggle_deleted(value)
        gitsigns.toggle_word_diff(value)
        gitsigns.toggle_numhl(value)
      end

      local function next_hunk()
        gitsigns.nav_hunk('next')
      end

      local function prev_hunk()
        gitsigns.nav_hunk('prev')
      end

      local gs_toggled = false

      vim.keymap.set("n", "<leader>ge", function()
        gs_toggled = not gs_toggled
        gs_toggle_diff(gs_toggled)
      end, { desc = "Git signs toggle diff" })

      vim.keymap.set("n", "<leader>gn", next_hunk, { desc = "Git signs next hunk" })
      vim.keymap.set("n", "[g", next_hunk, { desc = "Git signs next hunk" })

      vim.keymap.set("n", "<leader>gp", prev_hunk, { desc = "Git signs previous hunk" })
      vim.keymap.set("n", "]g", prev_hunk, { desc = "Git signs previous hunk" })

      table.insert(clear_functions, function()
        gs_toggled = false
        gs_toggle_diff(gs_toggled)
      end)
    end
  },

  {
    'folke/which-key.nvim',
    enabled = true,
    event = 'VimEnter',
    config = function()
      local wk = require('which-key')
      wk.setup()

      vim.opt.timeoutlen = 500

      wk.register({
        ['<C-w>'] = { name = "+Window" },
        ['g'] = { name = "+Go" },
        ['z'] = { name = "+Fold" },
        ['t'] = { name = "+Telescope"},
        ['s'] = { name = "+Flash search"},
        ['<space>'] = {
          name = "+LSP",
          ['g'] = {
            name = "+Goto",
            ['d'] = 'Goto definition',
            ['D'] = 'Goto declaration',
            ['i'] = 'Goto implementation',
            ['t'] = 'Goto type definition',
            ['r'] = 'Goto references'
          },
          ['w'] = {
            name = "+Workspace folders",
            ['a'] = 'Add document folder',
            ['r'] = 'Remove document folder',
            ['l'] = 'List document folders'
          },
          ['s'] = {
            name = "+View symbols",
            ['d'] = 'Document symbols',
            ['w'] = 'Workspace symbols'
          },
          ['K'] = { 'Hover documentation' },
          ['r'] = { 'Rename variable' },
          ['f'] = { 'Format code' }
        },
        ['<leader>'] = {
          name = "+Leader",
          ['f'] = { name = "+File" },
          ['i'] = { name = "+Indent/Context" },
          ['s'] = { name = "+Session" },
          ['x'] = { name = "+Trouble" },
          ['t'] = { name = "+ToggleTerm" },
          ['v'] = { name = "+MiniVisits" },
          ['p'] = { name = "+Dap" },
          ['u'] = { name = "+UI" },
          ['g'] = { name = "+Git" },
        }
      })
    end
  },

  {
    "folke/flash.nvim",
    enabled = true,
    event = "VeryLazy",
    opts = {
      label = {
        -- regenerate labels after typing more characters
        reuse = 'none'
      },
      modes = {
        search = { enabled = false },
        char = { enabled = false },
      },
      prompt = {
        enabled = false
      }
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "<C-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash search" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    },
  },
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
    "nvim-lualine/lualine.nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    enabled = true,
    config = function()
      vim.opt.statusline = ' '

      require('lualine').setup({
        options = {
          section_separators = { left = '', right = '' },
          component_separators = { left = '·', right = '·' },
          disabled_filetypes = {
            statusline = {
              'vimpanel',
              'dap-repl',
              'dapui_console', 'dapui_watches', 'dapui_stacks', 'dapui_breakpoints', 'dapui_scopes'
            }
          }
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

    end,
  },

  {
    -- NOTE open nvim from the VS2022 Command Prompt to install parsers on Windows
    -- NOTE for Redhat run `source scl_source enable devtoolset-12`
    "nvim-treesitter/nvim-treesitter",
    enabled = true,
    version = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "javascript", "python", "html", "bash", "markdown_inline" },
        auto_install = false,
        sync_install = false,
        ignore_install = {},
        modules = {},
        highlight = { enable = false },
        indent = { enable = false },
        incremental_selection = {
          enable = false,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        }
      })
    end
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      local tsc = require('treesitter-context')
      tsc.setup({
        enable = false,
        mode = 'topline',
        -- max_lines = 2
      })

      vim.api.nvim_create_user_command('ContextToggle', function()
        tsc.toggle()
      end, {})

      vim.keymap.set('n', '<leader>ic', '<cmd>ContextToggle<CR>', { desc = 'Toggle context' })
    end
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        "williamboman/mason.nvim",
        branch = 'v2.x'
      },
      { 'williamboman/mason-lspconfig.nvim', },
      { 'folke/neodev.nvim', opts = {} },
      { 'j-hui/fidget.nvim', opts = {} },
      { 'folke/neoconf.nvim', cmd = 'Neoconf' },
      {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        enabled = false,
        event = "LspAttach",
        opts = {}
      }
    },
    config = function()
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- tsserver = {},
        lua_ls = {},
      }

      require('neoconf').setup({})

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- unclear if this is needed
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      require('mason').setup()
      local ensure_installed = vim.tbl_keys(servers or {})

      require('mason-lspconfig').setup {
        ensure_installed = ensure_installed,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-lspattach", { clear = true }),
        callback = function(event)
          local map = function(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
          end

          local lspleader = '<space>'

          map("n", lspleader .. 'gD', vim.lsp.buf.declaration, 'Goto declaration')

          map("n", lspleader .. 'gd', require('telescope.builtin').lsp_definitions, 'Goto definition')
          map("n", lspleader .. 'gi', require('telescope.builtin').lsp_implementations, 'Goto implementation')
          map("n", lspleader .. 'gt', require('telescope.builtin').lsp_type_definitions, 'Goto type definition')
          map("n", lspleader .. 'gr', require('telescope.builtin').lsp_references, 'Goto references')

          map('n', lspleader .. 'sd', require('telescope.builtin').lsp_document_symbols, 'Document symbols')
          map('n', lspleader .. 'sw', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace symbols')

          map("n", lspleader .. 'K', vim.lsp.buf.hover, 'Hover documentation')
          map("n", lspleader .. 'S', vim.lsp.buf.signature_help, 'Signature help')
          map("n", lspleader .. 'r', vim.lsp.buf.rename, 'Rename variable')
          map({ "n", "v" }, lspleader .. 'c', vim.lsp.buf.code_action, 'Code action')

          map("n", lspleader .. 'wa', vim.lsp.buf.add_workspace_folder, 'Add workspace folder')
          map("n", lspleader .. 'wr', vim.lsp.buf.remove_workspace_folder, 'Remove workspace folder')
          map("n", lspleader .. 'wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, 'List workspace folders')

          map({ 'n', 'v'}, lspleader .. 'f', function()
            require("conform").format({ bufnr = event.buf })
            -- uncomment if using null-ls instead of conform.nvim
            -- vim.lsp.buf.format({ async = true })
          end, 'Format code')

          -- highlight references to the word under cursor (see :help CursorHold)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              group = vim.api.nvim_create_augroup('lsp-cursorhold', { clear = true }),
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              group = vim.api.nvim_create_augroup('lsp-cursormoved', { clear = true }),
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end

          map('n', lspleader .. 'dl', function() require("lsp_lines").toggle() end, 'Toggle virtual diagnostic lines')
        end,
      })
    end
  },

  {
    "hrsh7th/nvim-cmp",
    enabled = true,
    version = false,
    event = 'InsertEnter',
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        dependencies = {
          { "saadparwaiz1/cmp_luasnip" },
          {
            "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
              require("luasnip.loaders.from_snipmate").lazy_load()
              require("luasnip.loaders.from_lua").lazy_load()
            end,
          }
        },
      },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lsp-signature-help" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-cmdline" },
      { "andersevenrud/cmp-tmux" },
      { "lukas-reineke/cmp-rg" },
      { "onsails/lspkind.nvim" },
    },
    config = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

      local cmp = require("cmp")
      local luasnip = require('luasnip')
      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),

          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        }),
        sources = {
          -- sources in group 2 won't appear if the ones in group 1 are available
          { name = "nvim_lsp", group_index = 1 },
          { name = "nvim_lsp_signature_help", group_index = 1 },
          { name = "path", group_index = 1, option = { trailing_slash = true } },
          { name = "buffer", max_item_count = 3, group_index = 1 },
          { name = "luasnip", group_index = 1 },
          { name = "tmux", max_item_count = 2, keyword_length = 3, group_index = 1, option = { all_panes = true, label = '' } },
          { name = "rg", max_item_count = 3, keyword_length = 5, group_index = 1 }
        },
        formatting = {
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
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
      })

      cmp.setup.filetype("fancycmd", {
        enabled = false,
      })

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('dadbod-completion-filetype', { clear = true }),
        pattern = { 'sql', 'mysql', 'plsql' },
        callback = function()
          cmp.setup.buffer({
            sources = {
              { name = 'vim-dadbod-completion' },
            },
          })
        end
      })

      ---@diagnostic disable-next-line
      local searchOpts = {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      }
      -- cmp.setup.cmdline({ '/', '?' }, searchOpts)

      ---@diagnostic disable-next-line
      local cmdOpts = {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'path' },
          { name = 'cmdline' }
        },
        matching = { disallow_symbol_nonprefix_matching = false }
      }
      -- cmp.setup.cmdline(':', cmdOpts)
    end,
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
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      vim.api.nvim_create_autocmd('TermOpen', {
        group = vim.api.nvim_create_augroup('toggleterm-termopen', { clear = true }),
        pattern = { "term://*toggleterm*" },
        callback = function(event)
          local map = function(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
          end
              map('t', '<esc>', [[<C-\><C-n>]], 'Exit terminal mode')
              map('t', 'jk', [[<C-\><C-n>]], 'Exit terminal mode')
              map('t', '<C-w>', [[<C-\><C-n><C-w>]], 'Change window')
        end
      })

      local togkey = '<leader>t'

      vim.keymap.set('n', togkey .. 'f', "<Cmd>ToggleTerm direction=float<CR>",
        { desc = "ToggleTerm float" })
      vim.keymap.set('n', togkey .. 'h', "<Cmd>ToggleTerm size=10 direction=horizontal<CR>",
        { desc = "ToggleTerm horizontal split" })
      vim.keymap.set('n', togkey .. 'v', "<Cmd>ToggleTerm size=80 direction=vertical<CR>",
        { desc = "ToggleTerm vertical split" })

      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        shading_factor = 2,
        on_open = function()
          vim.opt_local.foldcolumn = "0"
          vim.opt_local.signcolumn = "no"
        end
      })
    end
  },
  {
    "christoomey/vim-tmux-navigator",
    enabled = true,
    cond = function () return vim.fn.has("win32") == 0 end,
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    keys = {
      { "<C-w><C-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<C-w><C-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<C-w><C-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<C-w><C-l>", "<cmd>TmuxNavigateRight<cr>" },
      { "<C-w>h", "<cmd>TmuxNavigateLeft<cr>" },
      { "<C-w>j", "<cmd>TmuxNavigateDown<cr>" },
      { "<C-w>k", "<cmd>TmuxNavigateUp<cr>" },
      { "<C-w>l", "<cmd>TmuxNavigateRight<cr>" },
    },
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    dependencies = {
      "TheGLander/indent-rainbowline.nvim"
    },
    opts = {
      enabled = false
    },
    main = "ibl",
    config = function(_, opts)
      require("ibl").setup(opts)

      local rainbowToggled = false
      local function toggleRainbowIndents()
        rainbowToggled = not rainbowToggled

        local moreOpts = vim.deepcopy(opts)
        moreOpts.enabled = true

        if rainbowToggled then
          moreOpts = require("indent-rainbowline").make_opts(moreOpts)
        end
        require("ibl").setup(moreOpts)
      end

      vim.keymap.set("n", '<leader>ir', toggleRainbowIndents, { desc = 'Toggle rainbow indents' })
      vim.keymap.set("n", '<leader>ib', '<cmd>IBLToggle<CR>', { desc = 'Toggle indent blankline' })
    end
  },

  { 'stevearc/oil.nvim', opts = {} },
  { 'stevearc/dressing.nvim', enabled = false, opts = {} },
  { 'stevearc/aerial.nvim', opts = {} },

  -- spectre requires rg, nvim-oxi and GNU sed
  { 'nvim-pack/nvim-spectre', opts = {} },

  {
    'kevinhwang91/nvim-ufo',
    enabled = true,
    dependencies = { 'kevinhwang91/promise-async' },
    event = 'VeryLazy',
    config = function()
      vim.o.foldcolumn = '0'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99

      vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
      vim.keymap.set("n", "zK", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end, { desc = 'Peek fold' })

      require('ufo').setup({
        preview = {
          win_config = {
            border = { "", "─", "", "", "", "─", "", "" },
          }
        },
        -- display percentage of folded rows
        -- https://github.com/kevinhwang91/nvim-ufo/issues/4
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local totalLines = vim.api.nvim_buf_line_count(0)
          local foldedLines = endLnum - lnum
          -- local suffix = (" 󰁂 %d %d%%"):format(foldedLines, foldedLines / totalLines * 100)
          local suffix = (" … 󰁂 %d%%"):format(foldedLines / totalLines * 100)
          local sufWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth = 0
          for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
              table.insert(newVirtText, chunk)
            else
              chunkText = truncate(chunkText, targetWidth - curWidth)
              local hlGroup = chunk[2]
              table.insert(newVirtText, { chunkText, hlGroup })
              chunkWidth = vim.fn.strdisplaywidth(chunkText)
              if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
              end
              break
            end
            curWidth = curWidth + chunkWidth
          end
          local rAlignAppndx = math.max(math.min(vim.opt.textwidth["_value"], width - 1) - curWidth - sufWidth, 0)
          suffix = (" "):rep(rAlignAppndx) .. suffix
          table.insert(newVirtText, { suffix, "MoreMsg" })
          return newVirtText
        end,
        provider_selector = function()
          return {'treesitter', 'indent'}
        end
      })
    end
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
    'nvimdev/dashboard-nvim',
    enabled = true,
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local logo = require('logo')

      logo = string.rep("\n", 8) .. logo .. "\n\n"

      local opts = {
        theme = "doom",
        hide = {
          statusline = false,
        },
        config = {
          header = vim.split(logo, "\n"),
          center = {
            { action = "Telescope find_files",desc = " Find File", icon = " ", key = "f" },
            { action = "enew", desc = " New File", icon = " ", key = "n" },
            { action = "Telescope oldfiles", desc = " Recent Files", icon = " ", key = "r" },
            { action = "Telescope live_grep", desc = " Find Text", icon = " ", key = "g" },
            { action = 'lua require("persistence").load({ last = true })', desc = " Restore Last Session", icon = " ", key = "s" },
            { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
            { action = "qa", desc = " Quit", icon = " ", key = "q" },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
      end

      require("dashboard").setup(opts)
    end,
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
  {
    'echasnovski/mini.indentscope',
    version = false,
    config = function()
      vim.g.miniindentscope_disable = true

      vim.keymap.set('n', '<leader>is', function()
        vim.g.miniindentscope_disable = not vim.g.miniindentscope_disable
      end, { desc = 'Toggle indent scope' })

      require('mini.indentscope').setup({
        symbol = '▎'
      })
    end,
  },
  { 'echasnovski/mini.move', version = false, opts = {} },
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
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader>d",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&yes\n&no\n&cancel")
            if choice == 1 then
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
    },
  },
  {
    'romgrk/barbar.nvim',
    enabled = true,
    config = function()
      require('barbar').setup({})
      vim.cmd('BarbarDisable')
      vim.cmd('set showtabline=0')

      vim.api.nvim_create_user_command('TablineToggle', function()
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
    enabled = false,
    event = 'VeryLazy',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {}
  },
  {
    'rcarriga/nvim-notify',
    opts = {
      stages = 'fade_in_slide_out'
    },
    init = function()
      table.insert(clear_functions, function()
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
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    }
  },
  {
    "NStefan002/screenkey.nvim",
    enabled = false, -- doesn't work so well
    cmd = "Screenkey",
    version = "*",
    config = true,
  },
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    init = function()
      -- vim.g.navic_silence = true
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("navic-lspattach", { clear = true }),
        callback = function(args)
          local buffer = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          if client and client.supports_method("textDocument/documentSymbol") then
            require("nvim-navic").attach(client, buffer)
          end
        end,
      })
    end,
    opts = function()
      return {
        lazy_update_context = true
      }
    end,
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
    'max397574/better-escape.nvim',
    event = "InsertCharPre",
    config = function()
      require('better_escape').setup({
        mapping = { 'jj', 'jk' }
      })
    end
  },
  {
    "luukvbaal/statuscol.nvim",
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        -- foldfunc = "builtin",
        relculright = true,
        segments = {
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
          { text = { "%s" }, click = "v:lua.ScSa" },
        },
      })
    end,
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
    "andersevenrud/nvim_context_vt",
    cmd = { "NvimContextVtToggle" },
    keys = {
      { '<leader>iv', mode = { 'n' }, function() vim.cmd('NvimContextVtToggle') end, desc = 'Toggle virtual text context' }
    },
    opts = {
      enabled = false
    }
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    dependencies = {
      {
        { "tpope/vim-dadbod" },
        { "kristijanhusak/vim-dadbod-completion", ft = { 'sql', 'mysql', 'plsql' } },
      }
    },
    init = function()
      vim.g.db_ui_save_location = os.getenv("DADBOD_CONFIG_FOLDER") or "~/.dbui"

      vim.g.db_ui_show_help = 0
      vim.g.db_ui_win_position = 'right'
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_use_nvim_notify = 1
      vim.g.db_ui_hide_schemas = { 'pg_toast_temp.*' }

      vim.g.db_ui_tmp_query_location = vim.g.db_ui_save_location

      -- vim.cmd('autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni')
    end
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
    "chrisgrieser/nvim-spider",
    enabled = true,
    config = function()
      vim.keymap.set({"n", "o", "x"}, "_", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Next word" })
      vim.keymap.set({"n", "o", "x"}, "<C-_>", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Previous word" })
    end
  },
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
}
