-- このマシンの開発環境で使う言語サーバーを有効にします。
-- Dartはflutter-tools.nvimが起動するため、重複を避けてここではdartlsを有効にしません。
vim.lsp.enable({
    "pyright", -- Python
    "ts_ls", -- JavaScript / TypeScript
    "lua_ls", -- Lua
    "omnisharp", -- C#
    "html", -- HTML
    "cssls", -- CSS
    "emmet_ls", -- HTML/CSS/JSX abbreviations
})

vim.lsp.config("pyright", {
    settings = {
        python = {
            analysis = {
                -- pandasなどのライブラリコードもインデックスと診断の対象にします。
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
