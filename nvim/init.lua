-- =========================
-- Leader（最優先）
-- =========================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- =========================
-- UI基本
-- =========================
vim.opt.termguicolors = true

-- VSCode NeovimではVSCodeと競合しない専用設定だけを読み込みます。
if vim.g.vscode then
    require("vscode-config")
    return
end

-- =========================
-- lazy.nvimをセットアップします。
-- =========================
local lazypath = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "lazy.nvim")

if not vim.uv.fs_stat(lazypath) then
    if vim.fn.executable("git") ~= 1 then
        error("lazy.nvimを取得できません。GitがPATHにあるか確認してください。")
    end

    local output = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })

    if vim.v.shell_error ~= 0 or not vim.uv.fs_stat(lazypath) then
        error("lazy.nvimの取得に失敗しました。\n" .. output)
    end
end

vim.opt.rtp:prepend(lazypath)

-- =========================
-- プラグイン定義を読み込みます。
-- =========================
require("lazy").setup("plugins", {
    defaults = { lazy = true },
})

-- =========================
-- lazy.nvimの初期化後に独自設定を読み込みます。
-- =========================
require("options")
require("keymaps")
require("autocmds")
require("mycommand")
require("vim_cheatsheet")
require("colorscheme")
require("lsp")

-- Neovideでは背景を半透明にします。
if vim.g.neovide then
    vim.g.neovide_opacity = 0.7
end
