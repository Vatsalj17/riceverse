return {
  url = "https://github.com/imlearning2024/makfile_lsp.git",
  ft = { "make" },
  config = function()
    require("makefile_ls").setup()
  end,
}
