-- ============================================================================
-- LSP Setup
--
-- Configures and Enables LSP servers
--
-- The LSP definitions live in:
-- lua/lsp/*.lua
--
-- The loader:
-- lua/lsp/init.lua
-- Loads LSP asynchronously for Neovim to auto-attach
-- ============================================================================
require("lsp").setup()

-- ============================================================================
-- LSP UI
-- ============================================================================
-- Customize built-in LSP floating windows.

-- Give all LSP floating windows rounded borders by default.
local original_open_floating_preview = vim.lsp.util.open_floating_preview

vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or "rounded"

	return original_open_floating_preview(contents, syntax, opts, ...)
end

-- ============================================================================
-- LSP Keymaps
-- ============================================================================
-- Configure buffer-local keymaps when an LSP server attaches.
-- These mappings only exist for files supported by an LSP.

local lsp_group = vim.api.nvim_create_augroup("LspConfig", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = lsp_group,
	desc = "Configure LSP keymaps",

	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)

		if not client then
			return
		end

		-- Show documentation for the symbol under the cursor.
		vim.keymap.set("n", "K", vim.lsp.buf.hover, {
			buffer = event.buf,
			desc = "Show hover documentation",
		})

		-- Navigate to where symbols are defined.
		vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {
			buffer = event.buf,
			desc = "Go to definition",
		})

		-- Navigate to a symbol's declaration.
		vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, {
			buffer = event.buf,
			desc = "Go to declaration",
		})

		-- Navigate to implementations of an interface or function.
		vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, {
			buffer = event.buf,
			desc = "Go to implementation",
		})

		-- Apply available language-server suggestions.
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {
			buffer = event.buf,
			silent = true,
			noremap = true,
			desc = "Code action",
		})

		-- Rename the symbol under the cursor.
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {
			buffer = event.buf,
			silent = true,
			noremap = true,
			desc = "Rename symbol",
		})

		-- Show diagnostic information at the cursor.
		vim.keymap.set("n", "<leader>d", function()
			vim.diagnostic.open_float({ scope = "cursor" })
		end, {
			buffer = event.buf,
			desc = "Show cursor diagnostics",
		})

		-- Show diagnostics for the current line.
		vim.keymap.set("n", "<leader>D", function()
			vim.diagnostic.open_float({ scope = "line" })
		end, {
			buffer = event.buf,
			desc = "Show line diagnostics",
		})

		-- Move between diagnostic messages.
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

-- ============================================================================
-- Diagnostics
-- ============================================================================
-- Configure how errors, warnings, and hints are displayed.

vim.diagnostic.config({
	-- Do not update diagnostics while typing.
	update_in_insert = false,

	-- Show more important diagnostics first.
	severity_sort = true,

	-- Underline problematic code.
	underline = true,

	-- Configure diagnostic floating windows.
	float = {
		border = "rounded",
		source = true,
		header = "",
		prefix = "",
		focusable = false,
		style = "minimal",
	},

	-- Configure signs shown in the gutter.
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "X",
			[vim.diagnostic.severity.WARN] = "!",
			[vim.diagnostic.severity.INFO] = "i",
			[vim.diagnostic.severity.HINT] = "?",
		},
	},
})

