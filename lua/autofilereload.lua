-- Autosave on text changes (very frequent)
vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! update")
    end
  end,
})

-- Optional: Also save on cursor hold (backup trigger)
vim.opt.updatetime = 1000  -- 1 second
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! update")
    end
  end,
})

-- Auto-reload files when changed externally
vim.opt.autoread = true

-- Check for external changes frequently
vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
  callback = function()
    vim.cmd("checktime")
  end,
})

-- Also check when entering a buffer
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.cmd("checktime")
  end,
})
