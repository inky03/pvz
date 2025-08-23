LawnStrings = require 'pvz.data.LawnStrings'

local Strings = {}

function Strings.reload()
	LawnStrings.load(Cache.main('properties/LawnStrings.txt'))
end

function Strings:get(entry, replacements)
	local lawnString = LawnStrings.strings[entry:upper()]
	
	if lawnString then
		if not replacements then return lawnString end
		
		return lawnString:gsub('%b{}', function(substring)
			local key = substring:sub(2, #substring - 1)
			local replacement = replacements[key]
			local replacementID = {}
			
			if replacement then
				if type(replacement) == 'table' then
					replacementID[key] = ((replacementID[key] or 0) + 1)
					return (replacement[replacementID[key]] or substring)
				else
					return replacement
				end
			else
				return substring
			end
		end)
	else
		return ('<Missing %s>'):format(entry)
	end
end

return Strings