local SunFlower = Plant:extend('SunFlower')

function SunFlower:init(x, y)
	Plant.init(self, x, y)
	self.hp = 300
	
	trace(self:getAnimation('idle'))
	self:playAnimation('idle', true)
end

function SunFlower:update(dt)
	self.super.update(self, dt)
end

function SunFlower:getReanim()
	return 'SunFlower'
end
function SunFlower:getPreviewFrame()
	return 4
end

return SunFlower