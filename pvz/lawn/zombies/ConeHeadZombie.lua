local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
local ConeHeadZombie = BasicZombie:extend('ConeHeadZombie')

function ConeHeadZombie:init(x, y)
	BasicZombie.init(self, x, y)
	
	self:toggleLayer('cone', true)
end

function ConeHeadZombie:hurt(hp)
	Zombie.hurt(self, hp)
	
	if self.hurtState == 0 and self.hp <= (self.maxHp - 130) then
		self:setHurtState(1)
	elseif self.hurtState == 1 and self.hp <= (self.maxHp - 260) then
		self:setHurtState(2)
	elseif self.hurtState == 2 and self.hp <= (self.maxHp - 370) then
		self:setHurtState(3)
	elseif self.hurtState == 3 and self.hp <= (self.maxHp - 440) then
		self:setHurtState(4)
	elseif self.hurtState == 4 and self.hp <= (self.maxHp - 505) then
		self:setHurtState(5)
		self:setState('dead')
	end
end

function ConeHeadZombie:setHurtState(state)
	Zombie.setHurtState(self, state)
	
	if state == 1 then
		self:replaceImage('Zombie_cone1', Reanim.getResource('Zombie_cone2'))
	elseif state == 2 then
		self:replaceImage('Zombie_cone1', Reanim.getResource('Zombie_cone3'))
	elseif state == 3 then
		self:toggleLayer('cone', false)
	elseif state == 4 then
		self:toggleLayer('Zombie_outerarm_hand', false)
		self:toggleLayer('Zombie_outerarm_lower', false)
		self:replaceImage('Zombie_outerarm_upper', Reanim.getResource('Zombie_outerarm_upper2'))
	elseif state == 5 then
		self:toggleLayer('hair', false)
		self:toggleLayer('head1', false)
		self:toggleLayer('head2', false)
		self:toggleLayer('tongue', false)
	end
end

function ConeHeadZombie.getHP()
	return 640
end

return ConeHeadZombie