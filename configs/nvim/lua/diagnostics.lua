vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	underline = true,
	float = {
		border = "rounded",
		source = true,
		header = "",
		prefix = "",
		focusable = false,
		style = "minimal",
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "X",
			[vim.diagnostic.severity.WARN] = "!",
			[vim.diagnostic.severity.INFO] = "i",
			[vim.diagnostic.severity.HINT] = "?",
		},
	},
})

require("lsp").setup()

local original_open_floating_preview = vim.lsp.util.open_floating_preview

vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or "rounded"

	return original_open_floating_preview(contents, syntax, opts, ...)
end

local lsp_group = vim.api.nvim_create_augroup("LspConfig", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = lsp_group,
	desc = "Configure LSP keymaps",
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)

		if not client then
			return
		end

		vim.keymap.set("n", "K", vim.lsp.buf.hover, {
			buffer = event.buf,
			desc = "Show hover documentation",
		})

		vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {
			buffer = event.buf,
			desc = "Go to definition",
		})

		vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, {
			buffer = event.buf,
			desc = "Go to declaration",
		})

		vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, {
			buffer = event.buf,
			desc = "Go to implementation",
		})

		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {
			buffer = event.buf,
			desc = "Code action",
		})

		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {
			buffer = event.buf,
			desc = "Rename symbol",
		})

		vim.keymap.set("n", "<leader>d", function()
			vim.diagnostic.open_float({ scope = "cursor" })
		end, {
			buffer = event.buf,
			desc = "Show cursor diagnostics",
		})

		vim.keymap.set("n", "<leader>D", function()
			vim.diagnostic.open_float({ scope = "line" })
		end, {
			buffer = event.buf,
			desc = "Show line diagnostics",
		})

		vim.keymap.set("n", "dn", function()
			vim.diagnostic.jump({ count = 1 })
		end, {
			buffer = event.buf,
			desc = "Next diagnostic",
		})

		vim.keymap.set("n", "dN", function()
			vim.diagnostic.jump({ count = -1 })
		end, {
			buffer = event.buf,
			desc = "Previous diagnostic",
		})
	end,
})

