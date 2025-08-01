local UIContainer = class('UIContainer')

function UIContainer:init(x, y, w, h)
	self.canClickChildren = true
	self.canClick = true
	
	self.hovering = false
	self.useHand = false
	self.visible = true
	self.children = {}
	self.parent = nil
	
	self:setPosition(x, y)
	self:setDimensions(w, h)
end

function UIContainer:addElement(element)
	table.insert(self.children, element)
	element.parent = self
	return element
end

function UIContainer:setPosition(x, y)
	self.x, self.y = (x or 0), (y or 0)
end
function UIContainer:setDimensions(w, h)
	self.w, self.h = (w or 50), (h or 50)
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

function UIContainer:getHoveringElement(x, y, mouseX, mouseY)
	if self.canClickChildren then
		for i = #self.children, 1, -1 do
			local child = self.children[i]
			child = child:getHoveringElement(child.x + x, child.y + y, mouseX, mouseY)
			
			if child then return child end
		end
	end
	
	if not self.canClick then return nil end
	return ((math.within(mouseX, x, x + self.w) and math.within(mouseY, y, y + self.h)) and self or nil)
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
	
	for _, child in ipairs(self.children) do child:draw(child.x + x, child.y + y) end
	
	if debugMode then self:debugDraw(x, y) end
end
function UIContainer:drawTop(x, y)
	if not self.visible then return end
	
	for _, child in ipairs(self.children) do child:drawTop(child.x + x, child.y + y) end
end
function UIContainer:debugDraw(x, y)
	love.graphics.setColor(0, 0, 1)
	love.graphics.rectangle('line', x, y, self.w, self.h)
	love.graphics.setColor(1, 1, 1)
end

return UIContainer