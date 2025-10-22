local ParticleEmitter = UIContainer:extend('ParticleEmitter')

ParticleEmitter.destroyOnFinish = true

function ParticleEmitter:init(emitterData, system)
	self.emitter = emitterData
	self.system = system
	
	UIContainer.init(self, 0, 0, 1, 1)
	
	self:reset()
	self.speed = 1
	self.particles = {}
	self.canClick = false
	
	if self.emitter.systemDuration then
		self.systemDuration = Particles.evaluateTrack(self.emitter.systemDuration, 0, random.number())
	else
		self.systemDuration = Particles.evaluateTrack(self.emitter.particleDuration, 0, 1)
	end
	self.systemDuration = math.max(1, self.systemDuration)
	
	self.systemFields = self.emitter.systemFields
	self.systemFieldInterp = table.populate(#Particles.fieldTypes, function() return { random.number() ; random.number() } end)
	self.trackInterp = table.populate(#Particles.definitions, function() return random.number() end)
end

function ParticleEmitter:reset()
	self.dead = false
	self.systemAge = 0
	self.spawnAccum = 0
	self.systemTimeValue, self.lastSystemTimeValue = -1, -1
	self.particlesSpawned = 0
	self.systemCenter = {
		x = 0;
		y = 0;
	}
	self.systemRed, self.systemGreen, self.systemBlue, self.systemAlpha = 1, 1, 1, 1
end

function ParticleEmitter:destroy()
	local emitters = self.system.emitters
	for i = 1, #emitters do
		if emitters[i] == self then
			table.remove(emitters, i)
		end
	end
	
	UIContainer.destroy(self)
end

function ParticleEmitter:update(dt)
	if self.dead then
		if self.systemAge >= self.systemDuration or #self.particles <= 0 then
			if self.destroyOnFinish then
				self:destroy()
			else
				for _, part in ipairs(self.particles) do
					self.part:destroy()
				end
			end
		end
		
		return UIContainer.update(self, dt)
	end
	
	local speedMultiplier = self.speed
	
	self.systemAge = (self.systemAge + dt * Constants.tickPerSecond * speedMultiplier)
	if self.systemAge >= self.systemDuration then
		if Particles.getEmitterFlag(self.emitter, 'systemLoops') then -- todo loop flag?
			self.systemAge = (self.systemAge % self.systemDuration)
		else
			self.systemAge = self.systemDuration
			self.dead = true
		end
	end
	
	self.systemTimeValue = (self.systemAge / self.systemDuration)
	self:updateFields(dt * speedMultiplier)
	self:updateEmitter(dt * speedMultiplier)
	self:updateSpawn(dt * speedMultiplier)
	self.lastSystemTimeValue = self.systemTimeValue
	
	UIContainer.update(self, dt)
end
function ParticleEmitter:updateFields(dt)
	if self.systemFields.SystemPosition then
		local pos = self.systemFields.SystemPosition
		local diffX, diffY = 0, 0
		if pos.x then diffX = (self:evaluateFieldTrack('SystemPosition', 'x') - self:evaluateFieldTrack('SystemPosition', 'x', self.lastSystemTimeValue)) end
		if pos.y then diffY = (self:evaluateFieldTrack('SystemPosition', 'y') - self:evaluateFieldTrack('SystemPosition', 'y', self.lastSystemTimeValue)) end
		self.systemCenter.x, self.systemCenter.y = (self.systemCenter.x + diffX), (self.systemCenter.y + diffY)
	end
end
function ParticleEmitter:updateEmitter(dt)
	self.systemRed = self:evaluateSystemTrack('systemRed')
	self.systemGreen = self:evaluateSystemTrack('systemGreen')
	self.systemBlue = self:evaluateSystemTrack('systemBlue')
	self.systemAlpha = self:evaluateSystemTrack('systemAlpha')
end
function ParticleEmitter:moveDelta(deltaX, deltaY)
	if Particles.getEmitterFlag(self.emitter, 'particlesDontFollow') then
		for i = 1, #self.particles do
			local particle = self.particles[i]
			particle.x = (particle.x - deltaX)
			particle.y = (particle.y - deltaY)
		end
	end
end
function ParticleEmitter:updateSpawn(dt)
	if self.dead then return end
	
	self.spawnAccum = (self.spawnAccum + self:evaluateSystemTrack('spawnRate') * dt)
	local spawnCount = math.floor(self.spawnAccum)
	self.spawnAccum = (self.spawnAccum % 1)
	
	if self.emitter.spawnMinActive then
		local spawnMinActive = self:evaluateSystemTrack('spawnMinActive')
		spawnCount = math.max(spawnCount, spawnMinActive - #self.particles)
	end
	if self.emitter.spawnMaxActive then
		local spawnMaxActive = self:evaluateSystemTrack('spawnMaxActive')
		spawnCount = math.min(spawnCount, spawnMaxActive - #self.particles)
	end
	if self.emitter.spawnMaxLaunched then
		local spawnMaxLaunched = self:evaluateSystemTrack('spawnMaxLaunched')
		spawnCount = math.min(spawnCount, spawnMaxLaunched - self.particlesSpawned)
	end
	
	for i = 1, spawnCount do
		self:spawnParticle(i, spawnCount)
	end
end
function ParticleEmitter:spawnParticle(index, spawnCount)
	local interp = self.trackInterp
	local def = Particles.definitionIds
	
	local t = self.systemTimeValue
	local particle = ParticleObject:new(self.emitter.fields, self)
	
	particle.duration = Particles.evaluateTrack(self.emitter.particleDuration, self.systemTimeValue, interp[def.particleDuration])
	
	local x, y = 0, 0
	local launchAngle = 0
	local launchSpeed = (Particles.evaluateTrack(self.emitter.launchSpeed, t, interp[def.launchSpeed]) * .01)
	
	local emitterType = Particles.getEmitterType(self.emitter)
	
	if emitterType == 'CirclePath' then
		-- todo
	elseif emitterType == 'CircleEvenSpacing' then
		launchAngle = (2 * math.pi * index / spawnCount + math.rad(Particles.evaluateTrack(self.emitter.launchAngle, t, interp[def.launchAngle])))
	elseif Particles.trackIsConstantZero(self.emitter.launchAngle) then
		launchAngle = random.number(2 * math.pi)
	else
		launchAngle = math.rad(Particles.evaluateTrack(self.emitter.launchAngle, t, interp[def.launchAngle]))
	end
	
	if emitterType == 'Box' then
		x = Particles.evaluateTrack(self.emitter.emitterBoxX, t, interp[def.emitterBoxX])
		y = Particles.evaluateTrack(self.emitter.emitterBoxY, t, interp[def.emitterBoxY])
	elseif emitterType == 'Circle' or emitterType == 'CirclePath' or emitterType == 'CircleEvenSpacing' then
		local radius = self:evaluateSystemTrack('emitterRadius', t, interp[def.emitterRadius])
		x, y = (math.sin(launchAngle) * radius), (math.cos(launchAngle) * radius)
	elseif emitterType == 'BoxPath' then
		-- todo
	else
		trace('Unknown emitter type: ' .. emitterType)
	end
	
	particle.textureKey = self.emitter.image
	particle.frames = self.emitter.imageFrames
	particle:setPosition(
		self.systemCenter.x + x + y * Particles.evaluateTrack(self.emitter.emitterSkewX, t, interp[def.emitterSkewX]),
		self.systemCenter.y + y + x * Particles.evaluateTrack(self.emitter.emitterSkewY, t, interp[def.emitterSkewY])
	)
	particle:setVelocity(
		math.sin(launchAngle) * launchSpeed,
		math.cos(launchAngle) * launchSpeed
	)
	particle:setPosition(
		particle.x + Particles.evaluateTrack(self.emitter.emitterOffsetX, t, interp[def.emitterOffsetX]) - particle.textureCoord.w * .5,
		particle.y + Particles.evaluateTrack(self.emitter.emitterOffsetY, t, interp[def.emitterOffsetY]) - particle.textureCoord.h * .5
	)
	
	if self.emitter.animated or self.emitter.animationRate then
		particle.frame = 1
	else
		particle.frame = random.int(1, self.emitter.imageFrames)
	end
	
	if Particles.getEmitterFlag(self.emitter, 'randomLaunchSpin') then
		self.angle = random.number(math.pi * 2)
	elseif Particles.getEmitterFlag(self.emitter, 'alignLaunchSpin') then
		self.angle = launchAngle
	end
	
	table.insert(self.particles, self:addElement(particle))
	self.particlesSpawned = (self.particlesSpawned + 1)
	
	return particle
end

function ParticleEmitter:evaluateSystemTrack(systemTrack, t)
	local track = self:getSystemTrack(systemTrack)
	if not track then return trace(systemTrack .. ' not a valid system track') end
	return Particles.evaluateTrack(track, t or self.systemTimeValue, self.trackInterp[Particles.definitionIds[systemTrack]])
end
function ParticleEmitter:evaluateFieldTrack(fieldTrack, var, t)
	if t and t < 0 then return 0 end
	local track = self.systemFields[fieldTrack]
	if not track then return trace(fieldTrack .. ' not a valid system field') end
	return Particles.evaluateTrack(track[var], t or self.systemTimeValue, self.systemFieldInterp[Particles.fieldIds[fieldTrack]][var == 'x' and 1 or 2])
end
function ParticleEmitter:getSystemTrack(systemTrack)
	return self.emitter[systemTrack]
end

return ParticleEmitter