-- ============================================================================
-- Nix Language Server
-- ============================================================================
-- Configuration for nixd.
--
-- This file only describes the server.
-- The loader (lua/lsp.lua) decides when to enable it.

return {
	-- Name used by vim.lsp.config() and vim.lsp.enable().
	name = "nixd",

	-- Language server configuration.
	config = {
		-- Filetypes handled by this server.
		filetypes = {
			"nix",
		},

		-- Command used to start the server.
		cmd = {
			"nixd",
		},

		-- Files used to detect the project root.
		root_markers = {
			"flake.nix",
			"default.nix",
			"shell.nix",
			".git",
		},

		-- Server-specific settings.
		settings = {},
	},
}

