Particles = require 'pvz.data.Particles'
ParticleObject = require 'pvz.particle.ParticleObject'
ParticleEmitter = require 'pvz.particle.ParticleEmitter'

local Particle = UIContainer:extend('Particle')

Particle.destroyOnFinish = true
Particle.triangle = {vert = {{0, 0; 0, 0}; {50, 0; 1, 0}; {0, 50; 0, 1}; {50, 50; 1, 1}}}
Particle.triangle.mesh = love.graphics.newMesh(Particle.triangle.vert, 'strip', 'dynamic')

function Particle:init(kind, x, y)
	UIContainer.init(self, x, y, 50, 50)
	
	self.canClick = false
	
	self.speed = 1
	self.images = {}
	self.emitters = {}
	self:setParticleData(Cache.particle(kind))
end

function Particle:update(dt)
	if self.particleData and #self.emitters <= 0 and #self.children <= 0 and self.destroyOnFinish then
		self:destroy()
	end
	
	UIContainer.update(self, dt * self.speed)
end

function Particle:setParticleData(particles)
	if not particles then return end
	
	self.images = table.copy(particles.images)
	self.particleData = particles
	self:reloadEmitters()
end
function Particle:reloadEmitters(cleanup)
	if cleanup then self:destroyEmitters() end
	
	for _, emitter in ipairs(self.particleData.emitters) do
		local newEmitter = self:addElement(ParticleEmitter:new(emitter, self))
		table.insert(self.emitters, newEmitter)
	end
end
function Particle:destroyEmitters()
	for _, emitter in ipairs(self.emitters) do emitter:destroy() end
	table.clear(self.emitters)
end

function Particle:replaceImage(image, newResource)
	if image == nil then
		return
	end
	local img = image
	if type(image) == 'string' then
		image = image:lower():gsub('image_', '')
	end
	if type(newResource) == 'string' then
		newResource = Cache.image(newResource, 'particles')
	end
	
	for k, v in pairs(self.images) do
		if v == image or k:lower():gsub('image_', '') == image then
			self.images[k] = newResource
			return
		end
	end
	
	trace(('%s: Could not find image ID %s'):format(self.particleData.name, tostr(img)))
end

return Particle