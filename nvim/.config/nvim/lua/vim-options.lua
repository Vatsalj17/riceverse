vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "css", "javascript", "typescript", "lua", "verilog" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

vim.opt.mouse = ""

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.termguicolors = true

vim.filetype.add({
  extension = {
    h = "c", -- force .h to be c
    hpp = "cpp", -- force .hpp to be c++ (usually default, but explicit is better)
  },
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
