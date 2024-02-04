return {
    on_new_config = function(config)
        local schemas = require("schemastore").json.schemas()
        config.settings.json.schemas = vim.tbl_deep_extend("force", config.settings.json.schemas or {}, schemas)
    end,
    settings = { format = { enable = true }, validate = { enable = true } },
}
