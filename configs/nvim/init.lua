vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		require("options")
		require("keymaps")
		require("autocmds")
		require("highlights")
		require("statusline")

		vim.schedule(function()
			require("diagnostics")
		end)
	end,
})

