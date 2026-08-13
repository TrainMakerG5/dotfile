local M = {}

-- この一覧を編集すると、Neovim版とVSCode版の両方へ反映されます。
M.sections = {
    {
        title = "移動",
        items = {
            { "h j k l", "左・下・上・右" },
            { "w / b", "次・前の単語" },
            { "e", "単語の末尾" },
            { "0 ^ $", "行頭・文字先頭・行末" },
            { "gg / G", "ファイル先頭・末尾" },
            { "{ / }", "前・次の段落" },
            { "%", "対応する括弧" },
            { "f{文字}", "行内の文字へ移動" },
            { "* / #", "単語を前方・後方検索" },
        },
    },
    {
        title = "編集",
        items = {
            { "i / a", "前・後ろから挿入" },
            { "I / A", "行頭・行末から挿入" },
            { "o / O", "下・上に新しい行" },
            { "x", "1文字削除" },
            { "dd / D", "1行・行末まで削除" },
            { "yy", "1行コピー" },
            { "p / P", "後ろ・前へ貼り付け" },
            { "u / <C-r>", "戻す・やり直す" },
            { ".", "直前の変更を繰り返す" },
        },
    },
    {
        title = "組み合わせ",
        items = {
            { "d{移動}", "範囲を削除" },
            { "c{移動}", "範囲を変更して挿入" },
            { "y{移動}", "範囲をコピー" },
            { "ciw / diw", "単語を変更・削除" },
            { 'ci" / di(', "引用符内変更・括弧内削除" },
            { "3dd / 2w", "回数を指定" },
        },
    },
    {
        title = "選択・検索",
        items = {
            { "v / V", "文字・行選択" },
            { "<C-v>", "矩形選択" },
            { "/{文字列}", "前方検索" },
            { "n / N", "次・前の検索結果" },
            { ":s/旧/新/g", "行内を置換" },
        },
    },
    {
        title = "ファイル全体",
        items = {
            { "ggVG", "全範囲を選択" },
            { "ggyG", "全範囲をコピー" },
            { "ggdG", "全範囲を削除" },
            { 'gg"+yG', "全範囲をクリップボードへコピー" },
            { ":%y / :%d", "全行をコピー・削除" },
        },
    },
}

---端末表示用の行一覧を生成します。
---@return string[]
function M.to_lines()
    local lines = { " VIM EDITING CHEATSHEET", "" }

    for _, section in ipairs(M.sections) do
        table.insert(lines, " " .. section.title)
        for _, item in ipairs(section.items) do
            local padding = string.rep(" ", math.max(1, 16 - vim.fn.strdisplaywidth(item[1])))
            table.insert(lines, "   " .. item[1] .. padding .. item[2])
        end
        table.insert(lines, "")
    end

    table.insert(lines, "   <leader>? で閉じる")
    return lines
end

---HTMLで特別な意味を持つ文字をエスケープします。
---@param value string
---@return string
local function escape_html(value)
    return value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
end

---VSCode Webview用のHTMLを生成します。
---@return string
function M.to_html()
    local cards = {}

    for _, section in ipairs(M.sections) do
        local entries = {}
        for _, item in ipairs(section.items) do
            table.insert(entries, "<dt>" .. escape_html(item[1]) .. "</dt><dd>" .. escape_html(item[2]) .. "</dd>")
        end
        table.insert(
            cards,
            "<section><h2>" .. escape_html(section.title) .. "</h2><dl>" .. table.concat(entries) .. "</dl></section>"
        )
    end

    return [[<!DOCTYPE html><html lang="ja"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0"><style>
:root{color-scheme:light dark}*{box-sizing:border-box}body{margin:0;padding:22px;color:var(--vscode-foreground);background:var(--vscode-editor-background);font-family:var(--vscode-font-family)}
.guide{max-width:620px;margin:auto;overflow:hidden;border:1px solid var(--vscode-widget-border);border-radius:14px;background:var(--vscode-sideBar-background);box-shadow:0 10px 28px #0003}
header{padding:18px 20px;border-bottom:1px solid var(--vscode-widget-border);background:linear-gradient(135deg,var(--vscode-editorSuggestWidget-background),var(--vscode-sideBar-background))}
h1{margin:0;color:var(--vscode-textLink-foreground);font-size:18px;letter-spacing:.04em}.hint{margin:6px 0 0;color:var(--vscode-descriptionForeground);font-size:12px}
main{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:12px;padding:14px}section{padding:14px;border:1px solid var(--vscode-widget-border);border-radius:10px;background:var(--vscode-editorWidget-background)}
h2{margin:0 0 10px;color:var(--vscode-symbolIcon-keywordForeground);font-size:14px}dl{display:grid;grid-template-columns:max-content 1fr;gap:8px 12px;margin:0;align-items:baseline}dt,dd{margin:0}dt{color:var(--vscode-terminal-ansiCyan);font-family:var(--vscode-editor-font-family);font-weight:700;white-space:nowrap}dd{color:var(--vscode-descriptionForeground);font-size:12px}
kbd{padding:2px 6px;border:1px solid var(--vscode-keybindingLabel-border);border-bottom-width:2px;border-radius:5px;color:var(--vscode-keybindingLabel-foreground);background:var(--vscode-keybindingLabel-background);font-family:var(--vscode-editor-font-family)}
</style></head><body><article class="guide"><header><h1>Vim Editing Guide</h1><p class="hint"><kbd>Space</kbd> <kbd>?</kbd> でもう一度押すと閉じます</p></header><main>]] .. table.concat(
        cards
    ) .. "</main></article></body></html>"
end

return M
