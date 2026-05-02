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
  config = function(_, opts)
    local autopairs = require("nvim-autopairs")
    autopairs.setup(opts)

    -- Explicitly disable " and ' inside strings/comments for C
    local Rule = require("nvim-autopairs.rule")
    local ts_conds = require("nvim-autopairs.ts-conds")

    autopairs.add_rules({
      Rule('"', '"', "c")
        :with_pair(ts_conds.is_not_ts_node({ "string" })),
      Rule("'", "'", "c")
        :with_pair(ts_conds.is_not_ts_node({ "string" })),
    })
  end,
}
