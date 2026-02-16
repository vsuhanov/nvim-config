return {
  's1n7ax/nvim-window-picker',
  name = 'window-picker',
  event = 'VeryLazy',
  version = '2.*',
  config = function()
    require 'window-picker'.setup({
      hint = 'floating-big-letter',
      filter_func = function(win_ids)
        return win_ids
      end
    })
  end,
  keys = {
    { "<leader>wj", function()
      local picked_window = require('window-picker').pick_window()
      if picked_window then
        vim.api.nvim_set_current_win(picked_window)
      end
    end, desc = "Pick window", mode = { "n", "t" } },
  },
}
