-- ============================================================================
-- Fish Language Server
-- ============================================================================
-- Configuration for fish-lsp.
--
-- This file only describes the server.
-- The loader (lua/lsp.lua) decides when to enable it.

return {
	-- Name used by vim.lsp.config() and vim.lsp.enable().
	name = "fish_lsp",

	-- Language server configuration.
	config = {
		-- Filetypes handled by this server.
		filetypes = {
			"fish",
		},

		-- Command used to start the server.
		cmd = {
			"fish-lsp",
			"start",
		},

		-- Files used to detect the project root.
		root_markers = {
			".git",
		},

		-- Server-specific settings.
		settings = {},
	},
}

