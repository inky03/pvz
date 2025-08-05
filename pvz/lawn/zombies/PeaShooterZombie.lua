local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
local PeaShooterZombie = BasicZombie:extend('PeaShooterZombie')

function PeaShooterZombie:init(x, y, challenge)
	BasicZombie.init(self, x, y, challenge)
	
	self:replaceImage('Zombie_head', nil)
	
	self:toggleLayer('hair', false)
	self:toggleLayer('head2', false)
	self:toggleLayer('tongue', false)
	
	self.plantHead = Reanimation:new('PeaShooterSingle')
	self.plantHead.animation:add('idle', 'head_idle')
	self.plantHead.animation:play('idle', true)
	self.plantHead.transform:set(-68, -6, -10, -10, -1, 1)
	self:attachReanim('head1', self.plantHead, 'idle')
	
	self.animation:get('walk'):setTrack(self.reanim:getTrack('walk2'))
end

return PeaShooterZombie