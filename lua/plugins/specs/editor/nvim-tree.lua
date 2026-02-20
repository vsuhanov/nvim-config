local previous_window = nil
local window_tracking = require('window-tracking')

local function memorize_current_window()
  previous_window = vim.api.nvim_get_current_win()
end

local function return_to_previous_window()
  if previous_window and vim.api.nvim_win_is_valid(previous_window) then
    vim.api.nvim_set_current_win(previous_window)
  end
end
local function return_to_previous_window_and_close()
  if previous_window and vim.api.nvim_win_is_valid(previous_window) then
    vim.api.nvim_set_current_win(previous_window)
    require('nvim-tree.api').tree.close()
  end
end

local function expand_node()
  local api = require('nvim-tree.api')
  local node = api.tree.get_node_under_cursor()
  api.tree.expand_all(node)
end
local function collapse_node()
  local api = require('nvim-tree.api')
  local node = api.tree.get_node_under_cursor()
  api.tree.expand_all(node)
end

local function memorize_and_open()
  memorize_current_window()
  vim.cmd("NvimTreeFindFile")
end

local function open_in_previous_window()
  local api = require('nvim-tree.api')
  local node = api.tree.get_node_under_cursor()
  if not node or node.nodes then return end

  local stored_win = window_tracking.get_last_file_window()

  if stored_win and vim.api.nvim_win_is_valid(stored_win) then
    vim.api.nvim_set_current_win(stored_win)
    vim.cmd('edit ' .. vim.fn.fnameescape(node.absolute_path))
  else
    api.node.open.edit()
  end
end

local function open_with_window_picker()
  local api = require('nvim-tree.api')
  local node = api.tree.get_node_under_cursor()
  if not node or node.nodes then return end

  local picker_ok, picker = pcall(require, 'window-picker')
  if not picker_ok then
    vim.notify("window-picker not available", vim.log.levels.ERROR)
    return
  end

  local picked_window = picker.pick_window()

  if picked_window then
    vim.api.nvim_set_current_win(picked_window)
    vim.cmd('edit ' .. vim.fn.fnameescape(node.absolute_path))
  end
end

