return {
    { "tpope/vim-fugitive", cmd = { "G", "Git", "GcLog", "Gread", "Gvdiffsplit" } },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
        opts = {
            current_line_blame = true,
            signs = {
                add = { text = require("simple.config.icons").common.OutlineBoxPlus },
                change = { text = require("simple.config.icons").common.OutlineBoxPencil },
                delete = { text = require("simple.config.icons").common.OutlineBoxMinus },
                topdelete = { text = require("simple.config.icons").common.OutlineBoxMinus },
                changedelete = { text = require("simple.config.icons").common.OutlineBoxPlusMinus },
                untracked = { text = require("simple.config.icons").common.OutlineBoxQuestionmark },
            },
            auto_attach = true,
            attach_to_untracked = true,
            on_attach = function(bufnr)
                local gs = require("gitsigns")
                local function map(mode, lhs, rhs, desc, opts)
                    opts = vim.tbl_deep_extend("force", { buffer = bufnr, desc = desc }, opts or {})
                    vim.keymap.set(mode, lhs, rhs, opts)
                end

                local nngs = require("nvim-next.integrations").gitsigns(gs)
                map("n", "]c", function()
                    if vim.wo.diff then return "]c" end
                    vim.schedule(function() nngs.next_hunk() end)
                    return "<Ignore>"
                end, "Previous Change", { expr = true })
                map("n", "[c", function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() nngs.prev_hunk() end)
                    return "<Ignore>"
                end, "Next Change", { expr = true })
                map("n", "<Leader>lc", gs.preview_hunk, "[Git] Preview Change")
                map("n", "<LocalLeader>gr", gs.reset_hunk, "[Git] Reset Hunk")
                map("n", "<LocalLeader>gs", gs.stage_hunk, "[Git] Stage Hunk")
                map("n", "<LocalLeader>gS", gs.stage_buffer, "[Git] Stage Buffer")
                map("n", "<LocalLeader>gu", gs.undo_stage_hunk, "[Git] Undo Stage Hunk")
                map("n", "<LocalLeader>gmw", gs.toggle_word_diff, "[Toggle Git] Word Diff")
                map("n", "<LocalLeader>gmb", gs.toggle_current_line_blame, "[Toggle Git] Line Blame")
                map({ "o", "x" }, "ic", ":<C-U>Gitsigns select_hunk<CR>", "Change")
                map({ "o", "x" }, "ac", ":<C-U>Gitsigns select_hunk<CR>", "Change")
            end,
        },
        config = function(_, opts)
            vim.schedule(function() require("gitsigns").setup(opts) end)
        end,
        init = function()
            vim.api.nvim_create_user_command("NextHunk", function() require("gitsigns").next_hunk() end, {})
            vim.api.nvim_create_user_command("PrevHunk", function() require("gitsigns").prev_hunk() end, {})
        end,
    },
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" },
        keys = {
            { "<LocalLeader>gd", "<CMD>DiffviewOpen<CR>", desc = "[Git] Diffview" },
            { "<LocalLeader>gh", "<CMD>DiffviewFileHistory %<CR>", desc = "[Git] Diffview File History" },
        },
        opts = function()
            local close = {
                { "n", "q", "<CMD>DiffviewClose<CR>", { desc = "[Git] Diffview Close" } },
                { "n", "<Leader>q", "<CMD>DiffviewClose<CR>", { desc = "[Git] Diffview Close" } },
            }
            return { keymaps = { view = close, file_panel = close, file_history_panel = close } }
        end,
    },
}
