if vim.g.vscode then
  -- Use VS Code's native commenting with your keybinds
  vim.keymap.set("x", "gc", "<cmd>call VSCodeCall('editor.action.commentLine')<CR>")
  vim.keymap.set("n", "gcc", "<cmd>call VSCodeCall('editor.action.commentLine')<CR>")

  -- Navigation (match your telescope feel)
  vim.keymap.set("n", "<leader>ff", "<cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>")
  -- Split management
  vim.keymap.set("n", "<leader>v", "<cmd>call VSCodeNotify('workbench.action.splitEditorRight')<CR>")
  vim.keymap.set("n", "<leader>s", "<cmd>call VSCodeNotify('workbench.action.splitEditorDown')<CR>")
end
