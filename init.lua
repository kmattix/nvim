require("config.lazy")

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.opt.cursorline = true
vim.opt.scrolloff = 5

vim.wo.number = true
vim.wo.relativenumber = true
