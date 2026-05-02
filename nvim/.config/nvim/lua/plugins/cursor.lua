local is_bare = require("utils.term").is_bare_terminal

return {
  "sphamba/smear-cursor.nvim",
  cond = function()
    return not is_bare()
  end,
  opts = {
    smear_between_buffers = true,
    smear_between_neighbor_lines = true,
    scroll_buffer_space = true,
    legacy_computing_symbols_support = false,
    smear_insert_mode = true,
  },
}
