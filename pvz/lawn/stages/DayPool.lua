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
	
	self:addElement(PoolEffect:new(34 + 220, 278))
	
	for col = 1, self.size.x do
		self:setSurfaceAt(col, 3, 'water')
		self:setSurfaceAt(col, 4, 'water')
	end
end

return DayPool