local PeaShooter = Cache.module(Cache.plants('PeaShooter'))
local Repeater = Cache.module(Cache.plants('Repeater'))
local GatlingPea = PeaShooter:extend('GatlingPea')

GatlingPea.upgradeOf = Repeater

GatlingPea.reanimName = 'GatlingPea'
GatlingPea.stemLayer = 'idle'
GatlingPea.packetRecharge = 5000
GatlingPea.packetCost = 250
GatlingPea.id = 40

function GatlingPea:animate()
	self.head.animation.onFrame:add(function(animation)
		if animation.name == 'shoot' then
			if animation.frame == 12 or animation.frame == 18 or animation.frame == 24 or animation.frame == 30 then
				self:fireProjectile()
			elseif animation.frame > 36 then
				self.head.animation:play('idle', false, nil, false)
			end
		end
	end)
end

function GatlingPea:fire()
	PeaShooter.fire(self)
end

return GatlingPea