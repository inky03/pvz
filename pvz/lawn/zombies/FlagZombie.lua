local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
local FlagZombie = BasicZombie:extend('FlagZombie')

local DamageVisualModifier = Cache.module(Cache.modifiers('DamageVisualModifier'))

FlagZombie.showOnStreet = false

function FlagZombie:init(x, y, challenge)
	BasicZombie.init(self, x, y, challenge)
	
	self:toggleLayer('innerarm1', false)
	self:toggleLayer('innerarm2', false)
	self:toggleLayer('innerarm3', false)
	
	self:toggleLayer('Zombie_flaghand', true)
	self:toggleLayer('Zombie_innerarm_screendoor', true)
	
	self.flag = Reanimation:new('Zombie_flagpole')
	self:attach('Zombie_flaghand', self.flag, 'idle')
	
	self.animation:get('walk'):setTrack(self.reanim:getTrack('walk2'))
	self.animation:get('walk').speed = random.number(1.1, 1.25)
	
	self:applyModifier(DamageVisualModifier, true, {
		{
			health = (self.maxHealth / 2);
			trigger = function(parent)
				self.flag:replaceImage('Zombie_flag1', Reanim.getResource('Zombie_flag3'))
			end
		};
		{
			health = 0;
			trigger = function(parent)
				self:toggleLayer('innerarm1', true)
				self:toggleLayer('innerarm2', true)
				self:toggleLayer('innerarm3', true)
				
				self:toggleLayer('Zombie_flaghand', false)
				self:toggleLayer('Zombie_innerarm_screendoor', false)
			end
		};
	})
end

function FlagZombie.getSpawnOffset()
	return 0
end

return FlagZombie