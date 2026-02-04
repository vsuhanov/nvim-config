local winmove = require('winmove')

winmove.configure({
  keymaps = {
    help = "?",                -- Open floating window with help for the current mode
    help_close = "q",          -- Close the floating help window
    quit = "q",                -- Quit current mode
    toggle_mode = "<tab>",     -- Toggle between modes when in a mode
  },
  modes = {
    move = {
      highlight = "Visual",                       -- Highlight group for move mode
      at_edge = {
        horizontal = winmove.AtEdge.None,         -- Behaviour at horizontal edges
        vertical = winmove.AtEdge.None,           -- Behaviour at vertical edges
      },
      keymaps = {
        left = "h",                 -- Move window left
        down = "j",                 -- Move window down
        up = "k",                   -- Move window up
        right = "l",                -- Move window right
        far_left = "H",             -- Move window far left and maximize it
        far_down = "J",             -- Move window down and maximize it
        far_up = "K",               -- Move window up and maximize it
        far_right = "L",            -- Move window right and maximize it
        split_left = "sh",          -- Create a split with the window on the left
        split_down = "sj",          -- Create a split with the window below
        split_up = "sk",            -- Create a split with the window above
        split_right = "sl",         -- Create a split with the window on the right
      },
    },
    swap = {
      highlight = "Substitute",                   -- Highlight group for swap mode
      at_edge = {
        horizontal = winmove.AtEdge.None,         -- Behaviour at horizontal edges
        vertical = winmove.AtEdge.None,           -- Behaviour at vertical edges
      },
      keymaps = {
        left = "h",          -- Swap left
        down = "j",          -- Swap down
        up = "k",            -- Swap up
        right = "l",         -- Swap right
      },
    },
    resize = {
      highlight = "Todo",             -- Highlight group for resize mode
      default_resize_count = 3,       -- Default amount to resize windows
      keymaps = {
        -- When resizing, the anchor is in the top-left corner of the window by default
        left = "h",                               -- Resize to the left
        down = "j",                               -- Resize down
        up = "k",                                 -- Resize up
        right = "l",                              -- Resize to the right
        large_left = "H",                         -- Resize window a large amount left
        large_down = "J",                         -- Resize window a large amount down
        large_up = "K",                           -- Resize window a large amount up
        large_right = "L",                        -- Resize window a large amount right
        left_botright = "<c-h>",                  -- Resize left with bottom-right anchor
        down_botright = "<c-j>",                  -- Resize down with bottom-right anchor
        up_botright = "<c-k>",                    -- Resize up with bottom-right anchor
        right_botright = "<c-l>",                 -- Resize right with bottom-right anchor
        large_left_botright = "<c-s-h>",          -- Resize a large amount left with bottom-right anchor
        large_down_botright = "<c-s-j>",          -- Resize a large amount down with bottom-right anchor
        large_up_botright = "<c-s-k>",            -- Resize a large amount up with bottom-right anchor
        large_right_botright = "<c-s-l>",         -- Resize a large amount right with bottom-right anchor
      },
    },
  },
})

-- Auto-mapping for Esc to stop winmove mode
-- local original_esc_mapping = nil

-- vim.api.nvim_create_autocmd("User", {
--   pattern = { "WinmoveModeStart", "WinmoveModeEnd" },
--   callback = function(event)
--     if event.match == "WinmoveModeStart" then
--       -- Save existing Esc mapping
--       local existing = vim.fn.maparg('<Esc>', 'n', false, true)
--       if existing and existing ~= {} then
--         original_esc_mapping = existing
--       else
--         original_esc_mapping = nil
--       end

--       -- Create temporary Esc mapping
--       vim.keymap.set('n', '<Esc>', function()
--         require('winmove').stop_mode()
--       end, {
--         desc = "Stop winmove mode",
--         silent = true
--       })
--     elseif event.match == "WinmoveModeEnd" then
--       -- Remove the temporary mapping
--       pcall(function() vim.keymap.del('n', '<Esc>') end, "")

--       -- Restore original mapping if it existed
--       if original_esc_mapping then
--         local opts = {
--           silent = original_esc_mapping.silent == 1,
--           noremap = original_esc_mapping.noremap == 1,
--           expr = original_esc_mapping.expr == 1,
--           nowait = original_esc_mapping.nowait == 1,
--         }
--         if original_esc_mapping.desc then
--           opts.desc = original_esc_mapping.desc
--         end

--         vim.keymap.set('n', '<Esc>', original_esc_mapping.rhs or original_esc_mapping.callback, opts)
--         original_esc_mapping = nil
--       end
--     end
--   end,
-- })
