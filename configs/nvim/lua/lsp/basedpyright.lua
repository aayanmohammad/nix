-- ============================================================================
-- BasedPyright Language Server
-- ============================================================================
-- Configuration for basedpyright.
--
-- This file only describes the server.
-- The loader (lua/lsp.lua) decides when to enable it.

return {
	-- Name used by vim.lsp.config() and vim.lsp.enable().
	name = "basedpyright",

	-- Language server configuration.
	config = {
		-- Command used to start the server.
		cmd = {
			"basedpyright-langserver",
			"--stdio",
		},

		-- Filetypes handled by this server.
		filetypes = {
			"python",
		},

		-- Files used to detect the project root.
		root_markers = {
			"pyproject.toml",
			"setup.py",
			"setup.cfg",
			"requirements.txt",
			"Pipfile",
			"pyrightconfig.json",
			".git",
		},

		-- Server-specific settings.
		settings = {
			basedpyright = {
				-- Use the project's environment whenever possible.
				analysis = {
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "workspace",
				},
			},
		},
	},
}

