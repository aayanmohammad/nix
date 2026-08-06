-- ============================================================================
-- Stylua Formatter
-- ============================================================================
-- Formatter configuration for Lua files.
--
-- The main formatter loader uses this information to know:
--   - when this formatter should run
--   - what command to execute
--   - what arguments to pass

return {
	-- Filetypes supported by this formatter.
	filetypes = {
		"lua",
	},

	-- Formatter executable.
	command = "stylua",

	-- Arguments passed to the formatter.
	-- "-" tells stylua to read from stdin.
	args = {
		"-",
	},
}

