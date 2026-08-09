return {
	name = "fish_lsp",
	config = {
		filetypes = {
			"fish",
		},
		root_markers = {
			".git",
		},
		cmd = {
			"fish-lsp",
			"start",
		},
		settings = {},
	},
}

