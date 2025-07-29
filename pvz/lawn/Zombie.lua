local Zombie = Unit:extend('Zombie')

function Zombie:init(x, y)
	Unit.init(self, x, y)
	
	self.transform.yOffset = 40
end

return Zombie