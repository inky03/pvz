FontData = require 'pvz.font.FontData'

local Font = UIContainer:extend('Font')

function Font:init(kind, size, x, y, w, h)
	self.canvasPadding = 10
	self.useCanvas = true
	
	UIContainer.init(self, x, y, w or 0, h or 0)
	
	self.transform = ReanimFrame:new()
	self.transform._internalXOffset = self.canvasPadding
	self.transform._internalYOffset = self.canvasPadding
	self.transform.scaleCoords = true
	
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
	
	self._dirty = false
	
	self._lines = {}
	self._lineWidths = {}
	self._lineHeights = {}
	
	self:setSize(size)
	self:setText('Hello World!')
end

function Font:setDimensions(w, h)
	UIContainer.setDimensions(self, w, h)
	self:resetCanvas()
end
function Font:resetCanvas()
	if self.canvas then self.canvas:release() end
	local w, h = (self.w <= 0 and gameWidth or self.w), (self.h <= 0 and gameHeight or self.h)
	self.canvas = love.graphics.newCanvas(w + self.canvasPadding * 2, h + self.canvasPadding * 2)
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
	
	self._dirty = true
end
function Font:setAlignment(horizontal, vertical)
	self.hAlignment = (horizontal or 'left')
	self.vAlignment = (vertical or 'top')
	self._dirty = true
end
function Font:setText(text)
	local text = tostring(text)
	
	if self.text ~= text then
		self.text = text
		self._dirty = true
	end
end
function Font:setSize(size)
	self.size = size
	self._dirty = true
	self:setFontData(Cache.font(self.kind .. size))
end
function Font:setLayerColor(layer, r, g, b, a)
	local t = self:getLayerTransform(layer)
	if t then
		t.r, t.g, t.b, t.a = (r or 1), (g or 1), (b or 1), (a or 1)
	else
		trace(('%s: Could not find layer %s'):format(self.kind, layer))
	end
	self._dirty = true
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
	
	local fullHeight = 0
	local fullWidth = 0
	
	local str = self.text
	local cursor = 1
	local lastSpace = 1
	local brokeLine = true
	local layer = self.fontData:getLayer(self.mainLayer)
	
	local xx, yy = 0, 0
	local charWidth = 0
	local lineHeight = 0
	local lastCharWidth = 0 -- TODO: some of this code is probably bogus ... need to fix some line width stuff
	
	while true do
		local char = str:sub(cursor, cursor)
		if char:match('%s') then
			lastSpace = cursor
			brokeLine = false
		end
		
		if layer:hasCharacter(char) then
			local _, _, w, h = layer:getRect(char)
			charWidth = (layer:getWidth(char) + self.characterSpacing + layer:getKerning(char, self.text:sub(cursor + 1, cursor + 1)))
			lineHeight = math.max(lineHeight + layer.lineSpacing + self.lineSpacing, h)
			fullHeight = math.max(fullHeight, yy + lineHeight)
		else
			charWidth = 0
		end
		
		local overflow = (cursor >= #str)
		if overflow or char == '\n' or (not self.autoWidth and (xx + charWidth) >= self.w and not char:match('%s') and not brokeLine) then
			local lineStr = (overflow and str or string.rtrim(str:sub(1, lastSpace - 1)))
			
			local lineWidth = self:getWidth(lineStr)
			table.insert(self._lineHeights, lineHeight)
			table.insert(self._lineWidths, lineWidth)
			table.insert(self._lines, lineStr)
			
			fullWidth = math.max(fullWidth, lineWidth)
			xx = (lastCharWidth + charWidth)
			yy = (yy + lineHeight)
			fullHeight = math.max(fullHeight, yy)
			
			if overflow or (not self.autoHeight and yy >= self.h) then
				break
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
	
	self.fieldWidth = fullWidth
	if self.autoWidth then
		self.w = self.fieldWidth
		self.hitbox.w = self.fieldWidth
	end
	self.fieldHeight = fullHeight
	if self.autoHeight then
		self.h = self.fieldHeight
		self.hitbox.h = self.fieldHeight
	end
end

function Font:draw(x, y, transforms)
	if not self.fontData then return end
	
	if self.useCanvas then
		if self._dirty then self:renderToCanvas() self._dirty = false end
		self:renderCanvas(x, y, transforms)
	else
		self:renderText(x, y)
	end
	
	UIContainer.draw(self, x, y)
end
function Font:renderCanvas(x, y, transforms)
	if transforms then
		for i, transform in ipairs(transforms) do
			table.insert(Reanimation.transformStack, i, transform)
		end
	else
		table.insert(Reanimation.transformStack, 1, self.transform)
	end
	
	local stack = Reanimation.transformStack
	local active = true
	local alpha = 1
	
	for i = 1, #stack do
		local transform = stack[i]
		active = (active and transform.active)
		alpha = (alpha * transform.alpha)
	end
	
	if active and alpha > 0 then
		local mesh = Reanimation.triangle
		local vert = mesh.vert
		
		for i, corner in ipairs(vert) do
			corner[1] = (i % 2 == 1 and 0 or self.canvas:getWidth())
			corner[2] = (i <= 2 and 0 or self.canvas:getHeight())
			
			Reanimation.transformVertex(corner, frame, false)
			for i = 1, #stack do Reanimation.transformVertex(corner, stack[i], true) end
			
			corner[1], corner[2] = (corner[1] + x), (corner[2] + y)
		end
		mesh.mesh:setVertices(vert)
		mesh.mesh:setTexture(self.canvas)
		
		love.graphics.setBlendMode('alpha', 'premultiplied')
		love.graphics.setColor(alpha, alpha, alpha, alpha)
		love.graphics.draw(mesh.mesh)
		love.graphics.setBlendMode('alpha')
	end
	
	for i = 1, (transforms and #transforms or 1) do
		table.remove(Reanimation.transformStack, 1)
	end
end
function Font:renderToCanvas()
	self:recalculate()
	
	local prevCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()
	self:renderText(self.canvasPadding, self.canvasPadding)
	love.graphics.setCanvas(prevCanvas)
end

function Font:renderText(x, y)
	local x, y = (x or 0), (y or 0)
	
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
				love.graphics.translate(0, math.round(mult * (self.h - self.fieldHeight)))
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
end

return Font