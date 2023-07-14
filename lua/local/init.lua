-- default return
local l = {
	lspconfig = {
		settings = {
			lua_ls = {
				Lua = {
					runtime = {
						version = 'LuaJIT'
					},
					diagnostics = {
						-- mark vim as a global for nvim config scripts to not warn
						globals = { 'vim' },
					},
					workspace = {
						-- add nvim runtime files
						library = vim.api.nvim_get_runtime_file('', true),
						-- disable popup for lua_ls when certain words are detected
						checkThirdParty = false,
					},
					telemetry = {
						-- disable anonymous telemetry
						enable = false,
					},
				}
			}
		}
	}
}

l = vim.tbl_deep_extend('force', l, require('local-util').deep_require('local', true))

-- return local config
return l
