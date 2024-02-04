local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- stylua: ignore
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
---@diagnostic disable-next-line: param-type-mismatch
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { import = "simple.plugin" },
        { import = "simple.plugin.language" },
    },
    defaults = { version = false, lazy = true },
    install = { colorscheme = { "catppuccin", "default" } },
    change_detection = { enabled = false },
    performance = {
        cache = { enabled = true },
        rtp = { disabled_plugins = { "gzip", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
    },
})

vim.cmd.colorscheme("catppuccin")
