local max_filesize_kb = 200
local large_file_group = vim.api.nvim_create_augroup("LargeFileHandler", { clear = true })

-- Part 1: Detect the large file as early as possible.
vim.api.nvim_create_autocmd("BufReadPre", {
  group = large_file_group,
  pattern = "*",
  callback = function(args)
    local ok, stats = pcall(vim.uv.fs_stat, args.file)
    if ok and stats and (stats.size / 1024) > max_filesize_kb then
      vim.b[args.buf].large_file = true
    end
  end,
})

-- Part 2: Act on the flag once the buffer is fully loaded.
vim.api.nvim_create_autocmd("BufEnter", {
  group = large_file_group,
  pattern = "*",
  callback = function(args)
    if not vim.b[args.buf].large_file then
      return
    end

    print(string.format("Large file mode active. Intensive features disabled."))

    -- THE FIX: Use hide() instead of config(). This is more direct and robust.
    -- The 'nil' means "all namespaces".
    vim.diagnostic.hide(nil, args.buf)

    pcall(vim.treesitter.stop, args.buf)
    vim.cmd("syntax off")

    vim.opt_local.foldmethod = "manual"
    vim.opt_local.spell = false
    vim.opt_local.wrap = false

    -- Self-destruct the autocmd for this buffer after it runs once.
    vim.api.nvim_clear_autocmds({ group = "LargeFileHandler", buffer = args.buf })
  end,
})
