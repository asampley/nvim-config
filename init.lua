-- default options
-- ===============

-- default 4 character indent with tab character saved
-- overriden by editorconfig
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 0
vim.opt.expandtab = false

-- whitespace
vim.opt.listchars = { tab = '|·', trail = '~', nbsp = '+' }
vim.opt.list = true

-- global keymappings
-- ==================
local u = require('local-util')

-- leader
vim.g.mapleader = ' '

-- make leader on its own no longer function in normal, visual, and select
u.map('', vim.g.mapleader, '<nop>')
-- allow terminal mode to be left with double escape
u.remap('t', '<Esc><Esc>', '<C-\\><C-n>', 'Go to normal mode from terminal')

u.map('', ']e', u.count(vim.diagnostic.goto_next), 'goto next diagnostic')
u.map('', '[e', u.count(vim.diagnostic.goto_prev), 'goto prev diagnostic')
u.map('', ']q', u.cmd.silentcount('cnext'), 'goto next [q]uickfix list')
u.map('', '[q', u.cmd.silentcount('cprev'), 'goto prev [q]uickfix list')
u.map('', ']l', u.cmd.silentcount('lnext'), 'goto next [l]ocation list')
u.map('', '[l', u.cmd.silentcount('lprev'), 'goto prev [l]ocation list')

u.remap('', '<leader>w', u.expr.count1('<c-w>'), '<c-w> - window action prefix', { expr = true })

u.map('n', '<leader>e', vim.diagnostic.setqflist, 'set quickfix list to diagnostics')
u.map('n', '<leader>E', vim.diagnostic.setloclist, 'set location list to diagnostics')

-- Set completeopt to have a better completion experience
vim.opt.completeopt = { 'menuone', 'noinsert', 'noselect' }

-- Avoid showing message extra message when using completion
vim.opt.shortmess:append({ c = true })

-- bootstrap lazy plugin manager
-- =============================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- startup plugins
require('lazy').setup(require('plugins'))
