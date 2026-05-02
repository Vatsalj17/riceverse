return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      default_file_explorer = false,
      view_options = {
        show_hidden = true,
        -- hide . and .. entries
        is_always_hidden = function(name)
          return name == ".." or name == ".git"
        end,
      },
      float = {
        padding = 5,
        max_width = 80,
        max_height = 30,
      },
      keymaps = {
        ["<C-h>"] = false, -- free up if conflicts with window nav
        ["<C-l>"] = false, -- free up if conflicts with window nav
        ["<C-p>"] = "actions.preview",
        ["<C-r>"] = "actions.refresh",
        ["H"] = "actions.toggle_hidden", -- toggle hidden files on the fly
        ["gs"] = "actions.change_sort", -- cycle sort order
      },
    })
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory in Oil" })
    vim.keymap.set("n", "<leader>-", "<CMD>Oil --float<CR>", { desc = "Open Oil (float)" })
  end,
}
