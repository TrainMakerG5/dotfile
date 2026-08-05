vim.cmd [[
try
  colorscheme nightfox
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
    set background=dark
endtry
]]

-- 背景透過設定（Lua方式）
local highlights = {
  'Normal',
  'NonText',
  'LineNr',
  'SignColumn',
  'EndOfBuffer',
  "highlight",
  --Neotree
  "NeoTreeNormal",
  "NeoTreeNormalNC",
  "NeoTreeCursorLine",
  "NeoTreeIndentMarker",
  "NeoTreeFloatBorder",
}

for _, group in ipairs(highlights) do
  vim.api.nvim_set_hl(0, group, { bg = 'NONE', ctermbg = 'NONE' })
end
