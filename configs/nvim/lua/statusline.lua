-- ============================================================================
-- Statusline
-- ============================================================================
-- Configure a custom statusline that shows the current mode, file information,
-- and cursor position.

-- ============================================================================
-- Mode
-- ============================================================================
-- Make the current Vim mode available to the statusline.
-- Statusline expressions run in Vimscript context, so the Lua function must
-- be exposed globally.

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

	return modes[mode] or mode
end

vim.g.statusline_mode = statusline_mode

-- ============================================================================
-- Layout
-- ============================================================================
-- Build the statusline from individual sections.
--
-- %f  = current file name
-- %m  = modified flag
-- %r  = readonly flag
-- %=  = separate left and right sections
-- %l  = current line number
-- %c  = current column number

vim.opt.statusline = table.concat({
	" %{v:lua.vim.g.statusline_mode()}",
	" | ",
	"%f",
	" %m",
	" %r",
	"%=",
	"Ln %l, Col %c ",
})

