local util = require("simple.util.format")

local formatters_by_ft = {
    twig = { "djlint" },
    blade = { "blade-formatter" },
    dockerfile = { "dockfmt" },
    python = { "black" },
}

---@param fts string[]
---@param formatters string[]
local function add_formatter_group(fts, formatters)
    for _, ft in pairs(fts) do
        formatters_by_ft[ft] = formatters_by_ft[ft] or {}
        table.insert(formatters_by_ft[ft], formatters)
    end
end

add_formatter_group({ "sh", "bash", "zsh" }, { "beautysh", "shellharden" })
add_formatter_group({ "sql", "mysql" }, { "sqlfluff" })
add_formatter_group({ "php", "phtml" }, { "easy-coding-standard", "php_cs_fixer" })
add_formatter_group({ "lua" }, { "stylua" })
-- stylua: ignore
add_formatter_group({
    "html", "css", "sass", "scss", "less",
    "javascript", "javascriptreact",
    "typescript", "typescriptreact",
    "vue",
}, { "prettier" })

return {
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            opts = opts or {}
            opts.ensure_installed = opts.ensure_installed or {}
            -- stylua: ignore
            vim.list_extend(opts.ensure_installed, {
                "beautysh", "shellharden",
                "sqlfluff",
                "prettier",
                "easy-coding-standard", "php-cs-fixer",
                "black",
                "djlint", "blade-formatter",
                "rustywind"
            })
            return opts
        end,
    },
    {
        "stevearc/conform.nvim",
        cmd = "ConformInfo",
        opts = {
            formatters_by_ft = formatters_by_ft,
            formatters = {
                rustywind = {},
                djlint = {
                    prepend_args = function()
                        if require("simple.util").has_root_file({ ".djlintrc" }) then return {} end
                        -- stylua: ignore
                        return {
                            "--profile", "nunjucks",
                            "--blank-line-after-tag", "load,extends,include",
                            "--custom-blocks", "autoescape",
                            "--max-blank-lines", "1",
                            "--max-attribute-length", "60",
                            "--max-line-length", "160",
                            "--no-function-formatting", "--no-set-formatting",
                        }
                    end,
                },
                sqlfluff = {
                    args = function()
                        local dialect = vim.b.simple_sqlfluff_dialect or vim.g.simple_sqlfluff_dialect
                        if not dialect and "mysql" == vim.bo.filetype then dialect = "mysql" end
                        dialect = ("--dialect=%s"):format(dialect or "ansi")
                        return { "fix", "--force", dialect, "-" }
                    end,
                },
            },
        },
        keys = {
            {
                "<LocalLeader>ff",
                function() util.format(false) end,
                desc = "Format",
                mode = { "n", "v" },
            },
            {
                "<LocalLeader>fw",
                function() util.format(true) end,
                desc = "Format & Save",
                mode = { "n", "v" },
            },
            {
                "<LocalLeader>fs",
                util.format_with_formatter,
                desc = "[Format] Select Formatter",
                mode = { "n", "v" },
            },
        },
    },
}
