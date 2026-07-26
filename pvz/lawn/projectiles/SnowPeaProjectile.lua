local Pea = Cache.module(Cache.projectiles('Pea'))
local SnowPeaProjectile = Pea:extend('SnowPeaProjectile')

local FrostModifier = Cache.module(Cache.modifiers('FrostModifier'))

SnowPeaProjectile.particleName = 'SnowPeaSplat'

function SnowPeaProjectile:init(challenge)
	Pea.init(self, challenge)
	
	self.texture = Cache.image('ProjectileSnowPea', 'images')
	
	self.trail = self.lawn:spawnParticle('SnowPeaTrail')
end

function SnowPeaProjectile:update(dt)
	Pea.update(self, dt)
	
	self.trail:moveTo(self.x, self.y + 44 + self.yOffset)
end

function SnowPeaProjectile:hit(collision)
	Pea.hit(self, collision)
	
	if not collision.flags.blockFrostFront then
		collision:applyModifier(FrostModifier, false, 15)
	end
end
function SnowPeaProjectile:destroy()
	Pea.destroy(self)
	
	self.trail:killEmitters()
end

return SnowPeaProjectile