Reanim = require 'pvz.data.Reanim'
AnimationController = require 'pvz.reanim.animation.AnimationController'

local Reanimation = UIContainer:extend('Reanimation')

function Reanimation:init(kind, x, y)
	UIContainer.init(self, x, y, 80, 80)
	
	self.canClick = false
	
	self.shader = nil
	self.hiddenLayers = {}
	
	self.transform = ReanimFrame:new()
	self.transform.scaleCoords = true
	self.transforms = {self.transform}
	
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
function Reanimation:attach(layer, object, basePose, offset)
	return self.animation:attach(layer, object, basePose, offset)
end
function Reanimation:findAttachment(needle)
	local layers = self.animation.current.layers
	for i = 1, #layers do
		local attachment = layers[i]:findAttachment(needle)
		if attachment then return attachment end
	end
	return nil
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
function Reanimation:assignRenderGroupToTrack(layer, renderGroup)
	local foundLayer = self:getAnimationLayer(layer)
	
	if foundLayer then
		foundLayer.renderGroup = renderGroup
	else
		trace(('%s: Could not find layer %s'):format(self.reanim.name, layer))
	end
end
function Reanimation:assignRenderGroupToPrefix(prefix, renderGroup)
	local foundLayer = false
	for i, layer in ipairs(self.animation.current.layers) do
		if layer.layerName:sub(1, #prefix) == prefix then
			layer.renderGroup = renderGroup
			foundLayer = true
		end
	end
	
	if not foundLayer then
		trace(('%s: Could not find any layer with prefix %s'):format(self.reanim.name, prefix))
	end
end

function Reanimation:update(dt)
	UIContainer.update(self, dt)
	
	if self.attachment then self.attachment:update(dt) end
	if self.font then self.font:update(dt) end
	
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
	return (((self.frameFloat - 1) / (self.animation.length - 1)) >= t and ((self.prevFrame - 1) / (self.animation.length - 1)) < t)
end

function Reanimation:draw(x, y, transforms)
	UIContainer.draw(self, x, y, transforms)
end
function Reanimation:drawRenderGroup(renderGroup, x, y, transforms)
	if not self.reanim or not self.visible then return end
	
	love.graphics.setShader(self.shader)
	self:render(x, y, transforms, renderGroup)
	love.graphics.setShader(nil)
end

Reanimation.transformStack = {}

function Reanimation:render(x, y, transforms, renderGroup)
	local transforms = (transforms or self.transforms)
	
	love.graphics.push()
	love.graphics.translate(x, y)
	
	local pop = Reanimation.applyTransform(transforms)
	
	Reanimation.drawReanim(renderGroup or 1, self.animation.current.layers, self.images, self.hiddenLayers)
	
	for _ = 1, pop do love.graphics.pop() end
	
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.pop()
end

function Reanimation.drawReanim(renderGroup, layers, textures, hiddenLayers)
	for i = 1, #layers do
		local layer = layers[i]
		
		if layer.renderGroup == renderGroup and layer.active and not (hiddenLayers and hiddenLayers[layer.layerName]) then
			Reanimation.drawLimb(layer, textures)
		end
	end
end
function Reanimation.drawLimb(limb, textures)
	if not limb.active or limb.alpha <= 0 then return end
	
	local image = textures[limb.image]
	local pop = Reanimation.applyTransform(limb)
	
	if image then love.graphics.draw(image) end
	
	if #limb.attachments > 0 then
		for i = 1, #limb.attachments do
			local attachment = limb.attachments[i]
			local object = attachment.object
			
			if object.visible then
				object:render(0, 0, {attachment.transform, object.transforms})
			end
		end
	end
	
	if limb.attachment then limb.attachment:render(0, 0) end
	
	for _ = 1, pop do love.graphics.pop() end
end

function Reanimation.flashScaleAndShear(xScale, yScale, xShear, yShear)
	local m00, m01, m10, m11 =
		(math.dcos(yShear) * xScale), (-math.dsin(xShear) * yScale),
		(math.dsin(yShear) * xScale), (math.dcos(xShear) * yScale)
	
	-- https://math.stackexchange.com/questions/861674/decompose-a-2d-arbitrary-transform-into-only-scaling-and-rotation
	
	local e, f, g, h = ((m00 + m11) * .5), ((m00 - m11) * .5), ((m10 + m01) * .5), ((m10 - m01) * .5)
	local q, r = math.sqrt(e * e + h * h), math.sqrt(f * f + g * g)
	local a1, a2 = math.atan2(g, f), math.atan2(h, e)
	
	return (q + r), (q - r), ((a2 - a1) * .5), ((a2 + a1) * .5)
end

local dcos, dsin = math.dcos, math.dsin
function Reanimation.applyTransform(frame)
	local r, g, b, a = love.graphics.getColor()
	
	if type(frame) == 'table' and not class.isInstance(frame) then
		local pop = 0
		
		for i = 1, #frame do
			pop = (pop + Reanimation.applyTransform(frame[i]))
		end
		
		return pop
	end
	
	local xScale, yScale, xShear, yShear = Reanimation.flashScaleAndShear(frame.xScale, frame.yScale, frame.xShear, frame.yShear)
	
	love.graphics.push('all')
	love.graphics.setColor(r * frame.red, g * frame.green, b * frame.blue, a * frame.alpha)
	love.graphics.translate(-frame.xOffset - frame._internalXOffset, -frame.yOffset - frame._internalYOffset)
	
	love.graphics.push()
	love.graphics.translate(frame.xOrigin, frame.yOrigin)
	love.graphics.translate(frame.x, frame.y)
	love.graphics.rotate(yShear)
    love.graphics.scale(xScale, yScale)
    love.graphics.rotate(xShear)
	love.graphics.translate(-frame.xOrigin, -frame.yOrigin)
	
	return 2
end

function Reanimation:getName()
	return (self.reanim and self.reanim.name or '')
end

function Reanimation:__tostring()
	return ('Reanimation(name:%s, x:%s, y:%s)'):format(self:getName(), self.x, self.y)
end

return Reanimation