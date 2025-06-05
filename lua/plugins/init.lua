local u = require('local-util')

return {
	-- colorschemes
	{
		'RRethy/base16-nvim',
		cond = vim.fn.has('termguicolors'),
		config = function()
			-- match terminal colors
			if vim.fn.has('termguicolors') then
				vim.opt.termguicolors = true
			end
		end,
	},
	{
		'chriskempson/base16-vim',
		cond = not vim.fn.has('termguicolors'),
		config = function()
			-- match terminal colors
			if not vim.fn.has('termguicolors') then
				vim.opt.termguicolors = false
			end
		end,
	},

	-- treesitter management
	{
		'nvim-treesitter/nvim-treesitter',
		build = function()
			require('nvim-treesitter.install').update({ with_sync = true })()
		end,
		config = function(_, _)
			require('nvim-treesitter.configs').setup {
				highlight = {
					enable = true,
				},
			}
		end,
	},

	-- fuzzy find files and more with telescope
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.2',
		dependecies = {
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope-ui-select.nvim'
		},
		opts = {
			defaults = {
				cache_picker = {
					num_pickers = 20,
				}
			},
		},
		config = function(_, opts)
			local telescope = require('telescope')
			telescope.setup(opts)
			telescope.load_extension('ui-select')

			local builtin = require('telescope.builtin')

			u.map('n', '<leader>ff', builtin.find_files, 'telescope - [f]ind [f]ile')
			u.map('n', '<leader>fw', builtin.grep_string, 'telescope - [f]ind [w]ord')
			u.map('n', '<leader>fs', builtin.live_grep, 'telescope - [f]ind [s]tring')
			u.map('n', '<leader>fb', builtin.buffers, 'telescope - [f]ind [b]uffer')
			u.map('n', '<leader>fh', builtin.help_tags, 'telescope - [f]ind [h]elp tag')
			u.map('n', '<leader>fk', builtin.keymaps, 'telescope - [f]ind [k]eymap')
			u.map('n', '<leader>qf', builtin.pickers, 'telescope - pickers history')
			u.map('n', '<leader>@f', builtin.resume, 'telescope -resume')

			u.map('n', '<leader>fr', builtin.registers, 'telescope - [f]ind [r]egister')
			u.map('n', '<leader>fe', builtin.diagnostics, 'telescope - [f]ind [e]rrors')

			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(args)
					u.map('n', 'gi', builtin.lsp_implementations, 'LSP - [g]oto [i]mplemnation', { buffer = args.buf })
					u.map('n', 'gr', builtin.lsp_references, 'LSP - [g]oto [r]eference', { buffer = args.buf })
					u.map('n', 'gd', builtin.lsp_definitions, 'LSP - [g]oto [d]efinition', { buffer = args.buf })
					u.map('n', '<leader>lws', builtin.lsp_workspace_symbols, 'LSP - [l]sp [w]orkspace [s]ymbols', { buffer = args.buf })
				end

			})
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
		config = function()
			local enable = {
				'lua_ls',
				'nixd',
				'rust_analyzer',
				'svelte',
				'vue_ls',
				'ts_ls',
				'jdtls',
			}

			if os.execute("command -v vue-language-server") == 0 then
				local stdout = io.popen("dirname $(command -v vue-language-server)")
				local location = stdout:read() .. "/../lib/node_modules/@vue/language-server/"
				stdout:close()

				vim.lsp.config('ts_ls', {
					init_options = {
						plugins = {
							{
								name = "@vue/typescript-plugin",
								location = location,
								languages = { "vue" },
							},
						},
					},
					filetypes = {
						"javascript",
						"typescript",
						"vue",
					},
				})
			end

			for _,v in ipairs(enable) do
				vim.lsp.enable(v)
			end
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
					if cmp.visible() then return f() else fallback() end
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
					{
						name = 'cmdline',
						trigger_characters = {},
						keyword_pattern = [==[\(^[^![:blank:]]*\|[^![:blank:]]\{1,}\)]==],
						option = {
							ignore_cmds = {},
						}
					}
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
