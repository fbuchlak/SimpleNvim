local M = {}

---@param string string
---@return string
function M.to_title_case(string)
    return (string:gsub("(%a)([%w_']*)", function(f, r) return f:upper() .. r:lower() end))
end

---@param string string
function M.to_sentence_case(string) return M.to_title_case(string:gsub("[_-]", " ")) end

---@param string string
---@return string
function M.escape_rg(string)
    return (
        string:gsub("[%(|%)|\\|%[|%]|%-|%{%}|%?|%+|%*|%^|%$|%.]", {
            ["\\"] = "\\\\",
            ["-"] = "\\-",
            ["("] = "\\(",
            [")"] = "\\)",
            ["["] = "\\[",
            ["]"] = "\\]",
            ["{"] = "\\{",
            ["}"] = "\\}",
            ["?"] = "\\?",
            ["+"] = "\\+",
            ["*"] = "\\*",
            ["^"] = "\\^",
            ["$"] = "\\$",
            ["."] = "\\.",
        })
    )
end

---@param string string
---@return integer
function M.len_utf8(string)
    local _, len = string:gsub("[^\128-\193]", "")
    return len
end

return M
