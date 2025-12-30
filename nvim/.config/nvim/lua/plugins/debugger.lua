return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    dapui.setup()

    -- Start/Continue (like 'c' or 'run' in gdb)
    vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Continue/Start" })
    -- Step Over (like 'n' or 'next' in gdb)
    vim.keymap.set("n", "<leader>dn", dap.step_over, { desc = "Debug: Next (Step Over)" })
    -- Step Into (like 's' or 'step' in gdb)
    vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })
    -- Step Out (like 'fin' or 'finish' in gdb)
    vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Debug: Step Out (Finish)" })
    -- Toggle Breakpoint (like 'b' in gdb)
    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    -- Conditional Breakpoint (like 'b 25 if x==5')
    vim.keymap.set("n", "<leader>dB", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "Debug: Set Conditional Breakpoint" })

    -- Open REPL (The interactive GDB-like prompt)
    vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })

    -- UI Listeners
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

    -- Adapters & Configurations (keeping your existing GDB logic)
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
    }

    dap.configurations.c = {
      {
        name = "Launch",
        type = "gdb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = true,
      },
    }
    dap.configurations.cpp = dap.configurations.c
  end,
}
