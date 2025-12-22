return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        -- 💡 Lua: Keep the 2-space indent for Neovim config standards
        null_ls.builtins.formatting.stylua.with({
          extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        }),

        -- 💡 Web/Docs: Prettier handles JSON, HTML, and Markdown perfectly
        null_ls.builtins.formatting.prettier.with({
          filetypes = { "html", "json", "yaml", "markdown" },
        }),

        -- 💡 C/C++: Strictly for systems code
        null_ls.builtins.formatting.clang_format.with({
          extra_args = { "--style=file" }, -- 🛠 Looks for .clang-format in your project root
        }),

        -- 💡 Python: Switched to Black for better consistency
        null_ls.builtins.formatting.black,

        -- 💡 Shell: Critical for your Linux shell scripts
        null_ls.builtins.formatting.shfmt.with({
          extra_args = { "-i", "2", "-ci" }, -- 2-space indent, switch cases indented
        }),

        -- 💡 Low-Level: Specialized formatters for Assembly and Verilog
        null_ls.builtins.formatting.asmfmt,
        null_ls.builtins.formatting.verible,
      },
    })
    -- Fast keymap for formatting
    vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, { desc = "Format current buffer" })
  end,
}
