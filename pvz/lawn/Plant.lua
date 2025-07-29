local Plant = Unit:extend('Plant')

function Plant:init(x, y)
	Unit.init(self, x, y)
	
	self.hitbox.x = 10
	self.hitbox.w = 60
	
	self.shadow = Cache.image('images/plantshadow')
end

function Plant:update(dt)
	Unit.update(self, dt)
	-- todo blinking logic
end

function Plant:draw(x, y, transforms)
	if not self.reanim or not self.visible then return end
	
	love.graphics.setShader(self.shader)
	love.graphics.draw(self.shadow, x + (80 - self.shadow:getPixelWidth()) * .5, y + 50)
	self:render(x, y, transforms)
	love.graphics.setShader(nil)
	
	self:debugDraw(x, y)
end

return Plant