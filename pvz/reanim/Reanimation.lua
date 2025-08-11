Reanim = require 'pvz.reanim.Reanim'
AnimationController = require 'pvz.reanim.animation.AnimationController'

local Reanimation = UIContainer:extend('Reanimation')

Reanimation.triangle = {vert = {{0, 0; 0, 0}; {50, 0; 1, 0}; {0, 50; 0, 1}; {50, 50; 1, 1}}}
Reanimation.triangle.mesh = love.graphics.newMesh(Reanimation.triangle.vert, 'strip', 'dynamic')

function Reanimation:init(kind, x, y)
	UIContainer.init(self, x, y, 80, 80)
	
	self.canClick = false
	
	self.shader = nil
	self.hiddenLayers = {}
	
	self.transform = ReanimFrame:new()
	self.transform.scaleCoords = true
	self.animation = AnimationController:new()
	
	self.ground = nil
	self.groundVelocity = 0
	self.groundVelocityMultiplier = 1
	
	self.prevFrame = 0
	self.frameFloat = 0
	
	self:setReanim(Cache.reanim(kind))
end

function Reanimation:setReanim(reanim)
	if not reanim then return end
	
	self.reanim = reanim
	self.images = table.copy(self.reanim.images)
	
	self.animation:setReanim(reanim)
	
	self.hiddenLayers['_ground'] = true
end

function Reanimation:replaceImage(image, newResource)
	if image == nil then
		return
	end
	local img = image
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
	
	trace(('%s: Could not find image ID %s'):format(self.reanim.name, tostr(img)))
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
		trace(('%s: Could not find layer %s'):format(self.reanim.name, layer))
	end
end
function Reanimation:toggleLayer(layer, on)
	local foundLayer = self:getLayer(layer)
	
	if foundLayer then
		self.hiddenLayers[foundLayer.name] = (not on)
	else
		trace(('%s: Could not find layer %s'):format(self.reanim.name, layer))
	end
end

function Reanimation:update(dt)
	UIContainer.update(self, dt)
	
	self:updateAnimation(dt)
end

function Reanimation:updateAnimation(dt)
	if not self.animation or not self.animation._cur then return end
	
	self.prevFrame = self.animation.frameFloat
	
	self.animation:update(dt)
	
	self.frameFloat = self.animation.frameFloat
	self.groundVelocity = (self.animation.groundVelocity * self.groundVelocityMultiplier)
	self.x = (self.x + self.groundVelocity)
end

function Reanimation:shouldTriggerTimedEvent(t)
	return ((self.frameFloat / self.animation.length) >= t and (self.prevFrame / self.animation.length) < t)
end

function Reanimation:draw(x, y, transforms)
	if not self.reanim or not self.visible then return end
	
	love.graphics.setShader(self.shader)
	self:render(x, y, transforms)
	love.graphics.setShader(nil)
	
	UIContainer.draw(self, x, y)
end

Reanimation.transformStack = {}

function Reanimation:render(x, y, transforms)
	if transforms then
		for i, transform in ipairs(transforms) do
			table.insert(Reanimation.transformStack, i, transform)
		end
	else
		table.insert(Reanimation.transformStack, 1, self.transform)
	end
	
	Reanimation.drawReanim(self.animation.current.layers, self.images, x, y, self.hiddenLayers)
	
	love.graphics.setColor(1, 1, 1, 1)
	
	for i = 1, (transforms and #transforms or 1) do
		table.remove(Reanimation.transformStack, 1)
	end
end

function Reanimation.drawReanim(layers, textures, x, y, hiddenLayers)
	x, y = (x or 0), (y or 0)
	
	local function renderFrame(frame)
		local stack = Reanimation.transformStack
		local image = textures[frame.image]
		local alpha = frame.alpha
		local active = true
		
		for i = 1, #stack do
			local transform = stack[i]
			active = (active and transform.active)
			alpha = (alpha * transform.alpha)
		end
		
		if active and alpha > 0 then
			if image then
				local mesh = Reanimation.triangle
				local vert = mesh.vert
				
				for i, corner in ipairs(vert) do
					corner[1] = ((i % 2 == 1 and 0 or image:getPixelWidth()) * frame.xScale)
					corner[2] = ((i <= 2 and 0 or image:getPixelHeight()) * frame.yScale)
					
					Reanimation.transformVertex(corner, frame, false)
					for i = 1, #stack do Reanimation.transformVertex(corner, stack[i], true) end
					
					corner[1], corner[2] = (corner[1] + x), (corner[2] + y)
				end
				mesh.mesh:setVertices(vert)
				mesh.mesh:setTexture(image)
				
				love.graphics.setColor(1, 1, 1, alpha)
				love.graphics.draw(mesh.mesh)
			end
			
			if #frame.attachments > 0 then
				for _, attachment in ipairs(frame.attachments) do
					local reanim = attachment.reanim
					if reanim.visible then
						reanim:render(x, y, {attachment.transform, reanim.transform, frame})
					end
				end
			end
		end
	end
	
	for i, layer in ipairs(layers) do
		if layer.active and not (hiddenLayers and hiddenLayers[layer.layerName]) then
			renderFrame(layer)
		end
	end
end

function Reanimation.transformVertex(vert, frame, scaleCoords)
	if frame == nil then return end
	
	local xScale, yScale = (scaleCoords and frame.xScale or 1), (scaleCoords and frame.yScale or 1)
	
	vert[1] = ((vert[1] - frame.xOrigin) * xScale - frame.xOffset - frame._internalXOffset)
	vert[2] = ((vert[2] - frame.yOrigin) * yScale - frame.yOffset - frame._internalYOffset)
	
	local rX = (vert[1] * math.dcos(frame.yShear) - vert[2] * math.dsin(frame.xShear))
	local rY = (vert[1] * math.dsin(frame.yShear) + vert[2] * math.dcos(frame.xShear))
	
	vert[1] = (frame.x * (frame.scaleCoords and xScale or 1) + rX + frame.xOrigin)
	vert[2] = (frame.y * (frame.scaleCoords and yScale or 1) + rY + frame.yOrigin)
end

function Reanimation:getName()
	return (self.reanim and self.reanim.name or '')
end

function Reanimation:__tostring()
	return ('Reanimation(name:%s, x:%s, y:%s)'):format(self:getName(), self.x, self.y)
end

return Reanimation