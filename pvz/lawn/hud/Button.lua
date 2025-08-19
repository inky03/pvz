local Button = UIContainer:extend('Button')

Button.slice = true
Button.useHand = true
Button.textureName = 'button'
Button.clickSound = 'buttonclick'
Button.fontName = 'DwarvenTodcraft'
Button.fontSize = 18
Button.fontExtra = {
	hovering = 'BrightGreenInset';
	normal = 'GreenInset';
	down = 'BrightGreenInset';
}
Button.fontOffsets = {
	hovering = {x = 3; y = -3};
	normal = {x = 3; y = -3};
	down = {x = 3; y = -2};
}
Button.buttonOffsets = {
	down = {x = 1; y = 0};
}
Button.defaultOffsets = {x = 0; y = 0}

function Button:init(x, y, text, fun, w)
	self.pushed = false
	self.textures = {
		hovering = {};
		normal = {};
		down = {};
	}
	self:create()
	
	self.onPress = Signal:new()
	if fun then self.onPress:add(fun) end
	
	local w = w
	if not w then
		w = self.textures.normal.left:getPixelWidth()
		
		if self.slice then
			w = (w + self.textures.normal.middle:getPixelWidth() + self.textures.normal.right:getPixelWidth())
		end
	end
	self.quad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)
	
	UIContainer.init(self, x, y, w, self.textures.normal.left:getPixelHeight())
	
	self.font = self:addElement(Font:new(self.fontName, self.fontSize, 0, 0, self.w, self.h, self.fontExtra[self:getState()]))
	self.font:setAlignment('center', 'center')
	self.font:setText(text)
end
function Button:create()
	for _, tex in ipairs({ 'left' ; 'middle' ; 'right' }) do
		local normalTexture = Cache.image(self.textureName .. '_' .. tex, 'images')
		
		self.textures.normal[tex] = normalTexture
		self.textures.down[tex] = (Cache.image(self.textureName .. '_down_' .. tex, 'images', true) or normalTexture)
		self.textures.hovering[tex] = (Cache.image(self.textureName .. '_hovering_' .. tex, 'images', true) or normalTexture)
	end
end

function Button:mousePressed(mouseX, mouseY, button)
	if button == 1 then
		self.pushed = true
	end
end
function Button:mouseReleasedAnywhere(mouseX, mouseY, button, isTouch, presses)
	UIContainer.mouseReleasedAnywhere(self, mouseX, mouseY, button, isTouch, presses)
	
	if button == 1 then
		if self.hovering and self.pushed then
			Sound.play(self.clickSound)
			self.onPress:dispatch(self)
		end
		self.pushed = false
	end
end

function Button:getState()
	return (self.hovering and (self.pushed and 'down' or 'hovering') or 'normal')
end

function Button:draw(x, y)
	local textures = self.textures[self:getState()]
	local fontPos = (self.fontOffsets[self:getState()] or self.defaultOffsets)
	local buttonPos = (self.buttonOffsets[self:getState()] or self.defaultOffsets)
	
	love.graphics.draw(textures.left, x + buttonPos.x, y + buttonPos.y)
	
	if self.slice then
		textures.middle:setWrap('repeat', 'clamp')
		
		local middleWidth = (self.w - textures.left:getPixelWidth() - textures.right:getPixelWidth())
		if middleWidth > 0 then
			self.quad:setViewport(0, 0, middleWidth, textures.middle:getPixelHeight(), textures.middle:getPixelDimensions())
			love.graphics.draw(textures.middle, self.quad, x + textures.left:getPixelWidth() + buttonPos.x, y + buttonPos.y)
		end
		
		love.graphics.draw(textures.right, x + self.w - textures.right:getPixelWidth() + buttonPos.x, y + buttonPos.y)
	end
	
	self.font:setPosition(fontPos.x + buttonPos.x, fontPos.y + buttonPos.y)
	self.font:setExtra(self.fontExtra[self:getState()])
	UIContainer.draw(self, x, y)
end

return Button