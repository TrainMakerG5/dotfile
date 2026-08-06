local platform = require("platform")

local memo_dir = platform.memo_dir
local daily_log_dir = platform.daily_log_dir

---指定したファイルを安全に開きます。
---@param path string
local function edit(path)
    vim.cmd.edit(vim.fn.fnameescape(path))
end

---現在のファイルをターミナルで実行します。
---@param command string
---@param args? string[]
---@param stdin_file? string
local function run_in_terminal(command, args, stdin_file)
    if vim.fn.executable(command) == 0 then
        vim.notify(command .. " が見つかりません。PATHを確認してください。", vim.log.levels.ERROR)
        return
    end

    vim.cmd.write()
    vim.cmd.split()

    local argv = { command }
    vim.list_extend(argv, args or {})
    if stdin_file then
        local escaped = vim.tbl_map(vim.fn.shellescape, argv)
        local shell_command = table.concat(escaped, " ") .. " < " .. vim.fn.shellescape(stdin_file)
        vim.fn.termopen(shell_command)
    else
        vim.fn.termopen(argv)
    end
    vim.cmd.startinsert()
end

vim.api.nvim_create_user_command("Memo", function()
    edit(platform.join(memo_dir, "memo.md"))
end, {})

vim.api.nvim_create_user_command("Smemo", function()
    edit(platform.join(memo_dir, "secretmemo.md"))
end, {})

vim.api.nvim_create_user_command("Dmemo", function()
    edit(platform.join(memo_dir, os.date("%Y-%m-%d") .. ".md"))
end, {})

vim.api.nvim_create_user_command("Dlog", function()
    edit(platform.join(daily_log_dir, os.date("%Y-%m-%d") .. ".md"))
end, {})

vim.api.nvim_create_user_command("P", function()
    edit(platform.join(memo_dir, "test.py"))
end, {})

vim.api.nvim_create_user_command("Py", function()
    run_in_terminal(platform.python or "python3", { vim.api.nvim_buf_get_name(0) })
end, {})

vim.api.nvim_create_user_command("W", function()
    vim.cmd.write()
end, {})

vim.api.nvim_create_user_command("Wq", function()
    vim.cmd.wq()
end, {})

vim.api.nvim_create_user_command("Ap", function()
    run_in_terminal(
        platform.python or "python3",
        { vim.api.nvim_buf_get_name(0) },
        platform.join(vim.fn.getcwd(), "test.txt")
    )
end, {})
