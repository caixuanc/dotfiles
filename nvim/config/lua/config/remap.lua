---------------------------------------------------------
-- => Keybindings
---------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('i', 'jk', '<Esc>', { desc = 'exit insert mode with jk' })
vim.keymap.set('i', 'kj', '<Esc>', { desc = 'exit insert mode with kj' })

vim.keymap.set('n', '<Tab>', ':bnext<CR>', { desc = 'jump to next buffer with tab'})
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', { desc = 'jump to previous buffer with shift+tab'})

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'clear hightlights on search when press <Ecs> at normal mode'})

-- Use CTRL + hjkl to resize windows
vim.keymap.set({ "n", "v", "o" }, "<C-h>", "<Cmd>vertical resize +3<CR>", { silent = true, desc = "Widen window" })
vim.keymap.set({ "n", "v", "o" }, "<C-l>", "<Cmd>vertical resize -3<CR>", { silent = true, desc = "Narrow window" })
vim.keymap.set({ "n", "v", "o" }, "<C-k>", "<Cmd>resize +3<CR>", { silent = true, desc = "Taller window" })
vim.keymap.set({ "n", "v", "o" }, "<C-j>", "<Cmd>resize -3<CR>", { silent = true, desc = "Shorter window" })

vim.keymap.set("n", "<C-n>", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { silent = true, desc = "Toggle relative number" })

-- <leader>cf to copy current file path 
local function copy_file_path()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("File path copied to clipboard: " .. path)
end

vim.keymap.set("n", "<leader>cf", copy_file_path, {
  desc = "Copy file path to clipboard",
})

vim.keymap.set("n", "<leader>gk", ":Explore /nfs/site/disks/psg.mod.000/release<CR>", {
  desc = "Open netrw at psg.mod.000/release",
})

