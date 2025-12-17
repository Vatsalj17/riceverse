local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

map("v", "Y", '"+y', opts)
map("n", "<leader>p", '"+p', opts)
map("n", "<leader>t", ':belowright 15split | terminal<CR>', opts)
map('n', '<leader>n', ':nohlsearch<CR>', opts)
map('n', '<leader>`~', ':!/home/Vatsal/.config/nvim/lua/plugins/trash/which-key-toggle.sh<CR>', opts)
map('n', '<leader>rs', ':!/home/Vatsal/.config/nvim/lua/plugins/trash/suggestions-remove.sh<CR>', opts)
map('i', '<C-H>', '<C-W>', opts)
map('i', '<C-BS>', '<C-W>', opts)
map("n", "<leader>bn", ":bnext<CR>", opts)
map("n", "<Tab>", ":bnext<CR>", opts)
map("n", "<leader>bp", ":bprevious<CR>", opts)
map("n", "<S-Tab>", ":bprevious<CR>", opts)
map("n", "<leader>bd", ":bd<CR>", opts)
map("n", "<leader>bD", ":%bd|e#|bd#<CR>", opts)
map("n", "<leader>bb", ":Telescope buffers<CR>", opts)

vim.api.nvim_create_autocmd("FileType", {
    pattern = "html",
    callback = function()
        vim.keymap.set("n", "<leader>oh", ":!firefox %:p &<CR>", { buffer = true })
    end
})

local keys = {
  "<Up>", "<Down>", "<Left>", "<Right>",
  "<Home>", "<End>", "<PageUp>", "<PageDown>",
  "<Insert>"
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
