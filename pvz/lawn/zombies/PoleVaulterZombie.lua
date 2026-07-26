local PoleVaulterZombie = Zombie:extend('PoleVaulterZombie')

local DamageVisualModifier = Cache.module(Cache.modifiers('DamageVisualModifier'))

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
	self.animation:add('idle', 'idle')
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
	
	self:applyModifier(DamageVisualModifier, false, {
		{
			health = (self.maxHealth * 2 / 3);
			trigger = function(parent)
				Sound.play('limbs_pop', 10)
				
				parent:toggleLayer('Zombie_outerarm_hand', false)
				parent:toggleLayer('Zombie_polevaulter_outerarm_lower', false)
				parent:replaceImage('Zombie_polevaulter_outerarm_upper', Reanim.getResource('Zombie_polevaulter_outerarm_upper2'))
			end
		};
		{
			health = (self.maxHealth / 3);
			trigger = function(parent)
				Sound.play('limbs_pop', 10)
				
				parent:setState('dead')
				parent:toggleLayer('hair', false)
				parent:toggleLayer('head1', false)
				parent:toggleLayer('head2', false)
				
				if not self.poleUsed then
					parent:toggleLayer('Zombie_polevaulter_pole', false)
					parent:toggleLayer('Zombie_polevaulter_pole2', false)
					parent:toggleLayer('Zombie_polevaulter_innerhand', false)
					parent:toggleLayer('Zombie_polevaulter_innerarm_lower', false)
					parent:toggleLayer('Zombie_polevaulter_innerarm_upper', false)
				end
			end
		};
	})
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