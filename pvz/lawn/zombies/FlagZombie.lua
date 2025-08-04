local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
local FlagZombie = BasicZombie:extend('FlagZombie')

function FlagZombie:init(x, y)
	BasicZombie.init(self, x, y)
	
	self:toggleLayer('innerarm1', false)
	self:toggleLayer('innerarm2', false)
	self:toggleLayer('innerarm3', false)
	
	self:toggleLayer('Zombie_flaghand', true)
	self:toggleLayer('Zombie_innerarm_screendoor', true)
	
	self.flag = Reanimation:new('Zombie_flagpole')
	self.flag.transform:setPosition(35, 3)
	self:attachReanim('Zombie_flaghand', self.flag, 'idle')
	
	self.animation:get('walk').speed = 1.5
	self.animation:get('walk'):setTrack(self.reanim:getTrack('walk2'))
end

function FlagZombie.getSpawnOffset()
	return 0
end

return FlagZombie