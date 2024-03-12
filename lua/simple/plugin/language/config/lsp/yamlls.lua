return {
    on_new_config = function(config)
        local schemas = require("schemastore").yaml.schemas()
        config.settings.yaml.schemas = vim.tbl_deep_extend("force", config.settings.yaml.schemas or {}, schemas)
    end,
    settings = {
        redhat = { telemetry = { enabled = false } },
        yaml = {
            format = { enable = true },
            keyOrdering = false,
            schemaStore = { enable = false, url = "" },
            validate = true,
            customTags = {
                "!php/enum",
                "!php/const",
            },
        },
    },
}
