local Pea = Projectile:extend('Pea')

function Pea:init()
	Projectile.init(self, x, y)
	
	self.texture = Cache.image('images/ProjectilePea')
	self.shadow = Cache.image('images/pea_shadows')
	
	self.shadowOffset = {x = 4; y = 66}
	self.shadowQuad = love.graphics.newQuad(0, 0, self.shadow:getPixelWidth() * .5, self.shadow:getPixelHeight(), self.shadow:getPixelWidth(), self.shadow:getPixelHeight())
end

function Pea:drawShadow(x, y)
	if self.flags.ignoreCollisions then return end
	
	love.graphics.draw(self.shadow, self.shadowQuad, x + self.shadowOffset.x, y + self.shadowOffset.y)
end

function Pea:drawSprite(x, y)
	love.graphics.draw(self.texture, math.round(x), math.round(y))
end

return Pea