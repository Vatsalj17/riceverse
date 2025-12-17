local is_bare = require("utils.term").is_bare_terminal

return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  cond = function()
    return not is_bare()
  end,
  config = function()
    vim.cmd.colorscheme("catppuccin")
  end
}
