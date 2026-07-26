local WallNut = Plant:extend('WallNut')

local DamageVisualModifier = Cache.module(Cache.modifiers('DamageVisualModifier'))

WallNut.defaultBlinkAnim = 'blink_twice'
WallNut.reanimName = 'Wallnut'
WallNut.packetRecharge = 3000
WallNut.packetCost = 50
WallNut.maxHealth = 4000
WallNut.id = 3

function WallNut:init(x, y, challenge)
	Plant.init(self, x, y, challenge)
	
	self.hard = true
	
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
	self.animation:setFrame(4)
	
	self:attachBlink(self, 'face')
	self.blinkCountdown = random.int(1000, 2000)
	self.blinkReanim.animation:add('twitch', 'blink_twitch', false)
	self.blinkReanim.animation:add('blinkThrice', 'blink_thrice', false)
	
	local mod = self:applyModifier(DamageVisualModifier, false, {
		{ health = (self.maxHealth * 2 / 3); trigger = function(parent) parent:replaceImage('Wallnut_body', Reanim.getResource('Wallnut_cracked1')) end };
		{ health = (self.maxHealth / 3); trigger = function(parent) parent:replaceImage('Wallnut_body', Reanim.getResource('Wallnut_cracked2')) end };
	})
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