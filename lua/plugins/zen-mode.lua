vim.keymap.set("n", "<leader>z",
  function()
    require("zen-mode").toggle({
      window = {
        backdrop = 1,
        width = 180,
      }
    })
  end, { silent = true })
