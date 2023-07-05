local function prequire(module)
	return pcall(require, module)
end

-- default return
local l = {
	lspconfig = {
		settings = {
			lua_ls = {
				Lua = {
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

-- attempt to load and merge into defaults
local status, local_lspconfig = prequire('local/lspconfig')

if status then
	l.lspconfig = vim.tbl_deep_extend('force', l.lspconfig, local_lspconfig)
end

-- return local config
return l
