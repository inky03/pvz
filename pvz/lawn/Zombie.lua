local Zombie = Unit:extend('Zombie')

function Zombie:init(x, y)
	Unit.init(self, x, y)
	
	self:setHitbox(
		7, 7, 50, 115,
		23, 7, 42, 115
	)
	
	self.animation.speed = self.speed
	
	self.state = 'normal'
	
	self.damageGroup = Plant
	self.collision = nil
	self.damage = 100
	
	self.autoBoardPosition = true
	self.yOffset = 40
	
	self.damageFilter = function(test)
		return (not test.dead and not test.flags.ignoreCollisions and math.round(test.boardY) == math.round(self.boardY))
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
		self.collision = self:queryCollision(self.damageGroup, self.damageFilter)
		if self.collision and self.state == 'normal' then
			self:setState('eating')
		elseif not self.collision and self.state == 'eating' then
			self:setState('normal')
		end
	else
		self.hp = (self.hp - dt * 12)
	end
	
	Unit.update(self, dt)
end

function Zombie:setState(state)
	Unit.setState(self, state)
	
	if state == 'normal' then
		self.animation:play('walk')
	elseif state == 'eating' then
		self.animation:play('eating')
	end
end

function Zombie:onDeath()
	self.animation:play('death')
	self.flags.ignoreCollisions = true
	self.animation.speed = random.number(.75, 1)
end

function Zombie.getReanim()
	return 'Zombie'
end

return Zombie