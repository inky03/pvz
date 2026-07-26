local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
local ConeHeadZombie = BasicZombie:extend('ConeHeadZombie')

local ShieldModifier = Cache.module(Cache.modifiers('ShieldModifier'))

ConeHeadZombie.maxHelmHealth = 470

ConeHeadZombie.value = 2
ConeHeadZombie.startingLevel = 3
ConeHeadZombie.firstAllowedWave = 1

function ConeHeadZombie:init(x, y, challenge)
	BasicZombie.init(self, x, y, challenge)
	
	self:toggleLayer('cone', true)
	
	self:applyModifier(ShieldModifier, true, self.maxHelmHealth, {
		{ health = (self.maxHelmHealth * 2 / 3); trigger = function(parent) self:replaceImage('Zombie_cone1', Reanim.getResource('Zombie_cone2')) end };
		{ health = (self.maxHelmHealth / 3); trigger = function(parent) self:replaceImage('Zombie_cone1', Reanim.getResource('Zombie_cone3')) end };
		{ health = 0; trigger = function(parent) self:toggleLayer('cone', false) end };
	}, function(modifier, damage) Sound.playRandom({ 'plastichit' ; 'plastichit2' }, 5) end)
end

return ConeHeadZombie
