local cmp = require("cmp")
local luasnip = require("luasnip")

luasnip.add_snippets("html", {
    luasnip.snippet("!", {
        luasnip.text_node({
            "<!DOCTYPE html>",
            '<html lang="ja">',
            "<head>",
            '    <meta charset="UTF-8">',
            '    <meta name="viewport" content="width=device-width, initial-scale=1.0">',
            "    <title>",
        }),
        luasnip.insert_node(1, "Document"),
        luasnip.text_node({
            "</title>",
            "</head>",
            "<body>",
            "    ",
        }),
        luasnip.insert_node(0),
        luasnip.text_node({
            "",
            "</body>",
            "</html>",
        }),
    }),
})

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping(function(fallback)
            if luasnip.expandable() then
                luasnip.expand()
            elseif cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<Down>"] = function(fallback)
            fallback() -- 常にカーソルを移動します。
        end,

        ["<Up>"] = function(fallback)
            fallback() -- 常にカーソルを移動します。
        end,
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-k>"] = cmp.mapping.select_prev_item(),
    }),

    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer" },
    },
})

cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" },
    },
})

cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        {
            name = "cmdline",
            option = {
                ignore_cmds = { "Man", "!" },
            },
        },
    }),
    matching = { disallow_symbol_nonprefix_matching = false },
})
