local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand
local general = augroup("GeneralSettings", { clear = true })
local platform = require("platform")

-- Don't auto commenting new lines
autocmd("BufEnter", {
    group = general,
    pattern = "*",
    command = "set fo-=c fo-=r fo-=o",
})

-- Restore cursor location when file is opened
autocmd({ "BufReadPost" }, {
    group = general,
    pattern = { "*" },
    callback = function()
        vim.api.nvim_exec('silent! normal! g`"zv', false)
    end,
})
-- Octoのバッファは q でも閉じられるようにする (デフォルトではqに何も割り当てられておらず、
-- 押しても閉じずにバッファがbarbarのタブに残り続けてしまうため)
autocmd("FileType", {
    group = general,
    pattern = { "octo", "octo_panel" },
    callback = function()
        vim.keymap.set("n", "q", ":bdelete<CR>", { buffer = true, silent = true })
    end,
})

-- Briefly highlight copied text.
autocmd("TextYankPost", {
    group = general,
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
})

-- Reload files changed by formatters or Git outside Neovim.
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = general,
    command = "checktime",
})

-- Keep utility buffers visually quiet and easy to close.
autocmd("FileType", {
    group = general,
    pattern = { "help", "qf", "checkhealth", "man" },
    callback = function(args)
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true })
    end,
})

-- Avoid swap/undo overhead when opening very large files.
autocmd("BufReadPre", {
    group = general,
    callback = function(args)
        local ok, stat = pcall(vim.uv.fs_stat, args.file)
        if ok and stat and stat.size > 2 * 1024 * 1024 then
            vim.b[args.buf].large_file = true
            vim.bo[args.buf].swapfile = false
            vim.bo[args.buf].undofile = false
            vim.bo[args.buf].syntax = ""
            vim.notify("Large file mode: expensive buffer features were reduced")
        end
    end,
})

autocmd("LspAttach", {
    group = general,
    callback = function(args)
        local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
        end

        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gr", vim.lsp.buf.references, "References")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("<leader>li", function()
            if vim.lsp.inlay_hint then
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
            end
        end, "Toggle inlay hints")
    end,
})
local function git(cwd, args)
    local command = { "git" }
    vim.list_extend(command, args)
    return vim.system(command, { cwd = cwd, text = true }):wait()
end

local function commit_and_push(opts)
    local cwd = vim.fn.expand(opts.cwd)
    local pathspec = opts.all and "." or vim.api.nvim_buf_get_name(0)
    local status = git(cwd, { "status", "--porcelain", "--", pathspec })

    if status.code ~= 0 then
        vim.notify(vim.trim(status.stderr), vim.log.levels.ERROR)
        return
    end
    if status.stdout == "" then
        vim.notify("変更はありません")
        return
    end
    if vim.fn.confirm("変更を commit して GitHub に push しますか？", "&Yes\n&No", 2) ~= 1 then
        return
    end

    local message = opts.message
    if not message then
        message = vim.fn.input("Commit message: ")
        if message == "" then
            message = "Auto-update memo"
        end
    end

    for _, step in ipairs({
        { "add", "--", pathspec },
        { "commit", "-m", message },
    }) do
        local result = git(cwd, step)
        if result.code ~= 0 then
            vim.notify(vim.trim(result.stderr ~= "" and result.stderr or result.stdout), vim.log.levels.ERROR)
            return
        end
    end

    local branch = git(cwd, { "branch", "--show-current" })
    if branch.code ~= 0 or vim.trim(branch.stdout) == "" then
        vim.notify("現在のブランチを取得できません", vim.log.levels.ERROR)
        return
    end

    local pushed = git(cwd, { "push", "origin", vim.trim(branch.stdout) })
    if pushed.code ~= 0 then
        vim.notify(vim.trim(pushed.stderr), vim.log.levels.ERROR)
        return
    end
    vim.notify("Committed and pushed: " .. cwd)
end

vim.api.nvim_create_user_command("MemoPush", function()
    commit_and_push({ cwd = platform.memo_dir })
end, { desc = "Commit and push the current memo" })

vim.api.nvim_create_user_command("DailyPush", function()
    commit_and_push({
        cwd = platform.daily_log_dir,
        all = true,
        message = os.date("%Y-%m-%d") .. "の日記",
    })
end, { desc = "Commit and push daily logs" })
