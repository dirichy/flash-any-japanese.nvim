local kana = require("flash-any.japanese.kana")
return function(readings)
	local codes = {}
	for _, reading in ipairs(readings) do
		local sequence = kana.split(reading)
		if sequence then
			codes[#codes + 1] = sequence
		end
	end
	return codes
end
