local Lawn = class('Lawn')

function Lawn:init()
	self.image = Cache.image('images/background1')
	
	self.topLeft = {
		x = 460 + 40;
		y = 60 + 80;
	}
	self.boardSpacing = {
		x = 80;
		y = 100;
	}
	self.boardSize = {
		x = 9;
		y = 5;
	}
	self.units = {} -- ALL
	self.plants = {} -- individual
	self.zombies = {} -- individual
	
	self.width, self.height = self.image:getPixelDimensions()
end

function Lawn:plantAt(x, y)
	return lambda.find(self.plants, function(plant) return (plant.boardX == x and plant.boardY == y) end)
end
function Lawn:plant(unit, x, y)
	unit:setPosition(self:getTilePosition(x, y))
	table.insert(self.plants, unit)
	unit.board = self
	
	self:refreshUnits()
	return unit
end

function Lawn:update(dt)
	lambda.foreach(self.units, function(unit) unit:update(dt) end)
end

function Lawn:draw(x, y)
	local x, y = (x or 0), (y or 0)
	love.graphics.draw(self.image, x + (1880 - self.width) * .5, y + (720 - self.height) * .5)
	
	self:debugDraw(x, y)
end
function Lawn:drawUnits(x, y)
	local x, y = (x or 0), (y or 0)
	
	lambda.foreach(self.units, function(unit) unit:draw(unit.x, unit.y) end)
end

function Lawn:refreshUnits()
	table.clear(self.units)
	lambda.foreach(self.plants, function(unit) self:insertUnitSort(unit) end)
	lambda.foreach(self.zombies, function(unit) self:insertUnitSort(unit) end)
end
function Lawn:insertUnitSort(unit)
	for i, v in ipairs(self.units) do
		if v.y < unit.y then
			table.insert(self.units, i, unit)
			return unit
		end
	end
	table.insert(self.units, unit)
	return unit
end

function Lawn:debugDraw(x, y)
	for col = 1, self.boardSize.y do
		for row = 1, self.boardSize.x do
			local x, y = self:getTilePosition(row, col)
			love.graphics.rectangle('line', x, y, self.boardSpacing.x, self.boardSpacing.y)
		end
	end
end

function Lawn:getTilePosition(row, col)
	return (self.topLeft.x + (row - 1) * self.boardSpacing.x), (self.topLeft.y + (col - 1) * self.boardSpacing.y)
end

return Lawn