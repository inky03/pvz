local PoolEffect = Cache.module('pvz.lawn.stages.pool.PoolEffect')
local Lawn = Cache.module('pvz.lawn.Lawn')
local DayPool = Lawn:extend('DayPool')

DayPool.textureName = 'background3'
DayPool.tileSize = {
	x = 80;
	y = 85;
}
DayPool.size = {
	x = 9;
	y = 6;
}

function DayPool:init(challenge, x, y)
	Lawn.init(self, challenge, x, y)
	
	self:addElement(PoolEffect:new(self, 34 + 220, 278))
	
	for col = 1, self.size.x do
		self:setSurfaceAt(col, 3, 'water')
		self:setSurfaceAt(col, 4, 'water')
	end
	
	self.poolCounter = 0
end

function DayPool:update(dt)
	Lawn.update(self, dt)
	
	self.poolCounter = (self.poolCounter + dt * Constants.tickPerSecond)
end

function DayPool:onPlant(entity, col, row, carry)
	Lawn.onPlant(self, entity, col, row)
	
	if self:getSurfaceAt(col, row) == 'water' then
		Sound.play('plant_water')
	end
end

function DayPool:drawTop(x, y) -- draw units
	if not self.visible then return end
	
	for _, unit in ipairs(self.units) do
		local yOffset = 0
		if unit:instanceOf(Plant) and self:getSurfaceAt(unit.boardX, unit.boardY) == 'water' then
			local poolPhase = (self.poolCounter * 2 * math.pi)
			local xPhase = (unit.boardX + unit.boardY)
			local wave = (poolPhase / 200)
			
			yOffset = (math.sin(xPhase + wave) * 2.5)
		end
		unit:draw(x + unit.x, y + unit.y + yOffset)
	end
	
	for _, part in ipairs(self.particles) do part:draw(x + part.x, y + part.y) end
	
	self:drawHover(x, y)
	
	UIContainer.drawTop(self, x, y)
end

function DayPool:canStreetZombieBeAt(col, row)
	return (col > 1)
end

return DayPool