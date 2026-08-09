local M = {}
local cheatsheet = require("vim_cheatsheet_data")

local buffer_name = "Vim Cheatsheet"
local sidebar_width = 38

local lines = cheatsheet.to_lines()

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
