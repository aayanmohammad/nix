return {
	name = "lua_ls",
	config = {
		filetypes = {
			"lua",
		},
		root_markers = {
			".luarc.json",
			".luarc.jsonc",
			".git",
		},
		cmd = {
			"lua-language-server",
		},
		settings = {
			Lua = {
				diagnostics = {
					globals = {
						"vim",
					},
				},
				runtime = {
					version = "LuaJIT",
				},
				workspace = {
					checkThirdParty = false,
				},
				telemetry = {
					enable = false,
				},
			},
		},
	},
}

