local BasicZombie = Zombie:extend('BasicZombie')

function BasicZombie:init(x, y)
	Zombie.init(self, x, y)
	
	self:toggleLayer('Zombie_mustache', false)
	self:toggleLayer('Zombie_flaghand', false)
	
	self:toggleLayer('screendoor', false)
	self:toggleLayer('Zombie_outerarm_screendoor', false)
	self:toggleLayer('Zombie_innerarm_screendoor', false)
	self:toggleLayer('Zombie_innerarm_screendoor_hand', false)
	
	self:toggleLayer('cone', false)
	self:toggleLayer('bucket', false)
	self:toggleLayer('Zombie_duckytube', false)
	self:toggleLayer('tongue', random.bool(50))
	
	self:playAnimation(random.bool(50) and 'walk' or 'walk2')
end

function BasicZombie:getReanim()
	return 'Zombie'
end

return BasicZombie