-- ============================================================================
-- Fish Formatter
-- ============================================================================
-- Formatter configuration for Fish shell scripts.
--
-- The main formatter loader uses this information to know:
--   - when this formatter should run
--   - what command to execute
--   - what arguments to pass

return {
	-- Filetypes supported by this formatter.
	filetypes = {
		"fish",
	},

	-- Formatter executable.
	command = "fish_indent",

	-- Arguments passed to the formatter.
	-- Default fish_indent reads from stdin.
	args = {},
}

