return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    -- FZF Native for blazing fast sorting
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")
    telescope.setup({
      defaults = {
        file_ignore_patterns = { ".git/" },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })

    telescope.load_extension("ui-select")
    telescope.load_extension("fzf")

    vim.keymap.set("n", "<c-p>", builtin.find_files, { desc = "Telescope find files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
    vim.keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "Telescope grep string under cursor" })
    vim.keymap.set("n", "<leader>fo", builtin.oldfiles, {})
  end,
}
