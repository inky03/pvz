local Plant = Unit:extend('Plant')

Plant.upgradeOf = nil
Plant.defaultBlinkAnim = 'blink'

function Plant:init(x, y, challenge)
	Unit.init(self, x, y, challenge)
	
	self:setHitbox(10, 0, 60, 80)
	
	self.damageGroup = Zombie
	
	if self.defaultBlinkAnim then
		self.blinkReanim = Reanimation:new(self.reanimName)
		self.blinkReanim.animation:add('blink', self.defaultBlinkAnim, false)
		self.blinkReanim.animation.onFinish:add(function(_) self.blinkReanim.visible = false end)
		self.blinkReanim.visible = false
		
		self.blinkCountdown = random.int(400, 800)
	end
end

function Plant:initBlink()
end

function Plant:attachBlink(target, layer)
	local target, layer = (target or self), (layer or 'idle')
	if self.blinkReanim then target:attachReanim(layer, self.blinkReanim, layer) end
end

function Plant:update(dt)
	Unit.update(self, dt)
	
	if self.blinkReanim then
		self.blinkCountdown = (self.blinkCountdown - dt * self.speed * self.speedMultiplier * Constants.tickPerSecond)
		if self.blinkCountdown < 0 then self:blink() end
	end
end

function Plant:blink()
	self.blinkReanim.visible = true
	self.blinkReanim.animation:play('blink', true)
	self.blinkCountdown = random.int(400, 800)
end

return Plant