local FontData = class('FontData')
local FontLayer = require 'pvz.font.FontLayer'

function FontData:init(name, instructions, origin)
	self.origin = (origin or 'data')
	self.name = name
	
	self.env = {}
	self.layers = {}
	self.pointSize = 10
	
	self:_setInstructions(instructions)
end
function FontData:_setInstructions(instructions)
	if not instructions then return end
	
	local function var(var)
		if type(var) == 'string' and #var > 1 and var:sub(1, 1) == '@' then
			return (self.env[var:sub(2)] or self:getLayer(var:sub(2)) or var:sub(2))
		end
		return var
	end
	local functions = {
		Define = function(var, val)
			self.env[var] = val
		end;
		
		CreateLayer = function(name)
			table.insert(self.layers, FontLayer:new(name:gsub('@', '')))
		end;
		LayerSetImage = function(layer, image) layer.textureName = image end;
		LayerSetAscent = function(layer, ascent) layer.ascent = ascent end;
		LayerSetAscentPadding = function(layer, ascent) layer.ascentPadding = ascent end;
		LayerSetPointSize = function(layer, pointSize) layer.pointSize = pointSize end;
		LayerSetLineSpacingOffset = function(layer, spacing) layer.lineSpacing = spacing end;
		LayerSetImageMap = function(layer, characterList, rectList) layer:addRects(characterList, rectList) end;
		LayerSetCharWidths = function(layer, characterList, widthList) layer:addWidths(characterList, widthList) end;
		LayerSetCharOffsets = function(layer, characterList, offsetList) layer:addOffsets(characterList, offsetList) end;
		LayerSetKerningPairs = function(layer, kerningPairs, kerningValues) layer:setKerningPairs(kerningPairs, kerningValues) end;
		
		SetDefaultPointSize = function(pointSize) self.pointSize = pointSize end;
	}
	
	self._instructions = instructions
	for _, instruction in ipairs(instructions) do
		local fun = functions[instruction.instruction]
		if fun then
			params = {}
			for i = 1, #instruction.parameters do table.insert(params, var(instruction.parameters[i])) end
			fun(unpack(params))
		else
			trace('Unimplemented method: ' .. instruction.instruction)
		end
	end
end
function FontData:getLayer(name)
	if type(name) ~= 'string' then return end
	return lambda.find(self.layers, function(layer) return (layer.name == name:gsub('@', '')) end)
end

function FontData.load(path, folder)
	local folder = (folder and folder .. '/' or 'data/')
	local instructions = FontData.parseFile(love.filesystem.read(folder .. path .. '.txt'))
	return FontData:new(path, instructions, origin)
end

function FontData.parseFile(data) -- if someone can write this better, please do that ...:sob:
	local cursor = 1
	local instructions = {}
	local curInstruction = {}

	local function nextExpr()
		local cur
		while true do
			cur = data:sub(cursor, cursor)
			
			if cur == ',' or cur == ')' or cur == ';' then
				if cur == ';' then
					return
				end
				cursor = (cursor + 1)
				return nextExpr()
			end
			if not cur:match('%s') then
				return
			end
			
			cursor = cursor + 1
			
			if cursor >= #data then error('Font parsing error (out of bounds)') end
		end
	end

	local function parseExpr()
		nextExpr()
		local cur = data:sub(cursor, cursor)
		if cur == '(' then
			local t = {}
			while true do
				cursor = (cursor + 1)
				table.insert(t, parseExpr())
				while true do
					if data:sub(cursor, cursor) == ',' then
						break
					elseif data:sub(cursor, cursor) == ')' then
						cursor = (cursor + 1)
						return t
					elseif cursor >= data then
						error('Font parsing error (unclosed array)')
					end
					cursor = (cursor + 1)
				end
			end
		elseif cur == '"' or cur == "'" then
			local str = ''
			while true do
				cursor = (cursor + 1)
				local ccur = data:sub(cursor, cursor)
				if cursor >= #data then error('Font parsing error (unclosed string)') end
				if ccur == cur then cursor = (cursor + 1) break end
				str = (str .. ccur)
			end
			return str
		elseif cur == ';' then
			local instr = table.remove(curInstruction, 1)
			table.insert(instructions, {
				instruction = instr;
				parameters = curInstruction;
			})
			curInstruction = {}
			while true do
				cursor = (cursor + 1)
				if cursor >= #data then
					return nil
				elseif not data:sub(cursor, cursor):match('%s') then
					return '\'"'
				end
			end
		else
			local expr = ''
			while true do
				local ccur = data:sub(cursor, cursor)
				if ccur:match('%s') or ccur == ',' or ccur == ';' or ccur == ')' then
					break
				end
				expr = (expr .. ccur)
				cursor = (cursor + 1)
				if cursor >= #data then error('Font parsing error (unterminated)') end
			end
			if expr == 'true' or expr == 'false' then return (expr == 'true') end
			return (tonumber(expr) or (#curInstruction > 0 and '@' .. expr or expr)) -- @identifier
		end
	end

	local expr = nil
	repeat
		expr = parseExpr()
		if expr ~= '\'"' then table.insert(curInstruction, expr) end
	until expr == nil
	
	return instructions
end

return FontData