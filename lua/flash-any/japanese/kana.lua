local M = {}
local path = assert(vim.api.nvim_get_runtime_file("lua/flash-any/japanese/kana.tsv", false)[1])
M.groups = require("flash-any.table").from_file(path, { format = "tsv" })
-- NFKC turns full-width punctuation in dictionary readings into these ASCII keys.
M.groups["~"], M.groups["="] = { "~" }, { "=" }

local voicing =
	"うゔ かが きぎ くぐ けげ こご さざ しじ すず せぜ そぞ ただ ちぢ つづ てで とど はばぱ ひびぴ ふぶぷ へべぺ ほぼぽ"
local voiced, unvoiced = {}, {}
for row in voicing:gmatch("%S+") do
	local forms = vim.fn.split(row, "\\zs")
	voiced[forms[1]] = forms[2]
	for i = 2, #forms do
		unvoiced[forms[i]] = forms[1]
	end
end

-- A small tsu borrows the next syllable's consonant. Keep those spellings in one
-- contextual group, so unrelated consonants cannot combine with the next kana.
local doubled = {}
for kana, spellings in pairs(M.groups) do
	local forms = {}
	for _, spelling in ipairs(spellings) do
		local first = spelling:sub(1, 1)
		if first:find("[bcdfghjklmpqrstvwxyz]") then
			forms[first .. spelling] = true
			if spelling:sub(1, 2) == "ch" then
				forms["t" .. spelling] = true
			end
		end
	end
	if next(forms) then
		doubled["っ" .. kana] = vim.tbl_keys(forms)
		table.sort(doubled["っ" .. kana])
	end
end
for kana, forms in pairs(doubled) do
	M.groups[kana] = forms
end

local longest = 0
for kana in pairs(M.groups) do
	longest = math.max(longest, #kana)
end
---Split a full-width kana reading into canonical kana group names.
---@param reading string
---@return string?
function M.split(reading)
	local chars = {}
	for _, cp in ipairs(vim.fn.str2list(reading)) do
		if (cp >= 0x30A1 and cp <= 0x30F6) or cp == 0x30FD or cp == 0x30FE then
			cp = cp - 0x60
		end
		local char = vim.fn.nr2char(cp)
		if cp == 0x309D or cp == 0x309E then
			local previous = chars[#chars]
			local number = previous and vim.fn.char2nr(previous) or 0
			-- Iteration marks have no reading without a preceding full-size kana.
			if
				number < 0x3041
				or number > 0x3096
				or ("ぁぃぅぇぉっゃゅょゎゕゖ"):find(previous, 1, true)
			then
				return nil
			end
			local base = unvoiced[previous] or previous
			if cp == 0x309E then
				char = voiced[base]
			else
				char = base
			end
			if not char then
				return nil
			end
		end
		chars[#chars + 1] = char
	end
	local kana = table.concat(chars)
	local sequence, at = {}, 1
	while at <= #kana do
		local found
		for size = math.min(longest, #kana - at + 1), 1, -1 do
			local name = kana:sub(at, at + size - 1)
			if M.groups[name] then
				found = name
				break
			end
		end
		if not found then
			return nil
		end
		sequence[#sequence + 1] = found
		at = at + #found
	end
	return #sequence > 0 and table.concat(sequence, " ") or nil
end

return M
