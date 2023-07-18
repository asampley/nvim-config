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

	expr = {
		-- create function to return an expression with count1 prefixing it
		count1 = function(expr)
			return function()
				return vim.v.count1 .. expr
			end
		end,
	},

	cmd = {
		-- create function to run cmd command with silent! and count in front of it
		silentcount = function(cmd)
			return function()
				return vim.cmd('silent! ' .. vim.v.count .. cmd)
			end
		end
	},

}
