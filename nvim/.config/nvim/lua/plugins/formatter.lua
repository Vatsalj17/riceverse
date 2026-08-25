return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" }, -- 🚀 Automatically formats on save
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>gf",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "black" }, -- Using black as suggested previously
      javascript = { "prettier" },
      typescript = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      c = { "clang_format" },
      cpp = { "clang_format" },
      asm = { "asmfmt" },
      systemverilog = { "verible" },
    },
    -- 💡 Engineering Extra: Customizing formatter arguments
    formatters = {
      clang_format = {
        prepend_args = { "--style=file" },
      },
      stylua = {
        prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
      },
      shfmt = {
        prepend_args = { "-i", "2", "-ci" },
      },
    },
    -- 💡 Auto-format on save settings
    -- format_on_save = {
    --   timeout_ms = 500,
    --   lsp_fallback = true,
    -- },
  },
}
