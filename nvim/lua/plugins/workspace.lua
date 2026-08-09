local platform = require("platform")

return {
    -- =========================
    -- 画像・図表表示 (Windowsでは無効化: MSVC/hererocks問題を回避)
    -- =========================
    {
        "3rd/image.nvim",
        cond = platform.image_support,
        -- magick_cli uses the system ImageMagick binary and does not need LuaRocks.
        build = false,
        opts = {
            -- Ghostty supports the Kitty graphics protocol.  Keep both the backend
            -- and processor explicit so Molten does not depend on auto-detection.
            backend = "kitty",
            processor = "magick_cli",
            integrations = {},
            -- Molten のグラフを十分な大きさで表示する
            max_width = 120,
            max_height = 30,
            max_width_window_percentage = math.huge,
            max_height_window_percentage = math.huge,
            window_overlap_clear_enabled = true,
            window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
        },
    },
    {
        "benlubas/molten-nvim",
        dependencies = platform.image_support and { "3rd/image.nvim" } or nil,
        -- Molten is a Python remote plugin. Lazy-loading its commands can remove
        -- the registered command while the kernel-selection prompt is open.
        lazy = false,
        build = ":UpdateRemotePlugins",
        init = function()
            vim.g.molten_auto_open_output = false
            vim.g.molten_output_win_max_height = 30
            -- 出力ウィンドウと画像が本文を覆わないよう、そのぶんの行を確保する
            vim.g.molten_output_virt_lines = true
            vim.g.molten_virt_text_output = true
            vim.g.molten_virt_text_max_lines = 30
            vim.g.molten_image_location = "both"
            -- Herdr does not reliably forward Kitty graphics; use the macOS image viewer there.
            vim.g.molten_auto_image_popup = vim.env.HERDR_ENV == "1"
            -- Windowsではimage.nvimを使わない（未ロードのため）
            if platform.image_support then
                vim.g.molten_image_provider = "image.nvim"
            end
        end,
    },
    {
        "GCBallesteros/NotebookNavigator.nvim",
        dependencies = { "benlubas/molten-nvim" },
        event = "VeryLazy",
        config = function()
            require("notebook-navigator").setup({ repl_provider = "molten" })
        end,
    },
    {
        "sindrets/diffview.nvim",
        cmd = {
            "DiffviewOpen",
            "DiffviewClose",
            "DiffviewFileHistory",
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = "markdown",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            render_modes = { "n", "v", "c", "t" },
            code = {
                disable = { "mermaid" },
            },
            image = {
                enabled = false,
            },
        },
    },
    {
        "shellRaining/hlchunk.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            chunk = {
                enable = true,
            },
            indent = {
                enable = true,
            },
            line_num = {
                enable = true,
            },
            blank = {
                enable = false,
            },
        },
    },
    {
        "stevearc/oil.nvim",
        lazy = false,

        dependencies = {
            "nvim-mini/mini.icons",
        },

        opts = {
            default_file_explorer = true,
            view_options = {
                show_hidden = true,
            },
        },

        keys = {
            { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
        },
    },
    {
        "Bekaboo/dropbar.nvim",
        event = { "LspAttach", "BufReadPost" },
        -- optional, but required for fuzzy finder support
        dependencies = { "nvim-telescope/telescope.nvim" },
        config = function()
            local dropbar_api = require("dropbar.api")
            vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
            vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
            vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
        end,
    },
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        config = function()
            require("dashboard").setup({
                -- config
            })
        end,
        dependencies = { { "nvim-tree/nvim-web-devicons" } },
    },
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        keys = {
            {
                "<leader>qs",
                function()
                    require("persistence").load()
                end,
                desc = "Session restore",
            },
            {
                "<leader>ql",
                function()
                    require("persistence").load({ last = true })
                end,
                desc = "Last session",
            },
            {
                "<leader>qd",
                function()
                    require("persistence").stop()
                end,
                desc = "Stop session save",
            },
        },
        opts = {},
    },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "│" },
                    change = { text = "│" },
                    delete = { text = "_" },
                    topdelete = { text = "‾" },
                    changedelete = { text = "~" },
                },
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns
                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end
                    map("n", "]c", gs.next_hunk, { desc = "Next hunk" })
                    map("n", "[c", gs.prev_hunk, { desc = "Prev hunk" })
                    map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
                    map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
                    map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
                end,
            })
        end,
    },
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer Diagnostics" },
        },
        opts = {},
    },
    {
        "akinsho/flutter-tools.nvim",
        ft = "dart",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("flutter-tools").setup({})
            vim.keymap.set("n", "<leader>cc", function()
                require("telescope").extensions.flutter.commands()
            end, { desc = "Flutter commands" })
            vim.keymap.set("n", "<leader>cr", "<cmd>FlutterReload<CR>", { desc = "Flutter Reload" })
            vim.keymap.set("n", "<leader>cR", "<cmd>FlutterRestart<CR>", { desc = "Flutter Restart" })
        end,
    },
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end,
    },
    {
        "cbochs/grapple.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = "Grapple",
        opts = {
            scope = "git",
            icons = true,
            quick_select = "123456789",
        },
        keys = {
            { "<leader>a", "<cmd>Grapple toggle<CR>", desc = "Pin/unpin current file" },
            { "<leader>A", "<cmd>Grapple toggle_tags<CR>", desc = "Open pinned files" },
            { "<leader>1", "<cmd>Grapple select index=1<CR>", desc = "Pinned file 1" },
            { "<leader>2", "<cmd>Grapple select index=2<CR>", desc = "Pinned file 2" },
            { "<leader>3", "<cmd>Grapple select index=3<CR>", desc = "Pinned file 3" },
            { "<leader>4", "<cmd>Grapple select index=4<CR>", desc = "Pinned file 4" },
            { "]a", "<cmd>Grapple cycle_tags next<CR>", desc = "Next pinned file" },
            { "[a", "<cmd>Grapple cycle_tags prev<CR>", desc = "Previous pinned file" },
        },
    },

    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            keywords = {
                IDEA = {
                    icon = "💡",
                    color = "hint",
                    alt = { "IDEAS" },
                },
                QUESTION = {
                    icon = "?",
                    color = "warning",
                    alt = { "Q" },
                },
                DEBUG = {
                    icon = "",
                    color = "error",
                },
                PERF = {
                    icon = "⚡",
                    color = "info",
                },
                MEMO = {
                    icon = "📝",
                    color = "hint",
                },
            },
        },
        keys = {
            {
                "]t",
                function()
                    require("todo-comments").jump_next()
                end,
                desc = "Next todo comment",
            },
            {
                "[t",
                function()
                    require("todo-comments").jump_prev()
                end,
                desc = "Prev todo comment",
            },
            {
                "<leader>ft",
                "<cmd>TodoTelescope<CR>",
                desc = "Todo (Telescope)",
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {
            max_lines = 3,
            separator = nil,
        },
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "VeryLazy",
        main = "ibl",
        opts = {
            scope = { enabled = true },
            indent = { char = "│" },
        },
        config = function(_, opts)
            local hooks = require("ibl.hooks")

            -- Neovim 0.12 can leave LineNr cleared, so ibl cannot derive its
            -- default IblScope highlight from it. Define it before every setup,
            -- including setups triggered by a colorscheme change.
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "IblScope", { fg = "#719cd6" })
            end)

            require("ibl").setup(opts)
        end,
    },
    {
        "nvim-mini/mini.ai",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("mini.ai").setup({})
        end,
    },
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        config = function()
            require("Comment").setup()
        end,
    },
    {
        "yorickpeterse/nvim-pqf",
        ft = "qf",
        opts = {},
    },
    {
        "mrjones2014/smart-splits.nvim",
        event = "VeryLazy",
        config = function()
            local sm = require("smart-splits")
            -- リサイズ (Alt+hjkl)
            vim.keymap.set("n", "<A-h>", sm.resize_left)
            vim.keymap.set("n", "<A-j>", sm.resize_down)
            vim.keymap.set("n", "<A-k>", sm.resize_up)
            vim.keymap.set("n", "<A-l>", sm.resize_right)
            -- 移動 (Herdrペインとシームレスに連携)
            vim.keymap.set("n", "<C-h>", sm.move_cursor_left)
            vim.keymap.set("n", "<C-j>", sm.move_cursor_down)
            vim.keymap.set("n", "<C-k>", sm.move_cursor_up)
            vim.keymap.set("n", "<C-l>", sm.move_cursor_right)
        end,
    },
    {
        "MagicDuck/grug-far.nvim",
        cmd = "GrugFar",
        opts = {},
        keys = {
            { "<leader>sr", "<cmd>GrugFar<CR>", desc = "Search and Replace" },
        },
    },
    {
        "pwntester/octo.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("octo").setup()
        end,
        cmd = "Octo",
        keys = {
            { "<leader>op", "<cmd>Octo pr list<CR>", desc = "PR一覧" },
            { "<leader>oc", "<cmd>Octo pr create<CR>", desc = "PR作成" },
            { "<leader>oi", "<cmd>Octo issue list<CR>", desc = "Issue一覧" },
            { "<leader>oI", "<cmd>Octo issue create<CR>", desc = "Issue作成" },
            { "<leader>or", "<cmd>Octo review start<CR>", desc = "レビュー開始" },
            { "<leader>os", "<cmd>Octo search<CR>", desc = "検索" },
        },
    },
    {
        "3rd/diagram.nvim",
        cond = platform.image_support,
        ft = "markdown",
        dependencies = {
            "3rd/image.nvim",
        },
        config = function()
            require("diagram").setup({
                integrations = {
                    require("diagram.integrations.markdown"),
                },
                events = {
                    render_buffer = { "InsertLeave", "BufWinEnter" }, -- インサートを抜けたら画像表示
                    clear_buffer = { "InsertEnter", "BufLeave" }, -- インサートに入ったら画像を消す
                },
                renderer_options = {
                    mermaid = {
                        theme = "dark",
                        scale = 2,
                    },
                },
            })
        end,
    },
}
