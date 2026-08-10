require("options")
require("keymaps")
require("autocmds")
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("highlights")
		require("statusline")

		vim.schedule(function()
			require("diagnostics")
			require("ollama")
		end)
	end,
})

