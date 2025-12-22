return {
  "echasnovski/mini.indentscope",
  version = false,
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    symbol = "│",
    draw = {
      -- Delay (in ms) between drawing steps
      -- Increase this number to slow down the animation
      delay = 50,
    },
    options = {
      try_as_border = true,
    },
  },
  config = function(_, opts)
    require("mini.indentscope").setup(opts)

    -- Keep your existing exclusions
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "help", "alpha", "dashboard", "neo-tree", "lazy", "mason" },
      callback = function()
        vim.b.miniindentscope_disable = true
      end,
    })
  end,
}
