vim.o.showmode = false
vim.o.cmdheight = 0

local function statusline_mode()
	local mode = vim.api.nvim_get_mode().mode

	local modes = {
		n = "NORMAL",
		i = "INSERT",
		v = "VISUAL",
		V = "V-LINE",
		["\22"] = "V-BLOCK",
		R = "REPLACE",
		c = "COMMAND",
		t = "TERM",
	}

	return modes[mode]
end

vim.g.statusline_mode = statusline_mode

vim.opt.statusline = table.concat({
	" ",
	"%{v:lua.vim.g.statusline_mode()}",
	" | ",
	"%f",
	" %m",
	" %r",
	"%=",
	"Ln %l, Col %c ",
})

