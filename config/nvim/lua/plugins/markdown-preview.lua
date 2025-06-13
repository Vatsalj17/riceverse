return {
  "iamcco/markdown-preview.nvim",
  build = "cd app && npm install",
  ft = { "markdown" },
  config = function()
    vim.g.mkdp_auto_start = 1
    vim.api.nvim_set_keymap('n', '<leader>mp', ':MarkdownPreviewToggle<CR>', { noremap = true, silent = true })
  end,
  init = function()
    -- Remove yarn.lock after install to avoid Lazy warnings
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyDone",
      callback = function()
        vim.fn.delete(vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim/app/yarn.lock")
      end,
    })
  end,
}

