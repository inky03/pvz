local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
local FlagZombie = BasicZombie:extend('FlagZombie')

FlagZombie.showOnStreet = false

function FlagZombie:init(x, y, challenge)
	BasicZombie.init(self, x, y, challenge)
	
	self:toggleLayer('innerarm1', false)
	self:toggleLayer('innerarm2', false)
	self:toggleLayer('innerarm3', false)
	
	self:toggleLayer('Zombie_flaghand', true)
	self:toggleLayer('Zombie_innerarm_screendoor', true)
	
	self.flag = Reanimation:new('Zombie_flagpole')
	self.flag.transform:setPosition(33, 15)
	self:attach('Zombie_flaghand', self.flag, 'idle')
	
	self.animation:get('walk'):setTrack(self.reanim:getTrack('walk2'))
	self.animation:get('walk').speed = random.number(1.1, 1.25)
end

function FlagZombie:setDamagePhase(phase)
	BasicZombie.setDamagePhase(self, phase)
	
	if phase == 1 then
		self.flag:replaceImage('Zombie_flag1', Reanim.getResource('Zombie_flag3'))
	elseif phase == 2 then
		self:toggleLayer('innerarm1', true)
		self:toggleLayer('innerarm2', true)
		self:toggleLayer('innerarm3', true)
		
		self:toggleLayer('Zombie_flaghand', false)
		self:toggleLayer('Zombie_innerarm_screendoor', false)
	end
end

function FlagZombie.getSpawnOffset()
	return 0
end

return FlagZombie