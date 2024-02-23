local icons = require("simple.config.icons")
local Icon = icons.common
local bufferline_diag_icons = { ["error"] = icons.diagnostic.Error, ["warning"] = icons.diagnostic.Warn }

return {
    {
        "stevearc/dressing.nvim",
        opts = {
            input = { insert_only = false, border = "single" },
            select = { telescope = {} },
        },
        init = function()
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.select = function(...)
                require("lazy").load({ plugins = { "dressing.nvim" } })
                return vim.ui.select(...)
            end
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.input = function(...)
                require("lazy").load({ plugins = { "dressing.nvim" } })
                return vim.ui.input(...)
            end
        end,
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function(_, opts)
            require("which-key").setup(opts)
            require("which-key").register({
                ["<Leader>e"] = "[Filesystem]",
                ["<Leader>g"] = "[Action]",
                ["<Leader>l"] = "[Show Details]",
                ["<Leader>r"] = "[Run]",
                ["<Leader>s"] = "[Search]",
                ["<Leader>S"] = "[Search][Relative]",
                ["<Leader>sa"] = "[Search][All]",
                ["<Leader>Sa"] = "[Search][Relative][All]",
                ["<Leader>sax"] = "[Search][Interactive]",
                ["<Leader>Sax"] = "[Search][Relative][All][Interactive]",
                ["<Leader>sg"] = "[Search][Git]",
                ["<Leader>sl"] = "[Search][LSP]",
                ["<Leader>so"] = "[Search] Opened Files",
                ["<Leader>sx"] = "[Search][Interactive]",
                ["<Leader>Sx"] = "[Search][Relative][All][Interactive]",
                ["<LocalLeader>b"] = "[Buf]",
                ["<LocalLeader>bq"] = "[Bufferline] Close",
                ["<LocalLeader>d"] = { name = "[DAP]", mode = { "n", "x" } },
                ["<LocalLeader>f"] = { name = "[Format]", mode = { "n", "x" } },
                ["<LocalLeader>g"] = "[Git]",
                ["<LocalLeader>gm"] = "[Git][Toggle]",
                ["<LocalLeader>m"] = "[Toggle]",
                ["<LocalLeader>r"] = { name = "[Refactor]", mode = { "n", "x" } },
                ["gs"] = "[Surround]",
            })
        end,
    },
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "TodoTelescope", "TodoNext", "TodoPrev" },
        opts = {
            signs = false,
            highlight = { pattern = vim.g.simple_config_todo_highlight_pattern or nil },
            search = { pattern = vim.g.simple_config_todo_search_pattern or nil },
        },
        keys = {
            { "<Leader>st", "<CMD>TodoTelescope<CR>", desc = "[Search] Todo Comments" },
            { "[t", "<CMD>TodoPrev<CR>", desc = "Previous Todo" },
            { "]t", "<CMD>TodoNext<CR>", desc = "Next Todo" },
        },
        config = function(_, opts)
            local todo = require("todo-comments")
            local prev, next = require("nvim-next.move").make_repeatable_pair(todo.jump_prev, todo.jump_next)
            vim.api.nvim_create_user_command("TodoNext", next, {})
            vim.api.nvim_create_user_command("TodoPrev", prev, {})
            todo.setup(opts)
        end,
    },
    {
        "echasnovski/mini.trailspace",
        event = { "BufReadPost", "BufNewFile" },
        opts = { only_in_normal_buffers = true },
        config = function(_, opts)
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "lazy", "mason" },
                callback = function()
                    vim.b.minitrailspace_disable = true
                    require("mini.trailspace").highlight()
                end,
            })
            require("mini.trailspace").setup(opts)
        end,
        init = function()
            vim.api.nvim_create_user_command("MiniTrailspaceToggle", function()
                vim.b.minitrailspace_disable = not vim.b.minitrailspace_disable
                require("mini.trailspace").highlight()
            end, {})
        end,
    },
    {
        "echasnovski/mini.indentscope",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            draw = { animation = function() return 0 end },
            options = { try_as_border = true },
            mappings = {
                object_scope = "ii",
                object_scope_with_border = "ai",
                goto_top = "[i",
                goto_bottom = "]i",
            },
        },
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "help", "man", "lazy", "mason" },
                callback = function() vim.b.miniindentscope_disable = true end,
            })
        end,
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            scope = { enabled = false },
            exclude = { filetypes = { "starter", "lazy", "mason" } },
        },
    },
    {
        "RRethy/vim-illuminate",
        event = { "BufReadPost", "BufNewFile" },
        opts = { delay = 200, large_file_cutoff = 1000, large_file_overrides = { providers = { "lsp" } } },
        config = function(_, opts)
            local illuminate = require("illuminate")
            illuminate.configure(opts)

            local prev, next = require("nvim-next.move").make_repeatable_pair(
                function() illuminate.goto_prev_reference(false) end,
                function() illuminate.goto_next_reference(false) end
            )
            local map = function(event)
                if vim.tbl_contains({ "lazy", "mason", "minifiles" }, vim.bo.filetype) then return end

                local bufnr = event and event.buf or nil
                vim.keymap.set("n", "[[", prev, { desc = "Previous Reference", buffer = bufnr })
                vim.keymap.set("n", "]]", next, { desc = "Next Reference", buffer = bufnr })
            end
            map()
            vim.api.nvim_create_autocmd("FileType", { callback = map })
        end,
        keys = {
            { "[[", desc = "Previous Reference" },
            { "]]", desc = "Next Reference" },
        },
    },
    {
        "akinsho/bufferline.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        keys = {
            { "H", "<CMD>BufferLineCyclePrev<CR>", desc = "[Bufferline] Prev" },
            { "L", "<CMD>BufferLineCycleNext<CR>", desc = "[Bufferline] Next" },
            { "<F7>", "<CMD>BufferLineMovePrev<CR>", desc = "[Bufferline] Swap Previous" },
            { "<F8>", "<CMD>BufferLineMoveNext<CR>", desc = "[Bufferline] Swap Next" },
            { "<LocalLeader>bql", "<CMD>BufferLineCloseLeft<CR>", desc = "[Bufferline] Close Left" },
            { "<LocalLeader>bqq", "<CMD>BufferLineCloseOthers<CR>", desc = "[Bufferline] Close Others" },
            { "<LocalLeader>bqr", "<CMD>BufferLineCloseRight<CR>", desc = "[Bufferline] Close Right" },
        },
        opts = {
            options = {
                always_show_bufferline = false,
                diagnostics = "nvim_lsp",
                indicator = { style = "none" },
                modified_icon = Icon.OutlineBoxPencil,
                show_close_icon = false,
                show_buffer_close_icons = false,
                offsets = {
                    { filetype = "undotree", text = "Undotree", text_align = "center", separator = true },
                    { filetype = "spectre_panel", text = "Spectre", text_align = "center", separator = true },
                    { filetype = "DiffviewFiles", text = "Diffview Files", text_align = "center", separator = true },
                },
                diagnostics_indicator = function(_, level) return bufferline_diag_icons[level] or "" end,
            },
        },
        config = function(_, opts)
            local hashl, highlights = pcall(require, "catppuccin.groups.integrations.bufferline")
            if hashl then opts.highlights = highlights:get() end
            require("bufferline").setup(opts)
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            {
                "SmiteshP/nvim-navic",
                opts = {
                    highlight = true,
                    lsp = {
                        auto_attach = true,
                        preference = { "twiggy_language_server" },
                    },
                },
            },
        },
        event = "VeryLazy",
        opts = {
            options = {
                theme = "catppuccin",
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = { "starter" },
                    winbar = { "DiffviewFiles", "spectre_panel", "starter", "undotree" },
                },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = {
                    { "b:gitsigns_head", icon = Icon.Branch },
                    {
                        "diff",
                        source = function() return vim.b.gitsigns_status_dict or nil end,
                        -- stylua: ignore
                        symbols = { added = Icon.OutlineBoxPlus, modified = Icon.OutlineBoxPencil, removed = Icon.OutlineBoxMinus },
                    },
                },
                lualine_c = {
                    {
                        "diagnostics",
                        sources = { "nvim_lsp", "nvim_diagnostic" },
                        -- stylua: ignore
                        symbols = { error = icons.diagnostic.Error, warn = icons.diagnostic.Warn, info = icons.diagnostic.Info, hint = icons.diagnostic.Hint },
                    },
                },
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
            -- stylua: ignore
            inactive_sections = { lualine_a = {}, lualine_b = {}, lualine_c = {}, lualine_x = {}, lualine_y = {}, lualine_z = {} },
            winbar = {
                lualine_b = { { "location", padding = { left = 0, right = 0 } } },
                lualine_c = {
                    { "filetype", icon_only = true, padding = { left = 1, right = 0 } },
                    { "filename", symbols = { modified = Icon.OutlineBoxPencil, readonly = Icon.Readonly } },
                    "navic",
                },
                lualine_x = { "fileformat", { "encoding", padding = { left = 0, right = 1 } } },
                lualine_y = { "progress" },
            },
            inactive_winbar = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {
                    { "location", padding = { left = 0, right = 0 } },
                    { "filetype", colored = false, icon_only = true, padding = { left = 1, right = 0 } },
                    { "filename", path = 3, symbols = { modified = Icon.OutlineBoxPencil, readonly = Icon.Readonly } },
                },
                lualine_x = { "progress" },
                lualine_y = {},
                lualine_z = {},
            },
            extensions = { "fugitive", "lazy", "man", "quickfix" },
        },
        init = function()
            vim.g.lualine_laststatus = vim.o.laststatus
            if vim.fn.argc(-1) > 0 then
                vim.o.statusline = " "
            else
                vim.o.laststatus = 0
            end
        end,
    },
}
