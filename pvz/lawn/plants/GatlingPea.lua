local PeaShooter = Cache.module(Cache.plants('PeaShooter'))
local Repeater = Cache.module(Cache.plants('Repeater'))
local GatlingPea = PeaShooter:extend('GatlingPea')

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

function GatlingPea.getReanim()
	return 'GatlingPea'
end
function GatlingPea.getStem()
	return 'idle'
end
function GatlingPea.isUpgradeOf()
	return Repeater
end

return GatlingPea