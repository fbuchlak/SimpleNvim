return {
    {
        "echasnovski/mini.splitjoin",
        opts = { mappings = { toggle = "gS" } },
        keys = { { "gS", desc = "Split Join Toggle", mode = { "n", "x" } } },
    },
    {
        "echasnovski/mini.ai",
        keys = {
            { "a", mode = { "x", "o" } },
            { "i", mode = { "x", "o" } },
        },
        opts = {
            mappings = {
                around = "a",
                inside = "i",
                around_next = "",
                inside_next = "",
                around_last = "",
                inside_last = "",
                goto_left = "",
                goto_right = "",
            },
            n_lines = 100,
        },
    },
    {
        "echasnovski/mini.surround",
        opts = {
            mappings = {
                add = "gsa",
                delete = "gsd",
                find = "gsf",
                find_left = "gsF",
                highlight = "gsh",
                replace = "gsr",
                update_n_lines = "gsn",
            },
        },
        keys = {
            { "gsa", desc = "[Surround] Add" },
            { "gsd", desc = "[Surround] Delete" },
            { "gsf", desc = "[Surround] Find next" },
            { "gsF", desc = "[Surround] Find previous" },
            { "gsh", desc = "[Surround] Highlight" },
            { "gsr", desc = "[Surround] Replace" },
            { "gsn", desc = "[Surround] Update n lines" },
            { "gsi", function() return "gsai" end, desc = "[Surround] In", mode = "n", remap = true, expr = true },
            { "gsw", function() return "gsaiw" end, desc = "[Surround] In w", mode = "n", remap = true, expr = true },
            { "gsW", function() return "gsaiW" end, desc = "[Surround] In W", mode = "n", remap = true, expr = true },
        },
    },
    {
        "echasnovski/mini.operators",
        keys = {
            { "<Leader>gr", mode = { "n", "v" } },
            { "<Leader>gs", mode = { "n", "v" } },
            { "<Leader>gx", mode = { "n", "v" } },
        },
        opts = {
            exchange = { prefix = "<Leader>gx" },
            replace = { prefix = "<Leader>gr" },
            sort = { prefix = "<Leader>gs" },
            evaluate = { prefix = "" },
            multiply = { prefix = "" },
        },
    },
    {
        "numToStr/Comment.nvim",
        dependencies = { { "JoosepAlviste/nvim-ts-context-commentstring", opts = { enable_autocmd = false } } },
        opts = function(_, opts)
            return vim.tbl_deep_extend("force", opts or {}, {
                pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
            })
        end,
        keys = {
            { "gc", desc = "Comment", mode = { "n", "o", "x" } },
            { "gb", desc = "Comment Block", mode = { "n", "o", "x" } },
        },
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        init = function()
            vim.api.nvim_create_user_command("ToggleAutopairs", function()
                local autopairs = require("nvim-autopairs")
                local _ = autopairs.state.disabled and autopairs.enable() or autopairs.disable()
            end, {})
        end,
        config = true,
    },
    {
        "ckolkey/ts-node-action",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        keys = {
            { "gG", function() require("ts-node-action").node_action() end, desc = "Node Action", mode = { "n", "x" } },
        },
        config = function()
            local util = require("simple.util.ts-node-action")
            local change_visibility = util.create_change_visibility_action()
            require("ts-node-action").setup({
                php = { ["visibility_modifier"] = change_visibility },
                typescript = { ["accessibility_modifier"] = change_visibility },
                tsx = { ["accessibility_modifier"] = change_visibility },
            })
        end,
    },
    {
        "danymat/neogen",
        cmd = "Neogen",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        keys = { { "<Leader>gd", "<CMD>Neogen<CR>", desc = "Generate Annotations" } },
        config = true,
    },
    {
        "nvim-pack/nvim-spectre",
        cmd = "Spectre",
        opts = { open_cmd = "noswapfile vnew" },
        keys = {
            { "<LocalLeader>rs", function() require("spectre").toggle() end, desc = "[Refactor] Spectre Toggle" },
        },
    },
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
        keys = {
            { "<LocalLeader>re", ":Refactor extract_var x", desc = "[Refactor] Extract Var", mode = { "n", "x" } },
            { "<LocalLeader>ri", ":Refactor inline_var", desc = "[Refactor] Inline Var", mode = { "n", "x" } },
            { "<LocalLeader>rb", ":Refactor extract_block x", desc = "[Refactor] Extract Block", mode = { "x" } },
        },
        config = true,
    },
}
