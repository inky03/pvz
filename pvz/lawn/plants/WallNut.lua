local WallNut = Plant:extend('WallNut')

WallNut.reanimName = 'Wallnut'
WallNut.packetRecharge = 3000
WallNut.packetCost = 50
WallNut.maxHp = 4000

function WallNut:init(x, y, challenge)
	Plant.init(self, x, y, challenge)
	
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
	self.animation:setFrame(4)
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

return WallNut