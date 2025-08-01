local Pea = Projectile:extend('Pea')

function Pea:init()
	Projectile.init(self, x, y)
	
	self.texture = Cache.image('images/ProjectilePea')
end

function Pea:drawSprite(x, y)
	love.graphics.draw(self.texture, math.round(x), math.round(y))
end

return Pea