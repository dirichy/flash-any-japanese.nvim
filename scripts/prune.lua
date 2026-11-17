-- Maintainer-only pass: compare the same group sequences used by the converter.
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:prepend(root)
assert(vim.env.FLASH_ANY_ROOT, "set FLASH_ANY_ROOT to the flash-any.nvim checkout")
vim.opt.runtimepath:prepend(vim.env.FLASH_ANY_ROOT)
local split = require("flash-any.japanese.kana").split
local path = assert(arg[1], "usage: nvim --clean -l scripts/prune.lua dictionary.tsv")
local rows, singles, sequences = {}, {}, {}
local function sequence(reading)
	if sequences[reading] == nil then
		sequences[reading] = split(reading) or false
	end
	return sequences[reading]
end
for line in io.lines(path) do
	local text, reading = line:match("^(.-)\t(.*)$")
	assert(text and reading, "invalid dictionary row")
	rows[#rows + 1] = { text, reading }
	if vim.fn.strchars(text) == 1 then
		local code = sequence(reading)
		if code then
			singles[text] = singles[text] or {}
			singles[text][code .. " "] = true
		end
	end
end
local temporary = path .. ".tmp"
local output = assert(io.open(temporary, "w"))
local removed = 0
local current, parts
for _, row in ipairs(rows) do
	local text, reading = row[1], row[2]
	if text ~= current then
		current, parts = text, {}
		for _, cp in ipairs(vim.fn.str2list(text)) do
			parts[#parts + 1] = singles[vim.fn.nr2char(cp)] or {}
		end
	end
	local code = #parts > 1 and sequence(reading)
	local positions = { [1] = true }
	if code then
		code = code .. " "
		for _, choices in ipairs(parts) do
			local next_positions = {}
			for at in pairs(positions) do
				for choice in pairs(choices) do
					if code:sub(at, at + #choice - 1) == choice then
						next_positions[at + #choice] = true
					end
				end
			end
			positions = next_positions
			if not next(positions) then
				break
			end
		end
	end
	if code and positions[#code + 1] then
		removed = removed + 1
	else
		output:write(text, "\t", reading, "\n")
	end
end
output:close()
assert(os.rename(temporary, path))
print(("Removed %d readings reproducible from single-character group sequences"):format(removed))
