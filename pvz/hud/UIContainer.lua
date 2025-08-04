local UIContainer = class('UIContainer')

UIContainer.hitbox = nil

function UIContainer:init(x, y, w, h)
	self.canClickChildren = true
	self.drawToTop = false
	self.canClick = true
	
	self.hovering = false
	self.useHand = false
	self.visible = true
	self.debug = false
	self.children = {}
	self.parent = nil
	
	self:setDimensions(w, h)
	self:setPosition(x, y)
	self:setHitbox()
end

function UIContainer:addElement(element)
	table.insert(self.children, element)
	element.parent = self
	return element
end
function UIContainer:destroy()
	if self.parent then
		for i, child in ipairs(self.parent.children) do
			if child == self then
				table.remove(self.parent.children, i)
				return
			end
		end
	end
end
function UIContainer:getCount()
	local objects = 1
	for _, child in ipairs(self.children) do
		objects = (objects + child:getCount())
	end
	return objects
end

function UIContainer:setPosition(x, y)
	self.x, self.y = (x or 0), (y or 0)
end
function UIContainer:setDimensions(w, h)
	self.w, self.h = (w or 50), (h or 50)
end
function UIContainer:getHitboxPosition()
	return (self.x + self.hitbox.x), (self.y + self.hitbox.y)
end
function UIContainer:getHitboxDimensions()
	return self.hitbox.w, self.hitbox.h
end
function UIContainer:screenToElement(x, y)
	local parX, parY = 0, 0
	if self.parent then
		parX, parY = self.parent:screenToElement()
	end
	return ((x or 0) + parX - self.x), ((y or 0) + parY - self.y)
end
function UIContainer:elementToScreen(x, y)
	local parX, parY = 0, 0
	if self.parent then
		parX, parY = self.parent:elementToScreen()
	end
	return ((x or 0) + parX + self.x), ((y or 0) + parY + self.y)
end
function UIContainer:setHitbox(x, y, w, h)
	self.hitbox = (self.hitbox or {})
	self.hitbox.x = (x or 0)
	self.hitbox.y = (y or 0)
	self.hitbox.w = (w or self.w)
	self.hitbox.h = (h or self.h)
end

function UIContainer:getHoveringElement(mouseX, mouseY)
	if self.canClickChildren then
		for i = #self.children, 1, -1 do
			local child = self.children[i]
			child = child:getHoveringElement(mouseX, mouseY)
			
			if child then return child end
		end
	end
	
	if not self.canClick then return nil end
	
	local ww, hh = self:getHitboxDimensions()
	local xx, yy = self:screenToElement(mouseX, mouseY)
	
	return ((math.within(xx, self.hitbox.x, self.hitbox.x + ww) and math.within(yy, self.hitbox.y, self.hitbox.y + hh)) and self or nil)
end

function UIContainer:mousePressed(mouseX, mouseY, button, isTouch, presses) end
function UIContainer:mouseReleased(mouseX, mouseY, button, isTouch, presses) end
function UIContainer:mouseMoved(mouseX, mouseY, deltaX, deltaY, isTouch, input) end
function UIContainer:mouseEntered() end
function UIContainer:mouseLeft() end

function UIContainer:setHovering(hovering)
	if self.hovering == hovering then return end
	
	if hovering then self:mouseEntered()
	else self:mouseLeft() end
	
	self.hovering = hovering
end
function UIContainer:canBeClicked()
	return (self.canClick and (not self.parent or self.parent.canClickChildren))
end

function UIContainer:update(dt)
	for _, child in ipairs(self.children) do
		child:update(dt)
	end
end

function UIContainer:draw(x, y)
	if not self.visible then return end
	
	for _, child in ipairs(self.children) do
		if not child.drawToTop then
			child:draw(child.x + x, child.y + y)
		end
	end
	
	if debugMode or self.debug then self:debugDraw(x, y) end
end
function UIContainer:drawTop(x, y)
	if not self.visible then return end
	
	for _, child in ipairs(self.children) do
		if child.drawToTop then
			child:draw(child.x + x, child.y + y)
		end
		child:drawTop(child.x + x, child.y + y)
	end
end
function UIContainer:debugDraw(x, y)
	love.graphics.setColor(0, 0, 1)
	love.graphics.rectangle('line', x + 1, y + 1, self.w - 1, self.h - 1)
	love.graphics.setColor(0, 1, 0)
	love.graphics.rectangle('line', x + 1 + self.hitbox.x, y + 1 + self.hitbox.y, self.hitbox.w - 1, self.hitbox.h - 1)
	love.graphics.setColor(1, 1, 1)
end

return UIContainer