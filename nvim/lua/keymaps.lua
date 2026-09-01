local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

local keymap = vim.api.nvim_set_keymap

-- Telescopeの検索機能を呼び出します。
vim.keymap.set("n", "<leader>ff", function()
    require("telescope.builtin").find_files()
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function()
    require("telescope.builtin").live_grep()
end, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", function()
    require("telescope.builtin").buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", function()
    require("telescope.builtin").help_tags()
end, { desc = "Help tags" })
-- SpaceをLeaderキーにします。
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 新しいタブを開きます。
keymap("n", "te", ":tabedit", opts)

-- 新しいタブを一番右に作ります。
keymap("n", "gn", ":tabnew<Return>", opts)

-- 前後のバッファへ移動します。
keymap("n", "<Tab>", ":bnext<CR>", { silent = true })
keymap("n", "<S-Tab>", ":bprev<CR>", { silent = true })
-- Vimのタブを閉じます。
keymap("n", "<leader>bt", ":tabclose<CR>", opts)
-- バッファ（上に並ぶタブ）を閉じます。
keymap("n", "<leader>bd", ":bdelete<CR>", opts)
keymap("n", "<Space>l", "$", opts)

-- Escで現在の検索ハイライトだけを消します。
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)

-- 選択範囲を維持したままインデントします。
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- VS Codeなどと同じ操作でバッファ全体を選択します。
vim.keymap.set("n", "<C-a>", "ggVG", { silent = true, desc = "Select all" })
vim.keymap.set({ "i", "x" }, "<C-a>", "<Esc>ggVG", { silent = true, desc = "Select all" })

-- Oilを現在の場所で開きます。
keymap("n", "<leader>e", ":Oil<Return>", opts)

-- MoltenのNotebook操作を定義します。
vim.keymap.set("n", "<leader>ni", function()
    vim.cmd("MoltenInit " .. (vim.env.NVIM_PYTHON_KERNEL or "python3"))
end, { desc = "Notebook init" })

-- カーソル位置の`# %%`セル全体を実行します。
vim.keymap.set("n", "<leader>nr", function()
    require("notebook-navigator").run_cell()
end, { desc = "Run cell" })

-- 選択範囲のセルを、それぞれ独立したMolten出力として実行します。
vim.keymap.set("x", "<leader>nr", function()
    local notebook = require("notebook-navigator")
    local first_line = math.min(vim.fn.line("v"), vim.fn.line("."))
    local last_line = math.max(vim.fn.line("v"), vim.fn.line("."))
    local original_cursor = vim.api.nvim_win_get_cursor(0)

    vim.api.nvim_win_set_cursor(0, { first_line, 0 })

    while true do
        notebook.run_cell()

        if notebook.move_cell("d") == "last" then
            break
        end

        if vim.api.nvim_win_get_cursor(0)[1] > last_line then
            break
        end
    end

    vim.api.nvim_win_set_cursor(0, original_cursor)
end, { desc = "Run selected cells" })

-- セルを実行して次のセルへ移動します。
vim.keymap.set("n", "<leader>nx", function()
    require("notebook-navigator").run_and_move()
end, { desc = "Run cell and move" })

-- 前後のセルへ移動します。
vim.keymap.set("n", "]n", function()
    require("notebook-navigator").move_cell("d")
end, { desc = "Next cell" })
vim.keymap.set("n", "[n", function()
    require("notebook-navigator").move_cell("u")
end, { desc = "Prev cell" })

-- 現在行または選択範囲をMoltenで評価します。
vim.keymap.set("n", "<leader>nl", ":MoltenEvaluateLine<CR>", { desc = "Evaluate line" })
vim.keymap.set("v", "<leader>nv", ":<C-u>MoltenEvaluateVisual<CR>", { desc = "Evaluate selection" })

-- 現在のセルを再実行します。
vim.keymap.set("n", "<leader>nR", ":MoltenReevaluateCell<CR>", { desc = "Re-evaluate cell" })

-- Moltenの出力ウィンドウへ入り、j/kやマウスでスクロールします。
vim.keymap.set("n", "<leader>no", "<cmd>noautocmd MoltenEnterOutput<CR>", { desc = "Open/scroll output" })
vim.keymap.set("n", "<leader>np", "<cmd>MoltenImagePopup<CR>", { desc = "Open output image" })
vim.keymap.set("n", "<leader>nh", "<cmd>MoltenHideOutput<CR>", { desc = "Hide output" })
vim.keymap.set("n", "<leader>nd", "<cmd>MoltenDelete!<CR>", { desc = "Delete all outputs" })

-- 現在位置の診断を表示します。
vim.keymap.set("n", "<leader>er", vim.diagnostic.open_float, { desc = "Show diagnostic" })
