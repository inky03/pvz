local BasicZombie = Zombie:extend('BasicZombie')

local DamageVisualModifier = Cache.module(Cache.modifiers('DamageVisualModifier'))

BasicZombie.maxHealth = 270

BasicZombie.pickWeight = 4000

BasicZombie.charredReanimName = 'Zombie_charred'

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
	
	self:applyModifier(DamageVisualModifier, false, {
		{
			health = (self.maxHealth / 2);
			trigger = function(parent)
				Sound.play('limbs_pop', 10)
				
				parent.lawn:spawnParticle('ZombieArm', self.x + self.w * .5, self.y + self.h * .5)
				
				parent:toggleLayer('Zombie_outerarm_hand', false)
				parent:toggleLayer('Zombie_outerarm_lower', false)
				parent:replaceImage('Zombie_outerarm_upper', Reanim.getResource('Zombie_outerarm_upper2'))
			end
		};
		{
			health = 0;
			trigger = function(parent)
				Sound.play('limbs_pop', 10)
				
				parent.lawn:spawnParticle('ZombieHead', self.x + 24, self.y - 16)
				
				parent:setState('dead')
				parent:toggleLayer('hair', false)
				parent:toggleLayer('head1', false)
				parent:toggleLayer('head2', false)
				parent:toggleLayer('tongue', false)
			end
		};
	})
end

return BasicZombie