local Plant = Unit:extend('Plant')

function Plant:init(x, y)
	Unit.init(self, x, y)
	
	self:setHitbox(10, 0, 60, 80)
	
	self.damageGroup = Zombie
	
	self.shadow = Cache.image('images/plantshadow')
end

function Plant:update(dt)
	Unit.update(self, dt)
	-- todo blinking logic
end

function Plant:drawShadow(x, y)
	love.graphics.draw(self.shadow, x + (80 - self.shadow:getPixelWidth()) * .5, y + 50)
end

return Plant