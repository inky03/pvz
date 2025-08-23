local BasicZombie = Zombie:extend('BasicZombie')

BasicZombie.maxHp = 270

BasicZombie.pickWeight = 4000

function BasicZombie:init(x, y, challenge)
	Zombie.init(self, x, y, challenge)
	
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
	
	self.animation:add('idle', random.object('idle', 'idle2'))
	self.animation:add('walk', random.object('walk', 'walk2'))
	self.animation:add('eating', 'eat')
	self.animation:play('walk', true)
	
	self:setSpeed(random.number(.9, 1.1))
	self.animation:get('eating').speed = 2.25
	
	-- random death animation
	self.animation:get('death').speed = 1.75
	if random.int(0, 100) == 99 and self.challenge.challenge >= 5 then
		self.animation:get('death'):setTrack(self.reanim:getTrack('superlongdeath'))
		self.animation:get('death').speed = 1
		self.fallTime = .788
	elseif random.bool(50) then
		self.animation:get('death'):setTrack(self.reanim:getTrack('death2'))
		self.fallTime = .71
	end
	
	self.animation.onFrame:add(function(animation)
		if animation.name == 'eating' and self.state == 'eating' then
			if self.collision and (animation.frame == 10 or animation.frame == 30) then
				self:chomp()
			end
		end
	end)
	
	self.shadowOffset = {x = 10; y = 60}
end

function BasicZombie:hurt(hp, glow)
	Zombie.hurt(self, hp, glow)
	
	if self.damagePhase == 0 and self.hp <= (self.maxHp - 90) then
		self:setDamagePhase(1)
	end if self.damagePhase == 1 and self.hp <= (self.maxHp - 181) then
		self:setDamagePhase(2)
	end
end

function BasicZombie:setDamagePhase(phase)
	Zombie.setDamagePhase(self, phase)
	
	if phase == 1 then
		Sound.play('limbs_pop', 10)
		self:toggleLayer('Zombie_outerarm_hand', false)
		self:toggleLayer('Zombie_outerarm_lower', false)
		self:replaceImage('Zombie_outerarm_upper', Reanim.getResource('Zombie_outerarm_upper2'))
		self.board:spawnParticle('ZombieArm', self.x + self.w * .5, self.y + self.h * .5)
	elseif phase == 2 then
		Sound.play('limbs_pop', 10)
		self:setState('dead')
		self:toggleLayer('hair', false)
		self:toggleLayer('head1', false)
		self:toggleLayer('head2', false)
		self:toggleLayer('tongue', false)
		self.board:spawnParticle('ZombieHead', self.x + 18, self.y - 18)
	end
end

return BasicZombie