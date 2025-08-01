local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
local FlagZombie = BasicZombie:extend('FlagZombie')

function FlagZombie:init(x, y)
	BasicZombie.init(self, x, y)
	
	self:toggleLayer('innerarm1', false)
	self:toggleLayer('innerarm2', false)
	self:toggleLayer('innerarm3', false)
	
	self:toggleLayer('Zombie_flaghand', true)
	self:toggleLayer('Zombie_innerarm_screendoor', true)
	
	local flagFrame = ReanimFrame:new():setPosition(35, 3)
	self.flag = Reanimation:new('Zombie_flagpole')
	self:attachReanim('Zombie_flaghand', self.flag, 'idle', flagFrame)
end

return FlagZombie