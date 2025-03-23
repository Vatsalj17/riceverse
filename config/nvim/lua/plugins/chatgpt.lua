return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  config = function()
    require("chatgpt").setup({
      api_key_cmd = "echo $OPENAI_API_KEY",
      yank_register = "+",
      edit_with_instructions = {
        diff = false, -- Disable diff mode by default
      },
      openai_params = {
        model = "gpt-4",
        max_tokens = 1024,
        temperature = 0.5,
        top_p = 1,
        frequency_penalty = 0,
        presence_penalty = 0,
      },
      openai_edit_params = {
        model = "gpt-4",
        max_tokens = 1024,
        temperature = 0.5,
        top_p = 1,
        frequency_penalty = 0,
        presence_penalty = 0,
      },
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim", -- Optional for better diagnostics
    "nvim-telescope/telescope.nvim"
  }
}

