local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
local BucketHeadZombie = BasicZombie:extend('BucketHeadZombie')

local ShieldModifier = Cache.module(Cache.modifiers('ShieldModifier'))

BucketHeadZombie.maxHelmHealth = 1100

BucketHeadZombie.value = 4
BucketHeadZombie.pickWeight = 3000
BucketHeadZombie.startingLevel = 8
BucketHeadZombie.firstAllowedWave = 1

function BucketHeadZombie:init(x, y, challenge)
	BasicZombie.init(self, x, y, challenge)
	
	self:toggleLayer('bucket', true)
	
	self:applyModifier(ShieldModifier, true, self.maxHelmHealth, {
		{ health = (self.maxHelmHealth * 2 / 3); trigger = function(parent) self:replaceImage('Zombie_bucket1', Reanim.getResource('Zombie_bucket2')) end };
		{ health = (self.maxHelmHealth / 3); trigger = function(parent) self:replaceImage('Zombie_bucket1', Reanim.getResource('Zombie_bucket3')) end };
		{ health = 0; trigger = function(parent) self:toggleLayer('bucket', false) end };
	}, function(modifier, damage) Sound.playRandom({ 'shieldhit' ; 'shieldhit2' }, 10) end)
end

return BucketHeadZombie
