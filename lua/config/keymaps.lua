-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "<C-BS>", "<C-w>")
vim.keymap.set("c", "<C-BS>", "<C-w>")
vim.keymap.set("i", "<C-H>", "<C-w>")
vim.keymap.set("c", "<C-H>", "<C-w>")

-- Format the current line automatically when typing ; or }
vim.keymap.set("i", ";", ";<C-o><cmd>lua require('conform').format({ range = { ['start'] = { vim.fn.line('.'), 0 }, ['end'] = { vim.fn.line('.'), 999 } }, quiet = true })<CR>")
vim.keymap.set("i", "}", "}<C-o><cmd>lua require('conform').format({ range = { ['start'] = { vim.fn.line('.'), 0 }, ['end'] = { vim.fn.line('.'), 999 } }, quiet = true })<CR>")
