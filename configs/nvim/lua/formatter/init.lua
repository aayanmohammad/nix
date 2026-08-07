-- ============================================================================
-- Formatter Manager
-- ============================================================================
-- Loads and manages formatter configurations.
--
-- Each formatter file defines:
-- - filetypes
-- - command
-- - args
--
-- Example:
-- lua/formatter/stylua.lua
--
-- This module discovers available formatters, selects the one matching the
-- current buffer, and applies formatting through an external command.

local M = {}

local formatters = {}

local formatter_path = vim.fn.stdpath("config") .. "/lua/formatter"

-- ============================================================================
-- Loading
-- ============================================================================
-- Discover and register all available formatter definitions.

for _, file in ipairs(vim.fn.readdir(formatter_path)) do
	-- Ignore non-Lua files and prevent loading this module recursively.
	if file:match("%.lua$") and file ~= "init.lua" then
		local name = file:gsub("%.lua$", "")

		formatters[name] = require("formatter." .. name)
	end
end

-- ============================================================================
-- Formatting
-- ============================================================================
-- Find and apply the formatter matching the current buffer.

local function get_formatter(filetype)
	for _, formatter in pairs(formatters) do
		if vim.tbl_contains(formatter.filetypes, filetype) then
			return formatter
		end
	end
end

function M.format()
	local formatter = get_formatter(vim.bo.filetype)

	if not formatter then
		vim.notify("No formatter for " .. vim.bo.filetype, vim.log.levels.WARN)
		return
	end

	-- Send the current buffer contents to the formatter process.
	local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")

	local result = vim.system({
		formatter.command,
		unpack(formatter.args),
	}, {
		stdin = content,
		text = true,
	}):wait()

	if result.code ~= 0 then
		vim.notify("Formatting failed:\n" .. result.stderr, vim.log.levels.ERROR)
		return
	end

	-- Replace the buffer contents with the formatter output.
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result.stdout, "\n"))
end

-- Format the buffer before saving.
-- This keeps files consistently formatted without manual commands.
local augroup = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	desc = "Format buffer before saving",

	callback = function()
		require("formatter").format()
	end,
})

-- Format the current buffer manually.
-- This provides a quick way to apply formatting without saving.
vim.keymap.set("n", "<leader>f", function()
	require("formatter").format()
end, {
	desc = "Format current buffer",
})

return M

