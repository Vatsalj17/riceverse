local M = {}

function M.is_bare_terminal()
  local term = vim.env.TERM or ""
  return term == "linux" or term:match("^st")
end

return M
