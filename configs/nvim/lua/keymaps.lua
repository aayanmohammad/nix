vim.keymap.set("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, {
	expr = true,
	desc = "Move down (wrap-aware)",
})

vim.keymap.set("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, {
	expr = true,
	desc = "Move up (wrap-aware)",
})

vim.keymap.set("n", "n", "nzzzv", {
	desc = "Next search result (centered)",
})

vim.keymap.set("n", "N", "Nzzzv", {
	desc = "Previous search result (centered)",
})

vim.keymap.set("n", "<C-d>", "<C-d>zz", {
	desc = "Scroll half page down (centered)",
})

vim.keymap.set("n", "<C-u>", "<C-u>zz", {
	desc = "Scroll half page up (centered)",
})

vim.keymap.set("n", "<leader>nh", "<cmd>nohlsearch<CR>", {
	desc = "Clear search highlights",
})

vim.keymap.set("x", "<leader>p", '"_dP', {
	desc = "Paste without yanking",
})

vim.keymap.set({ "n", "v" }, "<leader>x", '"_d', {
	desc = "Delete without yanking",
})

vim.keymap.set("v", "<leader>y", '"+y', {
	desc = "Yank to system clipboard",
})

vim.keymap.set("n", "J", "mzJ`z", {
	desc = "Join lines (keep cursor position)",
})

vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", {
	desc = "Switch to next buffer",
})

vim.keymap.set("n", "<leader>bN", "<cmd>bprevious<CR>", {
	desc = "Switch to previous buffer",
})

vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", {
	desc = "Delete current buffer",
})

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

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", {
	desc = "Move selection down",
})

vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", {
	desc = "Move selection up",
})

vim.keymap.set("v", "<", "<gv", {
	desc = "Indent left (keep selection)",
})

vim.keymap.set("v", ">", ">gv", {
	desc = "Indent right (keep selection)",
})

vim.keymap.set("i", "<Tab>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-n>"
	end

	return "<Tab>"
end, {
	expr = true,
	desc = "Select next completion item",
})

vim.keymap.set("i", "(", "()<Left>", {
	desc = "Auto close parentheses",
})

vim.keymap.set("i", "[", "[]<Left>", {
	desc = "Auto close brackets",
})

vim.keymap.set("i", "{", "{}<Left>", {
	desc = "Auto close braces",
})

vim.keymap.set("i", "'", "''<Left>", {
	desc = "Auto close single quote",
})

vim.keymap.set("i", '"', '""<Left>', {
	desc = "Auto close double quote",
})

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

vim.keymap.set("n", "<leader>f", function()
	require("formatter").format()
end, {
	desc = "Format current buffer",
})

