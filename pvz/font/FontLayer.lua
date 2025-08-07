local FontLayer = class('FontLayer')

FontLayer.textureName = nil

FontLayer.charList = {}
FontLayer.charRects = {}
FontLayer.charWidths = {}
FontLayer.charOffsets = {}
FontLayer.charIndexes = {}
FontLayer.kerningPairs = {}

FontLayer.ascent = 0
FontLayer.ascentPadding = 0
FontLayer.spacing = 0
FontLayer.pointSize = 10

FontLayer.defaultWidth = 0
FontLayer.defaultOffset = {0, 0}
FontLayer.defaultRect = {0, 0, 0, 0}

function FontLayer:init(name)
	self.name = name
end

function FontLayer:addCharacter(character)
	if not self.charIndexes[character] then
		table.insert(self.charList, character)
		table.insert(self.charRects, FontLayer.defaultRect)
		table.insert(self.charWidths, FontLayer.defaultWidth)
		table.insert(self.charOffsets, FontLayer.defaultOffset)
		self.charIndexes[character] = #self.charList
	end
	return self.charIndexes[character]
end

function FontLayer:getWidth(char)
	local index = self.charIndexes[char]
	return (index and self.charWidths[index] or FontLayer.defaultWidth)
end
function FontLayer:getOffset(char)
	local index = self.charIndexes[char]
	return (index and self.charOffsets[index] or FontLayer.defaultOffset)
end
function FontLayer:getRect(char)
	local index = self.charIndexes[char]
	return (index and self.charRects[index] or FontLayer.defaultRect)
end
function FontLayer:getKerning(char, nextChar)
	if not nextChar or nextChar == '' then return 0 end
	return (self.kerningPairs[char .. nextChar] or 0)
end

function FontLayer:addWidths(characterList, widthList)
	for i = 1, #characterList do
		self.charWidths[self:addCharacter(characterList[i])] = widthList[i]
	end
end
function FontLayer:addRects(characterList, rectList)
	for i = 1, #characterList do
		self.charRects[self:addCharacter(characterList[i])] = rectList[i]
	end
end
function FontLayer:addOffsets(characterList, offsetList)
	for i = 1, #characterList do
		self.charOffsets[self:addCharacter(characterList[i])] = offsetList[i]
	end
end
function FontLayer:setKerningPairs(kerningPairs, kerningValues)
	for i = 1, #kerningPairs do
		self.kerningPairs[kerningPairs[i]] = kerningValues[i]
	end
end

function FontLayer:__tostring()
	return ('FontLayer(name:%s, pointSize:%d)'):format(self.name, self.pointSize)
end

return FontLayer