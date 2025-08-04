local SunFlower = Plant:extend('SunFlower')

SunFlower.reanimName = 'SunFlower'
SunFlower.packetCost = 50

function SunFlower:init(x, y)
	Plant.init(self, x, y)
	
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
	self.animation:setFrame(4)
end

function SunFlower:update(dt)
	if not self.active then return end
	
	Plant.update(self, dt * self.speedMultiplier)
end

return SunFlower