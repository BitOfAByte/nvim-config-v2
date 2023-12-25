vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
-- Move from nvim-tree to editor window
vim.keymap.set("n", "<leader>fc", ":wincmd l<CR>", { noremap = true, silent = true })
-- Focus on nvim-tree
vim.api.nvim_set_keymap("n", "<leader>fe", ":NvimTreeFocus<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>f", ":Format<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fw", ":FormatWrite<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>da", ":%d<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>a", "ggVG", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>c", "y", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>cf", "<cmd>AdvancedNewFile<CR>", { noremap = true })
vim.keymap.set("n", "<leader>u", "<cmd>u<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-/>", [[:call copilot#Accept()<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>li", "<plug>(vimtex-info)", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ll", "<plug>(vimtex-compile)", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>lv", "<cmd>!xdg-open %:p:r.pdf<cr>", { noremap = true, silent = true })
