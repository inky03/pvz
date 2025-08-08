local PoleVaulterZombie = Zombie:extend('PoleVaulterZombie')

PoleVaulterZombie.reanimName = 'Zombie_polevaulter'

PoleVaulterZombie.maxHp = 500

PoleVaulterZombie.value = 2
PoleVaulterZombie.pickWeight = 2000
PoleVaulterZombie.startingLevel = 6
PoleVaulterZombie.firstAllowedWave = 5

function PoleVaulterZombie:init(x, y, challenge)
	Zombie.init(self, x, y, challenge)
	
	self.poleUsed = false
	
	self.animation:add('run', 'run')
	self.animation:add('walk', 'walk')
	self.animation:add('eating', 'eat')
	self.animation:add('jump', 'jump', false)
	self.animation:play('run', true)
	
	self.animation:get('run').speed = 3.5
	self.animation:get('jump').speed = 2.2
	self.animation:get('walk').speed = 1.1
	self.animation:get('death').speed = 1.6
	self.animation:get('eating').speed = 1.5
	
	self.fallTime = .68
	
	self.hitbox.x = -20
	self.hitbox.w = 50
	self.hurtbox.x = 50
	
	self.animation.onFinish:add(function(animation)
		if animation.name == 'jump' then
			self.flags.ignoreCollisions = false
			
			self.animation:play('walk', true)
			self:setState('normal')
			self.x = (self.x - 150)
		end
	end)
	
	self.animation.onFrame:add(function(animation)
		if animation.name == 'eating' and self.state == 'eating' then
			if self.collision and (animation.frame == 12 or animation.frame == 24) then
				self:chomp()
			end
		end
	end)
	
	self.yOffset = 50
	self.shadowOffset = {x = 20; y = 60}
end

function PoleVaulterZombie:hurt(hp, glow)
	Zombie.hurt(self, hp, glow)
	
	if self.damagePhase == 0 and self.hp <= (self.maxHp - 170) then
		self:setDamagePhase(1)
	end if self.damagePhase == 1 and self.hp <= (self.maxHp - 340) then
		self:setDamagePhase(2)
	end
end

function PoleVaulterZombie:setDamagePhase(phase)
	Zombie.setDamagePhase(self, phase)
	
	if phase == 1 then
		Sound.play('limbs_pop', 10)
		self:toggleLayer('Zombie_outerarm_hand', false)
		self:toggleLayer('Zombie_polevaulter_outerarm_lower', false)
		self:replaceImage('Zombie_polevaulter_outerarm_upper', Reanim.getResource('Zombie_polevaulter_outerarm_upper2'))
	elseif phase == 2 then
		Sound.play('limbs_pop', 10)
		self:setState('dead')
		self:toggleLayer('hair', false)
		self:toggleLayer('head1', false)
		self:toggleLayer('head2', false)
		if not self.poleUsed then
			self:toggleLayer('Zombie_polevaulter_pole', false)
			self:toggleLayer('Zombie_polevaulter_pole2', false)
			self:toggleLayer('Zombie_polevaulter_innerhand', false)
			self:toggleLayer('Zombie_polevaulter_innerarm_lower', false)
			self:toggleLayer('Zombie_polevaulter_innerarm_upper', false)
		end
	end
end

function PoleVaulterZombie:setState(state)
	if state == 'eating' and not self.poleUsed then
		self.flags.ignoreCollisions = true
		
		self.animation:play('jump')
		self.state = 'jumping'
		self.poleUsed = true
		
		self.hitbox.x = 25
		self.hitbox.w = 20
		
		Sound.play('polevault', 5)
	else
		Zombie.setState(self, state)
	end
end

function PoleVaulterZombie.getSpawnOffset()
	return Zombie.getSpawnOffset() + 50
end

return PoleVaulterZombie