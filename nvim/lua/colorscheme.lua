vim.cmd([[
try
  colorscheme nightfox
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
    set background=dark
endtry
]])

-- 主要なハイライトグループの背景を透過させます。
local highlights = {
    "Normal",
    "NonText",
    "LineNr",
    "SignColumn",
    "EndOfBuffer",
    "highlight",
    -- Neo-treeの背景も同じように透過させます。
    "NeoTreeNormal",
    "NeoTreeNormalNC",
    "NeoTreeCursorLine",
    "NeoTreeIndentMarker",
    "NeoTreeFloatBorder",
}

for _, group in ipairs(highlights) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
end
