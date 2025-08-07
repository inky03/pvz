local Pea = Cache.module(Cache.projectiles('Pea'))
local SnowPeaProjectile = Pea:extend('SnowPeaProjectile')

function SnowPeaProjectile:init()
	Pea.init(self, x, y)
	
	self.texture = Cache.image('ProjectileSnowPea', 'images')
end

function SnowPeaProjectile:hit(collision)
	Pea.hit(self, collision)
	
	if not collision.flags.blockFrostFront then
		collision.speedMultiplier = math.min(collision.speedMultiplier, .5)
		collision.frost = 15
	end
end

return SnowPeaProjectile