local ParticleObject = UIContainer:extend('ParticleObject')

function ParticleObject:init(fields, emitter)
	self.fields = fields
	self.emitter = emitter
	
	self.frame = 1
	self.frames = 1
	self.columns, self.rows = 1, 1
	
	self.textureKey = ''
	self.timeValue, self.lastTimeValue = -1, -1
	self.duration = 0
	self.age = 0
	self.dead = false
	self.velocity = {
		x = 0;
		y = 0;
	}
	self.shake = {
		x = 0;
		y = 0;
	}
	self.floorY = nil
	self.scale = 1
	self.angle = 0
	self.angleVelocity = 0
	self.textureCoord = {
		x = 0; y = 0;
		w = 0; h = 0;
	}
	self.fieldInterp = table.populate(#Particles.fieldTypes, function() return { random.number() ; random.number() } end)
	self.interp = table.populate(#Particles.definitions, function() return random.number() end)
	
	self.transform = ReanimFrame:new()
	self.transform.scaleCoords = true
	self.transforms = {self.transform}
	
	self.images = self.emitter.system.images
	
	UIContainer.init(self, x, y, 1, 1)
end

function ParticleObject:destroy()
	local particles = self.emitter.particles
	for i = 1, #particles do
		if particles[i] == self then
			table.remove(particles, i)
		end
	end
	
	UIContainer.destroy(self)
end

function ParticleObject:update(dt)
	if self.dead then
		self:destroy()
		return
	end
	local speedMultiplier = self.emitter.speed
	local die = false
	
	self.age = (self.age + dt * Constants.tickPerSecond * speedMultiplier)
	if self.age >= self.duration then
		if Particles.getEmitterFlag(self.emitter.emitter, 'particleLoops') then
			self.age = (self.age % self.duration)
		else
			self.age = self.duration
			self.dead = true
			return
		end
	end
	
	self.timeValue = (self.age / self.duration)
	self:updateParticle(dt * speedMultiplier)
	self:updateFields(dt * speedMultiplier)
	self.lastTimeValue = self.timeValue
	
	UIContainer.update(self, dt)
end

function ParticleObject:updateParticle(dt)
	if self.emitter:getSystemTrack('animationRate') then
		local fps = self:evaluateParticleTrack('animationRate')
		self.frame = ((self.frame + fps * dt - 1) % self.frames + 1)
	end
	
	self.x, self.y = (self.x + self.velocity.x * dt * Constants.tickPerSecond), (self.y + self.velocity.y * dt * Constants.tickPerSecond)
	
	local spinSpeed = self:evaluateParticleTrack('particleSpinSpeed')
	local diffSpinAngle = (self:evaluateParticleTrack('particleSpinAngle') - self:evaluateParticleTrack('particleSpinAngle', self.lastTimeValue))
	self.angle = (self.angle + (math.rad(spinSpeed + diffSpinAngle) + self.angleVelocity) * dt)
	
	local stretch = self:evaluateParticleTrack('particleStretch')
	self.scale = self:evaluateParticleTrack('particleScale')
	
	local ang = math.deg(self.angle)
	self.transform:setShear(ang, ang)
	self.transform:setScale(self.scale, self.scale * stretch)
end
function ParticleObject:updateFields(dt)
	if self.fields.Friction then
		local pos = self.fields.Friction
		if pos.x then self.velocity.x = (self.velocity.x * math.pow(1 - self:evaluateFieldTrack('Friction', 'x'), dt * Constants.tickPerSecond)) end
		if pos.y then self.velocity.y = (self.velocity.y * math.pow(1 - self:evaluateFieldTrack('Friction', 'y'), dt * Constants.tickPerSecond)) end
	end
	if self.fields.Acceleration then
		local pos = self.fields.Acceleration
		if pos.x then self.velocity.x = (self.velocity.x + self:evaluateFieldTrack('Acceleration', 'x') * dt) end
		if pos.y then self.velocity.y = (self.velocity.y + self:evaluateFieldTrack('Acceleration', 'y') * dt) end
	end
	if self.fields.Velocity then
		local pos = self.fields.Velocity
		if pos.x then self.x = (self.x + self:evaluateFieldTrack('Velocity', 'x') * dt) end
		if pos.y then self.y = (self.y + self:evaluateFieldTrack('Velocity', 'y') * dt) end
	end
	if self.fields.Position then
		local pos = self.fields.Position
		local diffX, diffY = 0, 0
		if pos.x then diffX = (self:evaluateFieldTrack('Position', 'x') - self:evaluateFieldTrack('Position', 'x', self.lastTimeValue)) end
		if pos.y then diffY = (self:evaluateFieldTrack('Position', 'y') - self:evaluateFieldTrack('Position', 'y', self.lastTimeValue)) end
		self.x, self.y = (self.x + diffX), (self.y + diffY)
	end
	if self.fields.GroundConstraint then
		self.floorY = (self.fields.GroundConstraint.y and self:evaluateFieldTrack('GroundConstraint', 'y') or 0)
		if self.y >= self.emitter.systemCenter.y + self.floorY then
			self.y = self.emitter.systemCenter.y + self.floorY
			
			local reflect, spin = self:evaluateParticleTrack('collisionReflect'), self:evaluateParticleTrack('collisionSpin')
			self.angleVelocity = (self.angleVelocity * spin)
			self.velocity.x = (self.velocity.x * reflect)
			self.velocity.y = (self.velocity.y * -reflect)
		end
	end
	if self.fields.Shake then
		local shakeX, shakeY = self:evaluateFieldTrack('Shake', 'x'), self:evaluateFieldTrack('Shake', 'y')
		self.shake.x, self.shake.y = random.number(-shakeX, shakeX), random.number(-shakeY, shakeY)
	end
end

function ParticleObject:evaluateParticleTrack(particleTrack, t)
	local track = self.emitter.emitter[particleTrack]
	if not track then return trace(particleTrack .. ' not a valid particle track') end
	return Particles.evaluateTrack(track, t or self.timeValue, self.interp[Particles.definitionIds[particleTrack]])
end
function ParticleObject:evaluateFieldTrack(fieldTrack, var, t)
	if t and t < 0 then return 0 end
	local track = self.fields[fieldTrack]
	if not track then return trace(fieldTrack .. ' not a valid particle field') end
	return Particles.evaluateTrack(track[var], t or self.timeValue, self.fieldInterp[Particles.fieldIds[fieldTrack]][var == 'x' and 1 or 2])
end

function ParticleObject:setVelocity(x, y)
	self.velocity.x, self.velocity.y = x, y
	return self
end

function ParticleObject:reloadTexture()
	self.columns, self.rows = Resources.getImageGrid(self.textureKey)
	
	self.textureCoord.w, self.textureCoord.h = (self.texture:getWidth() / self.columns), (self.texture:getHeight() / self.rows)
	self.transform:setOrigin(self.textureCoord.w * .5, self.textureCoord.h * .5)
	self.transform:setOffset(self.transform.xOrigin, self.transform.yOrigin)
	self:setDimensions(self.textureCoord.w, self.textureCoord.h)
	self:setHitbox(-self.w * .5, -self.h * .5, self.w, self.h)
end

function ParticleObject:draw(x, y)
	self:render(x, y)
	
	UIContainer.draw(self, x, y)
end
function ParticleObject:render(x, y)
	local x, y = ((x or 0) + self.shake.x), ((y or 0) + self.shake.y)
	local additive = Particles.getEmitterFlag(self.emitter.emitter, 'additive')
	local fullscreen = Particles.getEmitterFlag(self.emitter.emitter, 'fullscreen')
	
	local oldTexture = self.texture
	self.texture = (self.images[self.textureKey] or Cache.unknownTexture)
	if oldTexture ~= self.texture then
		self:reloadTexture()
	end
	
	self.textureCoord.x = (math.floor(self.frame - 1) % self.columns * self.textureCoord.w)
	self.textureCoord.y = (math.floor((self.frame - 1) / self.columns) * self.textureCoord.h)
	
	local stack = Reanimation.transformStack
	for i, transform in ipairs(transforms or self.transforms) do
		table.insert(stack, i, transform)
	end
	
	local active = true
	local alpha = 1
	
	local function transform(frame)
		if type(frame) == 'table' and not class.isInstance(frame) then
			for _, frame in ipairs(frame) do
				transform(frame)
			end
			return
		end
		
		active = (active and frame.active)
		alpha = (alpha * frame.alpha)
	end
	transform(stack)
	
	if active and alpha > 0 then
		local mesh = Particle.triangle
		local vert = mesh.vert
		
		for i, corner in ipairs(vert) do
			local xCorner = (i % 2 == 1 and 0 or 1)
			local yCorner = (i <= 2 and 0 or 1)
			
			corner[1] = (xCorner * (fullscreen and gameWidth or self.textureCoord.w))
			corner[2] = (yCorner * (fullscreen and gameHeight or self.textureCoord.h))
			
			corner[3] = ((self.textureCoord.x + xCorner * self.textureCoord.w) / self.texture:getPixelWidth())
			corner[4] = ((self.textureCoord.y + yCorner * self.textureCoord.h) / self.texture:getPixelHeight())
			
			if not fullscreen then
				Reanimation.transformVertex(corner, frame, false)
				for i = 1, #stack do Reanimation.transformVertex(corner, stack[i], true) end
			end
		end
		
		local bright = self:evaluateParticleTrack('particleBrightness')
		love.graphics.setColor(
			self:evaluateParticleTrack('particleRed') * bright * self.emitter.systemRed,
			self:evaluateParticleTrack('particleGreen') * bright * self.emitter.systemGreen,
			self:evaluateParticleTrack('particleBlue') * bright * self.emitter.systemBlue,
			self:evaluateParticleTrack('particleAlpha') * self.emitter.systemAlpha
		)
		
		if additive then love.graphics.setBlendMode('add') end
		
		mesh.mesh:setVertices(vert)
		mesh.mesh:setTexture(self.texture)
		love.graphics.draw(mesh.mesh, fullscreen and 0 or x, fullscreen and 0 or y)
		
		love.graphics.setBlendMode('alpha')
		love.graphics.setColor(1, 1, 1)
	end
	
	for i = 1, (transforms and #transforms or #self.transforms) do
		table.remove(stack, 1)
	end
end
function ParticleObject:debugDraw(x, y)
	if self.floorY then
		local _, emitterY = self.emitter:elementToScreen()
		local floorY = (emitterY + self.emitter.systemCenter.y + self.floorY)
		
		love.graphics.setColor(1, 1, 0)
		love.graphics.line(x, floorY, x + self.w, floorY)
	end
	
	UIContainer.debugDraw(self, x, y)
end

return ParticleObject