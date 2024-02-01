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