return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  enabled = true,
  keys = {
    {
      "-",
      function()
        memorize_and_open()
      end,
      desc = "Open nvim-tree at file"
    },
    { "<M-1>", ":NvimTreeFindFileToggle<cr>", desc = "Toggle nvim-tree" },
  },
  opts = {
    view = {
      side = "right",
      width = 60
    },
    actions = {
      open_file = {
        quit_on_open = false,
      }
    },
    update_focused_file = {
      enable = false,
      update_root = {
        enable = false
      }
    },
    on_attach = function(bufnr)
      local function reveal_in_finder()
        local node = require('nvim-tree.api').tree.get_node_under_cursor()
        if node then
          vim.fn.system('open -R "' .. node.absolute_path .. '"')
        end
      end
      local function open_in_intellij()
        local node = require('nvim-tree.api').tree.get_node_under_cursor()
        if node then
          local utils = require('utils')
          utils.open_in_idea(node.absolute_path)
        end
      end

      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end
      vim.keymap.set("n", "<C-]>", require('nvim-tree.api').tree.change_root_to_node, opts("CD"))
      vim.keymap.set("n", "<C-e>", require('nvim-tree.api').node.open.replace_tree_buffer, opts("Open: In Place"))
      vim.keymap.set("n", "<C-k>", require('nvim-tree.api').node.show_info_popup, opts("Info"))
      vim.keymap.set("n", "<C-r>", require('nvim-tree.api').fs.rename_sub, opts("Rename: Omit Filename"))
      vim.keymap.set("n", "<C-t>", require('nvim-tree.api').node.open.tab, opts("Open: New Tab"))
      vim.keymap.set("n", "<C-v>", require('nvim-tree.api').node.open.vertical, opts("Open: Vertical Split"))
      vim.keymap.set("n", "<C-x>", require('nvim-tree.api').node.open.horizontal, opts("Open: Horizontal Split"))
      vim.keymap.set("n", "<BS>", require('nvim-tree.api').node.navigate.parent_close, opts("Close Directory"))
      vim.keymap.set("n", "<CR>", open_in_previous_window, opts("Open in previous window"))
      vim.keymap.set("n", "<C-w>j", open_with_window_picker, opts("Open in window (picker)"))
      vim.keymap.set("n", "<Tab>", require('nvim-tree.api').node.open.preview, opts("Open Preview"))
      vim.keymap.set("n", ">", require('nvim-tree.api').node.navigate.sibling.next, opts("Next Sibling"))
      vim.keymap.set("n", "<", require('nvim-tree.api').node.navigate.sibling.prev, opts("Previous Sibling"))
      vim.keymap.set("n", ".", require('nvim-tree.api').node.run.cmd, opts("Run Command"))
      -- vim.keymap.set("n", "_",require('nvim-tree.api').tree.change_root_to_parent, opts("Up"))
      vim.keymap.set("n", "a", require('nvim-tree.api').fs.create, opts("Create File Or Directory"))
      vim.keymap.set("n", "bd", require('nvim-tree.api').marks.bulk.delete, opts("Delete Bookmarked"))
      vim.keymap.set("n", "bt", require('nvim-tree.api').marks.bulk.trash, opts("Trash Bookmarked"))
      vim.keymap.set("n", "bmv", require('nvim-tree.api').marks.bulk.move, opts("Move Bookmarked"))
      vim.keymap.set("n", "B", require('nvim-tree.api').tree.toggle_no_buffer_filter, opts("Toggle Filter: No Buffer"))
      vim.keymap.set("n", "c", require('nvim-tree.api').fs.copy.node, opts("Copy"))
      vim.keymap.set("n", "C", require('nvim-tree.api').tree.toggle_git_clean_filter, opts("Toggle Filter: Git Clean"))
      vim.keymap.set("n", "[c", require('nvim-tree.api').node.navigate.git.prev, opts("Prev Git"))
      vim.keymap.set("n", "]c", require('nvim-tree.api').node.navigate.git.next, opts("Next Git"))
      vim.keymap.set("n", "d", require('nvim-tree.api').fs.remove, opts("Delete"))
      vim.keymap.set("n", "D", require('nvim-tree.api').fs.trash, opts("Trash"))
      vim.keymap.set("n", "E", expand_node, opts("Expand All"));
      vim.keymap.set("n", "e", require('nvim-tree.api').fs.rename_basename, opts("Rename: Basename"))
      vim.keymap.set("n", "]e", require('nvim-tree.api').node.navigate.diagnostics.next, opts("Next Diagnostic"))
      vim.keymap.set("n", "[e", require('nvim-tree.api').node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
      vim.keymap.set("n", "F", require('nvim-tree.api').live_filter.clear, opts("Live Filter: Clear"))
      vim.keymap.set("n", "f", require('nvim-tree.api').live_filter.start, opts("Live Filter: Start"))
      vim.keymap.set("n", "g?", require('nvim-tree.api').tree.toggle_help, opts("Help"))
      vim.keymap.set("n", "gy", require('nvim-tree.api').fs.copy.absolute_path, opts("Copy Absolute Path"))
      vim.keymap.set("n", "<C-S-c>", require('nvim-tree.api').fs.copy.absolute_path, opts("Copy Absolute Path"))
      vim.keymap.set("n", "<C-M-c>", require('nvim-tree.api').fs.copy.relative_path, opts("Copy Absolute Path"))
      vim.keymap.set("n", "ge", require('nvim-tree.api').fs.copy.basename, opts("Copy Basename"))
      vim.keymap.set("n", "H", require('nvim-tree.api').tree.toggle_hidden_filter, opts("Toggle Filter: Dotfiles"))
      vim.keymap.set("n", "I", require('nvim-tree.api').tree.toggle_gitignore_filter, opts("Toggle Filter: Git Ignore"))
      vim.keymap.set("n", "i", open_in_intellij, opts("Open in Intellij"))
      vim.keymap.set("n", "J", require('nvim-tree.api').node.navigate.sibling.last, opts("Last Sibling"))
      vim.keymap.set("n", "K", require('nvim-tree.api').node.navigate.sibling.first, opts("First Sibling"))
      vim.keymap.set("n", "L", require('nvim-tree.api').node.open.toggle_group_empty, opts("Toggle Group Empty"))
      vim.keymap.set("n", "M", require('nvim-tree.api').tree.toggle_no_bookmark_filter,
        opts("Toggle Filter: No Bookmark"))
      vim.keymap.set("n", "m", require('nvim-tree.api').marks.toggle, opts("Toggle Bookmark"))
      vim.keymap.set("n", "o", require('nvim-tree.api').node.open.edit, opts("Open"))
      vim.keymap.set("n", "O", require('nvim-tree.api').node.open.no_window_picker, opts("Open: No Window Picker"))
      vim.keymap.set("n", "p", require('nvim-tree.api').fs.paste, opts("Paste"))
      vim.keymap.set("n", "P", require('nvim-tree.api').node.navigate.parent, opts("Parent Directory"))
      vim.keymap.set("n", "q", require('nvim-tree.api').tree.close, opts("Close"))
      vim.keymap.set("n", "r", require('nvim-tree.api').fs.rename, opts("Rename"))
      vim.keymap.set("n", "R", require('nvim-tree.api').tree.reload, opts("Refresh"))
      vim.keymap.set("n", "s", reveal_in_finder, opts("Reveal in finder"))
      vim.keymap.set("n", "S", require('nvim-tree.api').tree.search_node, opts("Search"))
      vim.keymap.set("n", "u", require('nvim-tree.api').fs.rename_full, opts("Rename: Full Path"))
      vim.keymap.set("n", "U", require('nvim-tree.api').tree.toggle_custom_filter, opts("Toggle Filter: Hidden"))
      vim.keymap.set("n", "W", require('nvim-tree.api').tree.collapse_all, opts("Collapse All"))
      vim.keymap.set("n", "x", require('nvim-tree.api').fs.cut, opts("Cut"))
      vim.keymap.set("n", "y", require('nvim-tree.api').fs.copy.filename, opts("Copy Name"))
      vim.keymap.set("n", "Y", require('nvim-tree.api').fs.copy.relative_path, opts("Copy Relative Path"))
      vim.keymap.set("n", "<2-LeftMouse>", require('nvim-tree.api').node.open.edit, opts("Open"))
      vim.keymap.set("n", "<2-RightMouse>", require('nvim-tree.api').tree.change_root_to_node, opts("CD"))
      vim.keymap.set("n", "<esc>", return_to_previous_window, { silent = true, buffer = bufnr })
      vim.keymap.set("n", "_", return_to_previous_window, { silent = true, buffer = bufnr })
      vim.keymap.set("n", "-", return_to_previous_window_and_close, { silent = true, buffer = bufnr })

      -- Custom function to search in current directory with Snacks picker
      vim.keymap.set("n", "<leader>ff", function()
        local node = require('nvim-tree.api').tree.get_node_under_cursor()
        if not node then return end

        local search_path
        if node.type == "directory" then
          search_path = node.absolute_path
        else
          search_path = vim.fn.fnamemodify(node.absolute_path, ":h")
        end

        require('plugins.config.telescope-live-multigrep').live_multigrep({
          cwd = search_path,
        })
      end, opts("Telescope Find in Directory"))
    end
  },
}
