---@class simple.TelescopeOptsBase
---@field key string Keymap suffix
---@field builtin string One of telescope's builtins
---@field modifier fun(opts: table, relative: boolean, hidden: boolean)|nil
---@field desc string|nil|false Keymap description

---@class simple.TelescopeOpts: simple.TelescopeOptsBase
---@field relative boolean Whenever to search only in files relative to this buffer. Defaults to false.
---@field hidden boolean Whenever to search in hidden files. Defaults to false.

local M = {}
local H = {}

---@param key string
---@param builtin string
---@param modifier fun(opts: table, relative: boolean, hidden: boolean)|nil
---@param desc string|nil|false
---@param relative boolean|nil
---@param hidden boolean|nil
---@return simple.TelescopeOpts
function M.opts(key, builtin, modifier, desc, relative, hidden)
    return {
        key = key,
        builtin = builtin,
        modifier = modifier,
        desc = desc,
        relative = nil ~= relative and relative or false,
        hidden = nil ~= hidden and hidden or false,
    }
end

---@param find_opts simple.TelescopeOpts
---@return LazyKeysSpec
function M.key(find_opts)
    return { H.lhs(find_opts), H.create_find_call(find_opts), desc = H.desc(find_opts), mode = { "n", "v" } }
end

---@param find_opts simple.TelescopeOpts
---@param input_name string
---@param input_default string|nil
---@param input_modifier nil|string|fun(input_value: string, opts: table, relative: boolean, hidden: boolean)
---@return LazyKeysSpec
function M.key_input(find_opts, input_name, input_default, input_modifier)
    local rhs = function()
        vim.ui.input({
            prompt = ("Please enter %q"):format(input_name),
            default = input_default or "",
        }, function(input_value)
            if nil == input_value or "" == input_value then
                require("simple.util.notify").warn(("No value provided for %q"):format(input_name))
            else
                local opts = vim.deepcopy(find_opts)
                local modifier = opts.modifier
                opts.modifier = function(resolved_opts, ...)
                    local prompt_title = resolved_opts.prompt_title
                    if nil ~= prompt_title then
                        resolved_opts.prompt_title = ("%s [%s = %q]"):format(prompt_title, input_name, input_value)
                    end

                    if "function" == type(modifier) then modifier(resolved_opts, ...) end
                    if "function" == type(input_modifier) then
                        input_modifier(input_value, resolved_opts, ...)
                    else
                        resolved_opts[input_modifier or input_name] = input_value
                    end
                end

                H.create_find_call(opts)()
            end
        end)
    end

    return { H.lhs(find_opts), rhs, desc = H.desc(find_opts), mode = { "n", "v" } }
end

---@param find_opts simple.TelescopeOptsBase
---@return LazyKeysSpec[]
function M.key_variants(find_opts)
    local keys = {}
    for _, opts in ipairs(H.opts_variants(find_opts)) do
        keys[#keys + 1] = M.key(opts)
    end
    return keys
end

---@param find_opts simple.TelescopeOptsBase
---@param input_name string
---@param input_default string|nil
---@param input_modifier nil|string|fun(input_value: string, opts: table, relative: boolean, hidden: boolean)
---@return LazyKeysSpec[]
function M.key_input_variants(find_opts, input_name, input_default, input_modifier)
    local keys = {}
    for _, opts in ipairs(H.opts_variants(find_opts)) do
        keys[#keys + 1] = M.key_input(opts, input_name, input_default, input_modifier)
    end
    return keys
end

local escape_ignore = { "fd", "find_files", "git_files" }

---@param opts simple.TelescopeOpts
function H.create_find_call(opts)
    local builtin_opts_default = {
        reuse_win = true,
        prompt_title = opts.desc ~= false and H.desc(opts) or nil,
        additional_args = { "--follow", "--trim" },
    }

    if true == opts.hidden then
        builtin_opts_default.hidden = true
        builtin_opts_default.no_ignore = true
        builtin_opts_default.no_ignore_parent = true

        vim.list_extend(builtin_opts_default.additional_args, { "--no-ignore", "--hidden", "--glob", "!**/.git/*" })
    end

    return function()
        local util = require("simple.util")
        if util.is_win_floating() then vim.cmd.close() end

        local builtin_opts = vim.deepcopy(builtin_opts_default)

        builtin_opts.cwd = opts.relative and require("telescope.utils").buffer_dir() or nil
        if vim.fn.mode() ~= "n" then
            local default_text = util.get_visual_selection()
            if not vim.tbl_contains(escape_ignore, opts.builtin) then
                default_text = require("simple.util.string").escape_rg(default_text)
            end
            if default_text:match("\n") then
                builtin_opts.additional_args[#builtin_opts.additional_args + 1] = "--multiline"
                if string.sub(default_text, -1) == "\n" then default_text = default_text:sub(1, #default_text - 1) end
                default_text = ("(?s)%s"):format((default_text:gsub("\n", ".*")))
            end
            builtin_opts.default_text = default_text
        end

        if "function" == type(opts.modifier) then opts.modifier(builtin_opts, opts.relative, opts.hidden) end

        local builtin = require("telescope.builtin")[opts.builtin]
        if "function" == type(builtin) then
            builtin(builtin_opts)
        else
            require("simple.util.notify").error(("telescope.builtin.%s is not a function"):format(builtin))
        end
    end
end
--
---@param opts simple.TelescopeOptsBase
---@return simple.TelescopeOpts[]
function H.opts_variants(opts)
    local optss = {}
    for j = 0, 1 do
        for k = 0, 1 do
            optss[#optss + 1] = M.opts(opts.key, opts.builtin, opts.modifier, opts.desc, j == 1, k == 1)
        end
    end

    return optss
end

---@param opts simple.TelescopeOpts
---@return string
function H.lhs(opts) return ("<Leader>%s%s%s"):format(opts.relative and "S" or "s", opts.hidden and "a" or "", opts.key) end

---@param opts simple.TelescopeOpts
---@return string
function H.desc(opts)
    local desc = require("simple.util.string").to_sentence_case(opts.desc or opts.builtin)
    return ("[Search]%s%s %s"):format(opts.relative and "[Relative]" or "", opts.hidden and "[Hidden]" or "", desc)
end

return M
