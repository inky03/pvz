local Zombie = Unit:extend('Zombie')

Zombie.reanimName = 'Zombie'

-- wave definition
Zombie.value = 1
Zombie.pickWeight = 0
Zombie.startingLevel = 1
Zombie.firstAllowedWave = 1

function Zombie:init(x, y, challenge)
	Unit.init(self, x, y, challenge)
	
	self:setHitbox(
		7, 7, 20, 115,
		23, 7, 42, 115
	)
	
	self.animation.speed = self.speed
	
	self.deathTimer = .5
	
	self.damageGroup = Plant
	self.collision = nil
	self.damage = 100
	self.wave = 0
	
	self.autoBoardPosition = true
	self.yOffset = 40
	
	self.damageFilter = function(test)
		return (not test.dead and not test.flags.cantBeEaten and not test.flags.ignoreCollisions and math.round(test.boardY) == math.round(self.boardY))
	end
	
	self.animation:add('death', 'death', false)
	self.animation.onFinish:add(function(animation)
		if animation.name == 'death' then
			self.fadeOutTimer = 0
		end
	end)
end

function Zombie:update(dt)
	Unit.update(self, dt)
	
	if self.fadeOutTimer then
		self.fadeOutTimer = (self.fadeOutTimer + dt * self.animation.speed)
		if self.fadeOutTimer > 1 then
			self.transform.alpha = (self.transform.alpha - dt * 8)
			if self.transform.alpha < 0 then
				self:destroy()
				return
			end
		end
	end
	
	if self.state ~= 'dead' then
		self.collision = self:queryCollision(self.damageGroup, self.damageFilter, self.x - self.hitbox.w * .5)
		if self.collision and self.state == 'normal' then
			self:setState('eating')
		elseif not self.collision and self.state == 'eating' then
			self:setState('normal')
		end
	else
		self.deathTimer = (self.deathTimer - dt * self.animation.speed)
		self:hurt(dt * 12)
		
		if (self.deathTimer <= 0) then
			self.canDie = true
		end
	end
end

function Zombie:setState(state)
	Unit.setState(self, state)
	
	if state == 'normal' then
		self.animation:play('walk')
	elseif state == 'eating' then
		self.animation:play('eating')
	elseif state == 'dead' then
		self.canDie = false
	end
end

function Zombie:onDeath()
	self.animation:play('death')
	self.flags.ignoreCollisions = true
end

function Zombie.getSpawnOffset()
	return random.number(25, 100)
end

function Zombie:__tostring()
	return ('Zombie(name:%s, value:%d, pickWeight:%d)'):format(self.name, self.value, self.pickWeight)
end

return Zombie