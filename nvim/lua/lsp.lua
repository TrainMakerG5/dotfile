-- Language servers used across the development environments on this machine.
-- Java is started by nvim-jdtls and Dart by flutter-tools.nvim, so enabling
-- jdtls/dartls here as well would create duplicate clients.
vim.lsp.enable({
  "pyright",       -- Python
  "ts_ls",         -- JavaScript / TypeScript
  "sourcekit",     -- Swift
  "lua_ls",        -- Lua
  "rust_analyzer", -- Rust
  "omnisharp",     -- C#
  "phpactor",      -- PHP
  "html",          -- HTML
  "cssls",         -- CSS
  "emmet_ls",      -- HTML/CSS/JSX abbreviations
  "sqls",
})

vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        -- Keep library code (including pandas) indexed and diagnosed.
        autoImportCompletions = true,
        diagnosticMode = "workspace",
        typeCheckingMode = "basic",
        useLibraryCodeForTypes = true,
      },
    },
  },
})
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  float = { border = "rounded" },
})
vim.lsp.config("emmet_ls", {
  cmd = { "emmet-ls", "--stdio" },
  filetypes = {
    "html",
    "css",
    "javascriptreact",
    "typescriptreact",
    "vue",
  },
})
