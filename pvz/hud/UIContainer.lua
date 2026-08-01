local UIContainer = class('UIContainer')

UIContainer.hitbox = nil
UIContainer.cursor = nil
UIContainer.useHand = false
UIContainer.canDrag = false
UIContainer.dragButton = 1

function UIContainer:init(x, y, w, h)
	self.canClickChildren = true
	self.drawToTop = false
	self.canClick = true
	self.active = true
	self.alive = true
	self.renderGroup = nil
	self.destroyed = false
	self.renderPixelPerfect = true
	
	self.hovering = false
	self.dragging = false
	self.visible = true
	self.debug = debugMode
	self.children = {}
	self.parent = nil
	
	self.transform = ReanimFrame:new()
	self.transforms = {self.transform}
	
	self:setDimensions(w, h)
	self:setPosition(x, y)
	self:setHitbox()
end

function UIContainer:addElement(element, index, renderGroup)
	if renderGroup then
		element.renderGroup = renderGroup
	end
	
	table.insert(self.children, index or #self.children + 1, element)
	element.parent = self
	
	return element
end
function UIContainer:indexOf(element)
	for i, child in ipairs(self.children) do
		if child == element then
			return i
		end
	end
	return -1
end
function UIContainer:kill()
	self.alive = false
end
function UIContainer:revive()
	self.alive = true
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
	
	self.destroyed = true
end
function UIContainer:getCount()
	local objects = 1
	for _, child in ipairs(self.children) do
		objects = (objects + child:getCount())
	end
	return objects
end
function UIContainer:getBounds(edge)
	local left, top, right, bottom = self.x, self.y, (self.x + self.w), (self.y + self.h)
	
	for i = 1, #self.children do
		local cLeft, cTop, cRight, cBottom = self.children[i]:getBounds(true)
		
		left = math.min(left, cLeft)
		top = math.min(top, cTop)
		right = math.max(right, cRight)
		bottom = math.max(bottom, cBottom)
	end
	
	if edge then
		return left, top, right, bottom
	else
		return left, top, (right - left), (bottom - top)
	end
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
function UIContainer:center(inX, inY, round)
	if inX ~= false then self.x = ((self.parent.w - self.w) * .5) end
	if inY ~= false then self.y = ((self.parent.h - self.h) * .5) end
	if round ~= false then self.x, self.y = math.floor(self.x), math.floor(self.y) end
end

function UIContainer:getHoveringElement(mouseX, mouseY)
	if not self.alive then return nil end
	
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

function UIContainer:mouseGrabbed(mouseX, mouseY, button, isTouch, presses) end
function UIContainer:mouseDrag(mouseX, mouseY, deltaX, deltaY, isTouch) end
function UIContainer:mouseDropped(mouseX, mouseY, button, isTouch, presses) end

function UIContainer:mouseMoved(mouseX, mouseY, deltaX, deltaY, isTouch) end
function UIContainer:mousePressed(mouseX, mouseY, button, isTouch, presses) end
function UIContainer:mouseReleased(mouseX, mouseY, button, isTouch, presses) end
function UIContainer:mouseMovedAnywhere(mouseX, mouseY, deltaX, deltaY, isTouch)
	for _, child in ipairs(self.children) do
		if child.active and child.alive then
			child:mouseMovedAnywhere(mouseX, mouseY, deltaX, deltaY, isTouch)
		end
	end
end
function UIContainer:mousePressedAnywhere(mouseX, mouseY, button, isTouch, presses)
	for _, child in ipairs(self.children) do
		if child.active and child.alive then
			child:mousePressedAnywhere(mouseX, mouseY, button, isTouch, presses)
		end
	end
end
function UIContainer:mouseReleasedAnywhere(mouseX, mouseY, button, isTouch, presses)
	for _, child in ipairs(self.children) do
		if child.active and child.alive then
			child:mouseReleasedAnywhere(mouseX, mouseY, button, isTouch, presses)
		end
	end
end
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
		if child.active and child.alive then
			if child.updateFun then
				child.updateFun(child, dt)
			else
				child:update(dt)
			end
		end
	end
end

function UIContainer:draw(x, y, transforms, ...)
	self:drawRenderGroup(1, x, y, transforms, ...)
end
function UIContainer:render(renderGroup)
	-- render here !!!
end
function UIContainer:drawRenderGroup(renderGroup, x, y, transforms, ...)
	love.graphics.push()
	if self.renderPixelPerfect then love.graphics.translate(math.round(x), math.round(y)) else love.graphics.translate(x, y) end
	
	if self.debug then self:debugRender(renderGroup) end
	
	local pop = (Reanimation.applyTransform(self.transforms) + Reanimation.applyTransform(transforms))
		
	self:render(renderGroup)
	self:renderChildren(renderGroup)
	
	for _ = 1, pop do love.graphics.pop() end
	love.graphics.pop()
end
function UIContainer:renderChildren(renderGroup)
	local children = self.children
	for i = 1, #children do
		local child = children[i]
		
		if not child.renderGroup then child.renderGroup = renderGroup end
		
		if child.renderGroup == renderGroup and child.visible and child.alive and not child.drawToTop then
			child:draw(child.x, child.y)
		end
	end
end
function UIContainer:drawTop(x, y)
	if not self.visible then return end
	
	love.graphics.push()
	love.graphics.translate(x, y)
	local pop = (Reanimation.applyTransform(self.transforms) + Reanimation.applyTransform(transforms))
	
	self:renderTop()
	
	local children = self.children
	for i = 1, #children do
		local child = children[i];
		
		if child.visible and child.drawToTop and child.alive then
			child:draw(child.x, child.y)
		end
		
		child:drawTop(child.x, child.y)
	end
	
	for _ = 1, pop do love.graphics.pop() end
	love.graphics.pop()
end
function UIContainer:renderTop()
	-- render here !!! 2
	-- i shoud just deprecate this in favor of rendergroup though probably. .
end
function UIContainer:drawWindow()
	if not self.visible then return end
	
	for _, child in ipairs(self.children) do
		if child.alive then
			child:drawWindow()
		end
	end
end

UIContainer.debugBoxFillAlpha = (1 / 8)
function UIContainer:debugRender(renderGroup)
	local r, g, b, a = love.graphics.getColor()
	
	love.graphics.setColor(0, 0, 1)
	love.graphics.rectangle('line', 1, 1, self.w - 1, self.h - 1)
	love.graphics.setColor(0, 0, 1, UIContainer.debugBoxFillAlpha)
	love.graphics.rectangle('fill', 1, 1, self.w - 1, self.h - 1)
	
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle('line', 1 + self.hitbox.x, 1 + self.hitbox.y, self.hitbox.w - 1, self.hitbox.h - 1)
	love.graphics.setColor(1, 0, 0, UIContainer.debugBoxFillAlpha)
	love.graphics.rectangle('fill', 1 + self.hitbox.x, 1 + self.hitbox.y, self.hitbox.w - 1, self.hitbox.h - 1)
	
	love.graphics.setColor(r, g, b, a)
end

return UIContainer