return {
    { "tpope/vim-repeat", event = "VeryLazy" },
    { "tpope/vim-abolish", cmd = { "Abolish", "S", "Subvert" } },
    { "tpope/vim-eunuch", event = "VeryLazy" },
    { "sQVe/sort.nvim", cmd = "Sort" },
    { "AndrewRadev/bufferize.vim", cmd = "Bufferize" },
    {
        "ghostbuster91/nvim-next",
        lazy = false,
        opts = { default_mappings = { original = true } },
        config = function(_, opts)
            local next = require("nvim-next")
            local move = require("nvim-next.move")
            next.setup(opts)

            local functions = require("nvim-next.builtins.functions")
            local f_backward, f_forward = move.make_repeatable_pair(functions.F, functions.f)
            vim.keymap.set({ "n", "x" }, "F", f_backward)
            vim.keymap.set({ "n", "x" }, "f", f_forward)
            local t_backward, t_forward = move.make_repeatable_pair(functions.T, functions.t)
            vim.keymap.set({ "n", "x" }, "T", t_backward)
            vim.keymap.set({ "n", "x" }, "t", t_forward)

            -- stylua: ignore start
            local diagnostic = require("nvim-next.integrations").diagnostic()
            vim.keymap.set("n", "[d", diagnostic.goto_prev({ severity = nil }), { desc = "Previous diagnostic" })
            vim.keymap.set("n", "]d", diagnostic.goto_next({ severity = nil }), { desc = "Next diagnostic" })
            vim.keymap.set("n", "[e", diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }), { desc = "Previous diagnostic error" })
            vim.keymap.set("n", "]e", diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }), { desc = "Next diagnostic error" })
            vim.keymap.set("n", "[w", diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN }), { desc = "Previous diagnostic warning" })
            vim.keymap.set("n", "]w", diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN }), { desc = "Next diagnostic warning" })
            -- stylua: ignore end
        end,
    },
    {
        "chrishrb/gx.nvim",
        submodules = false,
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = "Browse",
        keys = { { "gx", "<CMD>Browse<CR>", desc = "Open", mode = { "n", "x" } } },
        opts = { handlers = { search = false } },
        init = function() vim.g.netrw_nogx = 1 end,
    },
    {
        "echasnovski/mini.bufremove",
        keys = {
            {
                "<Leader>q",
                function()
                    local force = false
                    if vim.bo.modified then
                        local c = vim.fn.confirm(
                            ("Save changes to %q?"):format(vim.api.nvim_buf_get_name(0)),
                            "&Yes\n&No\n&Cancel"
                        )
                        if 1 == c then vim.cmd.w() end
                        force = 2 == c
                    end
                    force = force == true
                    require("mini.bufremove").delete(0, force)
                    if require("simple.util").is_win_floating(0) then vim.cmd.close() end
                end,
                desc = "[Buf] Delete",
            },
        },
    },
    {
        "kndndrj/nvim-projector",
        dependencies = { "MunifTanjim/nui.nvim" },
        cmd = "Projector",
        config = true,
    },
    {
        "christoomey/vim-tmux-navigator",
        keys = {
            { "<C-h>", desc = "[Pane] Left" },
            { "<C-j>", desc = "[Pane] Down" },
            { "<C-k>", desc = "[Pane] Up" },
            { "<C-l>", desc = "[Pane] Right" },
            { "<C-\\>", desc = "[Pane] Previous" },
        },
    },
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = { options = vim.opt.sessionoptions:get() },
        init = function()
            vim.api.nvim_create_user_command("PersistenceLoad", function() require("persistence").load() end, {})
            vim.api.nvim_create_user_command("PersistenceStop", function() require("persistence").stop() end, {})
        end,
    },
    {
        "echasnovski/mini.starter",
        event = "VimEnter",
        opts = {
            evaluate_single = true,
            header = "",
            items = {
                { name = "Load session", action = "PersistenceLoad" },
                { name = "Check updates", action = "Lazy check" },
                {
                    name = "Update",
                    action = function()
                        vim.cmd("TSUpdate|MasonUpdate")
                        vim.cmd("Lazy update")
                    end,
                },
                { name = "Profile", action = "Lazy profile" },
                { name = "Quit", action = "qall" },
            },
            footer = "",
            content_hooks = {},
        },
        config = function(_, opts)
            if "lazy" == vim.bo.filetype then
                vim.cmd.close()
                vim.api.nvim_create_autocmd("User", {
                    pattern = "MiniStarterOpened",
                    callback = function()
                        require("lazy").show()
                        vim.cmd("DotfyleGenerate")
                    end,
                    once = true,
                })
            end

            local starter = require("mini.starter")
            opts.content_hooks[#opts.content_hooks + 1] = starter.gen_hook.aligning("center", "center")
            opts.content_hooks[#opts.content_hooks + 1] = starter.gen_hook.adding_bullet("| ", false)
            for _, item in ipairs(opts.items) do
                if nil == item.section then item.section = "" end
            end
            starter.setup(opts)
        end,
    },
    {
        "echasnovski/mini.files",
        opts = {
            options = { use_as_default_explorer = true },
            windows = { preview = true, width_focus = 40, width_no_focus = 20, width_preview = 80 },
        },
        config = function(_, opts)
            vim.api.nvim_create_autocmd("User", {
                group = vim.api.nvim_create_augroup("MiniFilesMapping", { clear = true }),
                pattern = "MiniFilesBufferCreate",
                callback = function(args)
                    local minifiles = require("mini.files")
                    local mopts = { buffer = args.data.buf_id }
                    vim.keymap.set("n", "q", minifiles.close, mopts)
                    vim.keymap.set("n", "<Esc>", minifiles.close, mopts)
                    vim.keymap.set("n", "<Leader>q", minifiles.close, mopts)
                    vim.keymap.set({ "n", "i", "v" }, "<C-s>", minifiles.synchronize, mopts)
                end,
            })

            require("mini.files").setup(opts)
        end,
        keys = {
            { "<Leader>ee", function() require("mini.files").open() end, desc = "[Filesystem] Open" },
            { "<Leader>ed", function() require("mini.files").open(nil, false) end, desc = "[Filesystem] Open Cwd" },
            {
                "<Leader>er",
                function()
                    local ok, _ = pcall(require("mini.files").open, vim.api.nvim_buf_get_name(0))
                    if not ok then require("mini.files").open() end
                end,
                desc = "[Filesystem] Open Current Buffer Directory",
            },
        },
    },
    {
        "fbuchlak/telescope-directory.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
        opts = {
            features = {
                { name = "minifiles_open", callback = function(dirs) require("mini.files").open(dirs[1]) end },
            },
        },
        keys = {
            {
                "<Leader>es",
                function()
                    require("telescope-directory").directory({
                        feature = "minifiles_open",
                        prompt_title = "Open Directory",
                    })
                end,
                desc = "[Filesystem] Open Directory",
            },
            {
                "<Leader>eS",
                function()
                    require("telescope-directory").directory({
                        feature = "minifiles_open",
                        prompt_title = "Open Directory",
                        hidden = true,
                        no_ignore = true,
                    })
                end,
                desc = "[Filesystem][Hidden] Open Directory",
            },
        },
    },
    {
        "mbbill/undotree",
        cmd = "UndotreeToggle",
        keys = { { "<LocalLeader>u", "<CMD>UndotreeToggle<CR>", desc = "[UndoTree] Toggle" } },
        config = true,
    },
    {
        "kevinhwang91/nvim-fundo",
        dependencies = { "kevinhwang91/promise-async" },
        event = "BufReadPost",
        build = function() require("fundo").install() end,
        config = true,
    },
    {
        "LunarVim/bigfile.nvim",
        lazy = false,
        opts = {
            filesize_mib = 1,
            features = {
                "indent_blankline",
                "illuminate",
                "lsp",
                "treesitter",
                "syntax",
                "vimopts",
                "filetype",
                { name = "nvim_cmp", disable = function() vim.cmd("CompletionDisable") end },
                { name = "mini_indentscope", disable = function() vim.b.miniindentscope_disable = true end },
            },
            pattern = function(bufnr)
                local has_fname, fname = pcall(vim.api.nvim_buf_get_name, bufnr)
                if not has_fname then return false end

                if require("simple.util").is_binary(fname) then return true end

                local has_fsize, fsize = pcall(vim.fn.getfsize, fname)
                if not has_fsize then return false end

                local has_lines, lines = pcall(vim.fn.readfile, fname)
                if not has_lines then return false end

                return 15000 < #lines or #lines * 500 < fsize
            end,
        },
    },
}
