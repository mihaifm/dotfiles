------------------------------------
-- Global settings for some plugins

-- neovide
vim.g.neovide_padding_left = 5
vim.g.neovide_padding_right = 5
vim.g.neovide_transparency = 0.96
vim.g.neovide_hide_mouse_when_typing = true

-- termdebug
vim.g.termdebug_config = { wide = 1, sign = "󰯯" }

if vim.fn.exists(":Termdebug") then
  vim.opt.foldenable = false
end

-- vim-tpipeline
vim.g.tpipeline_restore = 1

----------------------------------
-- Single key for clearing things

ClearFunctions = {}
table.insert(ClearFunctions, function() vim.cmd.nohlsearch() end)

vim.keymap.set("n", "<leader>n", function()
  for _,fun in ipairs(ClearFunctions) do
    fun()
  end
end, { desc = "Clear things" })

--------------
-- Lazy specs

local plugins = {
  {
    -- NOTE undotree requires diff utility (it normally comes with the vim91 distribution)
    "mbbill/undotree",
  },
  {
    "mihaifm/bufstop",
    enabled = true,
    init = function()
      vim.g.BufstopAutoSpeedToggle = 1
      vim.g.BufstopSplit = 'topleft'

      vim.keymap.set('n', '<leader>b', function() vim.cmd('Bufstop') end,
      { desc = 'Bufstop' })
    end
  },
  {
    'folke/which-key.nvim',
    enabled = true,
    event = 'VimEnter',
    config = function()
      local wk = require('which-key')
      wk.setup({
        delay = 500,
        icons = { mappings = false }
      })

      wk.add({
        { "<C-w>", group = "Window" },
        { "s", group = "Flash search" },

        { "<space>", group = "LSP" },
        { "<space>g", group = "Goto" },
        { "<space>gD", desc = "Goto declaration" },
        { "<space>gd", desc = "Goto definition" },
        { "<space>gi", desc = "Goto implementation" },
        { "<space>gr", desc = "Goto references" },
        { "<space>gt", desc = "Goto type definition" },
        { "<space>w", group = "Workspace folders" },
        { "<space>wa", desc = "Add document folder" },
        { "<space>wl", desc = "List document folders" },
        { "<space>wr", desc = "Remove document folder" },
        { "<space>s", group = "View symbols" },
        { "<space>sd", desc = "Document symbols" },
        { "<space>sw", desc = "Workspace symbols" },
        { "<space>K", desc = "Hover documentation" },
        { "<space>f", desc = "Format code" },
        { "<space>r", desc = "Rename variable" },
        { "<space>I", desc = "Toggle inlay hints" },
        { "<space>d", group = "Diagnostics" },
        { "<space>dl", desc = "Toggle virtual diagnostic lines" },
        { "<space>do", desc = "Open diagnostics for current line" },

        { "<leader>", group = "Leader" },
        { "<leader>t", group = "Telescope" },
        { "<leader>f", group = "File" },
        { "<leader>g", group = "Git" },
        { "<leader>i", group = "Indent/Context" },
        { "<leader>p", group = "Dap" },
        { "<leader>s", group = "Session" },
        { "<leader>u", group = "UI" },
        { "<leader>v", group = "MiniVisits" },
        { "<leader>x", group = "Trouble" },
        { "<leader>z", group = "Fzf" },
        { "<leader>e", group = "Extras" },
        { "<leader>et", group = "ToggleTerm" },
      })
    end
  },
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

      local teleleader = "<leader>t"

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

      table.insert(ClearFunctions, function()
        gs_toggled = false
        gs_toggle_diff(gs_toggled)
      end)
    end
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

            vim.cmd('hi! link debugButtons Constant')
            vim.cmd('hi! link debugBreakpoint Statement')
            vim.cmd('hi! link debugBreakpointDisabled Comment')
          end
        end
      })

      vim.cmd.colorscheme("tokyonight")
    end,
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
    -- NOTE open nvim from the VS2022 Command Prompt to install parsers on Windows
    -- NOTE for Redhat run `source scl_source enable devtoolset-12`
    "nvim-treesitter/nvim-treesitter",
    enabled = true,
    version = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "javascript", "python", "html", "bash", "markdown", "markdown_inline" },
        auto_install = false,
        sync_install = false,
        ignore_install = {},
        modules = {},
        highlight = {
          enable = true,
          disable = function(lang, _)
            if lang == 'markdown' or lang == 'markdown_inline' then
              return false
            end
            return true
          end
        },
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
        enabled = true,
        event = "LspAttach",
        config = function()
          require("lsp_lines").setup()

          vim.diagnostic.config({ virtual_lines = false })
        end
      }
    },
    config = function()
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- tsserver = {},
        lua_ls = {
          settings = {
            Lua = {
              hint = {
                enable = true
              }
            }
          }
        },
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

          map("n", lspleader .. 'I', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, 'Toggle inlay hints')

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

          map({'n', 'x'}, lspleader .. 'f', ":FormatCode<CR>", "Format code")

          local lsp_lines_enabled = false
          map('n', lspleader .. 'dl', function()
            lsp_lines_enabled = not lsp_lines_enabled
            vim.diagnostic.config({ virtual_lines = lsp_lines_enabled })
            vim.diagnostic.config({ virtual_text = not lsp_lines_enabled })
          end, 'Toggle virtual diagnostic lines')

          map('n', lspleader .. 'do', function() vim.diagnostic.open_float() end, 'Open diagnostics for current line')
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
        "garymjr/nvim-snippets",
        opts = {
          friendly_snippets = true,
        },
        dependencies = { "rafamadriz/friendly-snippets" },
        keys = {
          {
            "<Tab>",
            function()
              return vim.snippet.active({ direction = 1 }) and "<cmd>lua vim.snippet.jump(1)<cr>" or "<Tab>"
            end,
            expr = true,
            silent = true,
            mode = { "i", "s" },
          },
          {
            "<S-Tab>",
            function()
              return vim.snippet.active({ direction = -1 }) and "<cmd>lua vim.snippet.jump(-1)<cr>" or "<S-Tab>"
            end,
            expr = true,
            silent = true,
            mode = { "i", "s" },
          },
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

      cmp.setup({
        completion = {
          completeopt = "menu,menuone,noinsert,noselect"
        },
        preselect = cmp.PreselectMode.None,
        snippet = {
          expand = function(args)
            return vim.snippet.expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-l>"] = cmp.mapping.complete(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<C-h>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace }),
        }),
        sources = {
          -- sources in group 2 won't appear if the ones in group 1 are available
          { name = "nvim_lsp", group_index = 1 },
          { name = "nvim_lsp_signature_help", group_index = 1 },
          { name = "path", group_index = 1, option = { trailing_slash = true } },
          { name = "buffer", max_item_count = 3, group_index = 1 },
          { name = "snippets", group_index = 1 },
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

      local togkey = '<leader>et'

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
    "chrisgrieser/nvim-spider",
    enabled = true,
    config = function()
      vim.keymap.set({"n", "o", "x"}, "_", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Next word" })
      vim.keymap.set({"n", "o", "x"}, "<C-_>", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Previous word" })
    end
  },
}

return plugins
