return {
    "MysticalDevil/inlay-hints.nvim",
    event = "LspAttach",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
        require("inlay-hints").setup()

        -- -- Keymap to toggle inlay hints for current buffer
        -- vim.keymap.set("n", "<leader>ih", function()
        --     local buf = vim.api.nvim_get_current_buf()
        --     local enabled = vim.lsp.inlay_hint.is_enabled(buf)
        --     vim.lsp.inlay_hint.enable(buf, not enabled)
        -- end, { desc = "Toggle Inlay Hints" })
    end,
}
