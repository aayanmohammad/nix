-- ============================================================================
-- LSP Manager
-- ============================================================================
-- Discovers, configures, and enables all available LSP servers.
--
-- Each server definition lives in:
--
--   lua/lsp/<server>.lua
--
-- A server module returns:
--
--   name       - Unique server name.
--   filetypes  - Supported filetypes.
--   config     - vim.lsp.config() configuration.
--
-- Setup:
--   1. Loads every server definition.
--   2. Registers every server configuration.
--   3. Enables every server asynchronously.
--
-- Neovim handles attaching servers to buffers automatically based on the
-- configured filetypes.
-- ============================================================================

local M = {}

local servers = {}

local lsp_path = vim.fn.stdpath("config") .. "/lua/lsp"

function M.setup()
	-- Discover and configure all servers.
	for _, file in ipairs(vim.fn.readdir(lsp_path)) do
		if file:match("%.lua$") and file ~= "init.lua" then
			local name = file:gsub("%.lua$", "")

			local ok, server = pcall(require, "lsp." .. name)

			if ok then
				servers[server.name] = server

				-- Register server configuration.
				vim.lsp.config(server.name, server.config)
			else
				vim.notify("Failed loading LSP: " .. name, vim.log.levels.ERROR)
			end
		end
	end

	-- Enable all configured servers after startup.
	vim.schedule(function()
		for _, server in pairs(servers) do
			vim.lsp.enable(server.name)
		end
	end)
end

return M

