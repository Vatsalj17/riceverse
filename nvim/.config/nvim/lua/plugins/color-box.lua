return{
  "NvChad/nvim-colorizer.lua",
  opts = {
    filetypes = { "*" },
    user_default_options = {
      tailwind = true,
      css = true,
      names = true,
      mode = "background", -- or 'forground'
    },
  },
  config = function(_, opts)
    require("colorizer").setup(opts)
  end,
}
