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
    cmd = { 'UndotreeShow', 'UndotreeToggle' }
  },
  {
    "mihaifm/bufstop",
    enabled = true,
    init = function()
      vim.g.BufstopAutoSpeedToggle = 1
      vim.g.BufstopSplit = 'topleft'

      vim.keymap.set('n', '<leader>b', function() vim.cmd('Bufstop') end, { desc = 'Bufstop' })

      local has_wk, wk = pcall(require, 'which-key')
      if has_wk then
        wk.add({
          { "<leader>1", hidden = true },
          { "<leader>2", hidden = true },
          { "<leader>3", hidden = true },
          { "<leader>4", hidden = true },
          { "<leader>5", hidden = true },
          { "<leader>6", hidden = true },
        })
      end
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
        icons = { mappings = false },
        win = { no_overlap = false },
      })

      wk.add({
        { "<space>", group = "LSP" },
        { "<leader>", group = "Leader" },
        { "<leader>f", group = "File" },
        { "<leader>g", group = "Git" },
        { "<leader>i", group = "Indent/Context" },
        { "<leader>s", group = "Session" },
        { "<leader>u", group = "UI" },
        { "<leader>e", group = "Extras" },
      })
    end
  },
  {
    -- NOTE telescope requires ripgrep for Live Grep
    "nvim-telescope/telescope.nvim",
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
      { 'nvim-telescope/telescope-file-browser.nvim' },
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
          find_files = {
            file_ignore_patterns = { 'node_modules', '.git', '.venv' },
            hidden = true,
          },
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
            file_ignore_patterns = { 'node_modules', '.git', '.venv' },
            additional_args = function()
              return { '--hidden' }
            end,
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
      pcall(require('telescope').load_extension, 'file_browser')

      local builtin = require("telescope.builtin")

      local teleleader = "<leader>t"

      local has_wk, wk = pcall(require, 'which-key')
      if has_wk then
        wk.add({ { teleleader, group = "Telescope" } })
        wk.add({ { "<leader>es", group = "Telescope" } })
      end

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

      vim.keymap.set('n', teleleader .. 'e', function()
        vim.cmd('doautocmd User LazyColorScheme')
        vim.cmd('Telescope colorscheme enable_preview=true')
      end, { desc = 'Colorscheme' })

      vim.keymap.set('n', '<leader>esl', function()
        vim.cmd('doautocmd User LazyTelescope')
      end, { desc = 'Load Telescope extensions' })

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

            vim.cmd('hi GitSignsDeleteInline guibg=#45273a')
          end
        end
      })

      vim.cmd.colorscheme("tokyonight")
    end,
  },
  {
    "folke/flash.nvim",
    enabled = true,
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
    config = function(_, opts)
      require("flash").setup(opts)

      local has_wk, wk = pcall(require, 'which-key')
      if has_wk then
        wk.add({ { "s", group = "Flash search" } })
      end
    end
  },
  {
    -- NOTE open nvim from the VS2022 Command Prompt to install parsers on Windows
    -- NOTE for Redhat run `source scl_source enable devtoolset-12`
    "nvim-treesitter/nvim-treesitter",
    enabled = true,
    version = false,
    -- build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "query", "javascript", "python", "html", "bash", "markdown", "markdown_inline" },
        ensure_installed = { },
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
          enable = true,
          keymaps = {
            init_selection = "<leader>rn",
            node_incremental = "<leader>rn",
            node_decremental = "<leader>rp",
          },
        }
      })

      local has_wk, wk = pcall(require, 'which-key')
      if has_wk then
        wk.add({ { "<leader>r", group = "Treesitter" } })
        wk.add({ { "<leader>rn", desc = "Select node incremental" } })
        wk.add({ { "<leader>rp", desc = "Select node decremental" } })
      end
    end
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      mode = 'cursor',
    },
    cmd = { 'TSContextEnable' },
    keys = {
      { '<leader>ic', '<cmd>ToggleContext<CR>', desc = 'Toggle context' }
    },
    init = function(_, opts)

      vim.api.nvim_create_user_command('ToggleContext', function()
        if not require("lazy.core.config").plugins['nvim-treesitter-context']._.loaded then
          require('treesitter-context').setup(opts)
          return
        end

        require('treesitter-context').toggle()
      end, {})

      vim.keymap.set('n', '<leader>ic', '<cmd>ToggleContext<CR>', { desc = 'Toggle context' })

      vim.keymap.set("n", "[c", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, { desc = "Jump to context (upwards)", silent = true })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = {
      textobjects = {
        select = {
          enable = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
          },
        },
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
        lsp_interop = {
          enable = false
        },
        swap = {
          enable = false
        }
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end
  },
  {
    "williamboman/mason.nvim",
    cmd = { 'Mason', 'MasonInstall' },
    opts = {}
  },
  {
    'j-hui/fidget.nvim',
    event = "LspAttach",
    config = function()
      require('fidget').setup {}

      vim.cmd("Fidget suppress")

      vim.keymap.set('n', '<space>F', '<cmd>Fidget suppress<CR>', { desc = 'Toggle Fidget notifications' })
    end
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    enabled = true,
    event = "LspAttach",
    config = function()
      require("lsp_lines").setup()

      vim.diagnostic.config({ virtual_lines = false })
    end
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { "williamboman/mason-lspconfig.nvim", config = function() end },
    },
    ft = { 'lua' },
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

          local has_wk, wk = pcall(require, 'which-key')
          if has_wk then
            wk.add({
              { lspleader .. "d", group = "Diagnostics" },
              { lspleader .. "s", group = "View symbols" },
              { lspleader .. "w", group = "Workspace folders" },
              { lspleader .. "g", group = "Goto" }
            })
          end

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

          local lsp_lines_enabled = false
          map('n', lspleader .. 'dl', function()
            lsp_lines_enabled = not lsp_lines_enabled
            vim.diagnostic.config({ virtual_lines = lsp_lines_enabled })
          end, 'Toggle virtual diagnostic lines')

          map('n', lspleader .. 'do', function() vim.diagnostic.open_float() end, 'Open diagnostics for current line')
        end,
      })

      vim.diagnostic.config({
        virtual_text = {
          prefix = '·',
          spacing = 1,
          format = function() return '' end
        },
        underline = false,
        float = {
          border = 'rounded',
          header = '',
          suffix='',
          prefix=' '
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰀩',
            [vim.diagnostic.severity.WARN] = '󰀦',
            [vim.diagnostic.severity.INFO] = '󰀧',
            [vim.diagnostic.severity.HINT] = '󱇎'
          }
        }
      })
      vim.cmd('hi DiagnosticVirtualTextError guibg=none')
      vim.cmd('hi DiagnosticVirtualTextWarn guibg=none')
      vim.cmd('hi DiagnosticVirtualTextInfo guibg=none')
      vim.cmd('hi DiagnosticVirtualTextHint guibg=none')
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
    },
    config = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

      local cmp = require("cmp")

      local kind_icons = {
        Text = '󰉿',
        Method = 'm',
        Function = '󰊕',
        Constructor = '',
        Field = '',
        Variable = '󰆧',
        Class = '󰌗',
        Interface = '',
        Module = '',
        Property = '',
        Unit = '',
        Value = '󰎠',
        Enum = '',
        Keyword = '󰌋',
        Snippet = '',
        Color = '󰏘',
        File = '󰈙',
        Reference = '',
        Folder = '󰉋',
        EnumMember = '',
        Constant = '󰇽',
        Struct = '',
        Event = '',
        Operator = '󰆕',
        TypeParameter = '󰊄',
      }

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
          { name = "rg", max_item_count = 3, keyword_length = 5, group_index = 1 },
          { name = "lazydev", group_index = 0 },
        },
        ---@diagnostic disable-next-line
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = function(entry, vim_item)
            vim_item.kind = string.format('%s ', kind_icons[vim_item.kind])
            vim_item.menu = ({
              snippets = 'snippet',
              nvim_lsp = 'LSP',
              buffer = 'buf',
              path = 'path',
              tmux = 'tmux',
              rg = 'rg',
            })[entry.source.name]
            return vim_item
          end,
        },
      })

      cmp.setup.filetype("fancycmd", {
        enabled = false,
      })

      local ghost_text = false

      vim.api.nvim_create_user_command("ToggleGhostText", function()
        ghost_text = not ghost_text

        if ghost_text then
          cmp.setup({ experimental = { ghost_text = { hl_group = 'CmpGhostText' } } })
        else
          cmp.setup({ experimental = { ghost_text = false } })
        end
      end, {})

      vim.keymap.set('n', '<leader>ug', '<cmd>ToggleGhostText<CR>', { desc = 'Toggle ghost text' })

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
      enabled = false,
      indent = {
        char = "│",
        -- tab_char = "│",
      },
      scope = {
        show_start = false
      }
    },
    main = "ibl",
    keys = function(plugin)
      local rainbowToggled = false
      local iblToggled = false

      local function toggleRainbowIndents()
        rainbowToggled = not rainbowToggled

        local moreOpts = vim.deepcopy(plugin.opts)

        if rainbowToggled then
          moreOpts.enabled = true
          moreOpts.indent.char = ""
          moreOpts = require("indent-rainbowline").make_opts(moreOpts, {
            color_transparency = 0.05,
            colors = { 0x222222, 0xdddddd }
          })
        else
          moreOpts.enabled = iblToggled
        end

        require("ibl").setup(moreOpts)
      end

      local function toggleIBL()
        iblToggled = not iblToggled
        plugin.opts.enabled = iblToggled

        require('ibl').setup(plugin.opts)

        if not iblToggled then
          rainbowToggled = false
        end
      end

      return {
        { '<leader>ir', toggleRainbowIndents, desc = 'Toggle rainbow indents'},
        { '<leader>ib', toggleIBL, desc = 'Toggle indent blankline' }
      }
    end
  },
  {
    'stevearc/oil.nvim',
    -- open Oil in a sidepanel: top 25sp +Oil
    cmd = "Oil",
    opts = {}
  },
  {
    'kevinhwang91/nvim-ufo',
    enabled = true,
    dependencies = { 'kevinhwang91/promise-async' },
    cmd = "ToggleFolds",
    keys = {
      { '<leader>uf', '<cmd>ToggleFolds<CR>', desc = 'Toggle Folds' }
    },
    config = function()
      local foldingEnabled = false

      vim.api.nvim_create_user_command("ToggleFolds", function()
        foldingEnabled = not foldingEnabled

        if foldingEnabled then
          vim.o.foldcolumn = '1'
          vim.o.foldenable = true
        else
          vim.o.foldcolumn = '0'
          vim.o.foldenable = false
        end
      end, {})

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

      ---@diagnostic disable-next-line
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
            { action = 'SesLoad', desc = " Restore Last Session", icon = " ", key = "s" },
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
    opts = {
      -- symbol = '▎'
      symbol = '│',
      draw = {
        delay = 0
      }
    },
    keys = {
      {
        '<leader>is', function()
          vim.g.miniindentscope_disable = not vim.g.miniindentscope_disable
          vim.cmd("hi! link MiniIndentscopeSymbol @keyword.function")
        end, desc = 'Toggle indent scope'
      }
    },
    init = function()
      vim.g.miniindentscope_disable = true
    end
  },
  {
    'echasnovski/mini.move',
    version = false,
    opts = {},
    keys = {
      { '<M-j>', mode = { 'n', 'x'}, desc = 'Move line down' },
      { '<M-k>', mode = { 'n', 'x'}, desc = 'Move line up' },
      { '<M-h>', mode = { 'n', 'x'}, desc = 'Move line left' },
      { '<M-l>', mode = { 'n', 'x'}, desc = 'Move line right' },
    }
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
      vim.opt.numberwidth = 2
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        -- foldfunc = "builtin",
        relculright = true,
        segments = {
          { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
          { text = {
            function(args, segment)
              if args.rnu and args.relnum == 0 then
                return "%=0"
              else
                return builtin.lnumfunc(args, segment)
              end
            end, " " }, click = "v:lua.ScLa" },
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
    keys = {
      { mode = {"n", "o", "x"}, "_", "<cmd>lua require('spider').motion('w')<CR>", desc = 'Next word' },
      { mode = {"n", "o", "x"}, "<C-_>", "<cmd>lua require('spider').motion('b')<CR>", desc = 'Previous word' },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true }, -- `vim.uv` typings
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = {
          { "nvim-neotest/nvim-nio" },
        }
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {}
      },
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "mason.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
          automatic_installation = true,
          ensure_installed = {},
        }
      },
      {
        "jbyuki/one-small-step-for-vimkind"
      },
    },
    keys = function(_, keys)
      return {
        -- wrap every key in a function to avoid loading the plugin on 'require'
        { '<F5>', function () require("dap").continue() end, desc = 'DAP continue' },
        { '<F10>', function() require("dap").step_over() end, desc = 'DAP step over' },
        { '<F11>', function() require("dap").step_into() end, desc = 'DAP step into' },
        { '<F12>', function() require("dap").step_out() end, desc = 'DAP step out' },
        { '<F9>', function() require("dap").toggle_breakpoint() end, desc = 'DAP toggle breakpoint' },
        { '<F7>', function() require("dapui").toggle() end, desc = 'DAP see last session result' },
        { '<F8>', function() require("osv").launch({port=8086}) end, desc = 'Start lua debug server (port 8086)' },
        unpack(keys),
      }
    end,
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.adapters.gdb = {
        id = "gdb",
        type = "executable",
        command = "gdb",
        args = { "--quiet", "--interpreter=dap" },
      }

      dap.adapters.nlua = function(callback, conf)
        local adapter = {
          type = "server",
          host = conf.host or "127.0.0.1",
          port = conf.port or 8086,
        }
        if conf.start_neovim then
          local dap_run = dap.run
          dap.run = function(c)
            adapter.port = c.port
            adapter.host = c.host
          end
          require("osv").run_this()
          dap.run = dap_run
        end
        callback(adapter)
      end

      dap.configurations.lua = {
        {
          type = "nlua",
          request = "attach",
          name = "Run this file",
          start_neovim = {},
        },
        {
          type = "nlua",
          request = "attach",
          name = "Attach to running Neovim instance (port = 8086)",
          port = 8086,
        },
      }

      dap.configurations.c = {
        {
          name = "Run executable (GDB)",
          type = "gdb",
          request = "launch",
          program = function()
            local path = vim.fn.input({
              prompt = "Path to executable: ",
              -- default = vim.fn.getcwd() .. "/",
              completion = "file",
            })

            return (path and path ~= "") and path or dap.ABORT
          end,
        },
        {
          name = "Run executable with arguments (GDB)",
          type = "gdb",
          request = "launch",
          program = function()
            local path = vim.fn.input({
              prompt = "Path to executable: ",
              -- default = vim.fn.getcwd() .. "/",
              completion = "file",
            })

            return (path and path ~= "") and path or dap.ABORT
          end,
          args = function()
            local args_str = vim.fn.input({
              prompt = "Arguments: ",
            })
            return vim.split(args_str, " +")
          end,
        },
        {
          name = "Attach to process (GDB)",
          type = "gdb",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }

      dap.configurations.cpp = dap.configurations.c

      dap.listeners.before.attach.dapui_config = function()
        dapui.open({})
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open({})
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close({})
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close({})
      end

      local function get_args(config)
        local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
        config = vim.deepcopy(config)
        config.args = function()
          ---@diagnostic disable-next-line
          local new_args = vim.fn.input("Run with args: ", table.concat(args, " "))
          return vim.split(vim.fn.expand(new_args), " ")
        end
        return config
      end

      local dbgleader = "<leader>p"

      local has_wk, wk = pcall(require, 'which-key')
      if has_wk then
        wk.add({ { dbgleader, group = "DAP" } })
      end

      local map = vim.keymap.set

      map("n", dbgleader .. 'b', function() require("dap").toggle_breakpoint() end, { desc = "DAP Toggle breakpoint"})
      map("n", dbgleader .. 'c', function() require("dap").continue() end, { desc = "Continue" })
      map('n', dbgleader .. 'a', function() require("dap").continue({ before = get_args }) end, { desc = "Run with args" })
      map("n", dbgleader .. 'C', function() require("dap").run_to_cursor() end, { desc = "Run to cursor" })
      map("n", dbgleader .. 'J', function() require("dap").goto() end, { desc = "Go to" })
      map("n", dbgleader .. 'i', function() require("dap").step_into() end, { desc = "Step into" })
      map("n", dbgleader .. 'j', function() require("dap").down() end, { desc = "Down" })
      map("n", dbgleader .. 'k', function() require("dap").up() end, { desc = "Up" })
      map("n", dbgleader .. 'l', function() require("dap").run_last() end, { desc = "Run last" })
      map("n", dbgleader .. 'o', function() require("dap").step_out() end, { desc = "Step out" })
      map("n", dbgleader .. 'O', function() require("dap").step_over() end, { desc = "Step over" })
      map("n", dbgleader .. 'P', function() require("dap").pause() end, { desc = "Pause" })
      map("n", dbgleader .. 'r', function() require("dap").repl.toggle() end, { desc = "Toggle repl" })
      map("n", dbgleader .. 's', function() require("dap").session() end, { desc = "Session" })
      map("n", dbgleader .. 't', function() require("dap").terminate() end, { desc = "Terminate" })

      map("n", dbgleader .. 'B', function()
        require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end, { desc = "Breakpoint Condition" })

      map("n", dbgleader .. 'm', function()
        require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end, { desc = "Set breakpoint with log" })

      map({ "n", "v" }, dbgleader .. 'K', function() require("dap.ui.widgets").hover() end, { desc = "Hover" })
      map({ "n", "v" }, dbgleader .. 'p', function() require("dap.ui.widgets").preview() end, { desc = "Preview" })

      map("n", dbgleader .. 'f', function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.frames)
      end, { desc = "Frames" })

      map("n", dbgleader .. 's', function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.scopes)
      end, { desc = "Scopes" })

      map("n", dbgleader .. 'S', function() require("osv").launch({port=8086}) end, { desc = "Start lua debug server (port 8086)" })
      map("n", dbgleader .. 'X', function() require("osv").stop() end, { desc = "Stop lua debug server" })
    end
  },
}

return plugins
