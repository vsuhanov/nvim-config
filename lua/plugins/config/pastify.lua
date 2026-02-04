require('pastify').setup({
  opts = {
    absolute_path = false,                    -- use absolute or relative path to the working directory
    -- apikey = '',                              -- Api key, required for online saving
    -- local_path = '/assets/imgs/',             -- The path to put local files in, ex ~/Projects/<name>/assets/images/<imgname>.png
    -- save = 'local',                           -- Either 'local' or 'online' or 'local_file'
    filename = function() return vim.fn.expand("%:t:r") .. '_' .. os.date('%Y-%m-%d_%H-%M-%S') end,
    default_ft = 'markdown',                  -- Default filetype to use
  },
  ft = {                                      -- Custom snippets for different filetypes, will replace $IMG$ with the image url
    html = '<img src="$IMG$" alt="$NAME$">',
    markdown = '![$NAME$]($IMG$)',
    tex = [[\includegraphics[width=\linewidth]{$IMG$}]],
    css = 'background-image: url("$IMG$");',
    js = 'const img = new Image(); img.src = "$IMG$";',
    xml = '<image src="$IMG$" />',
    php = '<?php echo "<img src=\"$IMG$\" alt=\"$NAME$\">"; ?>',
    python = '# $IMG$',
    java = '// $IMG$',
    c = '// $IMG$',
    cpp = '// $IMG$',
    swift = '// $IMG$',
    kotlin = '// $IMG$',
    go = '// $IMG$',
    typescript = '// $IMG$',
    ruby = '# $IMG$',
    vhdl = '-- $IMG$',
    verilog = '// $IMG$',
    systemverilog = '// $IMG$',
    lua = '-- $IMG$',
  }
})
