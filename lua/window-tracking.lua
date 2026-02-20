local file_window_stack = {}
local setup_done = false
local MAX_STACK_SIZE = 20

local function setup()
  if setup_done then return end
  setup_done = true

  -- vim.notify("[WindowTracking] Setup initialized with window stack", vim.log.levels.DEBUG)

  local group = vim.api.nvim_create_augroup('FileWindowTracking', { clear = true })

  vim.api.nvim_create_autocmd('WinEnter', {
    group = group,
    callback = function()
      local current_tab = vim.api.nvim_get_current_tabpage()
      local current_buf = vim.api.nvim_get_current_buf()
      local buf_type = vim.api.nvim_buf_get_option(current_buf, 'buftype')
      local current_win = vim.api.nvim_get_current_win()
      local buf_name = vim.api.nvim_buf_get_name(current_buf)

      -- vim.notify(string.format("[WindowTracking] WinEnter - Tab: %d, Win: %d, BufType: '%s', BufName: %s",
        -- current_tab, current_win, buf_type, buf_name), vim.log.levels.DEBUG)

      if buf_type == '' then
        if not file_window_stack[current_tab] then
          file_window_stack[current_tab] = {}
        end

        local stack = file_window_stack[current_tab]

        if #stack == 0 or stack[#stack] ~= current_win then
          table.insert(stack, current_win)
          if #stack > MAX_STACK_SIZE then
            table.remove(stack, 1)
            -- vim.notify(string.format("[WindowTracking] Stack limit reached, removed oldest window (size: %d)", #stack),
              -- vim.log.levels.DEBUG)
          else
            -- vim.notify(string.format("[WindowTracking] Pushed window %d to stack (size: %d)", current_win, #stack),
              -- vim.log.levels.DEBUG)
          end
        else
          -- vim.notify(string.format("[WindowTracking] Window %d already at top of stack", current_win),
            -- vim.log.levels.DEBUG)
        end
      else
        -- vim.notify(string.format("[WindowTracking] Skipped non-file buffer (buftype: '%s')", buf_type),
          -- vim.log.levels.DEBUG)
      end
    end
  })
end

local function get_last_file_window()
  local current_tab = vim.api.nvim_get_current_tabpage()

  if not file_window_stack[current_tab] then
    -- vim.notify(string.format("[WindowTracking] No stack for tab %d", current_tab), vim.log.levels.DEBUG)
    return nil
  end

  local stack = file_window_stack[current_tab]

  while #stack > 0 do
    local win = stack[#stack]

    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      local buf_type = vim.api.nvim_buf_get_option(buf, 'buftype')

      if buf_type == '' then
        -- vim.notify(string.format("[WindowTracking] Returning window %d with valid file buffer (stack size: %d)", win, #stack),
          -- vim.log.levels.DEBUG)
        return win
      else
        -- vim.notify(string.format("[WindowTracking] Window %d now has buftype '%s', removing from stack", win, buf_type),
          -- vim.log.levels.DEBUG)
        table.remove(stack)
      end
    else
      table.remove(stack)
      -- vim.notify(string.format("[WindowTracking] Removed invalid window from stack (new size: %d)", #stack),
        -- vim.log.levels.DEBUG)
    end
  end

  -- vim.notify(string.format("[WindowTracking] No valid file windows in stack for tab %d", current_tab),
    -- vim.log.levels.DEBUG)
  return nil
end

return {
  setup = setup,
  get_last_file_window = get_last_file_window,
}
