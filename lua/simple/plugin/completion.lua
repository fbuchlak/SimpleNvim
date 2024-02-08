return {
    {
        "hrsh7th/nvim-cmp",
        event = { "InsertEnter", "CmdLineEnter" },
        dependencies = {
            "onsails/lspkind.nvim",
            -- sources:
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "lukas-reineke/cmp-rg",
            "saadparwaiz1/cmp_luasnip",
        },
        opts = {
            enabled = function() return vim.b.cmp_enabled ~= false and vim.bo.buftype ~= "prompt" end,
            snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
            experimental = { ghost_text = true },
        },
        keys = { { "<LocalLeader>ma", "<CMD>CompletionToggle<CR>", desc = "[Toggle] autocompletion" } },
        config = function(_, opts)
            local cmp = require("cmp")

            cmp.setup(vim.tbl_deep_extend("force", opts, {
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = function()
                        if not cmp.confirm({ behavior = cmp.SelectBehavior.Insert, select = true }) then
                            cmp.complete()
                        end
                    end,
                    ["<C-n>"] = function()
                        if not cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert }) then cmp.complete() end
                    end,
                    ["<C-p>"] = function()
                        if not cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert }) then cmp.complete() end
                    end,
                    ["<S-CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                }),

                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    -- { name = "symfony" },
                }, {
                    { name = "buffer" },
                    { name = "path", options = { trailing_slash = false } },
                }, {
                    { name = "rg", keyword_length = 3 },
                }),
                formatting = {
                    format = require("lspkind").cmp_format({
                        mode = "text_symbol",
                        maxwidth = function() return math.floor(0.65 * vim.o.columns) end,
                        ellipsis_char = "...",
                        show_labelDetails = true,
                        menu = {
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snippets]",
                            -- symfony = "[Symfony]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                            rg = "[Grep]",
                        },
                    }),
                },
            }))

            local cmdline_mapping = cmp.mapping.preset.cmdline()
            cmp.setup.cmdline({ ":" }, {
                mapping = cmdline_mapping,
                sources = cmp.config.sources({
                    { name = "cmdline", option = { ignore_cmds = {} } },
                    { name = "path" },
                }),
            })

            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmdline_mapping,
                sources = cmp.config.sources({ { name = "buffer" } }),
            })
        end,
        -- stylua: ignore
        init = function()
            vim.api.nvim_create_user_command("CompletionDisable", function() vim.b.cmp_enabled = false end, {})
            vim.api.nvim_create_user_command("CompletionEnable", function() vim.b.cmp_enabled = true end, {})
            vim.api.nvim_create_user_command("CompletionToggle", function() vim.b.cmp_enabled = not vim.b.cmp_enabled end, {})
        end,
    },
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "rafamadriz/friendly-snippets",
            "h4kst3r/php-awesome-snippets",
            "nalabdou/twig-code-snippets",
        },
        build = "make install_jsregexp",
        opts = { history = false, delete_check_events = "TextChanged" },
        keys = {
            {
                "<Tab>",
                function() return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<Tab>" end,
                expr = true,
                mode = "i",
            },
            { "<Tab>", function() require("luasnip").jump(1) end, mode = "s" },
            { "<S-Tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
            {
                "<C-e>",
                function()
                    if require("luasnip").choice_active() then require("luasnip").change_choice(1) end
                end,
                mode = { "i", "s" },
            },
        },
        config = function(_, opts)
            require("luasnip.loaders.from_vscode").lazy_load()
            require("luasnip").setup(opts)
        end,
    },
}
