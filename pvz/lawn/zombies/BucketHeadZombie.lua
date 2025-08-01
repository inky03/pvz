local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
local BucketHeadZombie = BasicZombie:extend('BucketHeadZombie')

function BucketHeadZombie:init(x, y)
	BasicZombie.init(self, x, y)
	
	self:toggleLayer('bucket', true)
end

function BucketHeadZombie:hurt(hp)
	Zombie.hurt(self, hp)
	
	if self.hurtState == 0 and self.hp <= (self.maxHp - 350) then
		self:setHurtState(1)
	elseif self.hurtState == 1 and self.hp <= (self.maxHp - 700) then
		self:setHurtState(2)
	elseif self.hurtState == 2 and self.hp <= (self.maxHp - 1100) then
		self:setHurtState(3)
	elseif self.hurtState == 3 and self.hp <= (self.maxHp - 1235) then
		self:setHurtState(4)
	elseif self.hurtState == 4 and self.hp <= (self.maxHp - 1370) then
		self:setHurtState(5)
		self:setState('dead')
	end
end

function BucketHeadZombie:setHurtState(state)
	Zombie.setHurtState(self, state)
	
	if state == 1 then
		self:replaceImage('Zombie_bucket1', Reanim.getResource('Zombie_bucket2'))
	elseif state == 2 then
		self:replaceImage('Zombie_bucket1', Reanim.getResource('Zombie_bucket3'))
	elseif state == 3 then
		self:toggleLayer('bucket', false)
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

function BucketHeadZombie.getHP()
	return 1370
end

return BucketHeadZombie