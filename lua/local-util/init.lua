local function map(mode, key, action, desc, opt)
	local default = { silent = true, remap = false, desc = desc }

	vim.keymap.set(mode, key, action, vim.tbl_extend('force', default, opt or {}))
end

return {
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
	remap = function(mode, key, action, desc, opt)
		map(mode, key, action, desc, vim.tbl_extend('force', { remap = true }, opt or {}))
	end,
}
