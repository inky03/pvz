local Button = UIContainer:extend('Button')

Button.slice = true
Button.useHand = true
Button.hoverSound = nil
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
Button.textureNames = {
	hovering = 'button';
	normal = 'button';
	down = 'button_down';
}
Button.buttonOffsets = {
	down = {x = 1; y = 0};
}
Button.folder = 'images'
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
	if self.slice then
		for _, tex in ipairs({ 'left' ; 'middle' ; 'right' }) do
			self.textures.hovering[tex] = Cache.image(self.textureNames.hovering .. '_' .. tex, self.folder)
			self.textures.normal[tex] = Cache.image(self.textureNames.normal .. '_' .. tex, self.folder)
			self.textures.down[tex] = Cache.image(self.textureNames.down .. '_' .. tex, self.folder)
		end
	else
		self.textures.hovering.left = Cache.image(self.textureNames.hovering, self.folder)
		self.textures.normal.left = Cache.image(self.textureNames.normal, self.folder)
		self.textures.down.left = Cache.image(self.textureNames.down, self.folder)
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
			if self.clickSound then Sound.play(self.clickSound) end
			self.onPress:dispatch(self)
		end
		self.pushed = false
	end
end
function Button:mouseEntered()
	if self.hoverSound then Sound.play(self.hoverSound) end
	UIContainer.mouseEntered(self)
end

function Button:getState()
	return (self.hovering and (self.pushed and 'down' or 'hovering') or 'normal')
end

function Button:render(renderGroup)
	local textures = self.textures[self:getState()]
	local fontPos = (self.fontOffsets[self:getState()] or self.defaultOffsets)
	local buttonPos = (self.buttonOffsets[self:getState()] or self.defaultOffsets)
	
	love.graphics.draw(textures.left, buttonPos.x, buttonPos.y)
	
	if self.slice then
		textures.middle:setWrap('repeat', 'clamp')
		
		local middleWidth = (self.w - textures.left:getPixelWidth() - textures.right:getPixelWidth())
		if middleWidth > 0 then
			self.quad:setViewport(0, 0, middleWidth, textures.middle:getPixelHeight(), textures.middle:getPixelDimensions())
			love.graphics.draw(textures.middle, self.quad, textures.left:getPixelWidth() + buttonPos.x, buttonPos.y)
		end
		
		love.graphics.draw(textures.right, self.w - textures.right:getPixelWidth() + buttonPos.x, buttonPos.y)
	end
	
	self.font:setPosition(fontPos.x + buttonPos.x, fontPos.y + buttonPos.y)
	self.font:setExtra(self.fontExtra[self:getState()])
end

return Button
