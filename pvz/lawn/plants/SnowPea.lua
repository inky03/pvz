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
end

return SnowPea