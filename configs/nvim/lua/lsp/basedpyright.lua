return {
	name = "basedpyright",
	config = {
		filetypes = {
			"python",
		},
		root_markers = {
			"pyproject.toml",
			"setup.py",
			"setup.cfg",
			"requirements.txt",
			"Pipfile",
			"pyrightconfig.json",
			".git",
		},
		cmd = {
			"basedpyright-langserver",
			"--stdio",
		},
		settings = {
			basedpyright = {
				analysis = {
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "workspace",
				},
			},
		},
	},
}

