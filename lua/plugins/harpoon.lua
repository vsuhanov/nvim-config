local list_options = {
  height_in_lines = 30
}

local function create_advanced_list()
  return {
    create_list_item = function(config, name)
      local bufname = vim.api.nvim_buf_get_name(0)
      if bufname == "" then
        return nil
      end

      -- Check if current buffer is an NvimTree buffer
      if bufname:match("NvimTree_") then
        local ok, tree_api = pcall(require, "nvim-tree.api")
        if not ok then
          print("nvim-tree API not available")
          return nil
        end

        -- Get the current node
        local node = tree_api.tree.get_node_under_cursor()
        if not node then
          print("No node under cursor")
          return nil
        end

        local absolute_path = node.absolute_path
        local parent_dir = vim.fn.fnamemodify(absolute_path, ":h:t")
        local node_name = vim.fn.fnamemodify(absolute_path, ":t")

        return {
          value = "tree: " .. parent_dir .. "/" .. node_name,
          context = {
            treePath = absolute_path
          }
        }
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

      -- Handle tree entries
      if list_item.context and list_item.context.treePath then
        local ok, tree_api = pcall(require, "nvim-tree.api")
        if ok then
          tree_api.tree.focus()
          tree_api.tree.find_file(list_item.context.treePath)
        end
        return
      end

      -- Handle regular file entries
      if list_item.context and list_item.context.path then
        vim.cmd("edit " .. list_item.context.path)
        vim.fn.cursor(list_item.context.row, list_item.context.col)
      end
    end
  }
end
local base_lists_config = {}
local HarpoonMeta = {}
local create_base_lists_config = function(harpoon_instance)
  return {
    marks2 = create_advanced_list(),
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
            harpoon_instance.ui:toggle_quick_menu(harpoon_instance:list(list_item.context.list_name), list_options)
          elseif list_item.context.special_action == "create_new" then
            harpoon_instance:list("Lists"):add()
          elseif list_item.context.special_action == "create_for_branch" then
            -- Get current git branch name
            local handle = io.popen("git branch --show-current 2>/dev/null")
            local branch_name = handle:read("*a"):gsub("%s+", "")
            handle:close()

            if branch_name ~= "" then
              -- Get current directory basename
              local cwd = vim.fn.getcwd()
              local dir_basename = vim.fn.fnamemodify(cwd, ":t")

              -- Create list name with directory basename and branch name
              local list_name = dir_basename .. " - " .. branch_name

              -- Create new list with combined name
              HarpoonMeta.create_new_list(list_name)
              HarpoonMeta.switch_to_list(list_name)

              -- Add the new list to the Lists list
              harpoon_instance:list("Lists"):add({
                value = list_name,
                context = {
                  list_name = list_name
                }
              })
              print("Created and switched to list: " .. list_name)
            else
              print("Not in a git repository or unable to determine branch name")
            end
          end
        end
      end
    }
  }
end


local harpoon = require("harpoon"):new({
  settings = {
    key = function()
      return "root"
    end,
  },
})
harpoon:setup(create_base_lists_config(harpoon))

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
  vim.fn.writefile({ encoded }, harpoon_data_file)
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

-- Store current keymaps for cleanup
local current_keymaps = {}

-- Meta functions for dynamic list management
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
    {
      mode = "n",
      lhs = "<leader>ee",
      rhs = function()
        harpoon.ui:toggle_quick_menu(harpoon:list(current_list),
          list_options)
      end
    },
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

  local new_list_config = create_advanced_list()
  base_lists_config[list_name] = new_list_config
  harpoon:setup(base_lists_config)

  return list_name
end


-- Pre-populate Lists list with marks2 and special options
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
harpoon:list("Lists"):add({
  value = "marks2",
  context = {
    list_name = "marks2"
  }
})

-- Add special "NEW" option

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

  -- Add bright pink highlight for project name
  vim.api.nvim_set_hl(0, "HarpoonProjectName", { fg = "#ff1493", bold = true, cterm = { bold = true } })
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

  -- Get current project name for highlighting
  local cwd = vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(cwd, ":t")

  for line_nr, line in ipairs(lines) do
    -- Highlight project name if present in the line
    local project_start = 1
    while true do
      local start_col, end_col = line:find(vim.pesc(project_name), project_start)
      if not start_col then break end
      vim.api.nvim_buf_add_highlight(bufnr, -1, "HarpoonProjectName", line_nr - 1, start_col - 1, end_col)
      project_start = end_col + 1
    end

    -- Match pattern like "plugins/harpoon.lua:14" - extract just the filename
    local full_match, filename = line:match("(([^/]+%.[^:]+):%d+)")
    if filename then
      local color_group = get_file_color(filename)

      -- Find the start and end of the full file reference in the line
      local start_col, end_col = line:find(vim.pesc(full_match))
      if start_col and end_col then
        vim.api.nvim_buf_add_highlight(bufnr, -1, color_group, line_nr - 1, start_col - 1, end_col)
      end
    else
      -- Match pattern like "tree: parentdir/nodename" - extract just the nodename
      local nodename = line:match("tree:%s+[^/]+/([^/]+)%s*$")
      if nodename then
        local color_group = get_file_color(nodename)

        -- Find the start and end of the nodename in the line
        local start_col, end_col = line:find(vim.pesc(nodename))
        if start_col and end_col then
          vim.api.nvim_buf_add_highlight(bufnr, -1, color_group, line_nr - 1, start_col - 1, end_col)
        end
      end
    end
  end
end

-- Setup highlights and autocmd
setup_file_highlights()
local group = vim.api.nvim_create_augroup("HarpoonHighlight", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "harpoon",
  callback = function()
    vim.schedule(highlight_file_references)
  end
})

vim.api.nvim_create_user_command('HarpoonShowLog', function()
  require('harpoon.logger'):show()
end, {})

-- Export meta functions for external access
return HarpoonMeta
