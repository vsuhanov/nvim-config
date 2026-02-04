local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

local config = {
  cmd = {
    -- 💀
    '/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home/bin/java', -- or ''
    -- depends on if `java` is in your $PATH env variable and if it points to the right version.

    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    -- '-Djava.import.gradle.java.home=/Users/vitaly/.asdf/installs/java/openjdk-21.0.2',
    -- '-Djava.home=/Users/vitaly/.asdf/installs/java/openjdk-21.0.2',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

    -- 💀
    '-jar', '/Users/vitaly/projects/jdt-language-server/plugins/org.eclipse.equinox.launcher_1.6.700.v20231214-2017.jar',
    -- 💀
    '-configuration', '/Users/vitaly/projects/jdt-language-server/config_mac',

    -- 💀
    -- See `data directory configuration` section in the README
    '-data', ('/Users/vitaly/projects/jdtls-workspaces/' .. project_name)
  },
  root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
  -- settings = {
  --   java = {
  --     home = "/Users/vitaly/.asdf/installs/java/openjdk-19.0.2",
  --     -- configuration = {
  --     --   runtimes = {
  --     --     name = "JavaSE-19",
  --     --     path = "/Users/vitaly/.asdf/installs/java/openjdk-19.0.2"
  --     --   }
  --     -- }
  --   }
  -- }
}
-- require('jdtls').start_or_attach(config)
local function jdtls_setup(event)
  local jdtls = require('jdtls')
  jdtls.start_or_attach(config)
end
local java_cmds = vim.api.nvim_create_augroup("java_cmds", { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = java_cmds,
  pattern = { 'java' },
  desc = 'Setup jdtls',
  callback = jdtls_setup,
})
