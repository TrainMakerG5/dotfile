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
-- bootstrap lazy.nvim
-- =========================
local lazypath = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "lazy.nvim")

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- =========================
-- core plugin loader
-- =========================
require("lazy").setup("plugins", {
  defaults = { lazy = true },
})

-- =========================
-- 自前設定（lazyの後）
-- =========================
require("options")
require("keymaps")
require("autocmds")
require("mycommand")
require("vim_cheatsheet")
require("colorscheme")
require("lsp")

-- Neovide
if vim.g.neovide then
  vim.g.neovide_opacity = 0.7
end
