local M = {}

local buffer_name = "Vim Cheatsheet"
local sidebar_width = 38

local lines = {
    " VIM EDITING CHEATSHEET",
    "",
    " 移動",
    "   h / j / k / l   左 / 下 / 上 / 右",
    "   w / b           次 / 前の単語",
    "   e               単語の末尾",
    "   0 / ^ / $       行頭 / 文字先頭 / 行末",
    "   gg / G          ファイル先頭 / 末尾",
    "   { / }           前 / 次の段落",
    "   %               対応する括弧",
    "   f{文字}         行内の文字へ移動",
    "   * / #           単語を前方 / 後方検索",
    "",
    " 編集",
    "   i / a           前 / 後ろから挿入",
    "   I / A           行頭 / 行末から挿入",
    "   o / O           下 / 上に新しい行",
    "   x               1文字削除",
    "   dd              1行削除",
    "   D               行末まで削除",
    "   yy              1行コピー",
    "   p / P           後ろ / 前へ貼り付け",
    "   u / <C-r>       戻す / やり直す",
    "   .               直前の変更を繰り返す",
    "",
    " 組み合わせ",
    "   d{移動}         範囲を削除",
    "   c{移動}         範囲を変更して挿入",
    "   y{移動}         範囲をコピー",
    "   ciw / diw       単語を変更 / 削除",
    "   ci\" / di(      引用符内変更 / 括弧内削除",
    "   3dd / 2w        回数を指定",
    "",
    " 選択・検索",
    "   v / V / <C-v>   文字 / 行 / 矩形選択",
    "   /{文字列}       前方検索",
    "   n / N           次 / 前の検索結果",
    "   :s/旧/新/g      行内を置換",
    "",
    "   <leader>? で閉じる",
}

---チートシートのバッファを取得または作成します。
---@return integer
local function get_buffer()
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(buffer):match(buffer_name .. "$") then
            return buffer
        end
    end

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buffer, buffer_name)
    vim.bo[buffer].bufhidden = "hide"
    vim.bo[buffer].buftype = "nofile"
    vim.bo[buffer].swapfile = false
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.bo[buffer].modifiable = false
    return buffer
end

---開いているチートシートのウィンドウを探します。
---@param buffer integer
---@return integer?
local function find_window(buffer)
    for _, window in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(window) == buffer then
            return window
        end
    end
end

---右側のVim操作チートシートを開閉します。
function M.toggle()
    local buffer = get_buffer()
    local window = find_window(buffer)

    if window then
        vim.api.nvim_win_close(window, true)
        return
    end

    local width = math.min(sidebar_width, vim.o.columns - 4)
    local height = math.min(#lines, vim.o.lines - 4)

    window = vim.api.nvim_open_win(buffer, false, {
        relative = "editor",
        anchor = "NE",
        row = 1,
        col = vim.o.columns - 2,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = " Vim操作ガイド ",
        title_pos = "center",
        focusable = false,
        zindex = 50,
    })
    vim.wo[window].number = false
    vim.wo[window].relativenumber = false
    vim.wo[window].signcolumn = "no"
    vim.wo[window].foldcolumn = "0"
    vim.wo[window].wrap = false
    vim.wo[window].winblend = 8
    vim.wo[window].winhighlight = table.concat({
        "Normal:NormalFloat",
        "FloatBorder:WhichKeyBorder",
        "FloatTitle:WhichKeyTitle",
    }, ",")
end

vim.api.nvim_create_user_command("VimCheatsheet", M.toggle, {
    desc = "Vim操作のチートシートを開閉します",
})

vim.keymap.set("n", "<leader>?", M.toggle, {
    silent = true,
    desc = "Vim操作のチートシート",
})

return M
