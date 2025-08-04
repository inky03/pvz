local PeaShooter = Cache.module(Cache.plants('PeaShooter'))
local Repeater = PeaShooter:extend('Repeater')

Repeater.reanimName = 'PeaShooter'
Repeater.packetCost = 200

function Repeater:init(x, y, challenge)
	PeaShooter.init(self, x, y, challenge)
	
	self.head:toggleLayer('idle_shoot_blink', false)
	
	self.head.animation.onFrame:add(function(animation)
		if animation.name == 'shoot' then
			if animation.frame == 14 and self.firePhase == 0 then
				self.head.animation:play('shoot', true, self.head.animation:framesToSeconds(2))
				self.head.animation:setFrame(5)
				self.firePhase = 1
			end
		end
	end)
end

function Repeater:fire()
	self.firePhase = 0
	PeaShooter.fire(self)
end

return Repeater