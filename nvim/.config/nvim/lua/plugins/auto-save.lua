return {
  "okuuva/auto-save.nvim",
  config = function()
    require("auto-save").setup({
      enabled = true,
      execution_message = {
        message = function()
          return ""
        end,
      },
      debounce_delay = 1500,
      condition = function(buf)
        local fn = vim.fn
        local modifiable = fn.getbufvar(buf, "&modifiable") == 1
        local filetype = vim.bo[buf].filetype
        if filetype == "" or filetype == "neo-tree" or filetype == "lazy" then
          return false
        end

        return modifiable and filetype ~= "lua"
      end,
    })
  end,
}
