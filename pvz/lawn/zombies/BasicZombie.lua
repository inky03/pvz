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
	
	self:toggleLayer('Zombie_flaghand', false)
	self:toggleLayer('Zombie_innerarm_screendoor', false)
	
	self.animation:add('walk', random.object('walk', 'walk2'))
	self.animation:play('walk', true)
end

function BasicZombie:update(dt)
	Zombie.update(self, dt)
	-- self.flag:update(dt)
end

function BasicZombie:getReanim()
	return 'Zombie'
end

return BasicZombie