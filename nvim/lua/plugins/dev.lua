local platform = require("platform")

return {
    -- =========================
    -- Python環境
    -- =========================
    {
        "linux-cultist/venv-selector.nvim",
        main = "venv-selector",
        ft = "python",
        dependencies = {
            "neovim/nvim-lspconfig",
            "nvim-telescope/telescope.nvim",
        },
        keys = {
            { "<leader>vs", "<cmd>VenvSelect<CR>", desc = "Select Python environment" },
        },
        opts = {
            options = {},
            search = {},
        },
    },

    -- =========================
    -- タスクランナー
    -- =========================
    {
        "is0n/jaq-nvim",
        cmd = { "Jaq" },
        keys = {
            { "<leader>j", "<cmd>Jaq<CR>", desc = "コードを即実行 (jaq)" },
        },
        config = function()
            require("jaq-nvim").setup({
                cmds = {
                    internal = {
                        lua = "luafile %",
                        vim = "source %",
                    },
                    external = {
                        python = vim.fn.shellescape(platform.python or "python3") .. " %",
                        javascript = "node %",
                        sh = "sh %",
                    },
                },
                behavior = {
                    default = "float",
                    startinsert = false,
                    wincmd = false,
                    autosave = false,
                },
                ui = {
                    float = {
                        border = "rounded", -- 診断などの他のフロート表示と揃えます。
                        winhl = "Normal",
                        borderhl = "FloatBorder",
                        winblend = 0,
                        height = 0.8,
                        width = 0.8,
                        x = 0.5,
                        y = 0.5,
                    },
                    terminal = { position = "bot", size = 10, line_no = false },
                    quickfix = { position = "bot", size = 10 },
                },
            })
        end,
    },

    -- =========================
    -- LSP UI強化
    -- =========================
    {
        "nvimdev/lspsaga.nvim",
        event = "LspAttach",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            symbol_in_winbar = { enable = false },
            ui = { border = "rounded", title = false }, -- 他のフロート表示と揃えます。
            lightbulb = { enable = false },
        },
        keys = {
            { "K", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover Doc" },
            { "<leader>lf", "<cmd>Lspsaga finder<CR>", desc = "LSP Finder" },
            { "<leader>lr", "<cmd>Lspsaga rename<CR>", desc = "Rename" },
            { "<leader>la", "<cmd>Lspsaga code_action<CR>", desc = "Code Action" },
            { "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", desc = "Line Diagnostics" },
            { "<leader>lp", "<cmd>Lspsaga peek_definition<CR>", desc = "Peek Definition" },
            { "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Prev Diagnostic" },
            { "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Next Diagnostic" },
        },
    },
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim", -- 差分表示をDiffviewと統合します。
            "nvim-telescope/telescope.nvim", -- ブランチ選択などをTelescopeで表示します。
        },
        cmd = "Neogit",
        keys = {
            { "<leader>gg", "<cmd>Neogit<CR>", desc = "Neogit (Git Status)" },
            { "<leader>gc", "<cmd>Neogit commit<CR>", desc = "Neogit Commit" },
            { "<leader>gp", "<cmd>Neogit push<CR>", desc = "Neogit Push" },
        },
        config = function()
            require("neogit").setup({
                integrations = {
                    diffview = true, -- diffview.nvimと統合します。
                    telescope = true,
                },
            })
        end,
    },
}
