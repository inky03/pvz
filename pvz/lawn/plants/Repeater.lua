local PeaShooter = Cache.module(Cache.plants('PeaShooter'))
local Repeater = PeaShooter:extend('Repeater')

function Repeater:init(x, y)
	PeaShooter.init(self, x, y)
	
	self.head:toggleLayer('idle_shoot_blink', false)
	
	self.firePhase = 0
	
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

function Repeater.getReanim()
	return 'PeaShooter'
end

return Repeater