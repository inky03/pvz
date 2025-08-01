local Lawn = UIContainer:extend('Lawn')

function Lawn:init(x, y)
	self.texture = Cache.image('images/background1')
	
	UIContainer.init(self, 0, 0, 1880, 720)
	
	self.topLeft = {
		x = 460 + 40;
		y = 60 + 80;
	}
	self.tileSize = {
		x = 80;
		y = 100;
	}
	self.size = {
		x = 9;
		y = 5;
	}
	self.particles = {}
	self.units = {}
	
	self.hoveringEntity = nil
	self.hoverCanvas = love.graphics.newCanvas(windowWidth, windowHeight)
	
	self.tW, self.tH = self.texture:getPixelDimensions()
end

function Lawn:unitAt(x, y, entityGroup)
	return lambda.find(self.units, function(unit)
		if entityGroup and not unit:instanceOf(entityGroup) then return false end
		return (unit.boardX == x and unit.boardY == y)
	end)
end
function Lawn:spawnUnit(unit, x, y)
	unit.board = self
	unit.parent = self
	unit:setPosition(self:getWorldPosition(x, y))
	unit:updateBoardPosition()
	self:insertUnitSort(unit)
	
	return unit
end
function Lawn:removeUnit(needle)
	for i, unit in ipairs(self.units) do
		if unit == needle then
			table.remove(self.units, i)
			return
		end
	end
end
function Lawn:removeParticle(needle)
	for i, unit in ipairs(self.particles) do
		if unit == needle then
			table.remove(self.particles, i)
			return
		end
	end
end

function Lawn:mousePressed(mouseX, mouseY)
	if self.hoveringEntity then
		local x, y = self:screenToElement(mouseX, mouseY)
		
		if self:withinBoard(self:getBoardPosition(x, y)) then
			if self:tryPlant(self.hoveringEntity) then
				self.hoveringEntity = nil
			end
		end
	end
end
function Lawn:mouseMoved(mouseX, mouseY)
	self:updateHover(mouseX, mouseY)
end
function Lawn:mouseLeft()
	if self.hoveringEntity then
		self.hoveringEntity.visible = false
	end
end

function Lawn:update(dt)
	UIContainer.update(self, dt)
	
	lambda.foreach(self.units, function(unit) unit:update(dt) end)
	lambda.foreach(self.particles, function(unit) unit:update(dt) end)
end
function Lawn:updateHover(mouseX, mouseY)
	if self.hoveringEntity then
		local x, y = self:screenToElement(mouseX, mouseY)
		local boardX, boardY = self:getBoardPosition(x, y)
		boardX, boardY = math.floor(boardX), math.floor(boardY)
		
		self.hoveringEntity:setPosition(self:getWorldPosition(boardX, boardY))
		self.hoveringEntity.boardX, self.hoveringEntity.boardY = boardX, boardY
		
		self.hoveringEntity.visible = self:tryPlant(self.hoveringEntity, true)
	end
end
function Lawn:tryPlant(entity, eval)
	if not self:withinBoard(entity.boardX, entity.boardY) then return false end
	
	local plant = self:unitAt(entity.boardX, entity.boardY, Plant)
	
	if plant then
		local upgrade = entity.isUpgradeOf()
		if not upgrade or (upgrade and not plant:instanceOf(upgrade)) then
			if not eval then print('theres a plant here.') end
			return false
		end
	else
		if entity.isUpgradeOf() then
			if not eval then print('its an upgrade.') end
			return false
		end
	end
	
	if not eval then
		if plant then
			plant:destroy()
		end
		self:spawnUnit(entity, entity.boardX, entity.boardY)
	end
	
	return true
end

function Lawn:draw(x, y)
	if not self.visible then return end
	
	love.graphics.draw(self.texture, x + (self.w - self.tW) * .5, y + (self.h - self.tH) * .5)
	
	lambda.foreach(self.units, function(unit) unit:drawShadow(x + unit.x, y + unit.y) end)
	
	if debugMode then self:debugDraw(x, y) end
	
	UIContainer.draw(self, x, y)
end
function Lawn:drawTop(x, y) -- draw units
	if not self.visible then return end
	
	lambda.foreach(self.units, function(unit) unit:draw(x + unit.x, y + unit.y) end)
	lambda.foreach(self.particles, function(part) part:draw(x + part.x, y + part.y) end)
	
	if self.hoveringEntity then
		love.graphics.setCanvas(self.hoverCanvas)
		love.graphics.clear()
		self.hoveringEntity:draw(x + self.hoveringEntity.x, y + self.hoveringEntity.y)
		love.graphics.setCanvas()
		
		love.graphics.setBlendMode('alpha', 'premultiplied')
		love.graphics.setColor(.5, .5, .5, .5)
		love.graphics.draw(self.hoverCanvas)
		love.graphics.setBlendMode('alpha')
		
		local prevVisible = self.hoveringEntity.visible
		local mouseX, mouseY = love.mouse.getPosition()
		self.hoveringEntity.visible = true
		self.hoveringEntity:draw(mouseX - 36, mouseY - 60)
		self.hoveringEntity.visible = prevVisible
	end
	
	UIContainer.drawTop(self, x, y)
end

function Lawn:insertUnitSort(unit)
	for i = 1, #self.units do
		local otherUnit = self.units[i]
		if (unit.y < otherUnit.y) or (unit.y == otherUnit.y and unit:instanceOf(Plant)) then
			table.insert(self.units, i, unit)
			return unit
		end
	end
	table.insert(self.units, unit)
	return unit
end

function Lawn:debugDraw(x, y)
	UIContainer.debugDraw(self, x, y)
	
	for row = 1, self.size.y do
		for col = 1, self.size.x do
			local xx, yy = self:getWorldPosition(col, row)
			love.graphics.rectangle('line', xx + x, yy + y, self.tileSize.x, self.tileSize.y)
		end
	end
end

function Lawn:getDimensions()
	return self:getWorldPosition(self:getWidth(), self:getHeight())
end
function Lawn:getWidth()
	return (self.size.x * self.tileSize.x)
end
function Lawn:getHeight()
	return (self.size.y * self.tileSize.y)
end
function Lawn:getWorldPosition(col, row)
	return (self.topLeft.x + (col - 1) * self.tileSize.x), (self.topLeft.y + (row - 1) * self.tileSize.y)
end
function Lawn:getBoardPosition(x, y, bound)
	local xx, yy = ((x - self.topLeft.x) / self.tileSize.x + 1), ((y - self.topLeft.y) / self.tileSize.y + 1)
	if bound then return self:boundToBoard(xx, yy)
	else return xx, yy end
end
function Lawn:boundToBoard(x, y)
	return math.floor(math.clamp(x, 1, self.size.x)), math.floor(math.clamp(y, 1, self.size.y))
end
function Lawn:withinBoard(x, y)
	return (math.within(x, 1, self.size.x + 1) and math.within(y, 1, self.size.y + 1))
end

return Lawn