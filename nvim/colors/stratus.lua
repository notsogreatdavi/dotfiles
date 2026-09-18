-- Stratus: colorscheme derivado de 11.06_visual-identity/design-system.md
-- Papéis semânticos seguem a seção "Roles Semânticos por Contexto" do design system.

local c = require("stratus.palette")

-- Mistura fg sobre bg na proporção alpha; evita hex fora dos tokens em fundos de diff.
local function blend(fg, bg, alpha)
  local function channel(hex, i)
    return tonumber(hex:sub(i, i + 1), 16)
  end
  local mixed = {}
  for _, i in ipairs({ 2, 4, 6 }) do
    table.insert(mixed, math.floor(channel(fg, i) * alpha + channel(bg, i) * (1 - alpha) + 0.5))
  end
  return string.format("#%02X%02X%02X", unpack(mixed))
end

local function apply(groups)
  for group, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

local function editor()
  return {
    Normal = { fg = c.fg, bg = c.bg },
    NormalNC = { fg = c.fg, bg = c.bg },
    NormalFloat = { fg = c.fg, bg = c.surface },
    FloatBorder = { fg = c.border, bg = c.surface },
    FloatTitle = { fg = c.fg, bg = c.surface, bold = true },
    WinSeparator = { fg = c.border },
    CursorLine = { bg = c.elevated },
    CursorLineNr = { fg = c.fg, bold = true },
    LineNr = { fg = c.muted },
    SignColumn = { bg = c.bg },
    ColorColumn = { bg = c.surface },
    Cursor = { fg = c.bg, bg = c.highlight },
    Visual = { bg = c.elevated },
    Search = { fg = c.bg, bg = c.highlight },
    IncSearch = { fg = c.bg, bg = c.primary },
    CurSearch = { link = "IncSearch" },
    MatchParen = { fg = c.highlight, bold = true },
    Pmenu = { fg = c.fg2, bg = c.surface },
    PmenuSel = { fg = c.fg, bg = c.elevated },
    PmenuSbar = { bg = c.surface },
    PmenuThumb = { bg = c.border },
    StatusLine = { fg = c.fg2, bg = c.surface },
    StatusLineNC = { fg = c.muted, bg = c.surface },
    TabLine = { fg = c.fg2, bg = c.surface },
    TabLineSel = { fg = c.fg, bg = c.bg },
    TabLineFill = { bg = c.surface },
    Folded = { fg = c.fg2, bg = c.surface },
    FoldColumn = { fg = c.muted },
    NonText = { fg = c.border },
    Whitespace = { fg = c.border },
    EndOfBuffer = { fg = c.bg },
    Directory = { fg = c.primary },
    Title = { fg = c.fg, bold = true },
    ErrorMsg = { fg = c.error },
    WarningMsg = { fg = c.warning },
    MoreMsg = { fg = c.highlight },
    Question = { fg = c.highlight },
    SpellBad = { sp = c.error, undercurl = true },
    SpellCap = { sp = c.warning, undercurl = true },
    DiffAdd = { bg = blend(c.success, c.bg, 0.15) },
    DiffChange = { bg = c.elevated },
    DiffDelete = { fg = c.error, bg = blend(c.error, c.bg, 0.15) },
    DiffText = { bg = c.border },
  }
end

