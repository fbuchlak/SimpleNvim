local M = {}

---@param modifiers? string[]
---@return TSNodeActionDef
function M.create_change_visibility_action(modifiers)
    modifiers = modifiers or { "public", "protected", "private" }

    local function action(node)
        local node_text = require("ts-node-action.helpers").node_text(node)
        for index, modifier in ipairs(modifiers) do
            if modifier == node_text then return modifiers[(index % #modifiers) + 1] or node_text end
        end
        return node_text, { cursor = {} }
    end

    return { action, name = "Cycle Visibility" }
end

return M
