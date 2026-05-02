return {
  "AckslD/nvim-neoclip.lua",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("neoclip").setup({
      keys = {
        telescope = {
          i = {
            paste = "<CR>",
            paste_behind = "<C-k>",
          },
        },
      },
    })
    vim.keymap.set("n", "<leader>cb", ":Telescope neoclip<CR>", { noremap = true, silent = true })
  end,
}
