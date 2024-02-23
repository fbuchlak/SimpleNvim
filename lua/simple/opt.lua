vim.opt.exrc = true
vim.opt.sessionoptions = { "buffers", "curdir", "help", "tabpages", "winsize", "terminal", "skiprtp" }
vim.opt.compatible = false
vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.updatetime = 100
vim.opt.guicursor = ""
vim.opt.showmode = false
vim.opt.mouse = ""
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.autoread = true
vim.opt.confirm = true
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.virtualedit = "block"
vim.opt.completeopt = "menu,menuone,noselect,preview"
vim.opt.backspace = "indent,eol,nostop"
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore = ".git,*.o"

vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.smartcase = true

vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.shiftround = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

vim.opt.termguicolors = true
vim.opt.cmdheight = 2
vim.opt.winheight = 2
vim.opt.winminheight = 2
vim.opt.winminwidth = 4

vim.opt.colorcolumn = "80,120"
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true

vim.opt.scrolloff = 6
vim.opt.sidescrolloff = 6
vim.opt.wrap = false

vim.opt.list = true
vim.opt.listchars:append("eol:⏎")
vim.opt.listchars:append("tab:⭾ ")
vim.opt.listchars:append("space:·")
vim.opt.listchars:append("trail:·")

vim.opt.undofile = true
vim.opt.undolevels = 10000
