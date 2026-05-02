return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Pull directly from Catppuccin
    local C = require("catppuccin.palettes").get_palette("mocha")

    vim.api.nvim_set_hl(0, "AlphaHeader", { fg = C.yellow }) -- clean yellow
    -- vim.api.nvim_set_hl(0, "AlphaHeader", { fg = C.flamingo }) -- soft coral/salmon
    vim.api.nvim_set_hl(0, "AlphaButtons", { fg = C.blue })
    vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = C.peach, bold = true })
    vim.api.nvim_set_hl(0, "AlphaFooter", { fg = C.overlay0, italic = true })

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
    dashboard.section.header.opts = { hl = "AlphaHeader", position = "center" }

    local function button(key, icon, label, cmd)
      local btn = dashboard.button(key, icon .. "  " .. label, cmd)
      btn.opts.hl = {
        { "AlphaIcon", 0, #icon }, -- icon only
        { "AlphaButtons", #icon + 2, #icon + 2 + #label }, -- label only
      }
      btn.opts.hl_shortcut = "AlphaShortcut"
      return btn
    end

    dashboard.section.buttons.val = {
      button("n", "", "New file", ":ene <BAR> startinsert <CR>"),
      button("f", "󰈞", "Find file", ":Telescope find_files <CR>"),
      button("r", "󰊄", "Recent files", ":Telescope oldfiles <CR>"),
      button("g", "󰈬", "Find word", ":Telescope live_grep <CR>"),
      button("l", "󰒲", "Lazy", ":Lazy <CR>"),
      button("c", "", "Configurations", ":e ~/.config/nvim <CR>"),
      button("m", "󰮏", "Mason", ":Mason <CR>"),
      button("h", "󰓙", "Checkhealth", ":checkhealth <CR>"),
      button("q", "", "Quit", ":qa<CR>"),
    }

    local stats = require("lazy").stats()
    dashboard.section.footer.val = "⚡ " .. stats.count .. " plugins in " .. stats.startuptime .. "ms"
    dashboard.section.footer.opts = { hl = "AlphaFooter", position = "center" }

    dashboard.config.layout = {
      { type = "padding", val = 3 },
      dashboard.section.header,
      { type = "padding", val = 2 },
      dashboard.section.buttons,
      { type = "padding", val = 1 },
      dashboard.section.footer,
    }

    dashboard.opts = { margin = 5 }
    alpha.setup(dashboard.config)
  end,
}