local function syntax()
  return {
    Comment = { fg = c.muted, italic = true },
    Keyword = { fg = c.primary },
    Statement = { fg = c.primary },
    Conditional = { fg = c.primary },
    Repeat = { fg = c.primary },
    Exception = { fg = c.primary },
    PreProc = { fg = c.primary },
    Include = { fg = c.primary },
    String = { fg = c.secondary },
    Character = { fg = c.secondary },
    Function = { fg = c.highlight },
    Number = { fg = c.info },
    Float = { fg = c.info },
    Boolean = { fg = c.info },
    Constant = { fg = c.info },
    Type = { fg = c.secondary },
    Identifier = { fg = c.fg },
    Operator = { fg = c.fg2 },
    Delimiter = { fg = c.fg2 },
    Special = { fg = c.highlight },
    Todo = { fg = c.bg, bg = c.warning, bold = true },
    Error = { fg = c.error },
    Underlined = { fg = c.primary, underline = true },
    Bold = { fg = c.fg, bold = true },

    ["@variable"] = { fg = c.fg },
    ["@variable.builtin"] = { fg = c.primary, italic = true },
    ["@variable.member"] = { fg = c.fg },
    ["@property"] = { fg = c.fg },
    ["@constructor"] = { fg = c.highlight },
    ["@function.builtin"] = { fg = c.highlight },
    ["@keyword.function"] = { fg = c.primary },
    ["@keyword.return"] = { fg = c.primary },
    ["@module"] = { fg = c.fg },
    ["@punctuation"] = { fg = c.fg2 },
    ["@string.escape"] = { fg = c.highlight },
    ["@tag"] = { fg = c.primary },
    ["@tag.attribute"] = { fg = c.highlight },
    ["@tag.delimiter"] = { fg = c.fg2 },
    ["@markup.heading"] = { fg = c.fg, bold = true },
    ["@markup.link"] = { fg = c.primary, underline = true },
    ["@markup.raw"] = { fg = c.secondary },
    ["@markup.italic"] = { italic = true },
    ["@markup.strong"] = { bold = true },
  }
end

local function diagnostics()
  return {
    DiagnosticError = { fg = c.error },
    DiagnosticWarn = { fg = c.warning },
    DiagnosticInfo = { fg = c.info },
    DiagnosticHint = { fg = c.highlight },
    DiagnosticOk = { fg = c.success },
    DiagnosticVirtualTextError = { fg = c.error, italic = true },
    DiagnosticVirtualTextWarn = { fg = c.warning, italic = true },
    DiagnosticVirtualTextInfo = { fg = c.info, italic = true },
    DiagnosticVirtualTextHint = { fg = c.highlight, italic = true },
    DiagnosticUnderlineError = { sp = c.error, undercurl = true },
    DiagnosticUnderlineWarn = { sp = c.warning, undercurl = true },
    DiagnosticUnderlineInfo = { sp = c.info, undercurl = true },
    DiagnosticUnderlineHint = { sp = c.highlight, undercurl = true },
    LspReferenceText = { bg = c.elevated },
    LspReferenceRead = { bg = c.elevated },
    LspReferenceWrite = { bg = c.elevated, underline = true },
  }
end

local function plugins()
  return {
    GitSignsAdd = { fg = c.success },
    GitSignsChange = { fg = c.warning },
    GitSignsDelete = { fg = c.error },
    SnacksPickerMatch = { fg = c.highlight, bold = true },
    SnacksIndent = { fg = c.surface },
    SnacksIndentScope = { fg = c.border },
    SnacksDashboardHeader = { fg = c.primary },
    WhichKey = { fg = c.highlight },
    WhichKeyGroup = { fg = c.primary },
    WhichKeyDesc = { fg = c.fg },
    WhichKeySeparator = { fg = c.muted },
    BlinkCmpMenu = { link = "Pmenu" },
    BlinkCmpMenuSelection = { link = "PmenuSel" },
    BlinkCmpMenuBorder = { link = "FloatBorder" },
    BlinkCmpLabelMatch = { fg = c.highlight, bold = true },
    BufferLineFill = { bg = c.surface },
    BufferLineBackground = { fg = c.fg2, bg = c.surface },
    BufferLineBufferSelected = { fg = c.fg, bg = c.bg, bold = true },
    BufferLineIndicatorSelected = { fg = c.primary, bg = c.bg },
    NoiceCmdlinePopupBorder = { fg = c.primary },
    FlashLabel = { fg = c.bg, bg = c.highlight, bold = true },
  }
end

local function terminal()
  local ansi = {
    c.surface, c.error, c.success, c.warning, c.primary, c.secondary, c.highlight, c.fg2,
    c.border, c.error, c.success, c.warning, c.primary, c.secondary, c.highlight, c.fg,
  }
  for i, color in ipairs(ansi) do
    vim.g["terminal_color_" .. (i - 1)] = color
  end
end

vim.cmd("highlight clear")
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "stratus"

apply(editor())
apply(syntax())
apply(diagnostics())
apply(plugins())
terminal()
