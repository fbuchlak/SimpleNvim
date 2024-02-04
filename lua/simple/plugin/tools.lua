return {
    { "potamides/pantran.nvim", cmd = "Pantran", opts = {} },
    {
        "uga-rosa/ccc.nvim",
        cmd = { "CccPick", "CccHighlighterToggle" },
        keys = { { "<LocalLeader>mc", "<CMD>CccHighlighterToggle<CR>", desc = "[Toggle] Color Highlight" } },
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
}
