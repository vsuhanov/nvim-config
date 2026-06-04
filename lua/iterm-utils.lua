local M = {}

local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return {
    r = tonumber(hex:sub(1, 2), 16),
    g = tonumber(hex:sub(3, 4), 16),
    b = tonumber(hex:sub(5, 6), 16)
  }
end

function M.set_tab_color(hex_color)
  local rgb = hex_to_rgb(hex_color)
  local escape_seq = string.format(
    "\027]6;1;bg;red;brightness;%d\007\027]6;1;bg;green;brightness;%d\007\027]6;1;bg;blue;brightness;%d\007",
    rgb.r, rgb.g, rgb.b
  )
  io.write(escape_seq)
  io.flush()
end

return M
