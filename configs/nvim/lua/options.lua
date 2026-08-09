vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = 25

vim.o.shortmess = vim.o.shortmess .. "I"

vim.o.termguicolors = true

vim.o.wrap = false
vim.o.number = true
vim.o.relativenumber = true

vim.opt.guicursor = "a:block-blinkwait0-blinkon500-blinkoff500"
vim.o.cursorline = true
vim.o.cursorcolumn = true

vim.opt.colorcolumn = "80"
vim.o.signcolumn = "yes"

vim.o.showmode = false
vim.o.cmdheight = 1

vim.opt.fillchars = { eob = " " }

vim.o.concealcursor = ""
vim.o.synmaxcol = 300

vim.o.pumborder = "rounded"
vim.o.winborder = "rounded"

vim.o.smartindent = true
vim.o.autoindent = true

vim.o.expandtab = true

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

vim.o.backspace = "indent,eol,start"

vim.o.selection = "inclusive"

vim.opt.iskeyword:append("-")

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.hlsearch = true
vim.o.incsearch = true

vim.opt.path:append("**")

vim.o.scrolloff = 999
vim.o.sidescrolloff = 999

vim.o.splitbelow = true
vim.o.splitright = true

vim.o.completeopt = "menuone,noinsert,noselect"
vim.o.pumheight = 10

vim.o.wildmenu = true
vim.o.wildmode = "noselect:full,full"

vim.o.undofile = true
vim.o.swapfile = false

vim.o.writebackup = false
vim.o.backup = false

vim.o.autowrite = false
vim.o.autoread = true

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		vim.schedule(function()
			vim.opt_local.foldmethod = "expr"
			vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.opt_local.foldlevel = 99
		end)
	end,
})

vim.o.updatetime = 300
vim.o.timeoutlen = 500
vim.o.ttimeoutlen = 50
vim.o.autochdir = false
vim.opt.diffopt:append("linematch:60")
vim.o.redrawtime = 10000
vim.o.maxmempattern = 20000

