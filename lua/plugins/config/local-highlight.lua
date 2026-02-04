require('local-highlight').setup({
    -- file_types = {'python', 'cpp'}, -- If this is given only attach to this
    -- OR attach to every filetype except:
    -- disable_file_types = {'tex'},
    hlgroup = 'LocalHighlight',
    cw_hlgroup = nil,
    -- Whether to display highlights in INSERT mode or not
    insert_mode = true,
    min_match_len = 1,
    max_match_len = math.huge,
    highlight_single_match = true,
    animate = {
      enabled = false,
      -- easing = "linear",
      -- duration = {
      --   step = 10, -- ms per step
      --   total = 100, -- maximum duration
      -- },
    },
    debounce_timeout = 100,
})
