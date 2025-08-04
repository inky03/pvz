local Plant = Unit:extend('Plant')

Plant.upgradeOf = nil

function Plant:init(x, y, challenge)
	Unit.init(self, x, y, challenge)
	
	self:setHitbox(10, 0, 60, 80)
	
	self.damageGroup = Zombie
end

function Plant:update(dt)
	Unit.update(self, dt)
	-- todo blinking logic
end

return Plant