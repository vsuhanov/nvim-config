return {
  "MisanthropicBit/winmove.nvim",
  keys = {
    { "<C-w>m", function() require('winmove').start_mode(require('winmove').Mode.Move) end, desc = "Winmove move" },
    { "<C-w>s", function() require('winmove').start_mode(require('winmove').Mode.Swap) end, desc = "Winmove swap" },
    { "<C-w>r", function() require('winmove').start_mode(require('winmove').Mode.Resize) end, desc = "Winmove resize" },
  },
  config = function()
    require('plugins.config.winmove')
  end
}
