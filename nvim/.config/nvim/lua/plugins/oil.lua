return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" }, --
  config = function()
    require("oil").setup({
      default_file_explorer = false,
      view_options = {
        show_hidden = true,
      },
      float = {
        padding = 5,
      },
    })
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory in Oil" })
  end,
}
