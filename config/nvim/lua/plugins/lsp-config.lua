return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "clangd", "jdtls", "pyright", "html", "cssls", "ts_ls", "rust_analyzer", "tailwindcss" },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- Lua
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' },
            },
          },
        },
      })

      -- C/C++
      lspconfig.clangd.setup({ capabilities = capabilities })

      -- HTML
      lspconfig.html.setup({ capabilities = capabilities })

      -- CSS
      lspconfig.cssls.setup({ capabilities = capabilities })

      -- JavaScript/TypeScript
      lspconfig.ts_ls.setup({ capabilities = capabilities })

      -- Rust
      lspconfig.rust_analyzer.setup({ capabilities = capabilities })

      -- Tailwind 
      lspconfig.tailwindcss.setup({capabilities = capabilities})

      -- Set up diagnostics display
      vim.diagnostic.config({
        virtual_text = true, -- Inline message
        signs = true, -- Keep signs like 'W' and 'E'
        underline = true, -- Underline problem areas
        update_in_insert = false, -- Don't update while typing
        float = {
          border = "rounded",
          source = "always", -- Show source like 'clangd'
          header = "",
          prefix = "",
          scope = "cursor",
        },
      })

      -- Show diagnostics on hover after 250ms
      vim.o.updatetime = 250
      vim.cmd([[autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focus=false})]])

      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
      vim.keymap.set("n", "<leader>ld", require("telescope.builtin").diagnostics, { desc = "List diagnostics" })
      -- vim.keymap.set("n", "<leader>e", vim.diagnostics.open_float, {})

      local diagnostics_hidden = false
      vim.keymap.set("n", "<leader>td", function()
        diagnostics_hidden = not diagnostics_hidden
        if diagnostics_hidden then
          vim.diagnostic.disable(0)
          print("🔕 Diagnostics hidden")
        else
          vim.diagnostic.enable(0)
          print("🔔 Diagnostics shown")
        end
      end, { desc = "Toggle diagnostics display" })

    end,
  },
}
