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

local diagnostic_binds = {
	e = { desc = '[d]iagnostics at minimum [e]rror', opt = { severity = { min = vim.diagnostic.severity.ERROR } } },
	w = { desc = '[d]iagnostics at minimum [w]arning', opt = { severity = { min = vim.diagnostic.severity.WARN } } },
	d = { desc = '[d]iagnostics' }
}

for k, v in pairs(diagnostic_binds) do
	u.map(nxo, ']' .. k, u.count(function() vim.diagnostic.goto_next(v.opt) end), 'goto [count] next ' .. v.desc)
	u.map(nxo, '[' .. k, u.count(function() vim.diagnostic.goto_prev(v.opt) end), 'goto [count] prev ' .. v.desc)
	u.map(nx, '<leader>d' .. k .. 'q', function() vim.diagnostic.setqflist(v.opt) end, 'put ' .. v.desc .. ' into the [q]uickfix list')
	u.map(nx, '<leader>d' .. k .. 'l', function() vim.diagnostic.setloclist(v.opt) end, 'put ' .. v.desc .. ' into the [l]ocation list')
end

u.map(nxo, ']q', u.cmd('cnext', esilent), 'goto [count] next entry in the [q]uickfix list')
u.map(nxo, '[q', u.cmd('cprev', esilent), 'goto [count] prev entry in the [q]uickfix list')
u.map(nxo, ']l', u.cmd('lnext', esilent), 'goto [count] next entry in the [l]ocation list')
u.map(nxo, '[l', u.cmd('lprev', esilent), 'goto [count] prev entry in the [l]ocation list')
u.map(nxo, ']b', u.cmd('bnext'), 'goto [count] next [b]uffer')
u.map(nxo, '[b', u.cmd('bprev'), 'goto [count] prev [b]uffer')

u.remap(nx, '<leader>w', '<c-w>', '<c-w> - window action prefix')

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)

		-- LSP keybindings
		u.map('n', 'gD', vim.lsp.buf.declaration, 'LSP - [g]oto [D]eclaration', { buffer = args.buf })
		u.map('n', 'K', vim.lsp.buf.hover, 'LSP - hover', { buffer = args.buf })
		u.map('n', '<leader>h', vim.lsp.buf.signature_help, 'LSP - show [h]elp', { buffer = args.buf })
		u.map('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder, 'LSP - [l]sp [w]orkspace [a]dd folder', { buffer = args.buf })
		u.map('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder, 'LSP - [l]sp [w]orkspace [r]emove folder', { buffer = args.buf })
		u.map('n', '<leader>lwl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, 'LSP - [l]sp [w]orkspace [l]ist folders', { buffer = args.buf })
		u.map('n', '<leader>td', vim.lsp.buf.type_definition, 'LSP - goto [t]ype [d]efinition', { buffer = args.buf })
		u.map('n', '<leader>rn', vim.lsp.buf.rename, 'LSP - [r]e[n]ame', { buffer = args.buf })
		u.map('n', '<leader>ca', vim.lsp.buf.code_action, 'LSP - [c]ode [a]ction', { buffer = args.buf })

		client.server_capabilities.semanticTokensProvider = nil
	end
})

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

-- match terminal colors
if vim.fn.has('termguicolors') then
	vim.opt.termguicolors = false
end

-- startup plugins
require('lazy').setup(require('plugins'))

-- set colorscheme after plugins are loaded
vim.cmd('colorscheme base16-default-dark')
