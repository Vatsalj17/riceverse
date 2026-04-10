return {
  "kiddos/gemini.nvim",
  config = function()
    local completion_enabled = true
    local opts = {
      model_config = {
        model_id = "gemini-2.5-flash-lite", -- fastest + cheapest for code
        temperature = 0.05,                 -- low randomness for deterministic completions
        top_k = 64,                         -- lower sampling for speed + consistency
        response_mime_type = "text/plain",
        max_output_tokens = 128,            -- keep completions short & fast
        stream = true,                      -- stream results for faster "first token"
      },
      chat_config = {
        enabled = true,
      },
      hints = {
        enabled = true,
        hints_delay = 1200, -- slightly faster hint popup
        insert_result_key = "<S-Tab>",
        get_prompt = function(node, bufnr)
          local code_block = vim.treesitter.get_node_text(node, bufnr)
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
          return string.format(
            "Describe briefly what this %s function does:\n\n```%s\n%s\n```",
            filetype,
            filetype,
            code_block
          )
        end,
      },
      completion = {
        enabled = completion_enabled,
        blacklist_filetypes = { "help", "qf", "json", "yaml", "toml", "xml" },
        blacklist_filenames = { ".env" },
        completion_delay = 300, -- much faster response start
        insert_result_key = "<S-Tab>",
        move_cursor_end = true,
        can_complete = function()
          return vim.fn.pumvisible() ~= 1
        end,
        get_system_text = function()
          return "You are an AI code autocomplete engine. Provide only the missing code at <cursor></cursor> with no explanations."
        end,
        get_prompt = function(bufnr, pos)
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          local line, col = pos[1], pos[2]
          if lines[line] then
            lines[line] = lines[line]:sub(1, col) .. "<cursor></cursor>" .. lines[line]:sub(col + 1)
          else
            return nil
          end
          local code = table.concat(lines, "\n")
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":.")
          return string.format(
            "Complete the following %s file `%s` by filling in code at <cursor></cursor>:\n```%s\n%s\n```",
            filetype,
            filename,
            filetype,
            code
          )
        end,
      },
      instruction = {
        enabled = true,
        menu_key = "<Leader><Leader><Leader>g",
        prompts = {
          {
            name = "Unit Test",
            command_name = "GeminiUnitTest",
            menu = "Unit Test 🚀",
            get_prompt = function(lines, bufnr)
              return string.format(
                "Write concise unit tests for this code:\n```%s\n%s\n```",
                vim.api.nvim_get_option_value("filetype", { buf = bufnr }),
                table.concat(lines, "\n")
              )
            end,
          },
          {
            name = "Code Review",
            command_name = "GeminiCodeReview",
            menu = "Code Review 📜",
            get_prompt = function(lines, bufnr)
              return string.format(
                "Review this code for correctness and improvements:\n```%s\n%s\n```",
                vim.api.nvim_get_option_value("filetype", { buf = bufnr }),
                table.concat(lines, "\n")
              )
            end,
          },
          {
            name = "Code Explain",
            command_name = "GeminiCodeExplain",
            menu = "Code Explain",
            get_prompt = function(lines, bufnr)
              return string.format(
                "Explain this code in simple terms:\n```%s\n%s\n```",
                vim.api.nvim_get_option_value("filetype", { buf = bufnr }),
                table.concat(lines, "\n")
              )
            end,
          },
        },
      },
      task = {
        enabled = true,
        get_system_text = function()
          return "You are a helpful coding assistant. Respond only with code edits for the file."
        end,
        get_prompt = function(bufnr, user_prompt)
          local buffers = vim.api.nvim_list_bufs()
          local file_contents = {}
          for _, b in ipairs(buffers) do
            if vim.api.nvim_buf_is_loaded(b) then
              local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false)
              local abs_path = vim.api.nvim_buf_get_name(b)
              local filename = vim.fn.fnamemodify(abs_path, ":.")
              local filetype = vim.api.nvim_get_option_value("filetype", { buf = b })
              table.insert(
                file_contents,
                string.format("`%s`:\n```%s\n%s\n```", filename, filetype, table.concat(lines, "\n"))
              )
            end
          end
          local current_filepath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":.")
          return string.format(
            "%s\n\nCurrent Opened File: %s\n\nTask: %s",
            table.concat(file_contents, "\n\n"),
            current_filepath,
            user_prompt
          )
        end,
      },
    }
    local function toggle_gemini_completions()
      completion_enabled = not completion_enabled
      opts.completion.enabled = completion_enabled
      -- Re-run the plugin's setup() with the modified opts table
      require("gemini").setup(opts)
      -- Give user feedback
      vim.notify("Gemini ghost-text " .. (completion_enabled and "ENABLED" or "DISABLED"), vim.log.levels.INFO)
    end

    -- 5. This is your requested keymap
    vim.keymap.set("n", "<leader>gt", toggle_gemini_completions, {
      desc = "Toggle Gemini ghost-text completion",
    })
    -- 6. This is crucial! We must run setup() on load to initialize the plugin.
    require("gemini").setup(opts)
  end,
}
