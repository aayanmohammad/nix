-- ============================================================================
-- Lua Language Server
-- ============================================================================
-- Configuration for lua-language-server.
--
-- This file only describes the server.
-- The loader (lua/lsp.lua) decides when to enable it.

return {
	-- Name used by vim.lsp.config() and vim.lsp.enable().
	name = "lua_ls",

	-- Language server configuration.
	config = {
		-- Filetypes handled by this server.
		filetypes = {
			"lua",
		},

		-- Command used to start the server.
		cmd = {
			"lua-language-server",
		},

		-- Files used to detect the project root.
		root_markers = {
			".luarc.json",
			".luarc.jsonc",
			".git",
		},

		-- Server-specific settings.
		settings = {
			Lua = {
				-- Neovim provides the global "vim" object.
				-- Tell lua_ls not to report it as undefined.
				diagnostics = {
					globals = {
						"vim",
					},
				},

				-- Neovim runs on LuaJIT.
				runtime = {
					version = "LuaJIT",
				},

				-- Do not ask the server to inspect unrelated third-party files.
				workspace = {
					checkThirdParty = false,
				},

				-- Disable sending usage information.
				telemetry = {
					enable = false,
				},
			},
		},
	},
}

