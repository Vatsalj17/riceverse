return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text", -- shows variable values inline while debugging
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")

    -- Virtual text setup (shows values next to variables inline)
    require("nvim-dap-virtual-text").setup()

    dapui.setup({
      icons = { expanded = "", collapsed = "", current_frame = "" },
    })

    -- Keymaps
    local map = function(key, fn, desc)
      vim.keymap.set("n", key, fn, { desc = desc })
    end

    map("<leader>dc", dap.continue,          "Debug: Continue/Start")
    map("<leader>dn", dap.step_over,          "Debug: Step Over")
    map("<leader>di", dap.step_into,          "Debug: Step Into")
    map("<leader>do", dap.step_out,           "Debug: Step Out")
    map("<leader>db", dap.toggle_breakpoint,  "Debug: Toggle Breakpoint")
    map("<leader>dB", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end,                                      "Debug: Conditional Breakpoint")
    map("<leader>dl", function()
      dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
    end,                                      "Debug: Log Point")
    map("<leader>dr", dap.repl.open,          "Debug: Open REPL")
    map("<leader>dR", dap.run_last,           "Debug: Re-run Last")
    map("<leader>du", dapui.toggle,           "Debug: Toggle UI")
    map("<leader>dx", function()
      dap.terminate()
      dapui.close()
    end,                                      "Debug: Terminate")

    -- Auto open/close UI
    dap.listeners.before.attach.dapui_config    = function() dapui.open() end
    dap.listeners.before.launch.dapui_config    = function() dapui.open() end
    dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
    dap.listeners.before.event_exited.dapui_config     = function() dapui.close() end

    -- Adapters
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
    }

    -- Configurations
    dap.configurations.c = {
      {
        name = "Launch file",
        type = "gdb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = true,
      },
      {
        name = "Attach to process",           -- attach to already running process
        type = "gdb",
        request = "attach",
        pid = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
      },
    }

    dap.configurations.cpp = dap.configurations.c
    dap.configurations.rust = dap.configurations.c  -- works for basic rust too
  end,
}
