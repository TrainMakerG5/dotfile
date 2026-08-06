local platform = require("platform")

return {
  -- =========================
  -- Utility
  -- =========================
  {
    "nvim-lua/plenary.nvim",
  },

  -- =========================
  -- Colorscheme
  -- =========================
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
  },

  -- =========================
  -- UI
  -- =========================
  { "nvim-tree/nvim-web-devicons" },
  {
    "stevearc/dressing.nvim",
    lazy = false,
    opts = {},
  },
  {
    "sphamba/smear-cursor.nvim",
    lazy = false,
    opts = {},
  },
  -- =========================
  -- Telescope
  -- =========================
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- optional but recommended
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        cond = platform.fzf_build ~= nil,
        build = platform.fzf_build,
      },
    }
  },
  -- =========================
  -- Treesitter
  -- =========================
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
  },
  { "windwp/nvim-ts-autotag",     event = { "BufReadPost", "BufNewFile" } },

  -- =========================
  -- Auto pairs
  -- =========================
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- =========================
  -- Completion (nvim-cmp)
  -- =========================
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      require("cmp-config")
    end,
  },
  { "hrsh7th/cmp-cmdline", event = "CmdlineEnter" },

  -- =========================
  -- LSP core
  -- =========================
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
      vim.lsp.config("marksman", {
        cmd = { "marksman" },
        filetypes = { "markdown" },
      })
      vim.lsp.enable("marksman")

      -- Individual servers are configured and enabled in lua/lsp.lua.
    end,
  },
  {
    "j-hui/fidget.nvim",
    version = "*",
    event = "LspAttach",
    opts = {},
  },

  -- =========================
  -- Mason (installer)
  -- =========================
  {
    "williamboman/mason.nvim",
    -- Mason prepends its bin directory to PATH. Loading it only on :Mason
    -- leaves every Mason-managed LSP "not executable" during normal editing.
    lazy = false,
    config = true,
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
  },


  -- =========================
  -- Markdown preview
  -- =========================
  {
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    config = true,
  },

  -- =========================
  -- Color highlight
  -- =========================
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- ========================
  -- format
  -- ========================
  {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        desc = "Format buffer",
      },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_format" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          markdown = { "prettier" },
        },
      })
    end,
  },
  {
    'romgrk/barbar.nvim',
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      'lewis6991/gitsigns.nvim',     -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
      -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
      -- animation = true,
      -- insert_at_start = true,
      -- …etc.
    },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          section_separators = "",
          component_separators = "",
        },
        sections = {
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
        },
      })
    end,
  },
  {
    "Wansmer/treesj",
    keys = {
      { "<leader>cj", "<cmd>TSJToggle<CR>", desc = "Toggle split/join" },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesj").setup({
        use_default_keymaps = false,
        check_syntax_error = false,
      })
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = { { "<c-\\>", desc = "Toggle terminal" } },
    opts = {
      direction = "float",
      open_mapping = [[<c-\>]],
      start_in_insert = true,
      shade_terminals = true,

      float_opts = {
        border = "curved",
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")

      wk.add({
        { "<leader>f", group = "検索" },
        { "<leader>c", group = "コード" },
        { "<leader>l", group = "LSP" },
        { "<leader>g", group = "Git" },
        { "<leader>t", group = "ターミナル" },
        { "<leader>m", group = "Markdown" },
        { "<leader>n", group = "Notebook" },
        { "<leader>h", group = "Git Hunk" },
        { "<leader>x", group = "診断" },
        { "<leader>s", group = "検索・置換" },
        { "<leader>q", group = "セッション" },
        { "<leader>o", group = "Octo (GitHub)" },
        { "<leader>v", group = "Python環境" },
      })
    end,
  },

}
