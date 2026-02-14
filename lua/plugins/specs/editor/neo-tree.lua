local previous_window = nil

local function memorize_current_window()
  previous_window = vim.api.nvim_get_current_win()
end

local function return_to_previous_window()
  if previous_window and vim.api.nvim_win_is_valid(previous_window) then
    vim.api.nvim_set_current_win(previous_window)
  end
end

local function memorize_and_toggle()
  memorize_current_window()
  vim.cmd("Neotree toggle")
end

local function go_to_previous_window()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>p", true, false, true), "n", false)
end

local function open_in_intellij(state)
  local node = state.tree:get_node()
  if node then
    require('utils').open_in_idea(node.path)
  end
end
local function reveal_in_finder(state)
  local node = state.tree:get_node()
  if node then
    vim.fn.system('open -R "' .. node.path .. '"')
  end
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      {
        "-",
        ":Neotree reveal<CR>",
        desc = "Toggle neo-tree"
      },
    },
    opts = {
      sources = {
        "filesystem",
        "buffers",
        "git_status",
      },
      source_selector = {
        winbar = true,
      },
      filesystem = {
        side = "right",
        width = 60,
        follow_current_file = {
          enabled = false,
        },
        always_show_by_pattern = {
          ".env*",
        },
        never_show = {
          ".DS_Store",
          "thumbs.db"
        },
        group_empty_dirs = true,
      },
      window = {
        position = "right",
        width = 60,
        mappings = {
          ["-"] = go_to_previous_window,
          ["<esc>"] = go_to_previous_window,
          ["i"] = open_in_intellij,
          ["s"] = reveal_in_finder,
          ["<bs>"] = "noop",
          ["="] = "navigate_up",
          ["<C-v>"] = "open_vsplit",
          ["<C-x>"] = "open_split",
          ["e"] = "expand_all_subnodes",
          ["<leader>ff"] = function(state)
            print(state)
            local node = state.tree:get_node()
            if not node then return end

            local search_path
            if node.type == "directory" then
              search_path = node.path
            else
              search_path = vim.fn.fnamemodify(node.path, ":h")
            end

            require('plugins.config.telescope-live-multigrep').live_multigrep({
              cwd = search_path,
            })
          end
        }
      },
    },
  }
}
