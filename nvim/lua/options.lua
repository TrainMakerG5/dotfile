local platform = require("platform")

-- WSLではWindows側のクリップボードへ直接接続します。
if platform.is_wsl
    and vim.fn.executable("clip.exe") == 1
    and vim.fn.executable("powershell.exe") == 1
then
    local paste_command = {
        "powershell.exe",
        "-NoLogo",
        "-NoProfile",
        "-Command",
        '[Console]::Out.Write((Get-Clipboard -Raw).ToString().Replace("`r", ""))',
    }
    vim.g.clipboard = {
        name = "WslClipboard",
        copy = {
            ["+"] = { "clip.exe" },
            ["*"] = { "clip.exe" },
        },
        paste = {
            ["+"] = paste_command,
            ["*"] = paste_command,
        },
        cache_enabled = 0,
    }
end

local options = {
  encoding = "utf-8",
  fileencoding = "utf-8",
  title = true,
  backup = false,
  clipboard = "unnamedplus",
  cmdheight = 1,
  completeopt = { "menuone", "noselect" },
  conceallevel = 0,
  hlsearch = true,
  ignorecase = true,
  mouse = "a",
  pumheight = 10,
  showmode = false,
  showtabline = 2,
  smartcase = true,
  smartindent = true,
  breakindent = true,
  linebreak = true,
  swapfile = true,
  termguicolors = true,
  timeoutlen = 300,
  undofile = true,
  updatetime = 300,
  writebackup = false,
  expandtab = true,
  shiftwidth = 2,
  tabstop = 2,
  cursorline = true,
  number = true,
  relativenumber = false,
  numberwidth = 4,
  confirm = true,
  inccommand = "split",
  laststatus = 3,
  smoothscroll = true,
  splitkeep = "screen",
  virtualedit = "block",
  signcolumn = "yes",
  wrap = true,
  winblend = 0,
  wildoptions = "pum",
  pumblend = 5,
  background = "dark",
  scrolloff = 8,
  sidescrolloff = 8,
  splitbelow = true, -- オンのとき、ウィンドウを横分割すると新しいウィンドウはカレントウィンドウの下に開かれる
  splitright = true, -- オのとき、ウィンドウを縦分割すると新しいウィンドウはカレントウィンドウの右に開かれる
}

vim.opt.shortmess:append("c")

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- Unix系ではzshがある場合だけ利用し、WindowsではNeovimの既定シェルを維持します。
if vim.fn.has("win32") == 0 and vim.fn.executable("zsh") == 1 then
  vim.opt.shell = vim.fn.exepath("zsh")
end

vim.cmd([[set iskeyword+=-]])
vim.cmd([[set formatoptions-=cro]]) -- TODO: this doesn't seem to work
