-- lualine carrega este tema automaticamente quando colors_name == "stratus"
local c = require("stratus.palette")

local function mode(accent)
  return {
    a = { fg = c.bg, bg = accent, gui = "bold" },
    b = { fg = c.fg2, bg = c.surface },
    c = { fg = c.fg, bg = c.surface },
    z = { fg = c.fg, bg = c.elevated },
  }
end

return {
  normal = mode(c.primary),
  insert = mode(c.highlight),
  visual = mode(c.secondary),
  replace = mode(c.error),
  command = mode(c.warning),
  terminal = mode(c.success),
  inactive = {
    a = { fg = c.muted, bg = c.surface },
    b = { fg = c.muted, bg = c.surface },
    c = { fg = c.muted, bg = c.surface },
  },
}
