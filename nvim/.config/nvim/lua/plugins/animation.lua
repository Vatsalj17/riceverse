local is_bare = require("utils.term").is_bare_terminal

return {
  "sphamba/smear-cursor.nvim",
  cond = function()
    return not is_bare()
  end,
  opts = {},
}
