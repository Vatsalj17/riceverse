return {
  "echasnovski/mini.indentscope",
  version = false,
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    symbol = "│",
    draw = {
      delay = 50,
    },
    options = {
      try_as_border = true,
    },
  },
  config = function(_, opts)
    require("mini.indentscope").setup(opts)

    local allowed_ft = {
      c = true,
      cpp = true,
      java = true,
      lua = true,
      bash = true,
      sh = true,
      javascript = true,
      typescript = true,
      rust = true,
      html = true,
    }

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function(args)
        local current_filetype = vim.bo[args.buf].filetype

        if not allowed_ft[current_filetype] then
          vim.b[args.buf].miniindentscope_disable = true
        else
          vim.b[args.buf].miniindentscope_disable = false
        end
      end,
    })
  end,
}
