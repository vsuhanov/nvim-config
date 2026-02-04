return {
  "tzachar/local-highlight.nvim",
  event = "VeryLazy",
  opts = {
    hlgroup = 'LocalHighlight',
    cw_hlgroup = nil,
    insert_mode = true,
    min_match_len = 1,
    max_match_len = math.huge,
    highlight_single_match = true,
    animate = {
      enabled = false,
    },
    debounce_timeout = 100,
  }
}
