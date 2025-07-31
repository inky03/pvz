local PeaShooter = Plant:extend('PeaShooter')

function PeaShooter:init(x, y)
	Plant.init(self, x, y)
	self.hp = 300
	
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
	self.fireTimer = 25
	
	self.head = Reanimation:new(self:getReanim())
	self.head.animation.speed = self.animation.speed
	self.head.animation:add('idle', 'head_idle')
	self.head.animation:play('idle', true)
	
	self:attachReanim('stem', self.head)
end

function PeaShooter:update(dt)
	Plant.update(self, dt)
end

function PeaShooter:render(x, y, transforms)
	local trans = (transforms or {self.transform})
	
	Plant.render(self, x, y, trans)
end

function PeaShooter:getReanim()
	return 'PeaShooterSingle'
end
function PeaShooter:getPreviewAnimation()
	return 'full_idle'
end

return PeaShooter