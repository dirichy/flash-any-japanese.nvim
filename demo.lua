-- Keep the real source's converter, spelling groups and matcher in the recording.
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
vim.opt.runtimepath:append(root)
return vim.tbl_extend("force", require("flash-any.sources.japanese")(), {
	text_name = "Japanese",
	text = "本",
	mixed_text = "ほん with flash",
	comment = "Type hon, then choose a label to jump.",
	mixed_comment = "Mix kana and ASCII in the same search.",
	title = "Japanese romaji + ASCII",
})
