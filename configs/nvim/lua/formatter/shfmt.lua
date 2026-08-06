-- ============================================================================
-- Shfmt Formatter
-- ============================================================================
-- Formatter configuration for Bash and shell script files.
--
-- The main formatter loader uses this information to know:
--   - when this formatter should run
--   - what command to execute
--   - what arguments to pass

return {
	-- Filetypes supported by this formatter.
	filetypes = {
		"sh",
		"bash",
		"zsh",
	},

	-- Formatter executable.
	command = "shfmt",

	-- Arguments passed to the formatter.
	-- Reads from stdin and writes formatted output to stdout.
	args = {
		"-",
	},
}
