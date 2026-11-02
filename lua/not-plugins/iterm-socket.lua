local uv = vim.uv or vim.loop
local sid = os.getenv("ITERM_SESSION_ID")

if sid and not vim.env.NVIM then
  local uuid = sid:match(":(.+)$") or sid
  local sock = "/tmp/nvim-iterm-" .. uuid .. ".sock"

  if uv.fs_stat(sock) then
    local ok, chan = pcall(vim.fn.sockconnect, "pipe", sock, { rpc = true })
    if ok and chan > 0 then
      vim.fn.chanclose(chan)
      sock = nil
    else
      os.remove(sock)
    end
  end

  if sock then
    pcall(vim.fn.serverstart, sock)
  end
end
