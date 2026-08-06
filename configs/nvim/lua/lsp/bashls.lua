-- ============================================================================
-- Bash Language Server
-- ============================================================================
-- Configuration for bash-language-server.
--
-- This file only describes the server.
-- The loader (lua/lsp.lua) decides when to enable it.

return {
	-- Name used by vim.lsp.config() and vim.lsp.enable().
	name = "bashls",

	-- Language server configuration.
	config = {
		-- Filetypes handled by this server.
		filetypes = {
			"sh",
			"bash",
			"zsh",
		},

		-- Command used to start the server.
		cmd = {
			"bash-language-server",
			"start",
		},

		-- Files used to detect the project root.
		root_markers = {
			".git",
		},
	},
}
