return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
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

      vim.keymap.set("n", "<F5>", function() require("dap").continue() end, { desc = "DAP continue" })
      vim.keymap.set("n", "<F10>", function() require("dap").step_over() end, { desc = "DAP step over"})
      vim.keymap.set("n", "<F11>", function() require("dap").step_into() end, { desc = "DAP step into"})
      vim.keymap.set("n", "<F12>", function() require("dap").step_out() end, { desc = "DAP step out"})
      vim.keymap.set("n", "<F9>", function() require("dap").toggle_breakpoint() end, { desc = "DAP Toggle breakpoint"})

      vim.keymap.set("n", "<Leader>pm", function()
        require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end)
      vim.keymap.set("n", "<Leader>pr", function() require("dap").repl.open() end)
      vim.keymap.set("n", "<Leader>pl", function() require("dap").run_last() end)
      vim.keymap.set({ "n", "v" }, "<Leader>ph", function() require("dap.ui.widgets").hover() end)
      vim.keymap.set({ "n", "v" }, "<Leader>pp", function() require("dap.ui.widgets").preview() end)
      vim.keymap.set("n", "<Leader>pf", function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.frames)
      end)
      vim.keymap.set("n", "<Leader>ps", function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.scopes)
      end)
    end
  }
}
