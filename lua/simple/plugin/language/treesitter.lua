return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects", "gbprod/php-enhanced-treesitter.nvim" },
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile", "VeryLazy" },
        cmd = { "TSUpdate", "TSUpdateSync" },
        opts = {
            -- stylua: ignore
            ensure_installed = {
                "markdown", "markdown_inline",
                "bash", "diff", "make", "regex", "query", "tmux", "gitignore", "ini", "dockerfile", "printf",
                "json", "json5", "jsonc", "toml", "xml", "yaml",
                "sql",
                "html", "css", "scss",
                "javascript", "jsdoc", "typescript", "tsx", "svelte", "vue", "angular",
                "lua", "luap", "luadoc", "vim", "vimdoc",
                "c", "cpp",
                "go", "gomod", "gowork", "gosum", "templ",
                "rust", "ron",
                "php", "php_only", "phpdoc", "twig", "blade",
                "python", "requirements", "ninja",
                "terraform", "hcl"
            },
            indent = { enable = true },
            highlight = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-Space>",
                    node_incremental = "<C-Space>",
                    scope_incremental = "<Leader><Leader>",
                    node_decremental = "<Bs>",
                },
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["ah"] = "@assignment.inner",
                        ["al"] = "@assignment.outer",
                        ["ih"] = "@assignment.lhs",
                        ["il"] = "@assignment.rhs",
                        ["ik"] = "@class.inner",
                        ["ak"] = "@class.outer",
                        ["a8"] = "@comment.outer",
                        ["i8"] = "@comment.outer",
                        ["i3"] = "@conditional.inner",
                        ["a3"] = "@conditional.outer",
                        ["ax"] = "@constructor",
                        ["im"] = "@function.inner",
                        ["am"] = "@function.outer",
                        ["ij"] = "@loop.inner",
                        ["aj"] = "@loop.outer",
                        ["ir"] = "@parameter.inner",
                        ["ar"] = "@parameter.outer",
                        ["in"] = "@return.inner",
                        ["an"] = "@return.outer",
                    },
                },
                swap = {
                    enable = true,
                    repeatable = true,
                    swap_next = {
                        ["]qk"] = "@class.outer",
                        ["]qm"] = "@function.outer",
                        ["]qr"] = "@parameter.inner",
                    },
                    swap_previous = {
                        ["[qk"] = "@class.outer",
                        ["[qm"] = "@function.outer",
                        ["[qr"] = "@parameter.inner",
                    },
                },
                lsp_interop = {
                    enable = true,
                    peek_definition_code = { ["<Leader>ll"] = "@_start" },
                },
            },
            nvim_next = {
                enable = true,
                textobjects = {
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            ["]k"] = "@class.outer",
                            ["]8"] = "@comment.outer",
                            ["]/"] = "@comment.outer",
                            ["]3"] = "@conditional.outer",
                            ["]m"] = "@function.outer",
                            ["]j"] = "@loop.outer",
                            ["]r"] = "@parameter.inner",
                            ["]n"] = "@return.outer",
                        },
                        goto_next_end = {
                            ["]K"] = "@class.outer",
                            ["]*"] = "@comment.outer",
                            ["]?"] = "@comment.outer",
                            ["]#"] = "@conditional.outer",
                            ["]M"] = "@function.outer",
                            ["]J"] = "@loop.outer",
                            ["]R"] = "@parameter.inner",
                            ["]N"] = "@return.outer",
                        },
                        goto_previous_start = {
                            ["[k"] = "@class.outer",
                            ["[8"] = "@comment.outer",
                            ["[/"] = "@comment.outer",
                            ["[3"] = "@conditional.outer",
                            ["[m"] = "@function.outer",
                            ["[j"] = "@loop.outer",
                            ["[r"] = "@parameter.inner",
                            ["[n"] = "@return.outer",
                        },
                        goto_previous_end = {
                            ["[K"] = "@class.outer",
                            ["[*"] = "@comment.outer",
                            ["[?"] = "@comment.outer",
                            ["[#"] = "@conditional.outer",
                            ["[M"] = "@function.outer",
                            ["[J"] = "@loop.outer",
                            ["[R"] = "@parameter.inner",
                            ["[N"] = "@return.outer",
                        },
                    },
                },
            },
        },
        config = function(_, opts)
            local configs = require("nvim-treesitter.parsers").get_parser_configs()
            configs.blade = {
                install_info = {
                    url = "https://github.com/EmranMR/tree-sitter-blade",
                    files = { "src/parser.c" },
                    branch = "main",
                },
                filetype = "blade",
            }
            vim.filetype.add({
                pattern = {
                    [".*%.blade%.php"] = "blade",
                },
            })

            require("nvim-next.integrations").treesitter_textobjects()
            require("nvim-treesitter.configs").setup(opts)
        end,
        init = function(plugin)
            require("lazy.core.loader").add_to_rtp(plugin)
            require("nvim-treesitter.query_predicates")
        end,
    },
    {
        "overleaf/vim-env-syntax",
        event = { "BufNew", "BufReadPre" },
        init = function()
            vim.api.nvim_create_autocmd({ "BufNew", "BufReadPre" }, {
                pattern = ".env*",
                command = "set filetype=env",
            })
        end,
    },
}
