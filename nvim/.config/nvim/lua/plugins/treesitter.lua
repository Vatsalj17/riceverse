return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.config").setup({
      auto_install = true,
      ensure_installed = { "c", "lua", "cpp", "python", "markdown", "markdown_inline" },

      -- stripping its control over the ui
      -- highlight = { enable = true },
      -- indent = { enable = true },
    })
  end
}
