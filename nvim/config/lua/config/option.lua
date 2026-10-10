---------------------------------------------------------
-- => basic neovim config
---------------------------------------------------------
vim.opt.expandtab = true
vim.opt.tabstop = 8
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.clipboard = "unnamed,unnamedplus"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.mouse = 'a'
vim.opt.cursorline = true

-- Preserve netrw browsing history, enable Telescope to search netrw curret dir
vim.g.netrw_keepdir = 0
