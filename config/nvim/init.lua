local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
vim.g.loaded_perl_provider = 0

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.mouse = ""

vim.opt.number = true
vim.opt.relativenumber = true

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*", -- Applies to all file types
    callback = function()
        vim.opt_local.formatoptions = vim.opt_local.formatoptions - "o" - "r"
    end
})

vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
        vim.fn.setreg("c", "I// \027j")
    end,
})


require("lazy").setup("plugins")
require("vim-options")
require("keybindings")
