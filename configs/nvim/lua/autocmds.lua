-- ============================================================================
-- Augroups
-- ============================================================================
-- Autocommand groups organize related autocmds together.
-- Clearing the group first prevents duplicate autocmds when this file is
-- reloaded during development.

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- ============================================================================
-- Editing
-- ============================================================================
-- Autocmds that improve the general editing experience.

-- Briefly highlight text after yanking (copying).
-- This gives visual feedback showing what was copied.
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	desc = "Highlight text after yanking",

	callback = function()
		vim.hl.on_yank()
	end,
})

-- Restore the cursor position from the last time a file was opened.
-- This allows reopening a file and continuing where you stopped.
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",

	callback = function()
		-- Do not restore positions while viewing diffs because diff windows
		-- have their own navigation behavior.
		if vim.o.diff then
			return
		end

		-- Skip special buffers (help, terminal, etc.).
		if vim.bo.buftype ~= "" then
			return
		end

		-- The '"' mark stores the last cursor position before leaving a file.
		local last_pos = vim.api.nvim_buf_get_mark(0, '"')

		-- Get the current number of lines to make sure the saved position
		-- is still valid.
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]

		-- Ignore invalid positions (for example, when the file changed).
		if row < 1 or row > last_line then
			return
		end

		-- Move the cursor back to the saved location.
		-- pcall prevents errors if the position cannot be restored.
		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- Keep the focus on netrw while it is open.
-- If another buffer is entered while a visible netrw window exists,
-- immediately return focus to the netrw window. Once the netrw window
-- is closed, this behavior automatically stops.
vim.api.nvim_create_autocmd("BufEnter", {
	group = augroup,
	desc = "Keep focus on netrw while it is open",

	callback = function(args)
		-- Ignore the event if we've already entered the netrw buffer.
		if vim.bo[args.buf].filetype == "netrw" then
			return
		end

		-- Look for a visible netrw window and return focus to it.
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)

			if vim.bo[buf].filetype == "netrw" then
				vim.api.nvim_set_current_win(win)
				return
			end
		end
	end,
})

-- Replace netrw's default directory buffer when launching Neovim with
-- a directory path (e.g. `nvim .`) by opening the directory in a
-- vertical explorer split using `:Vexplore`.
vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup,
	desc = "Open directories in a vertical netrw explorer",

	callback = function()
		vim.cmd("silent! autocmd! FileExplorer")
		if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
			vim.cmd("Vexplore")
			vim.wo.statusline = " "
		end
	end,
})

-- ============================================================================
-- Filetypes
-- ============================================================================
-- Apply special settings to specific types of files.

-- Enable writing-friendly settings for documents and commit messages.
-- These settings make prose easier to read and edit.
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	desc = "Enable writing features for text files",

	pattern = {
		"markdown",
		"text",
		"gitcommit",
	},

	callback = function()
		-- Allow text to wrap instead of forcing horizontal scrolling.
		vim.opt_local.wrap = true

		-- Wrap long lines at word boundaries instead of splitting words.
		vim.opt_local.linebreak = true

		-- Enable spell checking for writing.
		vim.opt_local.spell = true
	end,
})

