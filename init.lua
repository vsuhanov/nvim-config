if vim.g.vscode then
  -- VSCode extension
  require('vscode.initvim')
  require('vscode.plugins')
  require('vscode.remap')
  require('vscode.commands')
  require('vscode.set')
  require('vscode.purple-config')
  require('vscode.windows-stuff')

  -- ignore errors: local-config may not exist
  pcall(function()
    require("vscode.local-config")
  end)
else
  require('initvim')
  require('plugins')
  require('remap')
  require('commands')
  require('set')
  require('purple-config')
  require('windows-stuff')

  -- ignore errors: local-config may not exist
  pcall(function()
    require("local-config")
  end)
end
