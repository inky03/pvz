local WallNut = Plant:extend('WallNut')

WallNut.reanimName = 'Wallnut'
WallNut.packetRecharge = 3000
WallNut.packetCost = 50
WallNut.maxHp = 4000

function WallNut:init(x, y)
	Plant.init(self, x, y)
	
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
	self.animation:setFrame(4)
end

function WallNut:hurt(hp)
	Plant.hurt(self, hp)
	
	if self.hurtState == 0 and self.hp <= (self.maxHp - 1333) then
		self:setHurtState(1)
	elseif self.hurtState == 1 and self.hp <= (self.maxHp - 2667) then
		self:setHurtState(2)
	end
end

function WallNut:setHurtState(state)
	Plant.setHurtState(self, state)
	
	if state == 1 then
		self:replaceImage('Wallnut_body', Reanim.getResource('Wallnut_cracked1'))
	elseif state == 2 then
		self:replaceImage('Wallnut_body', Reanim.getResource('Wallnut_cracked2'))
	end
end

return WallNut