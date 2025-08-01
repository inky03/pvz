local Lawn = class('Lawn')

function Lawn:init()
	self.image = Cache.image('images/background1')
	
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
	
	self.width, self.height = self.image:getPixelDimensions()
end

function Lawn:unitAt(x, y)
	return lambda.find(self.plants, function(plant) return (plant.boardX == x and plant.boardY == y) end)
end
function Lawn:spawnUnit(unit, x, y)
	unit.board = self
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

function Lawn:update(dt)
	lambda.foreach(self.units, function(unit) unit:update(dt) end)
	lambda.foreach(self.particles, function(unit) unit:update(dt) end)
end

function Lawn:draw(x, y)
	local x, y = (x or 0), (y or 0)
	love.graphics.draw(self.image, x + (1880 - self.width) * .5, y + (720 - self.height) * .5)
	
	if debugMode then self:debugDraw(x, y) end
end
function Lawn:drawUnits(x, y)
	local x, y = (x or 0), (y or 0)
	
	lambda.foreach(self.units, function(unit) unit:drawShadow(unit.x, unit.y) end)
	
	lambda.foreach(self.units, function(unit) unit:draw(unit.x, unit.y) end)
	lambda.foreach(self.particles, function(part) part:draw(part.x, part.y) end)
end

function Lawn:insertUnitSort(unit)
	for i = 1, #self.units do
		if unit.y < self.units[i].y then
			table.insert(self.units, i, unit)
			return unit
		end
	end
	table.insert(self.units, unit)
	return unit
end

function Lawn:debugDraw(x, y)
	for row = 1, self.size.y do
		for col = 1, self.size.x do
			local x, y = self:getWorldPosition(col, row)
			love.graphics.rectangle('line', x, y, self.tileSize.x, self.tileSize.y)
		end
	end
end

function Lawn:getWorldPosition(col, row)
	return (self.topLeft.x + (col - 1) * self.tileSize.x), (self.topLeft.y + (row - 1) * self.tileSize.y)
end
function Lawn:getBoardPosition(x, y)
	return ((x - self.topLeft.x) / self.tileSize.x + 1), ((y - self.topLeft.y) / self.tileSize.y + 1)
end

return Lawn