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

return {
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

      local dbgleader = "<leader>p"

      local map = vim.keymap.set

      map("n", "<F5>", function() require("dap").continue() end, { desc = "DAP continue" })
      map("n", "<F10>", function() require("dap").step_over() end, { desc = "DAP step over"})
      map("n", "<F11>", function() require("dap").step_into() end, { desc = "DAP step into"})
      map("n", "<F12>", function() require("dap").step_out() end, { desc = "DAP step out"})
      map("n", "<F9>", function() require("dap").toggle_breakpoint() end, { desc = "DAP Toggle breakpoint"})

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
  }
}
