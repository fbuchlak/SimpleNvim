local install_path = function(package) return require("mason-registry").get_package(package):get_install_path() end

return {
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            opts = opts or {}
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "debugpy", "delve", "php-debug-adapter" })
            return opts
        end,
    },
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" }, opts = {} },
            { "theHamsta/nvim-dap-virtual-text", opts = {} },
            { "leoluz/nvim-dap-go", opts = {} },
            {
                "mfussenegger/nvim-dap-python",
                config = function() require("dap-python").setup(("%s/venv/bin/python"):format(install_path("debugpy"))) end,
            },
        },
        keys = {
            { "<LocalLeader>dd", "<CMD>DapToggleBreakpoint<CR>", desc = "[DAP] Toggle Breakpoint" },
            {
                "<LocalLeader>dD",
                function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,
                desc = "[DAP] Breakpoint Condition",
            },
            { "<LocalLeader>do", "<CMD>DapStepOut<CR>", desc = "[DAP] Step Out" },
            { "<LocalLeader>di", "<CMD>DapStepIn<CR>", desc = "[DAP] Step In" },
            { "<LocalLeader>dc", "<CMD>DapContinue<CR>", desc = "[DAP] Continue" },
            { "<LocalLeader>dC", function() require("dap").run_to_cursor() end, desc = "[DAP] Run to Cursor" },
            { "<LocalLeader>du", function() require("dapui").toggle() end, desc = "[DAP] UI Toggle" },
            { "<LocalLeader>dr", function() require("dapui").open({ reset = true }) end, desc = "[DAP] UI Reset" },
            { "<LocalLeader>de", function() require("dapui").eval() end, desc = "[DAP] Eval", mode = { "n", "v" } },
            { "<LocalLeader>dw", function() require("dap.ui.widgets").hover() end, desc = "[DAP] Widgets" },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- stylua: ignore start
            vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
            -- stylua: ignore end

            dap.listeners.before.attach.dapui_config = function() dapui.open() end
            dap.listeners.before.launch.dapui_config = function() dapui.open() end
            dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
            dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

            local _, dap_continue = require("nvim-next.move").make_repeatable_pair(dap.step_back, dap.continue)
            vim.keymap.set("n", "<LocalLeader>dc", dap_continue, { desc = "[DAP] Continue" })

            dap.adapters.php = {
                type = "executable",
                command = "node",
                args = {
                    vim.g.simple_config_php_debug_adapter_path
                        or ("%s/extension/out/phpDebug.js"):format(install_path("php-debug-adapter")),
                },
            }
        end,
    },
    {
        "nvim-telescope/telescope-dap.nvim",
        dependencies = { "mfussenegger/nvim-dap", "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
        keys = {
            { "<LocalLeader>ds", "<CMD>Telescope dap commands<CR>", desc = "[DAP] Commands" },
        },
        config = function() require("telescope").load_extension("dap") end,
    },
}
