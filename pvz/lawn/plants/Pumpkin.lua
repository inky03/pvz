local Pumpkin = Plant:extend('Pumpkin')

Pumpkin.isShield = true

Pumpkin.defaultBlinkAnim = ''
Pumpkin.reanimName = 'Pumpkin'
Pumpkin.packetRecharge = 3000
Pumpkin.packetCost = 125
Pumpkin.maxHp = 4000

function Pumpkin:init(x, y, challenge)
	Plant.init(self, x, y, challenge)
	
	self.yOffset = -10
	self.carryTypes = nil
	self.shadowOffset.y = 60
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
end

function Pumpkin:drawBack(x, y)
	self:toggleLayer('Pumpkin_front', false)
	self:toggleLayer('Pumpkin_back', true)
	Plant.draw(self, x, y)
end
function Pumpkin:draw(x, y)
	self:toggleLayer('Pumpkin_front', true)
	self:toggleLayer('Pumpkin_back', false)
	Plant.draw(self, x, y)
end

function Pumpkin:canPlantOnTop(plant)
	return (plant.class ~= self.class and not plant.canCarry)
end

function Pumpkin:hurt(hp, glow)
	Plant.hurt(self, hp, glow)
	
	if self.damagePhase == 0 and self.hp <= (self.maxHp * 2 / 3) then
		self:setDamagePhase(1)
	end if self.damagePhase == 1 and self.hp <= (self.maxHp / 3) then
		self:setDamagePhase(2)
	end
end
function Pumpkin:setDamagePhase(phase)
	Plant.setDamagePhase(self, phase)
	
	if phase == 1 then
		self:replaceImage('Pumpkin_front', Reanim.getResource('Pumpkin_damage1'))
	elseif phase == 2 then
		self:replaceImage('Pumpkin_front', Reanim.getResource('Pumpkin_damage3'))
	end
end

return Pumpkin