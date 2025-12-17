return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	config = function()
		local ibl = require("ibl")

		local enabled_filetypes = {
			html = true,
			javascriptreact = true,
			typescriptreact = true,
            python = true;
		}

		ibl.setup({
			indent = { char = "│" },
			scope = {
                enabled = true,
                exclude = { language = {"python"} },
            },
			exclude = {
				filetypes = {
					"neo-tree",
					"help",
					"lazy",
					"lspinfo",
					"TelescopePrompt",
					"terminal",
				},
			},
		})

		vim.api.nvim_create_autocmd({
			"BufEnter",
			"BufWinEnter",
			"InsertLeave",
			"WinScrolled",
			"FocusGained",
		}, {
			callback = function()
				local ft = vim.bo.filetype
				if enabled_filetypes[ft] then
					vim.schedule(function()
						vim.cmd("IBLEnable")
					end)
				else
					vim.schedule(function()
						vim.cmd("IBLDisable")
					end)
				end
			end,
		})

		-- 🛠   Fix indent lines disappearing after Neo-tree closes
		vim.api.nvim_create_autocmd("User", {
			pattern = "NeotreeClose",
			callback = function()
				local ft = vim.bo.filetype
				if enabled_filetypes[ft] then
					vim.schedule(function()
						vim.cmd("IBLEnable")
					end)
				end
			end,
		})
	end,
}
