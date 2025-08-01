local SunFlower = Plant:extend('SunFlower')

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

function SunFlower.getReanim()
	return 'SunFlower'
end
function SunFlower.getPreviewFrame()
	return 4
end


return SunFlower