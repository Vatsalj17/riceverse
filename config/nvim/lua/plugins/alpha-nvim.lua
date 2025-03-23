--return {
--	"goolord/alpha-nvim",
--	dependencies = { "nvim-tree/nvim-web-devicons" },
--	config = function()
--		local startify = require("alpha.themes.startify")
--		startify.section.header.val = {
--			"",
--			"██╗   ██╗ █████╗ ████████╗███████╗ █████╗ ██╗     ",
--			"██║   ██║██╔══██╗╚══██╔══╝██╔════╝██╔══██╗██║     ",
--			"██║   ██║███████║   ██║   ███████╗███████║██║     ",
--			"╚██╗ ██╔╝██╔══██║   ██║   ╚════██║██╔══██║██║     ",
--			" ╚████╔╝ ██║  ██║   ██║   ███████║██║  ██║███████╗",
--			"  ╚═══╝  ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝",
--			"",
--		}
--
--		startify.file_icons.provider = "devicons"
--		require("alpha").setup(startify.config)
--	end,
--}
return {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        -- Centered ASCII Art
        dashboard.section.header.val = {
            "",
            "██╗   ██╗ █████╗ ████████╗███████╗ █████╗ ██╗     ",
            "██║   ██║██╔══██╗╚══██╔══╝██╔════╝██╔══██╗██║     ",
            "██║   ██║███████║   ██║   ███████╗███████║██║     ",
            "╚██╗ ██╔╝██╔══██║   ██║   ╚════██║██╔══██║██║     ",
            " ╚████╔╝ ██║  ██║   ██║   ███████║██║  ██║███████╗",
            "  ╚═══╝  ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝",
            "",
        }

        -- Custom Menu Buttons with Keybindings
        dashboard.section.buttons.val = {
            dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),  -- 'n' for New file
            dashboard.button("f", "󰈞  Find file", ":Telescope find_files <CR>"), -- 'f' for Find file
            dashboard.button("r", "󰊄  Recent files", ":Telescope oldfiles <CR>"), -- 'r' for Recent files
            dashboard.button("g", "󰈬  Find word", ":Telescope live_grep <CR>"),  -- 'g' for Find word
            dashboard.button("b", "  Bookmarks", ":Telescope marks <CR>"),      -- 'b' for Bookmarks
            -- dashboard.button("s", "  Sessions", ":SessionManager load_session <CR>"), -- 's' for Sessions
            dashboard.button("l", "󰒲  Lazy", ":Lazy <CR>"),
            dashboard.button("q", "  Quit", ":qa<CR>"),                         -- 'q' for Quit
        }

        -- Adjust layout with padding
        dashboard.config.layout = {
            { type = "padding", val = 4 },
            dashboard.section.header,
            { type = "padding", val = 2 },
            dashboard.section.buttons,
            { type = "padding", val = 2 },
            dashboard.section.footer,
        }

        -- Center everything
        dashboard.opts = {
            margin = 5,
        }

        alpha.setup(dashboard.config)
    end,
}

