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
vim.g.mapleader = ' '

-- allow terminal mode to be left with double escape
require('local-util').remap('t', '<Esc><Esc>', '<C-\\><C-n>', 'Go to normal mode from terminal')

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
