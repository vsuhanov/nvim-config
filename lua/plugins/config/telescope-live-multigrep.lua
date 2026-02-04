local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local conf = require "telescope.config".values
local sorters = require('telescope.sorters')
local process_glob_pattern = function(pattern)
  if pattern:sub(1, 1) == "/" then
    return "**/*" .. pattern:sub(2) .. "*/**"
  else
    return pattern
  end
end

local live_multigrep = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()

  local finder = finders.new_async_job {
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end
      local groups = vim.split(prompt, "   ")
      local args = { "rg", "--glob-case-insensitive" }

      for _, group in ipairs(groups) do
        local pieces = vim.split(group, "  ")
        if pieces[1] then
          table.insert(args, "-e")
          table.insert(args, pieces[1])
        end
        if pieces[2] then
          table.insert(args, "-g")
          table.insert(args, process_glob_pattern(pieces[2]))
        end
        if pieces[3] then
          table.insert(args, "-g")
          table.insert(args, process_glob_pattern(pieces[3]))
        end
      end

      return vim.iter({
        args,
        { "--color=never", "--vimgrep", "--smart-case" },
      }
      ):flatten():totable()
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,

  }
  pickers.new(opts,
    {
      finder = finder,
      prompt_title = "Multi Grep",
      debounce = 100,
      previewer = conf.grep_previewer(opts),
      sorter = sorters.highlighter_only(opts),

    }):find()
end
-- live_multigrep()
return {
  live_multigrep = live_multigrep
}
