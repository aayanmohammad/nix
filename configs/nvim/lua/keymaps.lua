-- ============================================================================
-- Editing
-- ============================================================================
-- Keymaps that improve text editing behavior.

-- Quickly leave insert/visual mode using a home-row key combination.
vim.keymap.set({ "i", "v" }, "kj", "<Esc>", {
	desc = "Enter normal mode",
})

-- Move visually wrapped lines as if they were real lines.
-- Counts still use normal j/k behavior.
vim.keymap.set("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, {
	expr = true,
	silent = true,
	desc = "Move down (wrap-aware)",
})

vim.keymap.set("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, {
	expr = true,
	silent = true,
	desc = "Move up (wrap-aware)",
})

-- Keep search results centered while navigating.
vim.keymap.set("n", "n", "nzzzv", {
	desc = "Next search result (centered)",
})

vim.keymap.set("n", "N", "Nzzzv", {
	desc = "Previous search result (centered)",
})

-- Keep cursor centered after half-page jumps.
vim.keymap.set("n", "<C-d>", "<C-d>zz", {
	desc = "Scroll half page down (centered)",
})

vim.keymap.set("n", "<C-u>", "<C-u>zz", {
	desc = "Scroll half page up (centered)",
})

-- Remove search highlighting.
vim.keymap.set("n", "<leader>nh", "<cmd>nohlsearch<CR>", {
	desc = "Clear search highlights",
})

-- ============================================================================
-- Clipboard
-- ============================================================================
-- Prevent deleted or replaced text from overwriting the default register.

vim.keymap.set("x", "<leader>p", '"_dP', {
	desc = "Paste without yanking",
})

vim.keymap.set({ "n", "v" }, "<leader>x", '"_d', {
	desc = "Delete without yanking",
})

-- Yank selection to system clipboard
vim.keymap.set("v", "<leader>y", '"+y', {
	desc = "Yank to system clipboard",
})

-- Join lines while preserving the current cursor position.
vim.keymap.set("n", "J", "mzJ`z", {
	desc = "Join lines (keep cursor position)",
})

-- ============================================================================
-- Buffers
-- ============================================================================
-- Navigate between open buffers.

vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", {
	desc = "Switch to next buffer",
})

vim.keymap.set("n", "<leader>bN", "<cmd>bprevious<CR>", {
	desc = "Switch to previous buffer",
})

vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", {
	desc = "Delete current buffer",
})

-- ============================================================================
-- Windows
-- ============================================================================
-- Create and resize editor splits.

vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<CR>", {
	desc = "Open vertical split",
})

vim.keymap.set("n", "<leader>sh", "<cmd>split<CR>", {
	desc = "Open horizontal split",
})

vim.keymap.set("n", "<C-h>", "<cmd>vertical resize -2<CR>", {
	desc = "Decrease split width",
})

vim.keymap.set("n", "<C-j>", "<cmd>resize -2<CR>", {
	desc = "Decrease split height",
})

vim.keymap.set("n", "<C-k>", "<cmd>resize +2<CR>", {
	desc = "Increase split height",
})

vim.keymap.set("n", "<C-l>", "<cmd>vertical resize +2<CR>", {
	desc = "Increase split width",
})

-- ============================================================================
-- Visual Mode
-- ============================================================================
-- Improve selection editing.

-- Move selected lines while keeping the selection active.
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", {
	desc = "Move selection down",
})

vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", {
	desc = "Move selection up",
})

-- Keep selection active after indentation.
vim.keymap.set("v", "<", "<gv", {
	desc = "Indent left (keep selection)",
})

vim.keymap.set("v", ">", ">gv", {
	desc = "Indent right (keep selection)",
})

-- ============================================================================
-- Completion
-- ============================================================================
-- Manually trigger completion.

vim.keymap.set("i", "<TAB>", "<C-x><C-o>", {
	desc = "Trigger completion",
})

-- ============================================================================
-- File Explorer
-- ============================================================================
-- Toggle Neovim's built-in netrw explorer.

vim.keymap.set("n", "<leader>e", function()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].filetype == "netrw" then
			vim.api.nvim_buf_delete(buf, { force = true })
			return
		end
	end

	vim.cmd("Vexplore")
	vim.wo.statusline = " "
end, {
	desc = "Toggle file explorer",
})

