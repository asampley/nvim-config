local function bnmap(lhs, rhs)
	vim.keymap.set('n', lhs, rhs, { silent = true, buffer = true })
end

local function nmap(lhs, rhs)
	vim.keymap.set('n', lhs, rhs, { silent = true })
end

local function on_attach(client, bufnr)
	local builtin = require('telescope.builtin')

	-- LSP keybindings
	bnmap('gD', vim.lsp.buf.declaration)
	bnmap('gd', builtin.lsp_definitions)
	bnmap('K', vim.lsp.buf.hover)
	bnmap('gi', builtin.lsp_implementations)
	bnmap('gr', builtin.lsp_references)
	bnmap('<leader>h', vim.lsp.buf.signature_help)
	bnmap('<leader>wa', vim.lsp.buf.add_workspace_folder)
	bnmap('<leader>wr', vim.lsp.buf.remove_workspace_folder)
	bnmap('<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end)
	bnmap('<leader>D', vim.lsp.buf.type_definition)
	bnmap('<leader>rn', vim.lsp.buf.rename)
	bnmap('<leader>ca', vim.lsp.buf.code_action)
	bnmap('<leader>fo', vim.lsp.buf.format)

	client.server_capabilities.semanticTokensProvider = nil
end

return {
	-- parse and adjust settings for formatting from .editorconfig file
	{ 'editorconfig/editorconfig-vim' },

	-- colorscheme
	{
		'tanvirtin/monokai.nvim',
		lazy = false,
		opts = {
			palette = {
				base2 = '#1c1e21',
			},
		}
	},

	-- fuzzy find files and more with telescope
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.2',
		dependecies = {
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope-ui-select.nvim'
		},
		config = function(_, opts)
			local telescope = require('telescope')
			telescope.setup(opts)
			telescope.load_extension('ui-select')

			local builtin = require('telescope.builtin')

			nmap('<leader>ff', builtin.find_files)
			nmap('<leader>fw', builtin.grep_string)
			nmap('<leader>fs', builtin.live_grep)
			nmap('<leader>fb', builtin.buffers)
			nmap('<leader>fh', builtin.help_tags)

			nmap('<leader>fr', builtin.registers)
			nmap('<leader>e', builtin.diagnostics)
		end,
	},

	{ 'nvim-lua/plenary.nvim' },
	{ 'nvim-telescope/telescope-ui-select.nvim' },

	-- preview markdown as you write using :MarkdownPreview
	{
		'iamcco/markdown-preview.nvim',
		build = function() vim.fn['mkdp#util#install']() end,
		ft = 'markdown',
	},

	{
		'neovim/nvim-lspconfig',
		dependencies = {
			-- only depends on this for lsp completion in config function
			'hrsh7th/cmp-nvim-lsp',
		},
	},

	-- installer and bridge for lsps and lspconfig
	{ 'williamboman/mason.nvim', config = true },
	{
		'williamboman/mason-lspconfig.nvim',
		dependencies = {
			'neovim/nvim-lspconfig',
			'hrsh7th/cmp-nvim-lsp',
		},
		config = function()
			require('mason-lspconfig').setup()

			require('mason-lspconfig').setup_handlers({
				function(server_name)
					require('lspconfig')[server_name].setup({
						on_attach = on_attach,
						capabilities = require('cmp_nvim_lsp').default_capabilities(),
						settings = require('local').lspconfig.settings[server_name],
					})
				end
			})
		end
	},

	-- snippet engine
	{ 'hrsh7th/vim-vsnip' },

	-- completion plugin
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-cmdline',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-vsnip',
		},
		config = function()
			local cmp = require('cmp')

			local select_behavior = cmp.SelectBehavior.Select;

			local if_vis_do = function(f)
				return function(fallback)
					if cmp.visible() then return f() else return fallback() end
				end
			end

			local select_next = if_vis_do(function()
				cmp.select_next_item({ behavior = select_behavior })
			end)

			local select_prev = if_vis_do(function()
				cmp.select_prev_item({ behavior = select_behavior })
			end)

			local comp_common = if_vis_do(function()
				local ret = cmp.complete_common_string()
				cmp.complete()
				return ret
			end)

			local opt = {
				snippet = {
					expand = function(args) vim.fn['vsnip#anonymous'](args.body) end
				},
				matching = {
					disallow_fuzzy_matching = false,
					disallow_partial_matching = false,
					disallow_prefix_unmatching = false,
				},
				mapping = {
					['<c-j>'] = cmp.mapping(select_next, { 'i', 'c' }),
					['<down>'] = cmp.mapping(select_next, { 'i', 'c' }),
					['<c-k>'] = cmp.mapping(select_prev, { 'i', 'c' }),
					['<up>'] = cmp.mapping(select_prev, { 'i', 'c' }),
					['<c-l>'] = cmp.mapping(comp_common, { 'i', 'c' }),
					['<right>'] = cmp.mapping(comp_common, { 'i', 'c' }),
					['<tab>'] = cmp.mapping(comp_common, { 'i', 'c' }),
					['<s-tab>'] = cmp.mapping(select_prev, { 'i', 'c' }),
					['<c-space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
					['<c-e>'] = cmp.mapping(cmp.mapping.abort(), { 'i', 'c' }),
					['<cr>'] = cmp.mapping(cmp.mapping.confirm(), { 'i', 'c' }),
				},
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'vsnip' },
				}, {
					{ name = 'buffer' },
				}, {
					{ name = 'path' },
				})
			}

			cmp.setup(opt)

			cmp.setup.cmdline(':', {
				sources = cmp.config.sources({
					{ name = 'path' },
				}, {
					{ name = 'cmdline' },
				})
			})

			cmp.setup.cmdline({ '/', '?' }, {
				sources = cmp.config.sources({
					{ name = 'buffer' },
				})
			})
		end
	},
}
