local PeaShooter = Plant:extend('PeaShooter')

function PeaShooter:init(x, y)
	Plant.init(self, x, y)
	
	self.hp = 300
	
	self.stem = self:getLayer('stem')
	self.stemTransform = ReanimFrame:new()
	self.headTransform = ReanimFrame:new()
	self.headTransform.scaleCoords = true
	
	self.head = Sprite:new('PeaShooterSingle')
	self.head:playAnimation('head_idle', true)
	
	self.blink = Sprite:new('PeaShooterSingle')
	self.blink.visible = false
end

function PeaShooter:doBlink()
	self.blink.visible = true
	self.blink.animation.loop = false
	self.blink:playAnimation('blink', true)
	self.blink.animation.onFinish:addOnce(function() self.blink.visible = false end)
end

function PeaShooter:update(dt)
	self.super.update(self, dt)
	
	self.head:update(dt)
	self.blink:update(dt)
end

function PeaShooter:render(x, y, transforms)
	local trans = (transforms or {self.transform})
	
	self.super.render(self, x, y, trans)
	
	self.stemTransform:copy(self.stem.frame)
	self.stemTransform:setPosition(self.stemTransform.x - 37.6, self.stemTransform.y - 48.7)
	
	table.insert(trans, 1, self.stemTransform)
	self.head:render(x, y, trans)
	
	if self.blink.visible then
		local faceFrame = self.head:getLayer('face').frame
		self.headTransform:copy(faceFrame)
		self.headTransform:setOffset(19.15, 17.5)
		self.headTransform:setOrigin(19.15, 17.5)
		self.headTransform:setScale(self.headTransform.xScale * 1.8, self.headTransform.yScale * 1.8)
		table.insert(trans, 1, self.headTransform)
		self.blink:render(x, y, trans)
	end
	
	love.graphics.setShader()
end

function PeaShooter:getReanim()
	return 'PeaShooterSingle'
end

return PeaShooter