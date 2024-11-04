local util = require("simple.util.format")

local formatters_by_ft = {
    twig = { "twig-cs-fixer", "djlint" },
    blade = { "blade-formatter" },
    dockerfile = { "dockfmt" },
    lua = { "stylua" },
    python = { "black" },
    go = { "goimports", "gofumpt" },
    xml = { "xmllint" },
    nix = { "nixpkgs_fmt" },
}

---@param fts string[]
---@param formatters string[]
local function set_formatter_group(fts, formatters)
    for _, ft in pairs(fts) do
        formatters_by_ft[ft] = formatters
        formatters_by_ft[ft].stop_after_first = true
    end
end

set_formatter_group({ "sh", "bash" }, { "shfmt", "beautysh", "shellharden" })
set_formatter_group({ "zsh" }, { "beautysh", "shellharden" })
set_formatter_group({ "sql", "mysql" }, { "sqlfluff" })
set_formatter_group({ "php", "phtml" }, { "easy-coding-standard", "php_cs_fixer" })
set_formatter_group({ "terraform", "tf", "terraform-vars" }, { "terraform_fmt" })
-- stylua: ignore
set_formatter_group({
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
                "shfmt", "beautysh", "shellharden",
                "sqlfluff",
                "prettier",
                "easy-coding-standard", "php-cs-fixer",
                "black",
                "goimports", "gofumpt",
                "djlint", "blade-formatter",
                "rustywind",
                "nixpkgs-fmt",
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
                ["easy-coding-standard"] = function()
                    -- -- To run easy coding standard from container
                    -- vim.g.simple_conform_ecs_command = "docker"
                    -- vim.g.simple_conform_ecs_args = function(_, ctx)
                    --     local cwd = vim.loop.cwd() or ""
                    --     local relative = ctx.filename:sub(cwd:len() + 1)
                    --     local filename = "/var/www/html" .. relative
                    --
                    --     return {
                    --         "compose",
                    --         "exec",
                    --         "php",
                    --         "vendor/bin/ecs",
                    --         "check",
                    --         filename,
                    --         "--fix",
                    --         "--no-interaction",
                    --     }
                    -- end

                    return {
                        command = vim.g.simple_conform_ecs_command,
                        args = vim.g.simple_conform_ecs_args,
                    }
                end,
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
