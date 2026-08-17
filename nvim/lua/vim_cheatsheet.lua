local M = {}
local cheatsheet = require("vim_cheatsheet_data")

local buffer_name = "Vim Cheatsheet"
local column_gap = 2

---@param lines string[]
---@return integer
local function display_width(lines)
    local width = 1
    for _, line in ipairs(lines) do
        width = math.max(width, vim.fn.strdisplaywidth(line))
    end
    return width
end

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
    vim.keymap.set("n", "q", function()
        local window = vim.fn.bufwinid(buffer)
        if window ~= -1 then
            vim.api.nvim_win_close(window, true)
        end
    end, { buffer = buffer, silent = true, desc = "チートシートを閉じます" })
    return buffer
end

---@param buffer integer
---@param lines string[]
local function set_lines(buffer, lines)
    vim.bo[buffer].modifiable = true
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.bo[buffer].modifiable = false
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

    local available_width = math.max(1, vim.o.columns - 4)
    local available_height = math.max(1, vim.o.lines - 4)
    local lines = cheatsheet.to_lines()
    local column_width = display_width(lines)

    if #lines > available_height and available_width >= (column_width * 2) + column_gap then
        lines = cheatsheet.to_two_column_lines(column_width)
    end

    set_lines(buffer, lines)
    local content_width = display_width(lines)
    local width = math.min(content_width, available_width)
    local height = math.min(#lines, available_height)
    local needs_scroll = #lines > available_height

    window = vim.api.nvim_open_win(buffer, needs_scroll, {
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
        focusable = true,
        zindex = 50,
    })
    vim.wo[window].number = false
    vim.wo[window].relativenumber = false
    vim.wo[window].signcolumn = "no"
    vim.wo[window].foldcolumn = "0"
    vim.wo[window].wrap = content_width > available_width
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
