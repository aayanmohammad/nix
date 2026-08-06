-- ============================================================================
-- Nixfmt Formatter
-- ============================================================================
-- Formatter configuration for Nix files.
--
-- The main formatter loader uses this information to know:
--   - when this formatter should run
--   - what command to execute
--   - what arguments to pass

return {
	-- Filetypes supported by this formatter.
	filetypes = {
		"nix",
	},

	-- Formatter executable.
	command = "nixfmt",

	-- Arguments passed to the formatter.
	-- "-" tells nixfmt to read from stdin.
	args = {
		"-",
	},
}
