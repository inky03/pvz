FontData = require 'pvz.font.FontData'

local Font = UIContainer:extend('Font')

function Font:init(kind, size, x, y, w)
	UIContainer.init(self, x, y, w or 0, 50)
	
	self.quad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)
	self.layerTransform = {}
	self.mainLayer = ''
	
	self.canClick = false
	self.kind = kind
	
	self.alignment = 'center'
	self.autoWidth = (self.w <= 0)
	self.autoHeight = true -- TODO: fixed height (autoHeight false)
	self.fieldWidth = 0
	self.fieldHeight = 0
	self.lineSpacing = 0
	self.characterSpacing = 0
	
	self:setSize(size)
	self:setText('Hello World!')
end

function Font:setFontData(fontData)
	if not fontData or #fontData.layers < 1 then return end
	
	self.fontData = fontData
	self.mainLayer = fontData.layers[#fontData.layers].name
	
	for _, layer in ipairs(fontData.layers) do
		if not self.layerTransform[layer.name:lower()] then
			self.layerTransform[layer.name:lower()] = {
				r = 1; g = 1; b = 1; a = 1;
			}
		end
	end
end
function Font:setText(text)
	self.text = tostring(text)
end
function Font:setSize(size)
	self.size = size
	self:setFontData(Cache.font(self.kind .. size))
end
function Font:setLayerColor(layer, r, g, b, a)
	local t = self:getLayerTransform(layer)
	if t then
		t.r, t.g, t.b, t.a = (r or 1), (g or 1), (b or 1), (a or 1)
	else
		trace(('%s: Could not find layer %s'):format(self.kind, layer))
	end
end
function Font:getLayerTransform(name)
	return self.layerTransform[name:lower()]
end
function Font:getWidth(text)
	local width = self:getDimensions(text)
	return width
end
function Font:getHeight(text)
	local _, height = self:getDimensions(text)
	return height
end
function Font:getDimensions(text)
	if not self.fontData or #self.fontData.layers < 1 then return 0, 0 end
	
	local xx, yy = 0, 0
	local width, height = 0, 0
	
	local layer = self.fontData:getLayer(self.mainLayer)
	for i = 1, #text do
		local char = text:sub(i, i)
		if layer:hasCharacter(char) then
			local _, _, rW, rH = layer:getRect(char)
			
			width = math.max(width, xx + rW)
			height = math.max(height, yy + rH)
			
			xx = (xx + layer:getWidth(char) + self.characterSpacing)
		end
	end
	
	return width, height
end

function Font:draw(x, y)
	if not self.fontData then return end
	
	self:render(x, y)
	
	UIContainer.draw(self, x, y)
end
local _lines = {}
local _lineWidths = {}
function Font:render(x, y)
	self.fieldWidth, self.fieldHeight = 0, 0
	
	table.clear(_lines)
	table.clear(_lineWidths)
	local lineHeight = 0
	if self.autoWidth then
		table.insert(_lines, self.text)
		table.insert(_lineWidths, 0)
	else
		local str = self.text
		local cursor = 1
		local lastSpace = 1
		local brokeLine = true
		local layer = self.fontData:getLayer(self.mainLayer)
		
		local xx = 0
		local charWidth = 0
		local lastCharWidth = 0 -- TODO: some of this code is probably bogus ... need to fix some line width stuff
		while cursor < #str do
			local char = str:sub(cursor, cursor)
			if char:match('%s') then
				lastSpace = cursor
				brokeLine = false
			end
			if layer:hasCharacter(char) then
				local _, _, w, h = layer:getRect(char)
				local charWidth = (layer:getWidth(char) + self.characterSpacing)
				
				if char == '\n' or ((xx + charWidth) >= self.w and not char:match('%s') and not brokeLine) then
					local lineStr = string.rtrim(str:sub(1, lastSpace - 1))
					table.insert(_lineWidths, self:getWidth(lineStr))
					table.insert(_lines, lineStr)
					
					str = string.ltrim(str:sub(lastSpace, -1))
					brokeLine = true
					cursor = 1
					
					xx = (lastCharWidth + charWidth)
				else
					xx = (xx + charWidth)
				end
				
				lineHeight = math.max(lineHeight, h)
				lastCharWidth = charWidth
			end
			cursor = (cursor + 1)
		end
		local lastString = string.rtrim(str)
		if #lastString > 0 then
			table.insert(_lines, lastString)
			table.insert(_lineWidths, self:getWidth(lastString))
		end
	end
	
	for i, layer in ipairs(self.fontData.layers) do
		local transform = self.layerTransform[layer.name:lower()]
		
		for i = 1, #_lines do
			love.graphics.push()
			
			if not self.autoWidth then
				if self.alignment == 'center' or self.alignment == 'middle' then
					love.graphics.translate(math.round((self.w - _lineWidths[i]) * .5), 0)
				elseif self.alignment == 'right' then
					love.graphics.translate(math.round(self.w - _lineWidths[i]), 0)
				end
			end
			
			local line = _lines[i]
			local xx, yy = 0, ((i - 1) * (lineHeight + layer.lineSpacing + self.lineSpacing))
			for j = 1, #line do
				local char = line:sub(j, j)
				if layer:hasCharacter(char) then
					local texture = Cache.image(layer.textureName, self.fontData.origin)
					local xOffset, yOffset = layer:getOffset(char)
					local rX, rY, rW, rH = layer:getRect(char)
					self.quad:setViewport(rX, rY, rW, rH, texture:getPixelDimensions())
					love.graphics.setColor(transform.r, transform.g, transform.b, transform.a)
					love.graphics.draw(texture, self.quad, x + xx + xOffset, y + yy + yOffset)
					
					self.fieldWidth = math.max(self.fieldWidth, xx + rW)
					self.fieldHeight = math.max(self.fieldHeight, yy + rH)
					
					xx = (xx + self.characterSpacing + layer:getWidth(char) + layer:getKerning(char, self.text:sub(j + 1, j + 1)))
				end
			end
			
			love.graphics.pop()
		end
	end
	
	if self.autoWidth then
		self.w = self.fieldWidth
		self.hitbox.w = self.fieldWidth
	end
	if self.autoHeight then
		self.h = self.fieldHeight
		self.hitbox.h = self.fieldHeight
	end
end

return Font