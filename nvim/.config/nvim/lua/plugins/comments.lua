return {
    "numToStr/Comment.nvim",
    lazy = false, -- Load on startup
    config = function()
        require("Comment").setup({
            padding = true, -- Add space after comment
            sticky = true, -- Cursor stays in place after commenting
            toggler = {
                line = "gcc", -- Line comment toggle
                block = "gbc", -- Block comment toggle
            },
            opleader = {
                line = "gc", -- Line comment in visual mode
                block = "gb", -- Block comment in visual mode
            },
            mappings = {
                basic = true, -- Enable basic mappings
                extra = false, -- Disable extra mappings
            },
        })
    end
}
