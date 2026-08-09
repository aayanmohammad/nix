return {
	name = "nixd",
	config = {
		filetypes = {
			"nix",
		},
		root_markers = {
			"flake.nix",
			"default.nix",
			"shell.nix",
			".git",
		},
		cmd = {
			"nixd",
		},
		settings = {},
	},
}

