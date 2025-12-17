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
            dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
            dashboard.button("f", "󰈞  Find file", ":Telescope find_files <CR>"),
            dashboard.button("r", "󰊄  Recent files", ":Telescope oldfiles <CR>"),
            dashboard.button("g", "󰈬  Find word", ":Telescope live_grep <CR>"),
            -- dashboard.button("b", "  Bookmarks", ":Telescope marks <CR>"),
            -- dashboard.button("s", "  Sessions", ":SessionManager load_session <CR>"), -- 's' for Sessions
            dashboard.button("l", "󰒲  Lazy", ":Lazy <CR>"),
            dashboard.button("c", "  Configurations", ":e ~/.config/nvim <CR>"),
            dashboard.button("m", "󰮏  Mason", ":Mason <CR>"),
            dashboard.button("h", "󰓙  Checkhealth", ":checkhealth <CR>"),
            dashboard.button("q", "  Quit", ":qa<CR>"),
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

