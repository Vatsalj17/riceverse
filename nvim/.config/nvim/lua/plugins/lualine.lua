local is_bare = require("utils.term").is_bare_terminal

return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  cond = function()
    return not is_bare()
  end,
  config = function()
    require('lualine').setup({
      options = {
        theme = 'dracula',
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
          {
            'buffers',
            show_filename_only = true,
            hide_filename_extension = false,
            show_modified_status = true,

            mode = 0,
            symbols = {
              modified = ' ●',
              alternate_file = '#',
            },

            buffers_color = {
              active = { fg = '#ffffff', bg = '#44475a', gui = 'bold' },
              inactive = { fg = '#6272a4' },
            },
          }
        },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    })
  end
}
