return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  config = function()
    local ibl = require("ibl")

    ibl.setup({
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = false, -- 💡 Leave this false so mini.indentscope handles the animation
      },
      exclude = {
        filetypes = {
          "neo-tree",
          "help",
          "lazy",
          "lspinfo",
          "TelescopePrompt",
          "terminal",
          "mason",
          "norg",
        },
        buftypes = { "terminal", "nofile" },
      },
    })

    -- Fix for UI refreshing (Neo-tree toggle can sometimes disrupt signs/lines)
    vim.api.nvim_create_autocmd("User", {
      pattern = "NeotreeClose",
      callback = function()
        vim.schedule(function()
          pcall(vim.cmd, "IBLRefresh")
        end)
      end,
    })
  end,
}
