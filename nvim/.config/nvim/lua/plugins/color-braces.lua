return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("rainbow-delimiters.setup")({
        strategy = {
          -- a sane default: highlight based on filetype
          [""] = require("rainbow-delimiters.strategy.global"),
        },
        query = {
          lua = "rainbow-delimiters",
          c = "rainbow-delimiters",
          cpp = "rainbow-delimiters",
          python = "rainbow-delimiters",
          javascript = "rainbow-delimiters",
          typescript = "rainbow-delimiters",
          rust = "rainbow-delimiters",
        },
        -- Customize your colors here (optional)
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      })
    end,
  },
}
