-- Your lsp-config.lua file, fully migrated for Nvim 0.11+

return {
	-- Mason and mason-lspconfig remain the same
	{
		"williamboman/mason.nvim",
		config = function()
			-- Add "stylua" here so Mason can install and manage it for you.
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
			end

			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Get the list of installed servers to auto-configure
			local servers = require("mason-lspconfig").get_installed_servers()

			-- Loop and set up servers using the NEW vim.lsp.config() function
			for _, server_name in ipairs(servers) do
				local server_opts = {
					on_attach = on_attach,
					capabilities = capabilities,
				}

				-- Handle special case for pyright
				if server_name == "pyright" then
					server_opts.settings = {
						python = {
							analysis = {
								extraPaths = { "/home/Vatsal/Codes/Python/OpenCV/stubs" },
							},
						},
					}
				end

        -- THE MAGIC HAPPENS HERE:
        -- We now use the built-in vim.lsp.config()
        vim.lsp.config(server_name, server_opts)
      end

      vim.lsp.config("asm_lsp", {
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = { "asm-lsp" }, -- Assumes ~/.cargo/bin is in your system PATH
        filetypes = { "asm", "vmasm", "nasm", "s" },
        root_dir = vim.fs.dirname(vim.fs.find({ ".git", ".gitignore" }, { upward = true })[1]),
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
