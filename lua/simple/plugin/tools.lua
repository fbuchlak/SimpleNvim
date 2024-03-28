return {
    {
        "stevearc/overseer.nvim",
        opts = {},
        keys = {
            { "<Leader>ru", "<CMD>OverseerRun<CR><CMD>OverseerOpen!<CR>", desc = "[Overseer] Run" },
            { "<Leader>rr", "<CMD>OverseerToggle<CR>", desc = "[Overseer] Toggle" },
            { "<Leader>ro", "<CMD>OverseerOpen<CR>", desc = "[Overseer] Open" },
        },
    },
    { "potamides/pantran.nvim", cmd = "Pantran", opts = {} },
    {
        "uga-rosa/ccc.nvim",
        cmd = { "CccPick", "CccHighlighterToggle" },
        keys = { { "<LocalLeader>mc", "<CMD>CccHighlighterToggle<CR>", desc = "[Toggle] Color Highlight" } },
        config = true,
    },
    {
        "kristijanhusak/vim-dadbod-ui",
        dependencies = { "tpope/vim-dadbod" },
        cmd = "DBUI",
        init = function()
            vim.g.db_ui_use_nerd_fonts = 1
            vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dbui/"
        end,
    },
    {
        "creativenull/dotfyle-metadata.nvim",
        cmd = { "DotfyleGenerate" },
    },
}
