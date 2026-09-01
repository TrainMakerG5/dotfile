local vscode = require("vscode")
local cheatsheet = require("vim_cheatsheet_data")

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.timeoutlen = 300

-- WSLを含め、VSCodeのクリップボードを利用します。
if vim.g.vscode_clipboard then
    vim.g.clipboard = vim.g.vscode_clipboard
end

---@param command string
---@return function
local function action(command)
    return function()
        vscode.action(command)
    end
end

---@param mode string|string[]
---@param lhs string
---@param command string
---@param description string
local function map(mode, lhs, command, description)
    vim.keymap.set(mode, lhs, action(command), {
        silent = true,
        desc = description,
    })
end

-- VSCodeの検索・ファイル操作へ接続します。
map("n", "<leader>ff", "workbench.action.quickOpen", "Find files")
map("n", "<leader>fg", "workbench.action.findInFiles", "Find in files")
map("n", "<leader>fb", "workbench.action.showAllEditors", "Open editors")
map("n", "<leader>e", "workbench.view.explorer", "Explorer")
map("n", "<leader>bd", "workbench.action.closeActiveEditor", "Close editor")
map("n", "<leader>tt", "workbench.action.terminal.toggleTerminal", "Toggle terminal")
map({ "n", "i", "x" }, "<C-a>", "editor.action.selectAll", "Select all")

---VSCode右側のVim操作ガイドを開閉します。
local function toggle_vim_cheatsheet()
    vscode.eval_async(
        [[
        const panelKey = "__vscodeNeovimCheatsheet";
        const currentPanel = globalThis[panelKey];

        if (currentPanel) {
            currentPanel.dispose();
            globalThis[panelKey] = undefined;
            return;
        }

        const panel = vscode.window.createWebviewPanel(
            "vimCheatsheet",
            "Vim操作ガイド",
            {
                viewColumn: vscode.ViewColumn.Beside,
                preserveFocus: true,
            },
            {
                enableScripts: false,
                retainContextWhenHidden: true,
            },
        );

        globalThis[panelKey] = panel;
        panel.onDidDispose(() => {
            if (globalThis[panelKey] === panel) {
                globalThis[panelKey] = undefined;
            }
        });
        panel.webview.html = args.html;
    ]],
        {
            args = { html = cheatsheet.to_html() },
        }
    )
end

vim.keymap.set("n", "<leader>?", toggle_vim_cheatsheet, {
    silent = true,
    desc = "Vim操作のチートシート",
})

-- VSCodeの言語機能へ接続します。
map("n", "gd", "editor.action.revealDefinition", "Go to definition")
map("n", "gr", "editor.action.goToReferences", "Go to references")
map("n", "gi", "editor.action.goToImplementation", "Go to implementation")
map("n", "K", "editor.action.showHover", "Show hover")
map("n", "<leader>lr", "editor.action.rename", "Rename")
map({ "n", "x" }, "<leader>la", "editor.action.quickFix", "Code action")
map("n", "<leader>cf", "editor.action.formatDocument", "Format document")
map("x", "<leader>cf", "editor.action.formatSelection", "Format selection")
map("n", "]d", "editor.action.marker.next", "Next diagnostic")
map("n", "[d", "editor.action.marker.prev", "Previous diagnostic")

-- VSCodeのソース管理へ接続します。
map("n", "<leader>gg", "workbench.view.scm", "Source control")

-- Neovim本来の編集操作だけを軽量に補います。
vim.keymap.set("x", "<", "<gv", { silent = true, desc = "Indent left" })
vim.keymap.set("x", ">", ">gv", { silent = true, desc = "Indent right" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })
