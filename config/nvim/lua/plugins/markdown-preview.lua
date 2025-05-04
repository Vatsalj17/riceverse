return {
  "iamcco/markdown-preview.nvim",
  build = "cd app && npm install",
  ft = { "markdown" },
  config = function()
    vim.g.mkdp_auto_start = 1
    vim.api.nvim_set_keymap('n', '<leader>mp', ':MarkdownPreviewToggle<CR>', { noremap = true, silent = true })
  end,
}

