local harpoon = require("harpoon")

-- Data file management
local harpoon_data_file = vim.fn.stdpath("data") .. "/harpoon_lists.json"

local function get_current_working_directory()
  return vim.fn.getcwd()
end

local function save_current_list(cwd, list_name)
  local data = {}

  if vim.fn.filereadable(harpoon_data_file) == 1 then
    local content = vim.fn.readfile(harpoon_data_file)
    if #content > 0 then
      local ok, decoded = pcall(vim.json.decode, table.concat(content, "\n"))
      if ok then
        data = decoded
      end
    end
  end

  data[cwd] = list_name

  local encoded = vim.json.encode(data)
  vim.fn.writefile({encoded}, harpoon_data_file)
end

local function get_saved_list(cwd)
  if vim.fn.filereadable(harpoon_data_file) == 1 then
    local content = vim.fn.readfile(harpoon_data_file)
    if #content > 0 then
      local ok, data = pcall(vim.json.decode, table.concat(content, "\n"))
      if ok and data[cwd] then
        return data[cwd]
      end
    end
  end
  return nil
end

-- Initialize current list from saved data or default to "marks2"
local cwd = get_current_working_directory()
local saved_list = get_saved_list(cwd)
local current_list = saved_list or "marks2"

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

  -- Save the current list for this working directory
  local cwd = get_current_working_directory()
  save_current_list(cwd, list_name)

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
      if list_item.context then
        if list_item.context.list_name then
          HarpoonMeta.switch_to_list(list_item.context.list_name)
        elseif list_item.context.special_action == "create_new" then
          harpoon:list("Lists"):add()
        elseif list_item.context.special_action == "create_for_branch" then
          -- Get current git branch name
          local handle = io.popen("git branch --show-current 2>/dev/null")
          local branch_name = handle:read("*a"):gsub("%s+", "")
          handle:close()

          if branch_name ~= "" then
            -- Create new list with branch name
            HarpoonMeta.create_new_list(branch_name)
            HarpoonMeta.switch_to_list(branch_name)

            -- Add the new list to the Lists list
            harpoon:list("Lists"):add({
              value = branch_name,
              context = {
                list_name = branch_name
              }
            })
            print("Created and switched to list: " .. branch_name)
          else
            print("Not in a git repository or unable to determine branch name")
          end
        end
      end
    end
  }
}

-- Initial setup
harpoon:setup(base_lists_config)

-- Pre-populate Lists list with marks2 and special options
harpoon:list("Lists"):add({
  value = "marks2",
  context = {
    list_name = "marks2"
  }
})

-- Add special "NEW" option
harpoon:list("Lists"):add({
  value = "NEW",
  context = {
    special_action = "create_new"
  }
})

-- Add special "NEW FOR CURRENT BRANCH" option
harpoon:list("Lists"):add({
  value = "NEW FOR CURRENT BRANCH",
  context = {
    special_action = "create_for_branch"
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


-- File highlighting for harpoon buffers
local file_colors = {}
local color_index = 1

-- Define colors for file highlighting
local highlight_colors = {
  "HarpoonFile1",
  "HarpoonFile2",
  "HarpoonFile3",
  "HarpoonFile4",
  "HarpoonFile5",
  "HarpoonFile6",
  "HarpoonFile7",
  "HarpoonFile8",
  "HarpoonFile9",
  "HarpoonFile10",
  "HarpoonFile11",
  "HarpoonFile12",
  "HarpoonFile13",
  "HarpoonFile14",
  "HarpoonFile15",
  "HarpoonFile16",
  "HarpoonFile17",
  "HarpoonFile18",
}

-- Create highlight groups
local function setup_file_highlights()
  local colors = {
    "#cc9999", -- muted red
    "#99cccc", -- muted teal
    "#9999cc", -- muted blue
    "#99cc99", -- muted green
    "#d4a574", -- muted orange
    "#cc99cc", -- muted pink
    "#99aacc", -- muted light blue
    "#aa99cc", -- muted purple
    "#b3b399", -- muted olive
    "#cc9999", -- muted coral
    "#99ccaa", -- muted seafoam
    "#aa99aa", -- muted lavender
    "#c4aa99", -- muted brown
    "#99aaaa", -- muted gray-blue
    "#aacc99", -- muted lime
    "#cc99aa", -- muted rose
    "#99ccbb", -- muted mint
    "#bbaa99", -- muted tan
  }

  for i, color in ipairs(colors) do
    vim.api.nvim_set_hl(0, highlight_colors[i], { fg = color, bold = true, cterm = { bold = true } })
  end
end

-- Get or assign color for a file
local function get_file_color(filename)
  if not file_colors[filename] then
    file_colors[filename] = highlight_colors[color_index]
    color_index = color_index % #highlight_colors + 1
  end
  return file_colors[filename]
end

-- Highlight file references in current buffer
local function highlight_file_references()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Clear existing highlights
  vim.api.nvim_buf_clear_namespace(bufnr, -1, 0, -1)

  for line_nr, line in ipairs(lines) do
    -- Match pattern like "plugins/harpoon.lua:14" - extract just the filename
    local full_match, filename = line:match("(([^/]+%.[^:]+):%d+)")
    if filename then
      local color_group = get_file_color(filename)

      -- Find the start and end of the full file reference in the line
      local start_col, end_col = line:find(vim.pesc(full_match))
      if start_col then
        vim.api.nvim_buf_add_highlight(bufnr, -1, color_group, line_nr - 1, start_col - 1, end_col)
      end
    end
  end
end

-- Setup highlights and autocmd
setup_file_highlights()

-- Create autocmd to highlight harpoon buffers
vim.api.nvim_create_autocmd({"BufEnter", "TextChanged", "TextChangedI"}, {
  pattern = "*",
  callback = function()
    -- Check if this looks like a harpoon buffer by examining content
    local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)
    local has_file_refs = false

    for _, line in ipairs(lines) do
      if line:match("[^/]+%.[^:]+:%d+") then
        has_file_refs = true
        break
      end
    end

    if has_file_refs then
      highlight_file_references()
    end
  end
})

-- Export meta functions for external access
return HarpoonMeta
