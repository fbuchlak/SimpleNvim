return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            opts = { flavour = "mocha" },
            integrations = {
                cmp = true,
                fidget = true,
                gitsigns = true,
                illuminate = { enabled = true, lsp = false },
                indent_blankline = { enabled = true },
                markdown = true,
                mason = true,
                mini = { enabled = true, indentscope_color = "lavender" },
                native_lsp = {
                    enabled = true,
                    virtual_text = {
                        errors = { "italic" },
                        hints = { "italic" },
                        warnings = { "italic" },
                        information = { "italic" },
                    },
                    underlines = {
                        errors = { "underline" },
                        hints = { "underline" },
                        warnings = { "underline" },
                        information = { "underline" },
                    },
                    inlay_hints = { background = true },
                },
                navic = { enabled = true, custom_bg = "lualine" },
                telescope = { enabled = true },
                treesitter = true,
                which_key = true,

                alpha = false,
                dashboard = false,
                flash = false,
                neogit = false,
                nvimtree = false,
                rainbow_delimiters = false,
                ufo = false,
            },
        },
    },
}
