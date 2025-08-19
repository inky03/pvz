local CheckBox = UIContainer:extend('CheckBox')

CheckBox.textureName = 'options_checkbox'
CheckBox.clickSound = 'buttonclick'

CheckBox.fontColor = { 107 / 255 ; 109 / 255 ; 149 / 255 }
CheckBox.fontName = 'DwarvenTodcraft'
CheckBox.fontDistance = 5
CheckBox.fontHeight = 30
CheckBox.fontSize = 18

function CheckBox:init(x, y, text, w, fun, checked)
	self.uncheckedTexture = Cache.image(self.textureName .. '0', 'images')
	self.checkedTexture = Cache.image(self.textureName .. '1', 'images')
	
	self.pushed = false
	self.useHand = true
	self.onCheck = Signal:new()
	self.checked = (checked or false)
	if fun then self.onCheck:add(fun) end
	
	UIContainer.init(self, x, y, w or 230, self.uncheckedTexture:getPixelHeight())
	
	self:setHitbox(self.w - self.uncheckedTexture:getPixelWidth(), 0, self.uncheckedTexture:getPixelDimensions())
	
	self.font = self:addElement(Font:new(self.fontName, self.fontSize, 0, 0, self.hitbox.x - self.fontDistance, self.fontHeight))
	self.font:setLayerColor('Main', unpack(self.fontColor))
	self.font:setAlignment('right', 'center')
	self.font:setText(text)
end

function CheckBox:mousePressed(mouseX, mouseY, button)
	if button == 1 then
		self.pushed = true
	end
end
function CheckBox:mouseReleasedAnywhere(mouseX, mouseY, button, isTouch, presses)
	UIContainer.mouseReleasedAnywhere(self, mouseX, mouseY, button, isTouch, presses)
	
	if button == 1 then
		if self.hovering and self.pushed then
			Sound.play(self.clickSound)
			self.onCheck:dispatch(self, not self.checked)
			self.checked = (not self.checked)
		end
		self.pushed = false
	end
end

function CheckBox:draw(x, y)
	local o = (self.pushed and 1 or 0)
	love.graphics.draw(self.checked and self.checkedTexture or self.uncheckedTexture, x + self.w - self.uncheckedTexture:getPixelWidth() + o, y + o)
	
	UIContainer.draw(self, x, y)
end

return CheckBox