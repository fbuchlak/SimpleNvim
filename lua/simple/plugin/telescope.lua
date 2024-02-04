return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-telescope/telescope-symbols.nvim",
        },
        cmd = "Telescope",
        opts = {
            defaults = {
                multi_icon = require("simple.config.icons").common.Checkbox,
                prompt_prefix = require("simple.config.icons").common.Search,
                preview = { filesize_limit = 1 },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
                symbols = {},
            },
        },
        keys = function(_, keys)
            local T = require("simple.util.telescope")

            local grep_open_files = function(opts) opts.grep_open_files = true end
            vim.list_extend(keys, {
                T.key(T.opts("r", "resume", function(opts) opts.prompt_title = nil end)),
                T.key(T.opts("?", "builtin", function(opts) opts.include_extensions = true end)),
                T.key(T.opts('"', "registers")),
                T.key(T.opts(":", "command_history")),
                T.key(T.opts("/", "current_buffer_fuzzy_find", nil, "Buffer Fuzzy")),
                T.key(T.opts("b", "buffers", function(opts) opts.sort_mru = true end)),
                T.key(T.opts("d", "diagnostics")),
                T.key(T.opts("h", "help_tags")),
                T.key(T.opts("H", "search_history")),
                T.key(T.opts("j", "jumplist")),
                T.key(T.opts("m", "symbols")),
                T.key(T.opts("q", "quickfix")),
                T.key(T.opts("S", "spell_suggest")),
                T.key(T.opts("gb", "git_bcommits", nil, "Buffer Commits")),
                T.key(T.opts("gc", "git_commits")),
                T.key(T.opts("gf", "git_files", function(opts) opts.show_untracked = true end)),
                T.key(T.opts("gs", "git_status")),
                T.key(T.opts("os", "live_grep", grep_open_files)),
                T.key(T.opts("ow", "grep_string", grep_open_files, false)),
            })

            local add_variants = function(...) vim.list_extend(keys, T.key_variants(T.opts(...))) end
            local add_input_variants = function(...) vim.list_extend(keys, T.key_input_variants(...)) end
            add_variants("e", "oldfiles", function(opts, relative) opts.only_cwd = not relative end)
            add_variants("f", "find_files")
            add_variants("s", "live_grep")
            add_variants("w", "grep_string", nil, false)
            add_input_variants(T.opts("xs", "live_grep", nil, "Glob Live Grep"), "glob_pattern", "*")

            return keys
        end,
        config = function(_, opts)
            vim.api.nvim_create_autocmd("User", {
                pattern = "TelescopePreviewerLoaded",
                callback = function(args)
                    vim.wo.wrap = false
                    if args.data.filetype ~= "help" then vim.wo.number = true end
                end,
            })

            local actions = require("telescope.actions")
            local yank_entry = function()
                local entry = require("telescope.actions.state").get_selected_entry()
                if nil ~= entry then
                    local text = entry.text or entry.ordinal
                    require("simple.util.notify").info(("Yanked %q"):format(text))
                    vim.fn.setreg('"', text)
                end
            end
            local control_actions = {
                ["<C-Space>"] = actions.toggle_selection + actions.move_selection_worse,
                ["<C-n>"] = actions.move_selection_next,
                ["<C-p>"] = actions.move_selection_previous,
                ["<C-i>"] = actions.cycle_history_next,
                ["<C-o>"] = actions.cycle_history_prev,
                ["<C-t>"] = actions.complete_tag,
                ["<C-h>"] = actions.preview_scrolling_left,
                ["<C-j>"] = actions.preview_scrolling_down,
                ["<C-k>"] = actions.preview_scrolling_up,
                ["<C-l>"] = actions.preview_scrolling_right,
                ["<C-a>"] = actions.send_selected_to_qflist + actions.open_qflist,
                ["<C-y>"] = yank_entry,
            }
            local defaults = require("telescope.themes").get_dropdown({
                buffer_previewer_maker = function(path, bufnr, preview_opts)
                    preview_opts = preview_opts or {}
                    if preview_opts.use_ft_detect == nil then preview_opts.use_ft_detect = true end
                    preview_opts.use_ft_detect = true == preview_opts.use_ft_detect
                        or not require("simple.util").has_min_bytes_per_line(path, 300)
                    return require("telescope.previewers").buffer_previewer_maker(path, bufnr, preview_opts)
                end,
                layout_config = {
                    width = 0.85,
                    height = function(o, _, max_height) return math.floor(max_height * (o.previewer and 0.35 or 1)) end,
                    anchor = "N",
                    prompt_position = "top",
                    mirror = true,
                },
                borderchars = {
                    { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                    prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
                    results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
                    preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                },
                mappings = {
                    i = control_actions,
                    n = vim.tbl_deep_extend("force", { q = actions.close }, control_actions),
                },
            })
            opts.defaults = vim.tbl_deep_extend("keep", opts.defaults or {}, defaults)

            require("telescope").setup(opts)
            require("telescope").load_extension("fzf")
        end,
        init = function()
            vim.api.nvim_create_autocmd("User", {
                group = vim.api.nvim_create_augroup("SimpleTelescopeFindPreCloseFloating", { clear = true }),
                pattern = "TelescopeFindPre",
                callback = function()
                    if vim.bo.filetype == "lazy" and require("simple.util").is_win_floating() then vim.cmd.close() end
                end,
            })
        end,
    },
}
