local M = {}

M.is_windows = vim.fn.has("win32") == 1
M.is_macos = vim.fn.has("macunix") == 1
M.is_wsl = vim.fn.has("wsl") == 1
M.is_linux = vim.fn.has("unix") == 1 and not M.is_macos

M.join = vim.fs.joinpath

---利用可能な実行ファイルを候補順に返します。
---@param candidates string[]
---@return string|nil
function M.executable(candidates)
    for _, candidate in ipairs(candidates) do
        if vim.fn.executable(candidate) == 1 then
            local path = vim.fn.exepath(candidate)
            return path ~= "" and path or candidate
        end
    end

    return nil
end

M.python = M.executable(M.is_windows and { "python", "python3" } or { "python3", "python" })

local home = vim.uv.os_homedir() or vim.fn.expand("~")
M.memo_dir = vim.fn.expand(vim.env.NVIM_MEMO_DIR or M.join(home, "Desktop", "memo"))
M.daily_log_dir = vim.fn.expand(vim.env.NVIM_DAILY_LOG_DIR or M.join(home, "Desktop", "daily_log"))

local has_kitty_graphics = vim.env.KITTY_WINDOW_ID ~= nil
    or vim.env.WEZTERM_PANE ~= nil
    or vim.env.GHOSTTY_RESOURCES_DIR ~= nil
    or vim.env.TERM_PROGRAM == "ghostty"
M.image_support = not M.is_windows
    and M.executable({ "magick" }) ~= nil
    and (not M.is_wsl or has_kitty_graphics)

if M.is_windows then
    M.fzf_build = vim.fn.executable("cmake") == 1
            and "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release"
        or nil
else
    M.fzf_build = vim.fn.executable("make") == 1 and "make" or nil
end

return M
