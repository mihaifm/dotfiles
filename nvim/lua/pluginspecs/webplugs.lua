-- neovide
vim.g.neovide_padding_left = 5
vim.g.neovide_padding_right = 5
vim.g.neovide_transparency = 0.96
vim.g.neovide_hide_mouse_when_typing = true

return {
  { "tpope/vim-fugitive" },
  { "tpope/vim-sleuth" },
  { "tpope/vim-surround" },

  { "numToStr/Comment.nvim", opts = {} },

  { "lewis6991/gitsigns.nvim", opts = {} },

  {
    "mbbill/undotree",
    desc = "requires diff utility (it comes with the vim91 distribution)",
  },

  {
    'folke/which-key.nvim',
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
    "shaunsingh/nord.nvim",
    enabled = false,
    config = function()
      vim.g.nord_italic = false
      require("nord").set()
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    enabled = true,
    config = function()
      require("lualine").setup()
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    enabled = true,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.install").compilers = { "/opt/rh/devtoolset-12/root/usr/bin/gcc" }

      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "python", "html" },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
    desc = "open nvim from the VS2022 Command Prompt to install parsers on Windows",
  },

  {
    "nvim-telescope/telescope.nvim",
    branch = '0.1.x',
    event = 'VimEnter',
    dependencies = {
      "nvim-lua/plenary.nvim",
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'ui-select')

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

    end,
    desc = "requires ripgrep",
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { "williamboman/mason.nvim" },
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
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio"
    },
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

      dap.configurations.c = {
        {
          name = "Run executable (GDB)",
          type = "gdb",
          request = "launch",
          -- This requires special handling of 'run_last', see
          -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
          program = function()
            local path = vim.fn.input({
              prompt = "Path to executable: ",
              default = vim.fn.getcwd() .. "/",
              completion = "file",
            })

            return (path and path ~= "") and path or dap.ABORT
          end,
        },
        {
          name = "Run executable with arguments (GDB)",
          type = "gdb",
          request = "launch",
          -- This requires special handling of 'run_last', see
          -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
          program = function()
            local path = vim.fn.input({
              prompt = "Path to executable: ",
              default = vim.fn.getcwd() .. "/",
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
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      vim.keymap.set("n", "<F5>", function() require("dap").continue() end)
      vim.keymap.set("n", "<F10>", function() require("dap").step_over() end)
      vim.keymap.set("n", "<F11>", function() require("dap").step_into() end)
      vim.keymap.set("n", "<F12>", function() require("dap").step_out() end)
      vim.keymap.set("n", "<F9>", function() require("dap").toggle_breakpoint() end)
      -- vim.keymap.set("n", "<Leader>B", function() require("dap").set_breakpoint() end)
      -- vim.keymap.set("n", "<Leader>lp", function()
      --   require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      -- end)
      -- vim.keymap.set("n", "<Leader>dr", function() require("dap").repl.open() end)
      -- vim.keymap.set("n", "<Leader>dl", function() require("dap").run_last() end)
      -- vim.keymap.set({ "n", "v" }, "<Leader>dh", function() require("dap.ui.widgets").hover() end)
      -- vim.keymap.set({ "n", "v" }, "<Leader>dp", function() require("dap.ui.widgets").preview() end)
      -- vim.keymap.set("n", "<Leader>df", function()
      --   local widgets = require("dap.ui.widgets")
      --   widgets.centered_float(widgets.frames)
      -- end)
      -- vim.keymap.set("n", "<Leader>ds", function()
      --   local widgets = require("dap.ui.widgets")
      --   widgets.centered_float(widgets.scopes)
      -- end)
    end,
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
          { name = "luasnip", group_index = 1 },
          { name = "nvim_lsp", group_index = 1 },
          { name = "nvim_lsp_signature_help", group_index = 1 },
          { name = "path", option = { trailing_slash = true }, group_index = 1 },
          { name = "buffer", group_index = 1 }
        }
      })

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'path' },
          { name = 'cmdline' }
        },
        matching = { disallow_symbol_nonprefix_matching = false }
      })
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
}
