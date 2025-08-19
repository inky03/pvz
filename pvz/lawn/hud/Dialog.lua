local Dialog = UIContainer:extend('Dialog')

Dialog.slice = true
Dialog.canDrag = true
Dialog.headerHeightOffset = -20

Dialog.textureName = 'dialog'
Dialog.headerTextureName = 'dialog_header'
Dialog.columnNames = { 'left' ; 'middle' ; 'right' }
Dialog.rowNames = { 'top' ; 'center' ; 'bottom' }

function Dialog:init(x, y, w, h)
	self.textures = {}
	self:create()
	
	local w, h = w, h
	if not w then
		w = self:getSliceTexture(1, 1):getPixelWidth()
		
		if self.slice then
			w = (w + self:getSliceTexture(2, 1):getPixelWidth() + self:getSliceTexture(3, 1):getPixelWidth())
		end
		
		if self.textures.header then
			w = math.max(w, self.textures.header:getPixelWidth())
		end
	end
	if not h then
		h = self:getSliceTexture(1, 1):getPixelHeight()
		
		if self.slice then
			h = (h + self:getSliceTexture(1, 2):getPixelHeight() + self:getSliceTexture(1, 3):getPixelHeight())
		end
		
		if self.textures.header then
			h = (h + self.textures.header:getPixelHeight() + self.headerHeightOffset)
		end
	end
	self.quad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)
	
	UIContainer.init(self, x, y, w, h)
end
function Dialog:create()
	for x = 1, #self.columnNames do
		for y = 1, #self.rowNames do
			local key = self:getSliceName(x, y)
			self.textures[key] = Cache.image(self.textureName .. '_' .. key, 'images')
		end
	end
	
	if self.headerTextureName ~= '' then
		self.textures.header = Cache.image(self.headerTextureName, 'images')
	end
end

function Dialog:mouseDrag(mouseX, mouseY, deltaX, deltaY, isTouch)
	self.x = math.clamp(self.x + deltaX, -10, self.parent.w - self.w + 10)
	self.y = math.clamp(self.y + deltaY, -10, self.parent.h - self.h + 10)
end

function Dialog:getSliceName(col, row)
	return ((self.rowNames[row] or '') .. (self.columnNames[col] or ''))
end
function Dialog:getSliceTexture(col, row)
	return self.textures[self:getSliceName(col, row)]
end
function Dialog:draw(x, y)
	local x, y = math.round(x), math.round(y)
	local textures = self.textures
	local header = textures.header
	
	for col = 1, 3 do
		for row = 1, 3 do
			local key = self:getSliceName(col, row)
			local texture = textures[key]
			local xx, yy = 0, 0
			local w, h
			
			if col == 2 then
				xx = textures[self:getSliceName(1, row)]:getPixelWidth()
				w = (self.w - xx - self:getSliceTexture(3, 1):getPixelWidth())
			elseif col == 3 then
				xx = (self.w - self:getSliceTexture(3, 1):getPixelWidth())
			end
			
			local headerHeight = (header and header:getPixelHeight() + self.headerHeightOffset or 0)
			if row == 1 then
				yy = headerHeight
			elseif row == 2 then
				yy = (textures[self:getSliceName(col, 1)]:getPixelHeight() + headerHeight)
				h = (self.h - yy - self:getSliceTexture(1, 3):getPixelHeight())
			elseif row == 3 then
				yy = (self.h - self:getSliceTexture(1, 3):getPixelHeight())
			end
			
			if w or h then
				texture:setWrap(col == 2 and 'repeat' or 'clamp', row == 2 and 'repeat' or 'clamp')
				self.quad:setViewport(0, 0, w or texture:getPixelWidth(), h or texture:getPixelHeight(), texture:getPixelDimensions())
				love.graphics.draw(texture, self.quad, x + xx, y + yy)
			else
				love.graphics.draw(texture, x + xx, y + yy)
			end
			
			if not self.slice then
				goto noslice
			end
		end
	end
	
	::noslice::
	
	if textures.header then
		love.graphics.draw(header, x + math.round((self.w - header:getPixelWidth()) * .5), y)
	end
	
	UIContainer.draw(self, x, y)
end

return Dialog