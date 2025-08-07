local Lawn = UIContainer:extend('Lawn')

Lawn.textureName = 'background1'
Lawn.topLeft = {
	x = 260;
	y = 80;
}
Lawn.tileSize = {
	x = 80;
	y = 100;
}
Lawn.size = {
	x = 9;
	y = 5;
}
Lawn.defaultSurface = 'ground'

function Lawn:init(challenge, x, y)
	self.texture = Cache.image(self.textureName, 'images')
	
	UIContainer.init(self, 0, 0, 1400, 600)
	
	self.challenge = challenge
	self.particles = {}
	self.units = {}
	
	self.selectedPacket = nil
	self.hoveringEntity = nil
	self.hoverCanvas = love.graphics.newCanvas(160, 160)
	
	self.onSpawnUnit = Signal:new()
	self.onDestroyUnit = Signal:new()
	self.onDestroyUnit:add(function()
		if self.hoveringEntity then
			self.hoveringEntity.visible = self:tryPlant(self.hoveringEntity, true)
		end
	end)
	
	self.tW, self.tH = self.texture:getPixelDimensions()
	
	self.surfaces = {}
	for row = 1, self.size.y do
		self.surfaces[row] = {}
		for col = 1, self.size.x do
			self.surfaces[row][col] = self.defaultSurface
		end
	end
end

function Lawn:getCount()
	return (UIContainer.getCount(self) + #self.particles + #self.units)
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
	
	unit:onSpawn()
	
	return unit
end
function Lawn:removeUnit(needle)
	for i, unit in ipairs(self.units) do
		if unit == needle then
			table.remove(self.units, i)
			self.onDestroyUnit:dispatch(unit, i)
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
				self.selectedPacket:onPlanted()
				
				self.hoveringEntity = nil
				self.selectedPacket = nil
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
	
	for _, unit in ipairs(self.units) do unit:update(dt) end
	for _, part in ipairs(self.particles) do part:update(dt) end
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
function Lawn:pickPlant(entity, packet, mouseX, mouseY)
	if self.hoveringEntity then
		print('can\'t pick plant')
	else
		self.hoveringEntity = entity
		self.selectedPacket = packet
		
		love.graphics.setCanvas(self.hoverCanvas)
		love.graphics.clear()
		self.hoveringEntity:draw(40, 40)
		love.graphics.setCanvas()
		
		self:updateHover(mouseX or 0, mouseY or 0)
	end
end
function Lawn:tryPlant(entity, eval)
	if not self:withinBoard(entity.boardX, entity.boardY) then return false end
	
	if not entity:canBeSpawnedAt(self, entity.boardX, entity.boardY) then
		if not eval then print('tile not allowed for planting.') end
		return false
	end
	
	local plant = self:unitAt(entity.boardX, entity.boardY, Plant)
	
	if plant then
		local upgrade = entity.upgradeOf
		if not upgrade or (upgrade and not plant:instanceOf(upgrade)) then
			if not eval then print('theres a plant here.') end
			return false
		end
	else
		if entity.upgradeOf then
			if not eval then print('its an upgrade.') end
			return false
		end
	end
	
	if not eval then
		if plant then
			plant:destroy()
		end
		self:spawnUnit(entity, entity.boardX, entity.boardY)
		entity.visible = true
	end
	
	return true
end

function Lawn:draw(x, y)
	if not self.visible then return end
	
	self:drawBackground(x, y)
	
	lambda.foreach(self.units, function(unit) unit:drawShadow(x + unit.x, y + unit.y) end)
	
	if debugMode then self:debugDraw(x, y) end
	
	UIContainer.draw(self, x, y)
end
function Lawn:drawBackground(x, y)
	love.graphics.draw(self.texture, x + (self.w - self.tW) * .5, y + (self.h - self.tH) * .5)
end
function Lawn:drawTop(x, y) -- draw units
	if not self.visible then return end
	
	for _, unit in ipairs(self.units) do unit:draw(x + unit.x, y + unit.y) end
	for _, part in ipairs(self.particles) do part:draw(x + part.x, y + part.y) end
	
	if self.hoveringEntity then
		local mouseX, mouseY = love.mouse.getPosition()
		
		love.graphics.setBlendMode('alpha', 'premultiplied')
		
		if self.hoveringEntity.visible then
			love.graphics.setColor(.5, .5, .5, .5)
			love.graphics.draw(self.hoverCanvas, x + self.hoveringEntity.x - 40, y + self.hoveringEntity.y - 40)
		end
		
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.hoverCanvas, mouseX - 40 - 36, mouseY - 40 - 60)
		
		love.graphics.setBlendMode('alpha')
	end
	
	UIContainer.drawTop(self, x, y)
end

function Lawn:insertUnitSort(unit)
	for i = 1, #self.units do
		local otherUnit = self.units[i]
		if (unit.y < otherUnit.y) or (unit.y == otherUnit.y and unit:instanceOf(Plant)) then
			return self:insertUnit(unit, i)
		end
	end
	return self:insertUnit(unit)
end
function Lawn:insertUnit(unit, i)
	local i = (i or #self.units + 1)
	table.insert(self.units, i, unit)
	
	self.onSpawnUnit:dispatch(unit, i)
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
function Lawn:getSurfaceAt(col, row)
	local surfaceRow = self.surfaces[row]
	return (surfaceRow and surfaceRow[col] or nil)
end
function Lawn:setSurfaceAt(col, row, surf)
	local surfaceRow = self.surfaces[row]
	if surfaceRow then
		surfaceRow[col] = surf
		return surf
	end
	return nil
end

return Lawn