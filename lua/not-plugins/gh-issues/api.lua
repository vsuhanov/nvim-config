local M = {}

local config_path = vim.fn.stdpath("data") .. "/gh-issues-config.json"

function M.read_config()
  local ok, data = pcall(vim.fn.readfile, config_path)
  if not ok or #data == 0 then return {} end
  local pok, parsed = pcall(vim.fn.json_decode, table.concat(data, "\n"))
  return pok and parsed or {}
end

function M.write_config(cfg)
  vim.fn.writefile({ vim.fn.json_encode(cfg) }, config_path)
end

local log_path = "/tmp/gh-issues-nvim.log"
function M.log(msg)
  local f = io.open(log_path, "a")
  if f then
    f:write(os.date("%H:%M:%S") .. " " .. tostring(msg) .. "\n")
    f:close()
  end
end

function M.get_repo_from_git()
  local url = vim.fn.system("git -C " .. vim.fn.shellescape(vim.fn.getcwd()) .. " remote get-url origin 2>/dev/null"):gsub("%s+$", "")
  if url == "" then return nil end
  local repo = url:match("github%.com[:/](.-)%.git$") or url:match("github%.com[:/](.-)$")
  if repo and repo:match("^[^/]+/[^/]+$") then return repo end
  return nil
end

function M.get_token()
  local cfg = M.read_config()
  local account = cfg.selected_account
  if account then
    local token = vim.fn.system("gh auth token -u " .. vim.fn.shellescape(account) .. " 2>/dev/null"):gsub("%s+$", "")
    if token ~= "" then return token end
  end
  return vim.env.GH_TOKEN or ""
end

function M.make_env_list()
  local token = M.get_token()
  local env = vim.uv.os_environ()
  if token ~= "" then
    env.GH_TOKEN = token
  end
  env.GITHUB_TOKEN = nil
  local list = {}
  for k, v in pairs(env) do
    table.insert(list, k .. "=" .. v)
  end
  return list
end

function M.gh_api(method, path, body)
  local token = M.get_token()
  local tmp
  local cmd
  if token ~= "" then
    cmd = string.format("GH_TOKEN=%s gh api --method %s %s 2>&1", vim.fn.shellescape(token), method, vim.fn.shellescape(path))
  else
    cmd = string.format("gh api --method %s %s 2>&1", method, vim.fn.shellescape(path))
  end
  if body then
    tmp = os.tmpname()
    vim.fn.writefile({ vim.fn.json_encode(body) }, tmp)
    cmd = cmd .. " --input " .. tmp
  end
  M.log("gh_api: " .. cmd)
  local result = vim.fn.system(cmd)
  M.log("gh_api result (" .. #result .. " bytes): " .. result:sub(1, 300))
  if tmp then os.remove(tmp) end
  local ok, parsed = pcall(vim.fn.json_decode, result)
  M.log("gh_api parse ok=" .. tostring(ok) .. " type=" .. type(parsed))
  return ok and parsed or nil
end

function M.gh_api_async(path, callback)
  M.log("gh_api_async: " .. path)
  local stdout = vim.uv.new_pipe()
  local chunks = {}
  vim.uv.spawn("gh", {
    args = { "api", "--method", "GET", path },
    stdio = { nil, stdout, nil },
    env = M.make_env_list(),
  }, function()
    stdout:close()
  end)
  vim.uv.read_start(stdout, function(err, chunk)
    if chunk then
      table.insert(chunks, chunk)
    else
      local raw = table.concat(chunks)
      vim.schedule(function()
        M.log("gh_api_async result (" .. #raw .. " bytes): " .. raw:sub(1, 200))
        local ok, data = pcall(vim.fn.json_decode, raw)
        M.log("gh_api_async parse ok=" .. tostring(ok) .. " type=" .. type(data))
        callback(ok and data ~= nil, ok and data or nil)
      end)
    end
  end)
end

return M
