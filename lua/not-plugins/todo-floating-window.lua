local M = {}

-- Module state for persistent window
local state = {
  win_id = nil,
  bufnr = nil,
  filename = nil,
  opts = nil,
  origin_win = nil, -- Track the window from which show was triggered
}

--- Setup autocommands for persistent window
local function setup_autocommands()
  -- local group = vim.api.nvim_create_augroup("TodoFloatingWindow", { clear = true })

  -- Recreate window if it gets closed
  -- vim.api.nvim_create_autocmd("WinClosed", {
  --   group = group,
  --   callback = function()
  --     if state.win_id then
  --       state.win_id = nil
  --       -- Recreate window after a short delay
  --       vim.defer_fn(function()
  --         if state.filename then
  --           M.toggle(state.filename, state.opts)
  --         end
  --       end, 100)
  --     end
  --   end,
  -- })
end

--- Show a floating window displaying a file
--- @param filename string Path to the file to display
--- @param opts table|nil Optional configuration table with:
---   - width: number (default: 60)
---   - height: number (default: 20)
---   - row: number (default: 0, top)
---   - col: number (default: right corner)
---   - border: string (default: "rounded")
function M.show(filename, opts)
  opts = opts or {}

  -- If window is already open and focused, return to origin window
  if state.win_id and vim.api.nvim_win_is_valid(state.win_id) and state.filename == filename then
    local current_win = vim.api.nvim_get_current_win()
    if current_win == state.win_id then
      -- Float window is focused, return to origin
      if state.origin_win and vim.api.nvim_win_is_valid(state.origin_win) then
        vim.api.nvim_set_current_win(state.origin_win)
      end
      return
    end
  end

  -- Close existing window if it's a different file
  if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
    vim.api.nvim_win_close(state.win_id, true)
  end

  -- Store the origin window before opening the float
  state.origin_win = vim.api.nvim_get_current_win()

  -- Store state
  state.filename = filename
  state.opts = opts

  -- Open the file in a buffer
  state.bufnr = vim.fn.bufnr(filename, true)
  vim.fn.bufload(state.bufnr)

  -- Set default options
  local width = opts.width or 60
  local height = opts.height or 2
  local row = opts.row or 0
  local col = opts.col or (vim.o.columns - width)
  local border = opts.border or "rounded"

  -- Open floating window with the file buffer
  state.win_id = vim.api.nvim_open_win(state.bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = border,
    -- zindex = 1000
  })

  -- Scroll to bottom
  vim.api.nvim_win_call(state.win_id, function()
    vim.cmd("normal! G")
  end)

  -- Setup autocommands
  setup_autocommands()

  return state.win_id, state.bufnr
end

--- Close the floating window
function M.close()
  if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
    vim.api.nvim_win_close(state.win_id, true)
  end
  state.win_id = nil
  state.bufnr = nil
  state.filename = nil
  state.origin_win = nil
end

-- Create the custom commands
vim.api.nvim_create_user_command("TodoFloatingWindowShow", function(opts)
  local filename = opts.args
  if filename == "" then
    vim.notify("TodoFloatingWindowShow: Please provide a file path", vim.log.levels.ERROR)
    return
  end
  M.show(filename)
end, {
  nargs = 1,
  complete = "file",
  desc = "Show floating window displaying file. Call again while focused to return to origin window",
})

vim.api.nvim_create_user_command("TodoFloatingWindowClose", function()
  M.close()
end, {
  desc = "Close the floating window",
})

return M
