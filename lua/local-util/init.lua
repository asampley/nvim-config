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
}
