return {
	name = "bashls",
	config = {
		filetypes = {
			"sh",
			"bash",
		},
		root_markers = {
			".git",
		},
		cmd = {
			"bash-language-server",
			"start",
		},
	},
}

