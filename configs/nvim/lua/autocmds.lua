local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	desc = "Enable writing features for text files",

	pattern = {
		"markdown",
		"text",
		"gitcommit",
	},

	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	desc = "Highlight text after yanking",
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then
			return
		end

		if vim.bo.buftype ~= "" then
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"')
		local last_line = vim.api.nvim_buf_line_count(0)
		local row = last_pos[1]

		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	group = augroup,
	desc = "Keep focus on netrw while it is open",
	callback = function(args)
		if vim.bo[args.buf].filetype == "netrw" then
			return
		end

		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)

			if vim.bo[buf].filetype == "netrw" then
				vim.api.nvim_set_current_win(win)
				return
			end
		end
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup,
	desc = "Open directories in a vertical netrw explorer",
	callback = function()
		vim.cmd("silent! autocmd! FileExplorer")

		if vim.fn.argc() == 0 or (vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1) then
			vim.schedule(function()
				vim.cmd("Vexplore")
				vim.wo.statusline = " "
			end)
		end
	end,
})

vim.api.nvim_create_autocmd("CmdlineChanged", {
	group = augroup,
	desc = "Trigger wildmenu completion while typing",
	callback = function()
		vim.fn.wildtrigger()
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	desc = "Format buffer before saving",
	callback = function()
		require("formatter").format()
	end,
})

local ignored_filetypes = {
	markdown = true,
	gitcommit = true,
	text = true,
}

vim.api.nvim_create_autocmd("TextChangedI", {
	group = augroup,
	desc = "Trigger omnifunc completion while typing",
	callback = function()
		if ignored_filetypes[vim.bo.filetype] then
			return
		end

		if vim.bo.omnifunc == "" then
			return
		end

		if vim.fn.pumvisible() == 1 then
			return
		end

		local _, col = unpack(vim.api.nvim_win_get_cursor(0))
		local text = vim.api.nvim_get_current_line():sub(1, col)

		if text == "" then
			return
		end

		if not text:match("[%w_]$") then
			return
		end

		vim.schedule(function()
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-o>", true, false, true), "n", false)
		end)
	end,
})

