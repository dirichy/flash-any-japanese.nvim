local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:prepend(vim.env.FLASH_ANY_ROOT or vim.uv.cwd())
local cache = vim.fn.tempname()
vim.fn.mkdir(cache, "p")
vim.env.XDG_CACHE_HOME = cache
local kana = require("flash-any.japanese.kana")
assert(kana.split("すし") == "す し")
assert(kana.split("がっこう") == "が っこ う")
assert(kana.split("きょう") == "きょ う")
assert(kana.split("ガッコウ") == "が っこ う")
assert(kana.split("コーヒー") == "こ ー ひ ー")
for _, example in ipairs({
	{ "いすゞ", "い す ず" },
	{ "こゝろ", "こ こ ろ" },
	{ "イスヾ", "い す ず" },
	{ "コヽロ", "こ こ ろ" },
	{ "がゝ", "が か" },
	{ "ぱゞ", "ぱ ば" },
	{ "かゝゞ", "か か が" },
	{ "う~ん", "う ~ ん" },
	{ "おび=わん・けのーび", "お び = わ ん ・ け の ー び" },
}) do
	assert(kana.split(example[1]) == example[2], example[1])
end
for _, reading in ipairs({ "ゝ", "ゞ", "ヽ", "ヾ", "あゞ", "ーゝ", "ゃゝ", "=ゝ" }) do
	assert(kana.split(reading) == nil, "invalid iteration context: " .. reading)
end
assert(kana.split("not kana") == nil and kana.split("") == nil)
local build = require("flash-any.build")
do
	local rows = build.read(root .. "/lua/flash-any/tables/japanese.tsv", { format = "tsv" })
	local unique, skipped = {}, {}
	for _, readings in pairs(rows) do
		for _, reading in ipairs(readings) do
			if not unique[reading] then
				unique[reading] = true
				if not kana.split(reading) then
					skipped[#skipped + 1] = reading
				end
			end
		end
	end
	assert(vim.tbl_contains(rows["学校"], "がっこう"))
	assert(vim.tbl_contains(rows["日本"], "にほん") and vim.tbl_contains(rows["日本"], "にっぽん"))
	assert(vim.tbl_contains(rows["食"], "た") and not vim.tbl_contains(rows["食"], "たべる"))
	local readings = vim.tbl_count(unique)
	table.sort(skipped)
	print(("%d entries, %d unique readings; %d unsupported readings"):format(vim.tbl_count(rows), readings, #skipped))
	print("unsupported examples: " .. table.concat(vim.list_slice(skipped, 1, 15), ", "))
	assert(vim.deep_equal(skipped, { "ゝ", "ゞ", "ヽ", "ヾ" }), "only standalone symbol definitions lack readings")
end
collectgarbage("collect")
local native = require("flash-any.native")
local book = native.load(nil, { "japanese" })
for _, example in ipairs({
	{ "寿司", "sushi" },
	{ "寿司", "susi" },
	{ "学校", "gakkou" },
	{ "日本", "nihon" },
	{ "日本", "nippon" },
	{ "食べる", "taberu" },
	{ "がっこう", "gakkou" },
	{ "かっぴ", "kappi" },
	{ "キャット", "kyatto" },
	{ "しち", "shiti" },
	{ "コーヒー", "ko-hi-" },
	{ "寿司 with flash", "susi with flash" },
	{ "いすゞ", "isuzu" },
	{ "こゝろ", "kokoro" },
	{ "う～ん", "u~n" },
	{ "オビ＝ワン・ケノービ", "obi=wanz/keno-bi" },
}) do
	local found = book:new_state():scan(0, 0, 1, 1, 1, { example[1] }, example[2], { "a", "s", "x" })
	assert(#found > 0, table.concat(example, " / "))
	assert(found[1].pos[2] == 0, "wrong start: " .. example[1])
	print(example[1] .. " <- " .. example[2])
end
for _, symbol in ipairs({ "ゝ", "ゞ", "ヽ", "ヾ" }) do
	assert(#book:new_state():scan(0, 0, 1, 1, 1, { symbol }, symbol, nil) > 0)
end
assert(#book:new_state():scan(0, 0, 1, 1, 1, { "寿司!" }, "su!", nil) == 0)
local open = io.open
rawset(io, "open", function()
	error("cached setup must not read the dictionary or run its converter")
end)
local cached_ok, cached = pcall(native.load, nil, { "japanese" })
rawset(io, "open", open)
assert(cached_ok, cached)
assert(#cached:new_state():scan(0, 0, 1, 1, 1, { "学校" }, "gakkou", nil) > 0)
local initial = native.load(
	nil,
	{ { name = "japanese", data = { ["寿司"] = "す し" }, groups = kana.groups, matcher = "initial" } }
)
assert(#initial:new_state():scan(0, 0, 1, 1, 1, { "寿司" }, "ss", nil) > 0)
vim.fn.delete(cache, "rf")
print("Japanese source tests passed")
