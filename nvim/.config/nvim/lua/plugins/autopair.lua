return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    check_ts = true,
    ts_config = {
      lua = { "string" },
      javascript = { "template_string" },
      c = { "string", "comment" },
    },
    enable_check_bracket_line = false, -- don't add pair if closing already exists on line
    ignored_next_char = [=[[%w%%%'%[%"%.%`]]=], -- ignore if next char is alphanumeric
  },
}
