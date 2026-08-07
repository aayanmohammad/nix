-- ============================================================================
-- Globals
-- ============================================================================
-- Global settings that affect Neovim behavior before plugins and other
-- configuration are loaded.

-- Use Space as the leader key for custom key mappings.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Configure netrw (built-in file browser).
-- Hide the banner, use tree-style listing, control split behavior, and hide
-- unnecessary dot files.
vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = 25
vim.g.netrw_sort_sequence = [[[\/]$,*,\.bak$,\.o$,\.h$,\.info$,\.swp$,\.obj$]]

-- ============================================================================
-- Appearance
-- ============================================================================
-- Control how Neovim looks and how information is displayed.

-- Enable true color support for modern terminal colorschemes.
vim.o.termguicolors = true

-- Keep long lines from wrapping visually.
vim.o.wrap = false

-- Show absolute line number and relative distance from the cursor.
-- Relative numbers make jumping with commands like 5j or 10k easier.
vim.o.number = true
vim.o.relativenumber = true

-- Set color column at 80 characters for readability
vim.opt.colorcolumn = "80"

-- Highlight the current line and column to make cursor location easier to track.
vim.o.cursorline = true
vim.o.cursorcolumn = true

-- Customize cursor for all modes.
vim.opt.guicursor = "a:block-blinkwait0-blinkon50-blinkoff50"

-- Highlight matching brackets when moving between them.
vim.o.showmatch = true

-- Always reserve space for signs so text
-- doesn't shift when signs appear.
vim.o.signcolumn = "yes"

-- Keep one line available for messages and commands.
vim.o.cmdheight = 1

-- Remove the "~" symbols shown after the end of a buffer.
vim.opt.fillchars = { eob = " " }

-- Allow concealed text to remain visible even when conceal is enabled.
vim.o.concealcursor = ""

-- Limit syntax highlighting on very long lines for better performance.
vim.o.synmaxcol = 300

-- Use rounded borders for popup menus.
vim.o.pumborder = "rounded"

-- Use rounded borders for floating menus.
vim.o.winborder = "rounded"

-- Hide the default mode indicator because the statusline displays it.
vim.o.showmode = false

-- ============================================================================
-- Editing
-- ============================================================================
-- Settings that affect writing code and modifying text.

-- Automatically indent new lines based on surrounding code.
vim.o.smartindent = true
vim.o.autoindent = true

-- Use spaces instead of tab characters.
vim.o.expandtab = true

-- Set indentation size.
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

-- Make backspace behave naturally when deleting indentation, line breaks,
-- and inserted characters.
vim.o.backspace = "indent,eol,start"

-- Make visual selections include the character under the cursor.
vim.o.selection = "inclusive"

-- Treat words containing "-" as a single word.
-- Useful for things like file-name-style identifiers.
vim.opt.iskeyword:append("-")

-- Allow editing buffers normally.
vim.o.modifiable = true

-- ============================================================================
-- Search
-- ============================================================================
-- Configure how searching behaves.

-- Ignore case unless uppercase letters are used.
-- Example: "test" matches "Test", but "Test" searches exactly.
vim.o.ignorecase = true
vim.o.smartcase = true

-- Highlight matches and show incremental search results.
vim.o.hlsearch = true
vim.o.incsearch = true

-- Search recursively through subdirectories.
vim.opt.path:append("**")

-- ============================================================================
-- Navigation & Windows
-- ============================================================================
-- Control movement and split behavior.

-- Keep the cursor centered vertically and horizontally while scrolling.
vim.o.scrolloff = 999
vim.o.sidescrolloff = 999

-- Open horizontal splits below and vertical splits to the right.
vim.o.splitbelow = true
vim.o.splitright = true

-- ============================================================================
-- Completion
-- ============================================================================
-- Configure completion menus and command-line suggestions.

-- Show completion menu but don't automatically select or insert items.
-- This gives completion plugins more control.
vim.o.completeopt = "menuone,noinsert,noselect"

-- Limit completion popup height.
vim.o.pumheight = 10

-- Enable command-line completion menu.
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"

-- ============================================================================
-- Persistence
-- ============================================================================

-- Preserve editing state between Neovim sessions.
vim.o.undofile = true

-- Disable backup, write backup, and swap files.
-- Undo history replaces most of the need for these.
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

-- Automatically check if files changed outside Neovim.
vim.o.autoread = true

-- Do not automatically write buffers when leaving them.
vim.o.autowrite = false

-- ============================================================================
-- Folding
-- ============================================================================
-- Configure code folding using Tree-sitter.

-- Use Tree-sitter to calculate fold regions.
-- Schedule the setup so it runs after filetype detection.
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		vim.schedule(function()
			vim.opt_local.foldmethod = "expr"
			vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"

			-- Start with folds open instead of collapsed.
			vim.opt_local.foldlevel = 99
		end)
	end,
})

-- ============================================================================
-- Performance
-- ============================================================================
-- Settings that reduce unnecessary UI updates and improve responsiveness.

-- Remove startup messages like "Welcome to Nvim".
vim.o.shortmess = vim.o.shortmess .. "I"

-- Faster updates for diagnostics, completion, and other events.
vim.o.updatetime = 300

-- Time before mapped keys are considered complete.
vim.o.timeoutlen = 500

-- Faster escape response in terminal environments.
vim.o.ttimeoutlen = 50

-- Disable automatic directory changes when switching files.
vim.o.autochdir = false

-- Improve diff display by matching changed lines more accurately.
vim.opt.diffopt:append("linematch:60")

-- Allow more time and memory for complex patterns.
vim.o.redrawtime = 10000
vim.o.maxmempattern = 20000

