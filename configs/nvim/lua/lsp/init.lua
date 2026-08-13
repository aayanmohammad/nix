local M = {}

local lsp_path = vim.fn.stdpath("config") .. "/lua/lsp"

function M.setup()
	local files = vim.fn.readdir(lsp_path)

	vim.schedule(function()
		for _, file in ipairs(files) do
			if file:match("%.lua$") and file ~= "init.lua" then
				local name = file:gsub("%.lua$", "")

				local ok, server = pcall(require, "lsp." .. name)

				if not ok then
					vim.notify("Failed loading LSP: " .. name, vim.log.levels.ERROR)
					goto continue
				end

				vim.lsp.config(server.name, server.config)
				vim.lsp.enable(server.name)

				::continue::
			end
		end
	end)
end

return M

