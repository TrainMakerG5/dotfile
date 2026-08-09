local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

--local keymap = vim.keymap
local keymap = vim.api.nvim_set_keymap
-- Telescope
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
--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = 'n',
--   insert_mode = 'i',
--   visual_mode = 'v',
--   visual_block_mode = 'x',
--   term_mode = 't',
--   command_mode = 'c',

-- Brtter window navigation (smart-splits.nvimに移行、plugins.luaで定義)

-- New tab
keymap("n", "te", ":tabedit", opts)

-- 新しいタブを一番右に作る
keymap("n", "gn", ":tabnew<Return>", opts)

-- move tab
keymap("n", "<Tab>", ":bnext<CR>", { silent = true })
keymap("n", "<S-Tab>", ":bprev<CR>", { silent = true })
-- Vimのタブを閉じる
keymap("n", "<leader>bt", ":tabclose<CR>", opts)
-- バッファ（上に並ぶタブ)を閉じる
keymap("n", "<leader>bd", ":bdelete<CR>", opts)
keymap("n", "<Space>l", "$", opts)

-- ESC でハイライトやめる
keymap("n", "<Esc>", ":<C-u>set nohlsearch<Return>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Oilを使いやすくした
keymap("n", "<leader>e", ":Oil<Return>", opts)

-- Molten
vim.keymap.set("n", "<leader>ni", function()
    vim.cmd("MoltenInit " .. (vim.env.NVIM_PYTHON_KERNEL or "python3"))
end, { desc = "Notebook init" })

-- セル実行(カーソル位置の # %% セルをまるごと実行)
vim.keymap.set("n", "<leader>nr", function()
    require("notebook-navigator").run_cell()
end, { desc = "Run cell" })

-- 選択範囲に含まれるセルを、それぞれ独立したMolten出力として実行
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

-- セル実行して次のセルへ移動
vim.keymap.set("n", "<leader>nx", function()
    require("notebook-navigator").run_and_move()
end, { desc = "Run cell and move" })

-- セル間移動
vim.keymap.set("n", "]n", function()
    require("notebook-navigator").move_cell("d")
end, { desc = "Next cell" })
vim.keymap.set("n", "[n", function()
    require("notebook-navigator").move_cell("u")
end, { desc = "Prev cell" })

-- 行・選択範囲はそのままMoltenでOK
vim.keymap.set("n", "<leader>nl", ":MoltenEvaluateLine<CR>", { desc = "Evaluate line" })
vim.keymap.set("v", "<leader>nv", ":<C-u>MoltenEvaluateVisual<CR>", { desc = "Evaluate selection" })

-- 再実行
vim.keymap.set("n", "<leader>nR", ":MoltenReevaluateCell<CR>", { desc = "Re-evaluate cell" })

-- Moltenの出力ウィンドウに入り、j/kやマウスでスクロールする
vim.keymap.set("n", "<leader>no", "<cmd>noautocmd MoltenEnterOutput<CR>", { desc = "Open/scroll output" })
vim.keymap.set("n", "<leader>np", "<cmd>MoltenImagePopup<CR>", { desc = "Open output image" })
vim.keymap.set("n", "<leader>nh", "<cmd>MoltenHideOutput<CR>", { desc = "Hide output" })
vim.keymap.set("n", "<leader>nd", "<cmd>MoltenDelete!<CR>", { desc = "Delete all outputs" })

-- エラーの確認
vim.keymap.set("n", "<leader>er", vim.diagnostic.open_float, { desc = "Show diagnostic" })
