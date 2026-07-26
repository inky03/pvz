local Pumpkin = Plant:extend('Pumpkin')

Pumpkin.isShield = true

Pumpkin.defaultBlinkAnim = ''
Pumpkin.reanimName = 'Pumpkin'
Pumpkin.packetRecharge = 3000
Pumpkin.packetCost = 125
Pumpkin.maxHealth = 4000
Pumpkin.id = 30

function Pumpkin:init(x, y, challenge)
	Plant.init(self, x, y, challenge)
	
	self.yOffset = -10
	self.carryTypes = nil
	self.shadowOffset.y = 60
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
	
	local mod = self:applyModifier(DamageVisualModifier, false, {
		{ health = (self.maxHealth * 2 / 3); trigger = function(parent) parent:replaceImage('Pumpkin_front', Reanim.getResource('Pumpkin_damage1')) end };
		{ health = (self.maxHealth / 3); trigger = function(parent) parent:replaceImage('Pumpkin_front', Reanim.getResource('Pumpkin_damage3')) end };
	})
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

return Pumpkin