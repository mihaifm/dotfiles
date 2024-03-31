-- neovide
vim.g.neovide_padding_left = 5
vim.g.neovide_padding_right = 5
vim.g.neovide_transparency = 0.96
vim.g.neovide_hide_mouse_when_typing = true

return {
  {
    "easymotion/vim-easymotion",
    enabled = false,
    config = function()
      vim.keymap.set('n', 'ss', '<Plug>(easymotion-s2)', { desc = 'EasyMotion search 2 characters' })
      vim.keymap.set('n', 'st', '<Plug>(easymotion-t2)', { desc = 'EasyMotion till 2 characters' })
      vim.keymap.set('n', 'sl', '<Plug>(easymotion-lineforward)', { desc = 'EasyMotion line forward' })
      vim.keymap.set('n', 'sj', '<Plug>(easymotion-j)', { desc = 'EasyMotion line below' })
      vim.keymap.set('n', 'sk', '<Plug>(easymotion-k)', { desc = 'EasyMotion line above' })
      vim.keymap.set('n', 'sh', '<Plug>(easymotion-linebackward)', { desc = 'EasyMotion line backward' })
      vim.keymap.set('n', 's/', '<Plug>(easymotion-sn)', { desc = 'EasyMotion search n characters' })
      vim.keymap.set('o', 's/', '<Plug>(easymotion-tn)', { desc = 'EasyMotion till n characters' })
      vim.keymap.set('n', 'sn', '<Plug>(easymotion-next)', { desc = 'EasyMotion jump to next match' })
      vim.keymap.set('n', 'sN', '<Plug>(easymotion-prev)', { desc = 'EasyMotion jump to previous match' })
      vim.keymap.set('n', 'sw', '<Plug>(easymotion-w)', { desc = 'EasyMotion jump to word' })
      vim.keymap.set('n', 'sb', '<Plug>(easymotion-bd-w)', { desc = 'EasyMotion jump to word backwards' })
      vim.keymap.set('n', 'se', '<Plug>(easymotion-e)', { desc = 'EasyMotion jump to end of word' })

      vim.g.EasyMotion_startofline = 0
      vim.g.EasyMotion_keys = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    end
  },

  { "tpope/vim-fugitive" },
  { "tpope/vim-sleuth" },
  { "tpope/vim-surround" },

  { "numToStr/Comment.nvim", opts = {} },

  { "lewis6991/gitsigns.nvim", opts = {} },

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
      local wk = require('which-key')
      wk.setup()

      wk.register({
        ['<C-w>'] = { name = "+Window" },
        ['g'] = { name = "+Go" },
        ['z'] = { name = "+Fold" },
        ['<space>'] = { name = "+LSP" },
        ['<leader>'] = {
          name = "+Leader",
          f = { name = "+Copy file info" },
          t = { name = "+Telescope"},
        }
      })
    end
  },

  {
    "mbbill/undotree",
    desc = "requires diff utility (it comes with the vim91 distribution)",
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
    "itchyny/lightline.vim",
    enabled = false,
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
    tag = "0.1.5",
    dependencies = {
      "nvim-lua/plenary.nvim",
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>tf", builtin.find_files, {})
      vim.keymap.set("n", "<leader>tg", builtin.live_grep, {})
      vim.keymap.set("n", "<C-p>", builtin.git_files, {})

      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
    end,
    desc = "requires ripgrep",
  },

  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      lspconfig.lua_ls.setup({ capabilities = capabilities })
      -- lspconfig.tsserver.setup({ capabilities = capabilities })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- Buffer local mappings. See :help vim.lsp.*
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set("n", "<space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<space>kf", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end,
      })
    end,
    dependencies = {
      {
        "williamboman/mason-lspconfig.nvim",
        config = function()
          require("mason-lspconfig").setup({
            ensure_installed = {
              "lua_ls",
              --"tsserver",
              "clangd",
            },
          })
        end,
      },
      { 'folke/neodev.nvim', opts = {} },
    }
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
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
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
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "luasnip" },
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  { "hrsh7th/cmp-nvim-lsp" },

  { "hrsh7th/cmp-nvim-lsp-signature-help" },

  { "hrsh7th/cmp-buffer" },

  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
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
