local MAX_KB = 200
local g = vim.api.nvim_create_augroup("LargeFile", { clear = true })

vim.api.nvim_create_autocmd("BufReadPre", {
  group = g,
  callback = function(args)
    local ok, stat = pcall(vim.uv.fs_stat, args.file)
    if ok and stat and stat.size > MAX_KB * 1024 then
      vim.b[args.buf].large_file = true
    end
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = g,
  callback = function(args)
    if not vim.b[args.buf].large_file then
      return
    end

    vim.notify(
      string.format("Large file: %s. Heavy features disabled.", vim.fn.fnamemodify(args.file, ":t")),
      vim.log.levels.WARN
    )

    vim.diagnostic.enable(false, { bufnr = args.buf })
    pcall(vim.treesitter.stop, args.buf)
    vim.cmd("syntax off")
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.spell = false
    vim.opt_local.wrap = false
    vim.opt_local.undofile = false
    vim.opt_local.swapfile = false
    vim.bo[args.buf].bufhidden = "unload"

    -- Explicitly disable heavy UI plugins
    vim.b[args.buf].miniindentscope_disable = true
    pcall(function() require("ibl").setup_buffer(args.buf, { enabled = false }) end)
    pcall(function() require("colorizer").detach_from_buffer(args.buf) end)

    vim.api.nvim_clear_autocmds({ group = "LargeFile", buffer = args.buf })
  end,
})
