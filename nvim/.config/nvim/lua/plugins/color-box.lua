local is_bare = require("utils.term").is_bare_terminal

return {
  "NvChad/nvim-colorizer.lua",
  cond = function()
    return not is_bare()
  end,
  opts = {
    filetypes = {
      "css",
      "scss",
      "sass",
      "less",
      "html",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "svelte",
      "vue",
      "astro",
    },
    user_default_options = {
      tailwind = true,
      css = true,
      names = true,
      mode = "background",
    },
  },
  config = function(_, opts)
    require("colorizer").setup(opts)
  end,
}
