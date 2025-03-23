local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

vim.keymap.set("v", "Y", '"+y', opts)
map('n', '<leader>n', ':nohlsearch<CR>', opts)
map('i', '<C-H>', '<C-W>', opts)
map('i', '<C-BS>', '<C-W>', opts)
map("n", "<leader>bn", ":bnext<CR>", opts)
map("n", "<leader>bp", ":bprevious<CR>", opts)
map("n", "<leader>bd", ":bd<CR>", opts)
map("n", "<leader>bD", ":%bd|e#|bd#<CR>", opts)
map("n", "<leader>bb", ":Telescope buffers<CR>", opts)
