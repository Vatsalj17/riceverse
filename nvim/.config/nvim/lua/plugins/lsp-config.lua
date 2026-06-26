return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ensure_installed = { "stylua" },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      -- This plugin's job is just to ensure LSP servers are installed.
      local ensure_installed = { "lua_ls", "clangd", "jdtls", "pyright", "html", "cssls", "rust_analyzer", "verible" }
      require("mason-lspconfig").setup({
        ensure_installed = ensure_installed,
      })
    end,
  },

  -- ===================================================================
  -- UPDATED: nvim-lspconfig using the new API
  -- ===================================================================
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Define our reusable on_attach function and capabilities
      local on_attach = function(client, bufnr)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "LSP: Hover" })
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "LSP: Go to Definition" })
        vim.keymap.set(
          { "n", "v" },
          "<leader>ca",
          vim.lsp.buf.code_action,
          { buffer = bufnr, desc = "LSP: Code Action" }
        )
        -- if client.supports_method("textDocument/inlayHint") then
        --   vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        -- end
      end

      -- local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      local servers = require("mason-lspconfig").get_installed_servers()

      -- Map of servers that need extra engineering "juice"
      local enhance_server_opts = {
        ["lua_ls"] = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } }, -- 🛠 Fixes the 'undefined vim' error
              workspace = { checkThirdParty = false },
            },
          },
        },
        ["clangd"] = {
          cmd = {
            "clangd",
            "--background-index", -- 🛠 Index the project in the background
            "--clang-tidy", -- 🛠 Enable C linting
            "--completion-style=detailed",
          },
        },
        ["pyright"] = {
          settings = {
            python = {
              analysis = {
                extraPaths = { vim.fn.expand("~/Codes/Python/OpenCV/stubs") },
              },
            },
          },
        },
      }

      for _, server_name in ipairs(servers) do
        local server_opts = {
          on_attach = on_attach,
          capabilities = capabilities,
        }

        -- Merge the enhancements if they exist
        if enhance_server_opts[server_name] then
          server_opts = vim.tbl_deep_extend("force", server_opts, enhance_server_opts[server_name])
        end

        -- Use the 0.11+ API
        vim.lsp.config(server_name, server_opts)
        vim.lsp.enable(server_name) -- 💡 Don't forget to enable!
      end

      vim.lsp.config("asm_lsp", {
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = { "asm-lsp" },
        filetypes = { "asm", "vmasm", "nasm", "s" },
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local toml = vim.fs.find(
            ".asm-lsp.toml",
            { upward = true, path = fname }
          )[1]
          if toml then
            on_dir(vim.fs.dirname(toml))
          end
          -- do nothing if not found
        end,
      })
      vim.lsp.enable("asm_lsp")

      -- All your diagnostic settings remain unchanged. They are perfect.
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
          scope = "cursor",
        },
      })
      local diagnostics_hidden = false
      -- Other keymaps and settings are also fine.
      vim.o.updatetime = 250
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          if not diagnostics_hidden then
            vim.diagnostic.open_float(nil, { focus = false })
          end
        end,
      })
      vim.keymap.set("n", "<leader>ld", require("telescope.builtin").diagnostics, { desc = "List diagnostics" })

      vim.keymap.set("n", "<leader>dt", function()
        diagnostics_hidden = not diagnostics_hidden
        if diagnostics_hidden then
          vim.diagnostic.enable(false, { bufnr = 0 })  -- to hide
          print("Diagnostics hidden")
        else
          vim.diagnostic.enable(true,  { bufnr = 0 })  -- to show
          print("Diagnostics shown")
        end
      end, { desc = "Toggle diagnostics display" })
    end,
  },
}
