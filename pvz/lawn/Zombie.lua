local Zombie = Unit:extend('Zombie')

Zombie.reanimName = 'Zombie'

Zombie.maxHelmHp = 0
Zombie.maxShieldHp = 0

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
	
	self.groanCounter = random.int(300, 400)
	self.variant = random.bool(100 / 5)
	
	self.helmHp, self.shieldHp = self.maxHelmHp, self.maxShieldHp
	self.helmDamagePhase, self.shieldDamagePhase = 0, 0
	
	self.animation.speed = self.speed
	
	self.fallTime = .5
	
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
	
	local delta = (dt * self.speed * self.speedMultiplier)
	
	self.groanCounter = (self.groanCounter - delta * Constants.tickPerSecond)
	if self.groanCounter < 0 then
		self:groan()
	end
	
	if self.fadeOutTimer then
		self.fadeOutTimer = (self.fadeOutTimer + delta)
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
	elseif not self.dead then
		if self.fallTime >= 0 and self:shouldTriggerTimedEvent(self.fallTime) then
			self:die()
		end
	end
end

function Zombie:setHelmDamagePhase(phase)
	self.helmDamagePhase = phase
end
function Zombie:setShieldDamagePhase(phase)
	self.shieldDamagePhase = phase
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
end

function Zombie:hurt(hp, glow)
	if self.shieldHp > 0 then
		self.shieldHp = math.max(self.shieldHp - hp, 0)
	elseif self.helmHp > 0 then
		self.helmHp = math.max(self.helmHp - hp, 0)
		self.damageGlow = math.max(self.damageGlow, glow or 1)
	else
		Unit.hurt(self, hp, glow)
	end
end
function Zombie:groan()
	if self:canGroan() then
		if self.variant then
			Sound.playRandom({ 'groan' ; 'groan2' ; 'groan3' ; 'groan4' ; 'groan5' ; 'groan6' ; 'sukhbir4' ; 'sukhbir5' ; 'sukhbir6' })
		else
			Sound.playRandom({ 'groan' ; 'groan2' ; 'groan3' ; 'groan4' ; 'groan5' ; 'groan6' })
		end
	end
	self.groanCounter = (self.groanCounter + random.int(1000, 1500))
end
function Zombie:chomp()
	self:hit(self.collision, .5)
	
	if self.collision.dead then
		Sound.play('gulp')
	else
		if self.collision.hard then
			Sound.playRandom({ 'chomp' ; 'chomp2' })
		else
			Sound.play('chompsoft', 4)
		end
	end
end

function Zombie.getSpawnOffset()
	return random.number(10, 50)
end
function Zombie:canGroan()
	return (random.int(0, #self.challenge:getSpawnedZombies()) == 0 and self.state ~= 'dead')
end

return Zombie