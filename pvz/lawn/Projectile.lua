local Projectile = Unit:extend('Projectile')

Projectile.reanimName = nil

function Projectile:init(x, y)
	Unit.init(self, x, y)
	
	self:setHitbox(2, 2, 24, 24)
	
	self.autoBoardPosition = true
	self.damageGroup = Zombie
	self.direction = 0
	self.speed = 300
end

function Projectile:update(dt)
	local xVel, yVel = self:getVelocity(self.speed * dt)
	local oldX, oldY = self.x, self.y
	self.x, self.y = (self.x + xVel), (self.y + yVel)
	
	local collision = self:queryCollision(self.damageGroup, self.damageFilter, oldX, oldY)
	if collision then
		self:hit(collision)
		self:destroy()
		return
	end
	
	local screenX = self:elementToScreen(-self.xOffset, -self.yOffset)
	if screenX > gameWidth then
		self:destroy()
		return
	end
	
	Unit.update(self, dt)
end

function Projectile:getVelocity(delta)
	return (math.cos(self.direction) * delta), (math.sin(self.direction) * delta)
end

return Projectile