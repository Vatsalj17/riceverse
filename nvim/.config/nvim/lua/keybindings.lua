local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

map("v", "Y", '"+y', opts)
map("n", "<leader>p", '"+p', opts)
map("n", "<leader>t", ":belowright 15split | terminal<CR>", opts)
map("n", "<leader>n", ":nohlsearch<CR>", opts)
map("n", "<leader>`~", ":!~/.config/nvim/lua/plugins/trash/which-key-toggle.sh<CR>", opts)
map("n", "<leader>rs", ":!~/.config/nvim/lua/plugins/trash/suggestions-remove.sh<CR>", opts)
map("i", "<C-H>", "<C-W>", opts)
map("i", "<C-BS>", "<C-W>", opts)
map("n", "<leader>bn", ":bnext<CR>", opts)
map("n", "<leader>bp", ":bprevious<CR>", opts)
map("n", "<leader>j", ":bprevious<CR>", opts)
map("n", "<leader>k", ":bnext<CR>", opts)
map("n", "<S-Tab>", "<C-^>", opts) -- previous buffer
map("n", "<leader>bd", ":bd<CR>", opts)
map("n", "<leader>bD", ":%bd|e#|bd#<CR>", opts)
map("n", "<leader>bb", ":Telescope buffers<CR>", opts)
-- map("n", "<C-C>", ":bd<CR>", opts)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    vim.keymap.set("n", "<leader>oh", ":!firefox %:p &<CR>", { buffer = true })
  end,
})

local keys = {
  "<Up>", "<Down>", "<Left>", "<Right>",
  "<Home>", "<End>", "<PageUp>", "<PageDown>",
  "<Insert>", "<Delete>"
}

-- Apply to normal, insert, visual modes
for _, mode in ipairs({ "n", "i", "v" }) do
  for _, key in ipairs(keys) do
    map(mode, key, "<Nop>", opts)
  end
end

vim.keymap.set("n", "<leader>rp", function()
  local plugin = vim.fn.input("Plugin to reload: ")
  for k in pairs(package.loaded) do
    if k:match(plugin) then
      package.loaded[k] = nil
    end
  end
  require(plugin)
  print("Reloaded " .. plugin)
end, { desc = "Reload plugin" })

-- indentation toggler and command
vim.api.nvim_create_user_command("Indent", function(fun_opts)
  local space = tonumber(fun_opts.args)
  if space then
    vim.opt_local.shiftwidth = space
    vim.opt_local.tabstop = space
    vim.opt_local.softtabstop = space
    print("Indentation set to " .. space .. " spaces")
  else
    print("Please provide a number, e.g., :Indent 2")
  end
end, { nargs = 1, desc = "Set buffer indentation width" })

vim.keymap.set("n", "<leader>ti", function()
  local current = vim.bo.shiftwidth
  local new_indent = current == 4 and 2 or 4
  vim.opt_local.shiftwidth = new_indent
  vim.opt_local.tabstop = new_indent
  vim.opt_local.softtabstop = new_indent
  print("Toggled indentation to " .. new_indent .. " spaces")
end, { desc = "Toggle indent between 2 and 4" })
