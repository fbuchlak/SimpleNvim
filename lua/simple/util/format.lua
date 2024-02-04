local M = {}

local lsp_fallback_formatter = "LSP"

---@param write boolean
---@param formatters? string[]
function M.format(write, formatters)
    local conform = require("conform")

    conform.format({ async = true, lsp_fallback = true, formatters = formatters }, true == write and function(error)
        if error then return require("simple.util.notify").error(error) end
        if nil == error then vim.cmd.w() end
    end or nil)
end

function M.format_with_formatter()
    local conform = require("conform")

    local Checkbox = require("simple.config.icons").common.Checkbox

    local items = { { icon = "󰒋 ", name = lsp_fallback_formatter } }
    local bufitems = conform.list_formatters_for_buffer()

    vim.list_extend(items, vim.tbl_map(function(name) return { name = name, icon = Checkbox } end, bufitems))
    vim.list_extend(
        items,
        vim.tbl_filter(function(fmt) return not vim.tbl_contains(bufitems, fmt.name) end, {
            {},
            { icon = "󰞷 ", name = "injected" },
            { icon = Checkbox, name = "trim_whitespace" },
            { icon = Checkbox, name = "trim_newlines" },
            { icon = "󱏿 ", name = "rustywind" },
            {},
        })
    )

    vim.list_extend(
        items,
        vim.tbl_map(
            function(fmt) return { name = fmt.name } end,
            vim.tbl_filter(
                function(fmt) return fmt.available and not vim.tbl_contains(bufitems, fmt.name) end,
                conform.list_all_formatters()
            )
        )
    )

    vim.ui.select(items, {
        prompt = "Format with",
        format_item = function(fmt)
            if not fmt.name then return "" end
            return ("%s %s"):format(fmt.icon or require("simple.config.icons").common.CheckboxBlank, fmt.name)
        end,
    }, function(fmt)
        if nil == fmt or "" == fmt.name then return end

        conform.format({
            async = true,
            formatters = lsp_fallback_formatter == fmt.name and {} or { fmt.name },
            lsp_fallback = lsp_fallback_formatter == fmt.name,
        })
    end)
end

return M
