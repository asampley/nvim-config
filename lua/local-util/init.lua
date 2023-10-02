-- set the keymap, defaulting to silent and noremap
local function map(mode, key, action, desc, opt)
	local default = { silent = true, remap = false, desc = desc }

	vim.keymap.set(mode, key, action, vim.tbl_extend('force', default, opt or {}))
end

return {
	-- require a module and all submodules under it.
	--
	-- Expects a table from the module and all submodules, and puts the
	-- submodules into the table using their names as keys.
	deep_require = function(dir, exclude_root)
		local tab = {}

		for file, typ in vim.fs.dir(vim.fn.stdpath('config') .. '/lua/' .. dir) do
			if typ == 'file' and file ~= 'init.lua' then
				local name = file:match('(.*).lua')

				if name then
					tab[name] = require(dir .. '.' .. name)
				end
			end
		end

		if not exclude_root then
			tab = vim.tbl_deep_extend('keep', tab, require(dir))
		end

		return tab
	end,

	map = map,

	-- set the keymap defaulting to silent and remap
	remap = function(mode, key, action, desc, opt)
		map(mode, key, action, desc, vim.tbl_extend('force', { remap = true }, opt or {}))
	end,

	-- wrap a function to call it vim.v.count times, defaulting to once if unset
	count = function(f)
		return function()
			for _ = 1, vim.v.count1 do f() end
		end
	end,

	-- wrap a function around vim.cmd with count passed through by default
	cmd = function (c, opt)
		return function()
			vim.cmd[c](vim.tbl_extend('force', { count = vim.v.count }, opt or {}))
		end
	end,

	-- function for an lsp attaching
	on_attach = function(client, bufnr)
		local builtin = require('telescope.builtin')

		-- LSP keybindings
		map('n', 'gD', vim.lsp.buf.declaration, 'LSP - [g]oto [D]eclaration')
		map('n', 'gd', builtin.lsp_definitions, 'LSP - [g]oto [d]efinition')
		map('n', 'K', vim.lsp.buf.hover, 'LSP - hover')
		map('n', 'gi', builtin.lsp_implementations, 'LSP - [g]oto [i]mplemnation')
		map('n', 'gr', builtin.lsp_references, 'LSP - [g]oto [r]eference')
		map('n', '<leader>h', vim.lsp.buf.signature_help, 'LSP - show [h]elp')
		map('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder, 'LSP - [l]sp [w]orkspace [a]dd folder')
		map('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder, 'LSP - [l]sp [w]orkspace [r]emove folder')
		map('n', '<leader>lwl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, 'LSP - [l]sp [w]orkspace [l]ist folders')
		map('n', '<leader>lws', builtin.lsp_workspace_symbols, 'LSP - [l]sp [w]orkspace [s]ymbols')
		map('n', '<leader>td', vim.lsp.buf.type_definition, 'LSP - goto [t]ype [d]efinition')
		map('n', '<leader>rn', vim.lsp.buf.rename, 'LSP - [r]e[n]ame')
		map('n', '<leader>ca', vim.lsp.buf.code_action, 'LSP - [c]ode [a]ction')
		map('n', '<leader>gq', vim.lsp.buf.format, 'LSP - format')

		vim.bo.formatexpr = 'v:lua.vim.lsp.formatexpr()'

		client.server_capabilities.semanticTokensProvider = nil
	end
}
