local LawnStrings = {}

LawnStrings.strings = {}

function LawnStrings.load(path)
	if not love.filesystem.getInfo(path) then
		trace('File ' .. path .. ' doesn\'t exist (lawn strings not loaded)')
		return
	end
	
	LawnStrings.strings = LawnStrings.parse(love.filesystem.read(path))
end

function LawnStrings.parse(content)
	local lines = content:split('\n')
	local strings = {}
	
	local curKey = nil
	for i = 1, #lines do
		local line = lines[i]:gsub('\r', '')
		
		if line:sub(1, 1) == '[' and line:sub(#line, #line) == ']' and line:upper() == line then
			curKey = line:sub(2, #line - 1)
			strings[curKey] = ''
		elseif curKey and #line > 0 then
			if strings[curKey] == '' then
				strings[curKey] = line
			else
				strings[curKey] = ('\n' .. line)
			end
		end
	end
	
	return strings
end

return LawnStrings