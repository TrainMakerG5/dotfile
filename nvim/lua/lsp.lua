-- Language servers used across the development environments on this machine.
-- Dart is started by flutter-tools.nvim, so enabling dartls here as well
-- would create a duplicate client.
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
