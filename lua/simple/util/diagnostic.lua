local M = {}

local icons = require("simple.config.icons")

local diagnostic_config = {
    severity_sort = true,
    underline = true,
    update_in_insert = false,
    virtual_text = { source = "always" },
    float = { source = "always" },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = icons.diagnostic.Error,
            [vim.diagnostic.severity.WARN] = icons.diagnostic.Warn,
            [vim.diagnostic.severity.HINT] = icons.diagnostic.Hint,
            [vim.diagnostic.severity.INFO] = icons.diagnostic.Info,
        },
    },
}

function M.reset() vim.diagnostic.config(vim.deepcopy(diagnostic_config)) end

function M.toggle()
    if vim.diagnostic.is_disabled() then
        vim.diagnostic.enable()
    else
        vim.diagnostic.disable()
    end
end

return M
