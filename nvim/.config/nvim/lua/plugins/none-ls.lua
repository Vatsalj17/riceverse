return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        -- null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.stylua.with({
          extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        }),
        null_ls.builtins.formatting.prettier,
        -- null_ls.builtins.formatting.verible,
        null_ls.builtins.formatting.clang_format.with({
          extra_args = { "--style=file" },
        }),
        null_ls.builtins.formatting.yapf,
        null_ls.builtins.formatting.shfmt,
        null_ls.builtins.formatting.yamlfix,
        null_ls.builtins.formatting.asmfmt,
        -- null_ls.builtins.diagnostics.cpplint,
        -- null_ls.builtins.diagnostics.shellcheck,
      },
    })
    vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
  end,
}
