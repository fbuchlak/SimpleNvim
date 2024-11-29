local linters_by_ft = {
    twig = { "djlint" },
    markdown = { "markdownlint" },
    dockerfile = { "hadolint" },
    make = { "checkmake" },
}

---@param fts string[]
---@param linters string[]
local function set_linters(fts, linters)
    for _, ft in pairs(fts) do
        linters_by_ft[ft] = linters
    end
end

set_linters({ "css", "less", "sass", "scss" }, { "stylelint" })
set_linters({ "sql", "mysql" }, { "sqlfluff" })
set_linters({ "php", "phtml" }, { "php", "phpstan", "phpinsights", "phpcs", "phpmd" })
set_linters({ "terraform", "tf" }, { "terraform_validate" })
set_linters({ "nix" }, { "statix", "deadnix" })

return {
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            opts = opts or {}
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, {
                "checkmake",
                "djlint",
                "hadolint",
                "markdownlint",
                "phpstan",
                "sqlfluff",
                "stylelint",
                "twigcs",
            })
            return opts
        end,
    },
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            linters_by_ft = linters_by_ft,
            linters = {
                sqlfluff = {
                    args = {
                        "lint",
                        "--format=json",
                        function()
                            local dialect = vim.b.simple_config_sqlfluff_dialect or vim.g.simple_config_sqlfluff_dialect
                            if not dialect and "mysql" == vim.bo.filetype then dialect = "mysql" end
                            return ("--dialect=%s"):format(dialect or "ansi")
                        end,
                    },
                },
                phpstan = {
                    args = {
                        "analyse",
                        function()
                            local cfgs = { "phpstan.neon", "phpstan.neon.dist", "phpstan.dist.neon" }
                            if require("simple.util").has_root_file(cfgs) then return nil end
                            return ("--level=%d"):format(vim.g.simple_config_lint_phpstan_level)
                        end,
                        "--error-format=json",
                        "--no-progress",
                    },
                    __conditions = {
                        function() return true ~= vim.g.simple_config_lint_phpstan_disabled end,
                    },
                },
                phpinsights = {
                    __conditions = {
                        function()
                            return true == vim.g.simple_config_lint_phpinsights_enabled
                                and require("simple.util").has_root_file({ "phpinsights.php" })
                        end,
                    },
                },
                phpcs = {
                    __conditions = {
                        function() return true == vim.g.simple_config_lint_phpcs_enabled end,
                    },
                },
                phpmd = {
                    __conditions = {
                        function() return true == vim.g.simple_config_lint_phpcs_enabled end,
                    },
                },
            },
        },
        config = function(_, opts)
            local lint = require("lint")

            lint.linters_by_ft = opts.linters_by_ft or {}
            for name, override in pairs(opts.linters) do
                local linter = lint.linters[name]
                if "table" == type(linter) and "table" == type(override) then
                    lint.linters[name] = vim.tbl_deep_extend("force", linter, override)
                end
            end

            vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "FileType", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("SimpleNvimLintCheck", { clear = true }),
                callback = require("simple.util").debounce(200, function()
                    if vim.g.nvim_lint_enabled ~= false then vim.cmd("Lint") end
                end),
            })
        end,
        init = function()
            vim.api.nvim_create_user_command("Lint", function()
                if not vim.diagnostic.is_enabled() then return end

                local ft = vim.bo.filetype

                local lint = require("lint")
                local resolved_linters = vim.tbl_filter(function(name)
                    local linter = lint.linters and lint.linters[name]
                    if "table" ~= type(linter) then return true end
                    for _, condition in ipairs((linter.__ft_conditions or {})[ft] or {}) do
                        if not condition() then return false end
                    end
                    for _, condition in ipairs(linter.__conditions or {}) do
                        if not condition() then return false end
                    end
                    return true
                end, lint._resolve_linter_by_ft(ft))

                if #resolved_linters > 0 then lint.try_lint(resolved_linters) end
            end, {})
        end,
    },
}
