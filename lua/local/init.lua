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

for f, t in vim.fs.dir('lua/local/') do
	if t == 'file' and f ~= 'init.lua' then
		local name = f:match('(.*).lua')

		if name then
			local status, local_config = prequire('local/' .. name)

			if status then
				l[name] = vim.tbl_deep_extend('force', l[name], local_config)
			end
		end
	end
end

-- return local config
return l
