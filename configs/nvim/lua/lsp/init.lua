local M = {}

local lsp_path = vim.fn.stdpath("config") .. "/lua/lsp"

local servers = {}

function M.setup()
	for _, file in ipairs(vim.fn.readdir(lsp_path)) do
		if file:match("%.lua$") and file ~= "init.lua" then
			local name = file:gsub("%.lua$", "")

			local ok, server = pcall(require, "lsp." .. name)

			if ok then
				servers[server.name] = server

				vim.lsp.config(server.name, server.config)
			else
				vim.notify("Failed loading LSP: " .. name, vim.log.levels.ERROR)
			end
		end
	end

	for _, server in pairs(servers) do
		vim.lsp.enable(server.name)
	end
end

return M

