local servers = {
    marksman = {},
    typos_lsp = { init_options = { diagnosticSeverity = "Hint" } },

    bashls = {}, -- integrates shellcheck
    dockerls = {},
    docker_compose_language_service = { telemetry = { enableTelemetry = false } },

    jsonls = require("simple.plugin.language.config.lsp.jsonls"),
    yamlls = require("simple.plugin.language.config.lsp.yamlls"),
    lemminx = { settings = { redhat = { telemetry = { enabled = false } } } },
    taplo = {},

    sqlls = {},

    html = { filetypes = { "html", "phtml", "twig", "blade" } },
    cssls = {},
    emmet_language_server = {
        -- stylua: ignore
        filetypes = {
            "html", "css", "less", "sass", "scss",
            "javascript", "javascriptreact", "typescript", "typescriptreact", "vue",
            "php", "phtml", "twig", "blade",
        },
    },
    tailwindcss = {
        -- stylua: ignore
        filetypes = {
            "html", "css", "less", "sass", "scss",
            "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte",
            "php", "phtml", "twig", "blade",
        },
    },

    eslint = {
        workingDirectories = { mode = "auto" },
        on_attach = function() vim.keymap.set("n", "<LocalLeader>fe", "<CMD>EslintFixAll<CR>", { desc = "Eslint Fix" }) end,
    },
    tsserver = { completions = { completeFunctionCalls = true } },
    svelte = {},
    volar = {}, -- filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },

    lua_ls = { settings = { Lua = { workspace = { checkThirdParty = false } } } },

    clangd = {},

    gopls = require("simple.plugin.language.config.lsp.gopls"),
    templ = {},

    rust_analyzer = {},

    stimulus_ls = { filetypes = { "php", "twig", "blade" } },
    twiggy_language_server = {},

    pyright = {},
    ruff_lsp = {},
}

return {
    { "b0o/SchemaStore.nvim", module = true },
    { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },
            { "folke/neoconf.nvim", opts = {} },
            { "folke/neodev.nvim", opts = {} },
            { "gbprod/phpactor.nvim" },
            { "zeioth/garbage-day.nvim", opts = {} },
        },
        event = { "BufReadPost", "BufNewFile", "VeryLazy" },
        keys = {
            { "gK", vim.lsp.buf.signature_help, desc = "[LSP] Signature Help" },
            { "gR", vim.lsp.buf.rename, desc = "[LSP] Rename" },
            { "gr", "<CMD>Telescope lsp_references<CR>", desc = "[LSP] References" },
            { "gI", "<CMD>Telescope lsp_implementations<CR>", desc = "[LSP] Implementation" },
            { "gy", "<CMD>Telescope lsp_type_definitions<CR>", desc = "[LSP] Type Definition" },
            { "<Leader>sls", "<CMD>Telescope lsp_document_symbols<CR>", desc = "[LSP] Document Symbols" },
            { "<Leader>slw", "<CMD>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "[LSP] Workspace Symbols" },
        },
        config = function()
            require("simple.util.diagnostic").reset()

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local bufnr = args.buf
                    local function map(lhs, rhs, method)
                        if 0 ~= #vim.lsp.get_clients({ bufnr = bufnr, method = method }) then
                            vim.keymap.set("n", lhs, rhs, { buffer = bufnr })
                        end
                    end

                    map("K", vim.lsp.buf.hover, "textDocument/hover")
                    map("gD", vim.lsp.buf.declaration, "textDocument/declaration")
                    map("gd", "<CMD>Telescope lsp_definitions<CR>", "textDocument/definition")
                end,
            })

            local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities() or {}
            local capabilities =
                vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), cmp_capabilities)
            local default_server_opts = { capabilities = vim.deepcopy(capabilities or {}) }

            local function setup(server_name)
                local server_opts = vim.tbl_deep_extend("force", default_server_opts, servers[server_name] or {})
                require("lspconfig")[server_name].setup(server_opts)
            end

            local ensure_installed = {}
            local lspconfig_to_package = require("mason-lspconfig.mappings.server").lspconfig_to_package
            local servers_all = vim.tbl_keys(lspconfig_to_package) or {}
            for server, _ in pairs(servers) do
                if
                    not vim.tbl_contains(servers_all, server)
                    or 1 == vim.fn.executable(lspconfig_to_package[server])
                then
                    setup(server)
                else
                    ensure_installed[#ensure_installed + 1] = server
                end
            end

            require("mason-lspconfig").setup({ ensure_installed = ensure_installed, handlers = { setup } })
        end,
    },
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        opts = function(_, opts)
            opts = opts or {}
            opts.ensure_installed = opts.ensure_installed or {}

            vim.list_extend(opts.ensure_installed, { "gh", "jq", "yq", "shellcheck" })

            -- Ignore present executables
            -- NOTE: This does not filter tools if executable differs from package name (e.g. "delve"-s executable is "dlv")
            opts.ensure_installed = vim.tbl_filter(
                function(executable) return 0 == vim.fn.executable(executable) end,
                opts.ensure_installed
            )
            opts.PATH = "append" -- prefer system executables

            return vim.tbl_deep_extend("force", opts or {}, {
                ui = {
                    icons = {
                        package_pending = require("simple.config.icons").common.Timer,
                        package_installed = require("simple.config.icons").common.Checkbox,
                        package_uninstalled = require("simple.config.icons").common.CheckboxBlank,
                    },
                },
            })
        end,
        config = function(_, opts)
            require("mason").setup(opts)

            local registry = require("mason-registry")
            local function ensure_installed()
                for _, name in ipairs(opts.ensure_installed or {}) do
                    local ok, package = pcall(registry.get_package, name)
                    if ok then
                        if not package:is_installed() then package:install() end
                    else
                        require("simple.util.notify").error(("There is no %q package in registry!"):format(name))
                    end
                end
            end

            registry.refresh(ensure_installed)
        end,
    },
    {
        "aznhe21/actions-preview.nvim",
        opts = { telescope = {} },
        keys = {
            {
                "<Leader>ga",
                function() require("actions-preview").code_actions() end,
                desc = "[LSP] Code Actions",
                mode = { "n", "v" },
            },
        },
    },
    {
        "gbprod/phpactor.nvim",
        cmd = "PhpActor",
        filetype = { "php", "phtml" },
        build = ":PhpActor update",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {
            install = { check_on_startup = "daily" },
            lspconfig = {
                enabled = true,
                options = {
                    filetypes = { "php", "phtml" },
                    on_attach = function(_, buffer)
                        -- stylua: ignore start
                        vim.keymap.set("n", "<Leader>go", "<CMD>PhpActor navigate<CR>", { desc = "[PHP Actor] Navigate", buffer = buffer })
                        vim.keymap.set("n", "<Leader>gp", "<CMD>PhpActor context_menu<CR>", { desc = "[PHP Actor] Menu", buffer = buffer })
                        vim.keymap.set("n", "<Leader>gc", "<CMD>PhpActor copy_fcqn<CR>", { desc = "[PHP Actor] Yank Namespace", buffer = buffer })
                        -- stylua: ignore end
                    end,
                },
            },
        },
    },
}
