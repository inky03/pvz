local PeaShooter = Cache.module(Cache.plants('PeaShooter'))
local SnowPea = PeaShooter:extend('SnowPea')
local SnowPeaProjectile = Cache.module(Cache.projectiles('SnowPeaProjectile'))

SnowPea.reanimName = 'SnowPea'
SnowPea.packetCost = 175
SnowPea.id = 5

SnowPea.projectile = SnowPeaProjectile

function SnowPea:fireProjectile()
	PeaShooter.fireProjectile(self)
	Sound.play('snow_pea_sparkles', 10)
	self.lawn:spawnParticle('SnowPeaPuff', self.x + 68, self.y + 20)
end

return SnowPea