-- neovide
vim.g.neovide_padding_left = 5
vim.g.neovide_padding_right = 5
vim.g.neovide_transparency = 0.96
vim.g.neovide_hide_mouse_when_typing = true

vim.g.termdebug_config = { wide = 1 }

vim.g.tmux_navigator_no_mappings = 1

return {
  { "tpope/vim-fugitive" },
  { "tpope/vim-sleuth", enabled = false },
  { "tpope/vim-surround", enabled = false },

  { "numToStr/Comment.nvim", opts = {} },

  { "lewis6991/gitsigns.nvim", opts = {} },

  {
    -- NOTE undotree requires diff utility (it normally comes with the vim91 distribution)
    "mbbill/undotree",
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
          ['f'] = { name = "+Copy file info" },
        }
      })
    end
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = { enabled = false },
        char = { enabled = false },
      }
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      -- { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<C-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {
    "folke/tokyonight.nvim",
    enabled = true,
    config = function()
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  {
    'folke/persistence.nvim',
    event = "BufReadPre",
    opts = {}
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
    "nvim-lualine/lualine.nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    enabled = true,
    config = function()
      vim.opt.statusline = ' '
      require('lualine').setup({
        options = {
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' },
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
        }
      })
    end,
  },

  {
    -- NOTE open nvim from the VS2022 Command Prompt to install parsers on Windows
    -- NOTE for Redhat run `source scl_source enable devtoolset-12`
    "nvim-treesitter/nvim-treesitter",
    enabled = true,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "javascript", "python", "html", "bash" },
        auto_install = false,
        sync_install = false,
        ignore_install = {},
        modules = {},
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
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
      require'treesitter-context'.setup({
        max_lines = 2
      })
    end
  },

  {
    -- NOTE telescope equires ripgrep for Live Grep
    "nvim-telescope/telescope.nvim",
    branch = '0.1.x',
    event = 'VimEnter',
    dependencies = {
      "nvim-lua/plenary.nvim",
      'nvim-telescope/telescope-ui-select.nvim',
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      local actions_generate = require('telescope.actions.generate')
      local lga_actions = require("telescope-live-grep-args.actions")

      telescope.setup {
        defaults = {
          mappings = {
            i = {
              ["<C-_>"] = actions_generate.which_key { keybind_width = 12 },
              ["<C-k><C-h>"] = { actions.select_horizontal, type = "action" },
              ["<C-k><C-v>"] = { actions.select_vertical, type = "action" },
              ["<C-v>"] = { "<cmd>i<C-R>+", type = "command" },
              ["<C-x>"] = false,
              ["<C-k><C-z>"] = { actions.to_fuzzy_refine, type = "action" },
            },
            n = {
              ["?"] = actions_generate.which_key { keybind_width = 12 },
              ["<C-k><C-z>"] = { actions.to_fuzzy_refine, type = "action" },
              ["<C-k><C-h>"] = { actions.select_horizontal, type = "action" },
              ["<C-k><C-v>"] = { actions.select_vertical, type = "action" },
              ["<C-v>"] = { "<cmd><C-R>+", type = "command" },
              ["<C-x>"] = false,
            },
          }
        },
        pickers = {
          live_grep = {
            layout_config = { width = 0.99 }
          },
        },
        extensions = {
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
      }

      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'live_grep_args')

      local builtin = require("telescope.builtin")

      local telekey = "t"

      vim.keymap.set("n", telekey .. 'f', function()
          builtin.find_files({ hidden = true, no_ignore = true })
        end, { desc = 'Find files' })

      vim.keymap.set("n", telekey .. 'g', builtin.live_grep, { desc = 'Grep files' })
      vim.keymap.set("n", telekey .. 't', builtin.git_files, { desc = 'Find git files' })
      vim.keymap.set("n", telekey .. 'h', builtin.help_tags, { desc = 'Search help' })
      vim.keymap.set("n", telekey .. 'k', builtin.keymaps, { desc = 'Search keymaps' })
      vim.keymap.set("n", telekey .. 'u', builtin.builtin, { desc = 'Select Telescope builtin' })
      vim.keymap.set('n', telekey .. 'w', builtin.grep_string, { desc = 'Search current word' })
      vim.keymap.set("n", telekey .. 'd', builtin.diagnostics, { desc = 'Search diagnostics' })
      vim.keymap.set("n", telekey .. 'r', builtin.resume, { desc = 'Resume previous search' })
      vim.keymap.set("n", telekey .. 'p', builtin.oldfiles, { desc = 'Find recent files' })
      vim.keymap.set("n", telekey .. 'b', builtin.buffers, { desc = 'Find buffers' })

      vim.keymap.set('n', telekey .. 'c', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = 'Search current buffer' })

      vim.keymap.set('n', telekey .. 'o', function()
        builtin.live_grep { grep_open_files = true, prompt_title = 'Grep open files' }
      end, { desc = 'Search in open files' })

      vim.keymap.set('n', telekey .. 'n', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = 'Search Neovim files' })

      vim.keymap.set("n", telekey .. "a", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
        { desc = 'Grep with args' })
    end
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        "williamboman/mason.nvim",
        branch = 'v2.x'
      },
      { "williamboman/mason-lspconfig.nvim", },
      { 'folke/neodev.nvim', opts = {} },
      { 'j-hui/fidget.nvim', opts = {} },
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
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(event)
          local map = function(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
          end

          local lspkey = '<space>'

          map("n", lspkey .. 'gD', vim.lsp.buf.declaration, 'Goto declaration')

          map("n", lspkey .. 'gd', require('telescope.builtin').lsp_definitions, 'Goto definition')
          map("n", lspkey .. 'gi', require('telescope.builtin').lsp_implementations, 'Goto implementation')
          map("n", lspkey .. 'gt', require('telescope.builtin').lsp_type_definitions, 'Goto type definition')
          map("n", lspkey .. 'gr', require('telescope.builtin').lsp_references, 'Goto references')

          map('n', lspkey .. 'sd', require('telescope.builtin').lsp_document_symbols, 'Document symbols')
          map('n', lspkey .. 'sw', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace symbols')

          map("n", lspkey .. 'K', vim.lsp.buf.hover, 'Hover documentation')
          map("n", lspkey .. 'S', vim.lsp.buf.signature_help, 'Signature help')
          map("n", lspkey .. 'r', vim.lsp.buf.rename, 'Rename variable')
          map({ "n", "v" }, lspkey .. 'c', vim.lsp.buf.code_action, 'Code action')

          map("n", lspkey .. 'wa', vim.lsp.buf.add_workspace_folder, 'Add workspace folder')
          map("n", lspkey .. 'wr', vim.lsp.buf.remove_workspace_folder, 'Remove workspace folder')
          map("n", lspkey .. 'wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, 'List workspace folders')

          map({ 'n', 'v'}, lspkey .. 'f', function()
            require("conform").format({ bufnr = event.buf })
            -- uncomment if using null-ls instead of conform.nvim
            -- vim.lsp.buf.format({ async = true })
          end, 'Format code')

          -- highlight references to the word under cursor (see :help CursorHold)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })
    end
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        dependencies = {
          { "saadparwaiz1/cmp_luasnip" },
          {
            "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
            end,
          }
        },
      },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lsp-signature-help" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-cmdline" },
      { "onsails/lspkind.nvim" },
    },
    config = function()
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
          { name = "path", option = { trailing_slash = true }, group_index = 1 },
          { name = "buffer", max_item_count = 3, group_index = 1 },
          { name = "luasnip", group_index = 1 },
        },
        formatting = {
          format = require("lspkind").cmp_format()
        }
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
    -- cmd = { "ToggleTerm", "TermExec" }, -- doesn't seem to work
    config = function()
      vim.api.nvim_create_autocmd("TermOpen", {
        group = vim.api.nvim_create_augroup("UserTermOpen", { clear = true }),
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
    main = "ibl",
    config = function()
      require("ibl").setup({ enabled = false })
      vim.keymap.set("n", '<leader>ib', '<cmd>IBLToggle', { desc = 'Toggle indent blankline' })
    end
  },

  { 'stevearc/oil.nvim', opts = {} },
  { 'stevearc/dressing.nvim', opts = {} },
  { 'stevearc/aerial.nvim', opts = {} },

  -- spectre requires rg, nvim-oxi and GNU sed
  { 'nvim-pack/nvim-spectre', opts = {} },

  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = 'VeryLazy',
    config = function()
      vim.o.foldcolumn = '0'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99

      vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
      vim.keymap.set("n", "<leader>zk", function()
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
          local suffix = (" 󰁂 %d %d%%"):format(foldedLines, foldedLines / totalLines * 100)
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
            { action = 'lua require("persistence").load()', desc = " Restore Session", icon = " ", key = "s" },
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
}