local previous_window = nil

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
  end
end

local nvimTree = require('nvim-tree')
local api = require('nvim-tree.api')

nvimTree.setup(
  {
    view = {
      side = "left",
      width = 60
    },
    actions = {
      open_file = {
        quit_on_open = false,
      }
    },
    update_focused_file = {
      enable = true,
      update_root = {
        enable = false
      }
    },
    on_attach = function(bufnr)
      local function reveal_in_finder()
        local node = api.tree.get_node_under_cursor()
        if node then
          vim.fn.system('open -R "' .. node.absolute_path .. '"')
        end
      end
      local function open_in_intellij()
        local node = api.tree.get_node_under_cursor()
        if node then
          -- print('open -a "IntelliJ IDEA.app" --args "' .. node.absolute_path .. '"')
          vim.fn.system('open -a "IntelliJ IDEA.app" "' .. node.absolute_path .. '"')
        end
      end

      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end
      vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("CD"))
      vim.keymap.set("n", "<C-e>", api.node.open.replace_tree_buffer, opts("Open: In Place"))
      vim.keymap.set("n", "<C-k>", api.node.show_info_popup, opts("Info"))
      vim.keymap.set("n", "<C-r>", api.fs.rename_sub, opts("Rename: Omit Filename"))
      vim.keymap.set("n", "<C-t>", api.node.open.tab, opts("Open: New Tab"))
      vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts("Open: Vertical Split"))
      vim.keymap.set("n", "<C-x>", api.node.open.horizontal, opts("Open: Horizontal Split"))
      vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
      vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "<Tab>", api.node.open.preview, opts("Open Preview"))
      vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts("Next Sibling"))
      vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts("Previous Sibling"))
      vim.keymap.set("n", ".", api.node.run.cmd, opts("Run Command"))
      vim.keymap.set("n", "_", api.tree.change_root_to_parent, opts("Up"))
      vim.keymap.set("n", "a", api.fs.create, opts("Create File Or Directory"))
      vim.keymap.set("n", "bd", api.marks.bulk.delete, opts("Delete Bookmarked"))
      vim.keymap.set("n", "bt", api.marks.bulk.trash, opts("Trash Bookmarked"))
      vim.keymap.set("n", "bmv", api.marks.bulk.move, opts("Move Bookmarked"))
      vim.keymap.set("n", "B", api.tree.toggle_no_buffer_filter, opts("Toggle Filter: No Buffer"))
      vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
      vim.keymap.set("n", "C", api.tree.toggle_git_clean_filter, opts("Toggle Filter: Git Clean"))
      vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts("Prev Git"))
      vim.keymap.set("n", "]c", api.node.navigate.git.next, opts("Next Git"))
      vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
      vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
      vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
      vim.keymap.set("n", "e", api.fs.rename_basename, opts("Rename: Basename"))
      vim.keymap.set("n", "]e", api.node.navigate.diagnostics.next, opts("Next Diagnostic"))
      vim.keymap.set("n", "[e", api.node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
      vim.keymap.set("n", "F", api.live_filter.clear, opts("Live Filter: Clear"))
      vim.keymap.set("n", "f", api.live_filter.start, opts("Live Filter: Start"))
      vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
      vim.keymap.set("n", "gy", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
      vim.keymap.set("n", "ge", api.fs.copy.basename, opts("Copy Basename"))
      vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Filter: Dotfiles"))
      vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Filter: Git Ignore"))
      vim.keymap.set("n", "i", open_in_intellij, opts("Open in Intellij"))
      vim.keymap.set("n", "J", api.node.navigate.sibling.last, opts("Last Sibling"))
      vim.keymap.set("n", "K", api.node.navigate.sibling.first, opts("First Sibling"))
      vim.keymap.set("n", "L", api.node.open.toggle_group_empty, opts("Toggle Group Empty"))
      vim.keymap.set("n", "M", api.tree.toggle_no_bookmark_filter, opts("Toggle Filter: No Bookmark"))
      vim.keymap.set("n", "m", api.marks.toggle, opts("Toggle Bookmark"))
      vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "O", api.node.open.no_window_picker, opts("Open: No Window Picker"))
      vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
      vim.keymap.set("n", "P", api.node.navigate.parent, opts("Parent Directory"))
      vim.keymap.set("n", "q", api.tree.close, opts("Close"))
      vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
      vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
      vim.keymap.set("n", "s", reveal_in_finder, opts("Reveal in finder"))
      vim.keymap.set("n", "S", api.tree.search_node, opts("Search"))
      vim.keymap.set("n", "u", api.fs.rename_full, opts("Rename: Full Path"))
      vim.keymap.set("n", "U", api.tree.toggle_custom_filter, opts("Toggle Filter: Hidden"))
      vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse All"))
      vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
      vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Name"))
      vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("Copy Relative Path"))
      vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "<2-RightMouse>", api.tree.change_root_to_node, opts("CD"))
      vim.keymap.set("n", "<esc>", return_to_previous_window, { silent = true, buffer = bufnr })
      vim.keymap.set("n", "-", return_to_previous_window, { silent = true, buffer = bufnr })
      vim.keymap.set("n", "<C-->", return_to_previous_window_and_close, { silent = true, buffer = bufnr })

      -- Custom function to search in current directory with Snacks picker
      vim.keymap.set("n", "<leader>ff", function()
        local node = api.tree.get_node_under_cursor()
        if not node then return end

        local search_path
        if node.type == "directory" then
          search_path = node.absolute_path
        else
          search_path = vim.fn.fnamemodify(node.absolute_path, ":h")
        end

        require('snacks').picker.grep({
          cwd = search_path,
          win = { title = "Search in " .. vim.fn.fnamemodify(search_path, ":t") }
        })
      end, opts("Snacks Picker Search in Directory"))
    end
  }
)

local opts = { silent = true }
vim.keymap.set("n", "-", function()
  memorize_current_window()
  vim.cmd("NvimTreeFindFile")
end, opts)
vim.keymap.set("n", "<M-1>", function()
  vim.cmd("NvimTreeFindFileToggle")
end, opts)
