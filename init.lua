require("bitofabyte")

vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])
-- Automatically load keymaps
vim.cmd("source ~/.config/nvim/lua/bitofabyte/remap.lua")
-- disable netrw at the very start of your init.lua
vim.cmd("source ~/.config/nvim/after/plugin/mason.lua")
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup()

-- OR setup with some options
require("nvim-tree").setup({
	sort_by = "case_sensitive",
	view = {
		width = 30,
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		dotfiles = true,
	},
})
