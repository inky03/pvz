local PeaShooter = Cache.module(Cache.plants('PeaShooter'))
local SnowPea = PeaShooter:extend('SnowPea')
local SnowPeaProjectile = Cache.module(Cache.projectiles('SnowPeaProjectile'))

SnowPea.reanimName = 'SnowPea'
SnowPea.packetCost = 175

SnowPea.projectile = SnowPeaProjectile

return SnowPea