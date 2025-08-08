FontData = require 'pvz.font.FontData'

local Font = UIContainer:extend('Font')

function Font:init(kind, size, x, y, w, h)
	UIContainer.init(self, x, y, w or 0, h or 0)
	
	self.quad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)
	self.layerTransform = {}
	self.mainLayer = ''
	
	self.canClick = false
	self.kind = kind
	
	self:setAlignment()
	self.autoWidth = (self.w <= 0)
	self.autoHeight = (self.h <= 0) -- TODO: fixed height (autoHeight false)
	self.fieldWidth = 0
	self.fieldHeight = 0
	self.lineSpacing = 0
	self.characterSpacing = 0
	
	self._lines = {}
	self._lineWidths = {}
	self._lineHeights = {}
	
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
function Font:setAlignment(horizontal, vertical)
	self.hAlignment = (horizontal or 'left')
	self.vAlignment = (vertical or 'top')
end
function Font:setText(text)
	self.text = tostring(text)
	self:recalculate()
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
			
			xx = (xx + layer:getWidth(char) + self.characterSpacing + layer:getKerning(char, self.text:sub(i + 1, i + 1)))
		end
	end
	
	return width, height
end
function Font:recalculate()
	table.clear(self._lines)
	table.clear(self._lineWidths)
	table.clear(self._lineHeights)
	
	if self.autoWidth then
		table.insert(self._lines, self.text)
		table.insert(self._lineWidths, 0)
		table.insert(self._lineHeights, 0)
	else
		local str = self.text
		local cursor = 1
		local lastSpace = 1
		local brokeLine = true
		local layer = self.fontData:getLayer(self.mainLayer)
		
		local xx, yy = 0, 0
		local charWidth = 0
		local lastCharWidth = 0 -- TODO: some of this code is probably bogus ... need to fix some line width stuff
		local lineHeight = 0
		
		while cursor < #str do
			local char = str:sub(cursor, cursor)
			if char:match('%s') then
				lastSpace = cursor
				brokeLine = false
			end
			
			if layer:hasCharacter(char) then
				local _, _, w, h = layer:getRect(char)
				charWidth = (layer:getWidth(char) + self.characterSpacing + layer:getKerning(char, self.text:sub(cursor + 1, cursor + 1)))
				lineHeight = math.max(lineHeight + layer.lineSpacing + self.lineSpacing, h)
			else
				charWidth = 0
			end
			
			if char == '\n' or ((xx + charWidth) >= self.w and not char:match('%s') and not brokeLine) then
				local lineStr = string.rtrim(str:sub(1, lastSpace - 1))
				table.insert(self._lineWidths, self:getWidth(lineStr))
				table.insert(self._lineHeights, lineHeight)
				table.insert(self._lines, lineStr)
				
				xx = (lastCharWidth + charWidth)
				yy = (yy + lineHeight)
				
				if not self.autoHeight and yy >= self.h then
					return
				end
				
				str = string.ltrim(str:sub(lastSpace, -1))
				lineHeight = 0
				brokeLine = true
				cursor = 1
			else
				xx = (xx + charWidth)
			end
			
			lastCharWidth = charWidth
			
			cursor = (cursor + 1)
		end
		local lastString = string.rtrim(str)
		if #lastString > 0 then
			table.insert(self._lines, lastString)
			table.insert(self._lineWidths, self:getWidth(lastString))
			table.insert(self._lineHeights, lineHeight)
		end
	end
end

function Font:draw(x, y)
	if not self.fontData then return end
	
	self:render(x, y)
	
	UIContainer.draw(self, x, y)
end
function Font:render(x, y)
	self.fieldWidth, self.fieldHeight = 0, 0
	
	local fullHeight
	if not self.autoHeight then
		fullHeight = 0
		for i = 1, #self._lineHeights do
			fullHeight = (fullHeight + self._lineHeights[i])
		end
	end
	for i, layer in ipairs(self.fontData.layers) do
		local transform = self.layerTransform[layer.name:lower()]
		
		local yy = 0
		for i = 1, #self._lines do
			love.graphics.push()
			
			if not self.autoWidth then
				local mult = (self.hAlignment == 'right' and 1 or ((self.hAlignment == 'center' or self.hAlignment == 'middle') and .5 or 0))
				love.graphics.translate(math.round(mult * (self.w - self._lineWidths[i])), 0)
			end
			if not self.autoHeight then
				local mult = (self.vAlignment == 'bottom' and 1 or ((self.vAlignment == 'center' or self.vAlignment == 'middle') and .5 or 0))
				love.graphics.translate(0, math.round(mult * (self.h - fullHeight)))
			end
			
			local line = self._lines[i]
			local xx = 0
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
					
					if self.debug then
						love.graphics.setColor(0, 0, 1)
						love.graphics.rectangle('line', x + xx + xOffset, y + yy + yOffset, rW, rH)
					end
					
					xx = (xx + self.characterSpacing + layer:getWidth(char) + layer:getKerning(char, self.text:sub(j + 1, j + 1)))
				end
			end
			
			yy = (yy + self._lineHeights[i])
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