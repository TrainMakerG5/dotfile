return {
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
            python = "python3 %",
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
            border = "rounded", -- 他のfloat(診断等)と統一
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
  -- デバッガ (DAP)
  -- =========================
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
      },
      "mfussenegger/nvim-dap-python",
    },
    keys = {
      { "<leader>dc", function() require("dap").continue() end,          desc = "Continue" },
      { "<leader>do", function() require("dap").step_over() end,         desc = "Step Over" },
      { "<leader>di", function() require("dap").step_into() end,         desc = "Step Into" },
      { "<leader>dO", function() require("dap").step_out() end,          desc = "Step Out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Breakpoint Toggle" },
      {
        "<leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
        desc = "Conditional Breakpoint",
      },
      {
        "<leader>dl",
        function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end,
        desc = "Log Point",
      },
      { "<leader>du", function() require("dapui").toggle() end, desc = "DAP UI Toggle" },
      { "<leader>de", function() require("dapui").eval() end,   desc = "DAP Eval",     mode = { "n", "v" } },
    },
    config = function()
      require("mydap")
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    event = "VeryLazy",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      enabled = true,

      -- 変更された値だけ表示
      highlight_changed_variables = true,

      -- 新しい値を強調
      highlight_new_as_changed = false,

      -- 停止中だけ表示
      all_references = false,

      -- コメント風の表示
      commented = true,

      -- 実行位置だけ表示
      virt_text_pos = "eol",
    },
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
      ui = { border = "rounded", title = false }, -- 他のfloatと統一
      lightbulb = { enable = false },
    },
    keys = {
      { "K",         "<cmd>Lspsaga hover_doc<CR>",             desc = "Hover Doc" },
      { "<leader>lf", "<cmd>Lspsaga finder<CR>",                desc = "LSP Finder" },
      { "<leader>lr", "<cmd>Lspsaga rename<CR>",                desc = "Rename" },
      { "<leader>la", "<cmd>Lspsaga code_action<CR>",           desc = "Code Action" },
      { "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", desc = "Line Diagnostics" },
      { "<leader>lp", "<cmd>Lspsaga peek_definition<CR>",       desc = "Peek Definition" },
      { "[d",         "<cmd>Lspsaga diagnostic_jump_prev<CR>",  desc = "Prev Diagnostic" },
      { "]d",         "<cmd>Lspsaga diagnostic_jump_next<CR>",  desc = "Next Diagnostic" },
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",        -- 既に導入済み。差分表示が統合される
      "nvim-telescope/telescope.nvim", -- 既に導入済み。ブランチ選択等がTelescopeで出る
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>",        desc = "Neogit (Git Status)" },
      { "<leader>gc", "<cmd>Neogit commit<CR>", desc = "Neogit Commit" },
      { "<leader>gp", "<cmd>Neogit push<CR>",   desc = "Neogit Push" },
    },
    config = function()
      require("neogit").setup({
        integrations = {
          diffview = true, -- 既存のdiffview.nvimと統合
          telescope = true,
        },
      })
    end,
  },
}
