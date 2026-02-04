if vim.g.vscode then
  -- VSCode extension
  require('vscode_suhanov.initvim')
  require('vscode_suhanov.plugins')
  require('vscode_suhanov.remap')
  require('vscode_suhanov.commands')
  require('vscode_suhanov.set')
  require('vscode_suhanov.purple-config')
  require('vscode_suhanov.windows-stuff')

  -- ignore errors: local-config may not exist
  pcall(function()
    require("vscode_suhanov.local-config")
  end)
else
  require('initvim')
  require('set')
  require('plugins')
  require('remap')
  require('commands')
  require('set-afterplugins')
  require('purple-config')
  require('windows-stuff')
  require('autofilereload')
  require('autocmd')
  require('lsp')
  require('not-plugins.terminal-improvements')
  require('not-plugins.todo-floating-window')
  require('claude')
  -- Setup quickfix/loclist magic
  require('quickfix-magic').setup()

  -- Setup git branch highlighting
  require('git-branch-highlight').setup()

  -- ignore errors: local-config may not exist
  pcall(function()
    require("local-config")
  end)
  if vim.fn.has("nvim") == 1 and vim.fn.executable("nvr") == 1 then
    vim.env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
  end
end
