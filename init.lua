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

vim.opt.timeout = false

-- global keymappings
-- ==================
local u = require('local-util')

-- leader
vim.g.mapleader = ' '

-- normal, visual, and operator mode set
local nxo = { 'n', 'x', 'o' }
-- normal and visual mode set
local nx = { 'n', 'x' }

-- make leader on its own no longer function in normal, visual, and select
u.map(nxo, vim.g.mapleader, '<nop>')
-- allow terminal mode to be left with double escape
u.remap('t', '<Esc><Esc>', '<C-\\><C-n>', 'Go to normal mode from terminal')

local esilent = { mods = { emsg_silent = true } }

u.map(nxo, ']e', u.count(vim.diagnostic.goto_next), 'goto [count] next diagnostic')
u.map(nxo, '[e', u.count(vim.diagnostic.goto_prev), 'goto [count] prev diagnostic')
u.map(nxo, ']q', u.cmd('cnext', esilent), 'goto [count] next [q]uickfix list')
u.map(nxo, '[q', u.cmd('cprev', esilent), 'goto [count] prev [q]uickfix list')
u.map(nxo, ']l', u.cmd('lnext', esilent), 'goto [count] next [l]ocation list')
u.map(nxo, '[l', u.cmd('lprev', esilent), 'goto [count] prev [l]ocation list')
u.map(nxo, ']b', u.cmd('bnext'), 'goto [count] next [b]uffer')
u.map(nxo, '[b', u.cmd('bprev'), 'goto [count] prev [b]uffer')

u.remap(nx, '<leader>w', '<c-w>', '<c-w> - window action prefix')

u.map(nx, '<leader>e', vim.diagnostic.setqflist, 'set quickfix list to diagnostics')
u.map(nx, '<leader>E', vim.diagnostic.setloclist, 'set location list to diagnostics')

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
