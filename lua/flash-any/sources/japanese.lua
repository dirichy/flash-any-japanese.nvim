return function()
	return {
		file = assert(vim.api.nvim_get_runtime_file("lua/flash-any/tables/japanese.tsv", false)[1]),
		format = "tsv",
		converter = assert(vim.api.nvim_get_runtime_file("lua/flash-any/japanese/converter.lua", false)[1]),
		groups = require("flash-any.japanese.kana").groups,
		matcher = "full_code",
	}
end
