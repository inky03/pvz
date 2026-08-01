local Image = UIContainer:extend('Image')

Image.quad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)

function Image:init(texture, x, y)
	self.texture = texture
	self.scissor = nil -- { x = ; y = ; w = ; h = }
	self.scissorCrop = true
	
	UIContainer.init(self, x, y, texture:getPixelDimensions())
end

function Image:setImage(texture)
	if type(texture) == 'string' then
		texture = Resources.fetch(texture, 'Image')
	end
	
	self.texture = texture
	
	self:setDimensions(texture:getPixelDimensions())
	self:setScissor()
	
	return self
end

function Image:setScissor(x, y, w, h, updateHitbox, crop)
	if crop ~= nil then self.scissorCrop = crop end
	
	if not x then
		self.scissor = nil
		
		if updateHitbox ~= false then self:setHitbox() end
	else
		if not self.scissor then self.scissor = {} end
		
		self.scissor.x, self.scissor.y, self.scissor.w, self.scissor.h = (x or 0), (y or 0), (w or 0), (h or 0)
		
		if updateHitbox ~= false then self:setHitbox(self.scissorCrop and x or 0, self.scissorCrop and y or 0, w, h) end
	end
end
function Image:setScissorPosition(x, y, updateHitbox, crop)
	return self:setScissor(x, y, self.scissor and self.scissor.w or 0, self.scissor and self.scissor.h or 0, updateHitbox, crop)
end
function Image:setScissorDimensions(w, h, updateHitbox, crop)
	return self:setScissor(self.scissor and self.scissor.x or 0, self.scissor and self.scissor.y or 0, w, h, updateHitbox, crop)
end

function Image:getScissor()
	if not scissor then return 0, 0, 0, 0 end
	return self.scissor.x, self.scissor.y, self.scissor.w, self.scissor.h
end
function Image:getScissorPosition()
	if not scissor then return 0, 0 end
	return self.scissor.x, self.scissor.y
end
function Image:getScissorDimensions()
	if not scissor then return 0, 0 end
	return self.scissor.w, self.scissor.h
end

function Image:render()
	if self.scissor then
		Image.quad:setViewport(self.scissor.x, self.scissor.y, self.scissor.w, self.scissor.h, self.texture:getPixelDimensions())
		
		if self.scissorCrop then
			love.graphics.draw(self.texture, Image.quad)
		else
			love.graphics.draw(self.texture, Image.quad, self.scissor.x, self.scissor.y)
		end
	else
		love.graphics.draw(self.texture)
	end
end

return Image
