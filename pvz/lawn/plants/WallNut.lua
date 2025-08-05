local WallNut = Plant:extend('WallNut')

WallNut.defaultBlinkAnim = 'blink_twice'
WallNut.reanimName = 'Wallnut'
WallNut.packetRecharge = 3000
WallNut.packetCost = 50
WallNut.maxHp = 4000

function WallNut:init(x, y, challenge)
	Plant.init(self, x, y, challenge)
	
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
	self.animation:setFrame(4)
	
	self:attachBlink(self, 'face')
	self.blinkReanim.animation:add('twitch', 'blink_twitch', false)
	self.blinkReanim.animation:add('blinkThrice', 'blink_thrice', false)
end

function WallNut:hurt(hp, glow)
	Plant.hurt(self, hp, glow)
	
	if self.damagePhase == 0 and self.hp <= (self.maxHp - 1333) then
		self:setDamagePhase(1)
	end if self.damagePhase == 1 and self.hp <= (self.maxHp - 2667) then
		self:setDamagePhase(2)
	end
end

function WallNut:setDamagePhase(phase)
	Plant.setDamagePhase(self, phase)
	
	if phase == 1 then
		self:replaceImage('Wallnut_body', Reanim.getResource('Wallnut_cracked1'))
	elseif phase == 2 then
		self:replaceImage('Wallnut_body', Reanim.getResource('Wallnut_cracked2'))
	end
end

function WallNut:blink()
	local rand = random.int(0, 10)
	
	if rand < 1 then
		self.blinkReanim.animation:play('blink', true)
	else
		self.blinkReanim.animation:play(rand < 7 and 'blink' or 'blinkThrice', true)
	end
	
	self.blinkReanim.visible = true
	self.blinkCountdown = random.int(1000, 2000)
end

return WallNut