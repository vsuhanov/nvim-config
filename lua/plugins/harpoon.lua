local harpoon = require("harpoon")

-- Current active list name
local current_list = "marks2"

local list_options = {
  height_in_lines = 30
}
-- Store current keymaps for cleanup
local current_keymaps = {}

-- Static base configuration for all lists (declare early)
local base_lists_config = {}

-- Meta functions for dynamic list management
local HarpoonMeta = {}

HarpoonMeta.switch_to_list = function(list_name)
  if not list_name or list_name == "" then
    print("List name is required")
    return
  end

  -- Ensure the list configuration exists (creates it if needed)
  HarpoonMeta.create_new_list(list_name)

  -- Clear current keymaps
  for _, keymap in ipairs(current_keymaps) do
    vim.keymap.del(keymap.mode, keymap.lhs)
  end
  current_keymaps = {}

  -- Update current list
  current_list = list_name

  -- Set up new keymaps for current list
  local keymaps = {
    { mode = "n", lhs = "<leader>aa", rhs = function() harpoon:list(current_list):add() end },
    { mode = "n", lhs = "<leader>ee", rhs = function() harpoon.ui:toggle_quick_menu(harpoon:list(current_list), list_options) end },
  }

  for _, keymap in ipairs(keymaps) do
    vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs)
    table.insert(current_keymaps, keymap)
  end

  print("Switched to list: " .. list_name)
end

HarpoonMeta.create_new_list = function(list_name)
  if not list_name or list_name == "" then
    return
  end

  -- Create new list config with same behavior as marks2
  local new_list_config = {
    create_list_item = function(config, name)
      local bufname = vim.api.nvim_buf_get_name(0)
      if bufname == "" then
        return nil
      end

      local line_num = vim.fn.line(".")
      local col = vim.fn.col(".")

      -- Get parent directory and filename
      local parent_dir = vim.fn.fnamemodify(bufname, ":h:t")
      local filename = vim.fn.fnamemodify(bufname, ":t")

      -- Get line contents
      local line_content = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1] or ""
      line_content = line_content:gsub("^%s+", "")

      return {
        value = parent_dir .. "/" .. filename .. ":" .. line_num .. " - " .. line_content,
        context = {
          row = line_num,
          col = col,
          path = bufname,
        }
      }
    end,

    select = function(list_item, list, option)
      if list_item.value:match("^#") then
        return
      end

      if list_item.context and list_item.context.path then
        vim.cmd("edit " .. list_item.context.path)
        vim.fn.cursor(list_item.context.row, list_item.context.col)
      end
    end
  }

  -- Add new list to base config and re-setup
  base_lists_config[list_name] = new_list_config
  harpoon:setup(base_lists_config)

  return list_name
end

-- Configure the base lists
base_lists_config = {
  marks2 = {
    create_list_item = function(config, name)
      local bufname = vim.api.nvim_buf_get_name(0)
      if bufname == "" then
        return nil
      end

      local line_num = vim.fn.line(".")
      local col = vim.fn.col(".")

      -- Get parent directory and filename
      local parent_dir = vim.fn.fnamemodify(bufname, ":h:t")
      local filename = vim.fn.fnamemodify(bufname, ":t")

      -- Get line contents
      local line_content = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1] or ""
      line_content = line_content:gsub("^%s+", "")

      return {
        value = parent_dir .. "/" .. filename .. ":" .. line_num .. " - " .. line_content,
        context = {
          row = line_num,
          col = col,
          path = bufname,
        }
      }
    end,

    select = function(list_item, list, option)
      if list_item.value:match("^#") then
        return
      end

      if list_item.context and list_item.context.path then
        vim.cmd("edit " .. list_item.context.path)
        vim.fn.cursor(list_item.context.row, list_item.context.col)
      end
    end
  },

  Lists = {
    create_list_item = function(config, name)
      local list_name = vim.fn.input("Enter new list name: ")
      if list_name == "" then
        print("List creation cancelled")
        return nil
      end

      if base_lists_config[list_name] then
        print("List '" .. list_name .. "' already exists")
        return nil
      end

      -- Create the new list
      HarpoonMeta.create_new_list(list_name)

      -- Add it to the Lists list itself
      return {
        value = list_name,
        context = {
          list_name = list_name
        }
      }
    end,

    select = function(list_item, list, option)
      if list_item.context and list_item.context.list_name then
        HarpoonMeta.switch_to_list(list_item.context.list_name)
      end
    end
  }
}

-- Initial setup
harpoon:setup(base_lists_config)

-- Pre-populate Lists list with marks2
harpoon:list("Lists"):add({
  value = "marks2",
  context = {
    list_name = "marks2"
  }
})

-- Set up initial keymaps
HarpoonMeta.switch_to_list(current_list)

-- Custom commands for Lists list handling
vim.api.nvim_create_user_command('HarpoonLists', function()
  harpoon.ui:toggle_quick_menu(harpoon:list("Lists"), list_options)
end, { desc = 'Open Harpoon Lists manager' })

vim.api.nvim_create_user_command('HarpoonCreateList', function()
  harpoon:list("Lists"):add()
end, { desc = 'Create a new Harpoon list via Lists list' })

vim.api.nvim_create_user_command('HarpoonSwitchTo', function(opts)
  if opts.args and opts.args ~= "" then
    HarpoonMeta.switch_to_list(opts.args)
  else
    harpoon.ui:toggle_quick_menu(harpoon:list("Lists"), list_options)
  end
end, { nargs = '?', desc = 'Switch to a list (opens Lists manager if no arg)' })

vim.api.nvim_create_user_command('HarpoonCurrentList', function()
  print("Current list: " .. current_list)
end, { desc = 'Show current active list' })


vim.keymap.set("n", "<leader>al", function() harpoon:list("Lists"):add() end, { silent = true })
vim.keymap.set("n", "<leader>ea", function() harpoon.ui:toggle_quick_menu(harpoon:list("Lists"), list_options) end,
  { silent = true })


-- Export meta functions for external access
return HarpoonMeta
