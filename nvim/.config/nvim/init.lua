-- ----------------------------
-- Basics
-- ----------------------------
vim.g.mapleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.mouse = "a"
o.clipboard = "unnamedplus"   -- use system clipboard (wl-copy / xclip)
o.undofile = true
o.ignorecase = true
o.smartcase = true
o.signcolumn = "yes"
o.cursorline = true
o.scrolloff = 8
o.splitright = true
o.splitbelow = true
o.termguicolors = true

-- Indentation
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true

-- ----------------------------
-- Keymaps
-- ----------------------------
local map = vim.keymap.set
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- ----------------------------
-- Go uses tabs
-- ----------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function() vim.opt_local.expandtab = false; vim.opt_local.shiftwidth = 4; vim.opt_local.tabstop = 4 end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank() end,
})
