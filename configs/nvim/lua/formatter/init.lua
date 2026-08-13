local M = {}

local formatter_path = vim.fn.stdpath("config") .. "/lua/formatter"

local formatters = {}

for _, file in ipairs(vim.fn.readdir(formatter_path)) do
	if file:match("%.lua$") and file ~= "init.lua" then
		local name = file:gsub("%.lua$", "")

		formatters[name] = require("formatter." .. name)
	end
end

function M.format()
	local filetype = vim.bo.filetype
	local formatter

	for _, candidate in pairs(formatters) do
		if vim.tbl_contains(candidate.filetypes, filetype) then
			formatter = candidate
			break
		end
	end

	if not formatter then
		vim.notify("No formatter for " .. filetype, vim.log.levels.WARN)
		return
	end

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

	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result.stdout, "\n"))
end

return M

