local Slider = UIContainer:extend('Slider')

Slider.slotTextureName = 'options_sliderslot'
Slider.knobTextureName = 'options_sliderknob2'
Slider.dropSound = 'buttonclick'
Slider.cursor = 'drag'
Slider.canDrag = true
Slider.edgeNear = 11

Slider.fontColor = { 107 / 255 ; 109 / 255 ; 149 / 255 }
Slider.fontName = 'DwarvenTodcraft'
Slider.fontDistance = 10
Slider.fontHeight = 6
Slider.fontSize = 18

function Slider:init(x, y, text, w, fun, progress)
	self.slotTexture = Cache.image(self.slotTextureName, 'images')
	self.knobTexture = Cache.image(self.knobTextureName, 'images')
	
	self.onDrop = Signal:new()
	self.onChange = Signal:new()
	self.progress = (progress or .5)
	if fun then self.onChange:add(fun) end
	
	UIContainer.init(self, x, y, w or 250, self.slotTexture:getPixelHeight())
	
	local knobX = self:getKnobX(self.progress)
	local leftEdge = self:getEdges()
	self:setHitbox(
		knobX, math.round((self.slotTexture:getPixelHeight() - self.knobTexture:getPixelHeight()) * .5),
		self.knobTexture:getPixelDimensions()
	)
	self.dragOffset = 0
	
	self.font = self:addElement(Font:new(self.fontName, self.fontSize, 0, 0, leftEdge - self.fontDistance, self.fontHeight))
	self.font:setLayerColor('Main', unpack(self.fontColor))
	self.font:setAlignment('right', 'center')
	self.font:setText(text)
end

function Slider:getEdges()
	local center = (self.knobTexture:getPixelWidth() * .5)
	return (self.w - self.slotTexture:getPixelWidth() - center + self.edgeNear), (self.w - center - self.edgeNear)
end
function Slider:getKnobX(progress)
	local leftEdge, rightEdge = self:getEdges()
	return math.round(math.lerp(leftEdge, rightEdge, progress))
end
function Slider:getKnobProgress()
	local leftEdge, rightEdge = self:getEdges()
	return math.remap(self.hitbox.x, leftEdge, rightEdge, 0, 1)
end
function Slider:mouseGrabbed(mouseX, mouseY)
	local dragX = self:screenToElement(mouseX)
	self.dragOffset = (self.hitbox.x - dragX)
end
function Slider:mouseDrag(mouseX, mouseY, deltaX, deltaY, isTouch)
	local oldProgress = self.progress
	self.hitbox.x = math.clamp(self:screenToElement(mouseX, mouseY) + self.dragOffset, self:getEdges())
	self.progress = self:getKnobProgress()
	if oldProgress ~= self.progress then
		self.onChange:dispatch(self.progress, oldProgress)
	end
end
function Slider:mouseDropped()
	self.onDrop:dispatch(self.progress)
	Sound.play(self.dropSound)
end

function Slider:draw(x, y)
	love.graphics.draw(self.slotTexture, x + self.w - self.slotTexture:getPixelWidth(), y)
	love.graphics.draw(self.knobTexture, x + self.hitbox.x, y + self.hitbox.y + (self.dragging and 1 or 0))
	
	UIContainer.draw(self, x, y)
end

return Slider