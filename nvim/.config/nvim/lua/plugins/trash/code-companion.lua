-- ~/.config/nvim/lua/plugin/gemini.lua
-- Gemini + codecompanion.nvim (ghost-text style completions)
-- Uses the new adapters.http.<adapter_name> API (>=v17, future-proof for v18).

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local api_key = vim.env.GEMINI_API_KEY or "<PUT_YOUR_KEY_HERE>"
    local endpoint = "https://generativelanguage.googleapis.com/v1beta/openai/"

    local model_candidates = {
      "gemini-2.5-flash",       -- default: fastest + smart
      "gemini-2.5-flash-lite",  -- ultra low latency, lighter
      "gemini-2.5-pro",         -- most capable, slower
    }
    local current_model_index = 1
    local function current_model() return model_candidates[current_model_index] end

    local function setup_cc()
      require("codecompanion").setup({
        adapters = {
          http = {
            gemini = function()
              return require("codecompanion.adapters").extend("openai_compatible", {
                env = {
                  url = endpoint,
                  api_key = api_key,
                },
                schema = {
                  model = {
                    default = current_model(),
                    choices = model_candidates,
                  },
                },
              })
            end,
          },
        },

        strategies = {
          chat   = { adapter = "gemini" },
          inline = { adapter = "gemini" },
          agent  = { adapter = "gemini" },
        },

        opts = {
          log_level = "INFO", -- change to "DEBUG" if debugging
        },

        inline = {
          enabled = true,
          debounce = 120,
          trigger = "auto", -- ghost-text as you type
          keymaps = {
            accept = "<Tab>",
            next   = "<C-n>",
            prev   = "<C-p>",
            reject = "<C-]>",
          },
        },
      })
    end

    -- Model switching helpers
    function _G.GeminiCycleModel()
      current_model_index = (current_model_index % #model_candidates) + 1
      setup_cc()
      vim.notify(("Gemini model → %s"):format(current_model()), vim.log.levels.INFO)
    end

    function _G.GeminiSetModel(name)
      for i, v in ipairs(model_candidates) do
        if v == name then
          current_model_index = i
          setup_cc()
          vim.notify(("Gemini model → %s"):format(name), vim.log.levels.INFO)
          return
        end
      end
      vim.notify(("Unknown model: %s"):format(name), vim.log.levels.WARN)
    end

    -- Keymaps
    vim.keymap.set("n", "<leader>gC", "<cmd>CodeCompanionChat<CR>", { desc = "Gemini Chat" })
    vim.keymap.set("i", "<C-Space>", "<cmd>CodeCompanionInline<CR>", { desc = "Trigger Inline Suggestion" })
    vim.keymap.set("n", "<leader>gm", function() _G.GeminiCycleModel() end, { desc = "Cycle Gemini model" })
    vim.keymap.set("v", "<leader>gr", "<cmd>CodeCompanionRefactor<CR>", { desc = "Gemini Refactor" })

    setup_cc()

    if api_key == "<PUT_YOUR_KEY_HERE>" or api_key == "" then
      vim.schedule(function()
        vim.notify("[gemini] GEMINI_API_KEY not set!", vim.log.levels.ERROR)
      end)
    else
      vim.schedule(function()
        vim.notify(("Gemini ready (model: %s)"):format(current_model()), vim.log.levels.INFO)
      end)
    end
  end,
}
