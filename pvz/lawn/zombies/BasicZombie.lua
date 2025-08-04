local BasicZombie = Zombie:extend('BasicZombie')

BasicZombie.maxHp = 270

BasicZombie.pickWeight = 4000

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
	self.animation:add('eating', 'eat')
	self.animation:play('walk', true)
	
	self:setSpeed(random.number(1, 1.25))
	self.animation:get('eating').speed = 2.25
	self.animation:get('death').speed = 1.75
	
	self.animation.onFrame:add(function(animation)
		if animation.name == 'eating' and self.state == 'eating' then
			if self.collision and (animation.frame == 10 or animation.frame == 30) then
				self:hit(self.collision, .5)
			end
		end
	end)
end

function BasicZombie:hurt(hp)
	Zombie.hurt(self, hp)
	
	if self.hurtState == 0 and self.hp <= (self.maxHp - 90) then
		self:setHurtState(1)
	elseif self.hurtState == 1 and self.hp <= (self.maxHp - 181) then
		self:setHurtState(2)
		self:setState('dead')
	end
end

function BasicZombie:setHurtState(state)
	Zombie.setHurtState(self, state)
	
	if state == 1 then
		self:toggleLayer('Zombie_outerarm_hand', false)
		self:toggleLayer('Zombie_outerarm_lower', false)
		self:replaceImage('Zombie_outerarm_upper', Reanim.getResource('Zombie_outerarm_upper2'))
	elseif state == 2 then
		self:toggleLayer('hair', false)
		self:toggleLayer('head1', false)
		self:toggleLayer('head2', false)
		self:toggleLayer('tongue', false)
	end
end

return BasicZombie