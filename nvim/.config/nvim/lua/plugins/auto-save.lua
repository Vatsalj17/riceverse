return {
  "okuuva/auto-save.nvim",
  config = function ()
    require("auto-save").setup({
            debounce_delay = 100,
            condition = function(buf)
              local fn = vim.fn
              local modifiable = fn.getbufvar(buf, "&modifiable") == 1
              local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
              return modifiable and filetype ~= "lua"
              -- return fn.getbufvar(buf, "&modifiable") == 1
              end,
        })
  end,
}
