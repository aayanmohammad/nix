-- ============================================================================
-- Core Configuration
-- ============================================================================
-- Load settings that should exist immediately when Neovim starts.

require("options")
require("keymaps")
require("autocmds")
require("highlights")
require("statusline")

-- ============================================================================
-- Deferred Features
-- ============================================================================
-- Load features after startup so they do not block the first screen render.

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		vim.schedule(function()
			require("diagnostics")
		end)
	end,
})

