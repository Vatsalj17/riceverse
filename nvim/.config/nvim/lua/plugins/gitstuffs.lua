return {
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gg", "<cmd>Git<CR>", desc = "Git: Fugitive status" },
      { "<leader>gD", "<cmd>Gdiffsplit<CR>", desc = "Git: Diff split" },
      { "<leader>gP", "<cmd>Git push<CR>", desc = "Git: Push" },
      { "<leader>gl", "<cmd>Git log --oneline<CR>", desc = "Git: Log" },
    },
  },
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = false, -- toggle with keymap below
        current_line_blame_opts = {
          delay = 300,
          virt_text_pos = "eol",
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, key, fn, desc)
            vim.keymap.set(mode, key, fn, { buffer = bufnr, desc = desc })
          end

          -- Navigation
          map("n", "]h", gs.next_hunk, "Git: Next hunk")
          map("n", "[h", gs.prev_hunk, "Git: Prev hunk")

          -- Hunk actions
          map("n", "<leader>gp", gs.preview_hunk, "Git: Preview hunk")
          map("n", "<leader>gs", gs.stage_hunk, "Git: Stage hunk")
          map("n", "<leader>gr", gs.reset_hunk, "Git: Reset hunk")
          map("n", "<leader>gu", gs.undo_stage_hunk, "Git: Undo stage hunk")
          map("n", "<leader>gS", gs.stage_buffer, "Git: Stage buffer")
          map("n", "<leader>gR", gs.reset_buffer, "Git: Reset buffer")

          -- Visual mode staging (stage only selected lines)
          map("v", "<leader>gs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, "Git: Stage selected hunk")

          -- Blame
          map("n", "<leader>gb", gs.toggle_current_line_blame, "Git: Toggle blame")

          -- Diff
          map("n", "<leader>gd", gs.diffthis, "Git: Diff this")

          -- Text object (select hunk with vih or vah)
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Git: Select hunk")
        end,
      })
    end,
  },
}
