local M = {}

function M.is_bare_terminal()
  local term = vim.env.TERM or ""
  local is_linux = term == "linux"
  local is_st = term:match("^st") ~= nil
  local is_ssh = vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil
  return is_linux or is_st or is_ssh
end

return M
