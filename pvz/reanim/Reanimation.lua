Reanim = require 'pvz.reanim.Reanim'
AnimationController = require 'pvz.reanim.animation.AnimationController'

local Reanimation = class('Reanimation')

Reanimation.triangle = {vert = {{0, 0; 0, 0}; {50, 0; 1, 0}; {0, 50; 0, 1}; {50, 50; 1, 1}}}
Reanimation.triangle.mesh = love.graphics.newMesh(Reanimation.triangle.vert, 'strip', 'dynamic')

function Reanimation:init(kind, x, y)
	self.x = (x or 0)
	self.y = (y or 0)
	self.shader = nil
	self.visible = true
	self.hiddenLayers = {}
	
	self.transform = ReanimFrame:new()
	self.transform.scaleCoords = true
	self.animation = AnimationController:new()
	
	self.ground = nil
	self.groundVelocity = 0
	self.groundVelocityMultiplier = 1
	
	if kind then
		self:setReanim(Cache.reanim(kind))
	end
end

function Reanimation:setReanim(reanim)
	self.reanim = reanim
	self.images = table.copy(self.reanim.images)
	
	self.animation:setReanim(reanim)
	
	self.ground = self:getAnimationLayer('_ground')
	if self.ground then self:toggleLayer('_ground', false) end
end

function Reanimation:replaceImage(image, newResource)
	if newResource == nil or image == nil then
		return
	end
	if type(image) == 'string' then
		image = image:lower():gsub('image_reanim_', '')
	end
	if type(newResource) == 'string' then
		newResource = Cache.image(newResource)
	end
	
	for k, v in pairs(self.images) do
		if v == image or k:lower():gsub('image_reanim_', '') == image then
			self.images[k] = newResource
			return
		end
	end
end
function Reanimation:attachReanim(layer, reanim, basePose, offset)
	return self.animation:attachReanim(layer, reanim, basePose, offset)
end
function Reanimation:getAnimationLayer(layer)
	return self.animation:getLayer(layer)
end
function Reanimation:getLayer(layer)
	return self.reanim:getLayer(layer)
end
function Reanimation:getTrack(layer)
	return self.reanim:getTrack(layer)
end
function Reanimation:layerIsHidden(layer)
	local foundLayer = self:getLayer(layer)
	
	if foundLayer then
		return self.hiddenLayers[foundLayer.name]
	else
		print(('%s: Could not find layer %s'):format(self.reanim.name, layer))
	end
end
function Reanimation:toggleLayer(layer, on)
	local foundLayer = self:getLayer(layer)
	
	if foundLayer then
		self.hiddenLayers[foundLayer.name] = (not on)
	else
		print(('%s: Could not find layer %s'):format(self.reanim.name, layer))
	end
end

function Reanimation:update(dt)
	self:updateAnimation(dt)
end

function Reanimation:updateAnimation(dt)
	self.animation:update(dt)
	
	if self.ground and self.ground.frame.active then
		self.groundVelocity = -self.ground.frame.diffX * self.groundVelocityMultiplier
		self.x = (self.x + self.groundVelocity)
	end
end

function Reanimation:setPosition(x, y)
	self.x, self.y = (x or 0), (y or 0)
end

function Reanimation:draw(x, y, transforms)
	if not self.reanim or not self.visible then return end
	
	love.graphics.setShader(self.shader)
	self:render(x, y, transforms)
	love.graphics.setShader(nil)
end

function Reanimation:render(x, y, transforms)
	Reanimation.drawReanim(self.animation.current.layers, self.images, x, y, transforms or {self.transform}, self.hiddenLayers)
end

function Reanimation.drawReanim(layers, textures, x, y, transforms, hiddenLayers)
	x, y = (x or 0), (y or 0)
	
	local function renderFrame(frame, transforms)
		local image = textures[frame.image]
		local alpha = frame.alpha
		
		if image and frame.alpha > 0 then
			local mesh = Reanimation.triangle
			local vert = mesh.vert
			
			for i, corner in ipairs(vert) do
				corner[1] = ((i % 2 == 1 and 0 or image:getPixelWidth()) * frame.xScale)
				corner[2] = ((i <= 2 and 0 or image:getPixelHeight()) * frame.yScale)
				
				Reanimation.transformVertex(corner, frame, false)
				Reanimation.transformVertex(corner, transforms, true)
				
				corner[1], corner[2] = (corner[1] + x), (corner[2] + y)
			end
			mesh.mesh:setVertices(vert)
			mesh.mesh:setTexture(image)
			
			love.graphics.setColor(1, 1, 1, alpha)
			love.graphics.draw(mesh.mesh)
		end
		
		for _, attachment in ipairs(frame.attachments) do
			local reanim = attachment.reanim
			Reanimation.drawReanim(reanim.animation.current.layers, reanim.images, x, y, {attachment.transform, frame, transforms}, reanim.hiddenLayers)
		end
	end
	
	for i, layer in ipairs(layers) do
		if layer.frame.active and not hiddenLayers[layer.name] then
			renderFrame(layer.frame, transforms)
		end
	end
end

function Reanimation.transformVertex(vert, frame, scaleCoords)
	if frame == nil then return end
	
	if type(frame) == 'table' and not class.isInstance(frame) then
		for _, frame in ipairs(frame) do
			Reanimation.transformVertex(vert, frame, scaleCoords)
		end
		return
	end
	
	local xScale, yScale = (scaleCoords and frame.xScale or 1), (scaleCoords and frame.yScale or 1)
	
	vert[1], vert[2] = (vert[1] - frame.xOrigin - frame.xOffset) * xScale, (vert[2] - frame.yOrigin - frame.yOffset) * yScale
	
	local rX = (vert[1] * math.dcos(frame.yShear) - vert[2] * math.dsin(frame.xShear))
	local rY = (vert[1] * math.dsin(frame.yShear) + vert[2] * math.dcos(frame.xShear))
	
	vert[1], vert[2] = (frame.x * (frame.scaleCoords and xScale or 1) + rX + frame.xOrigin), (frame.y * (frame.scaleCoords and yScale or 1) + rY + frame.yOrigin)
end

function Reanimation:__tostring()
	return ('Reanimation(name:%s, x:%s, y:%s)'):format(self.reanim.name, self.x, self.y)
end

return Reanimation