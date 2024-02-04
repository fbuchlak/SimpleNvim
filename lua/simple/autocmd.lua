vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("SimpleResizeFixSplit", { clear = true }),
    command = [[wincmd =]],
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = vim.api.nvim_create_augroup("SimpleChecktime", { clear = true }),
    command = "checktime",
})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("SimpleHighlightYank", { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})

vim.api.nvim_create_autocmd({ "BufNew", "BufEnter", "BufRead" }, {
    group = vim.api.nvim_create_augroup("SimpleFormatoptions", { clear = true }),
    callback = function() vim.opt.formatoptions = vim.opt.formatoptions - "o" + "r" end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("SimpleBufferCloseMap", { clear = true }),
    pattern = {
        "checkhealth",
        "fugitive",
        "fugitiveblame",
        "help",
        "lsp",
        "lspinfo",
        "man",
        "qf",
        "spectre_panel",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<CMD>close<CR>", { buffer = event.buf })
        vim.keymap.set("n", "<ESC>", "<CMD>close<CR>", { buffer = event.buf })
        vim.keymap.set("n", "<Leader>q", "<CMD>close<CR>", { buffer = event.buf })
    end,
})
