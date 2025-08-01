local PeaShooter = Cache.module(Cache.plants('PeaShooter'))
local SnowPea = PeaShooter:extend('SnowPea')
local SnowPeaProjectile = Cache.module(Cache.projectiles('SnowPeaProjectile'))

function SnowPea:fireProjectile()
	local projectile = self.board:spawnUnit(SnowPeaProjectile:new(), self.boardX, self.boardY)
	projectile.x = (projectile.x + 60)
	projectile.yOffset = -10
end

function SnowPea.getReanim()
	return 'SnowPea'
end

return SnowPea