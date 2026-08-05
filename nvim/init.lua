-- =========================
-- Leader（最優先）
-- =========================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- =========================
-- UI基本
-- =========================
vim.opt.termguicolors = true

-- =========================
-- bootstrap lazy.nvim
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
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
require("colorscheme")
require("lsp")

-- Neovide
if vim.g.neovide then
  vim.g.neovide_opacity = 0.7
end
