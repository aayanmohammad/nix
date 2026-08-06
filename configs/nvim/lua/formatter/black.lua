-- ============================================================================
-- Black Formatter
-- ============================================================================
-- Formatter configuration for Python files.
--
-- The main formatter loader uses this information to know:
--   - when this formatter should run
--   - what command to execute
--   - what arguments to pass

return {
	-- Filetypes supported by this formatter.
	filetypes = {
		"python",
	},

	-- Formatter executable.
	command = "black",

	-- Arguments passed to the formatter.
	-- "-" tells black to read from stdin.
	args = {
		"-",
		"--quiet",
	},
}

