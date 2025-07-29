Reanim = require 'pvz.reanim.Reanim'

local Sprite = class('Sprite')

Sprite.triangle = {vert = {{0, 0; 0, 0}; {50, 0; 1, 0}; {0, 50; 0, 1}; {50, 50; 1, 1}}}
Sprite.triangle.mesh = love.graphics.newMesh(Sprite.triangle.vert, 'strip', 'dynamic')

function Sprite:init(kind, x, y)
	self.x = (x or 0)
	self.y = (y or 0)
	self.shader = nil
	self.visible = true
	
	self.transform = ReanimFrame:new()
	self.transform.scaleCoords = true
	self.animation = {
		current = {name = nil; first = 1; last = 1};
		name = 'nil';
		
		finished = false;
		speed = 1.0;
		loop = true;
		
		onFinish = Signal:new();
		onFrame = Signal:new();
		onLoop = Signal:new();
	}
	
	self.ground = nil
	self.groundVelocity = 0
	self.groundFrame = ReanimFrame:new()
	
	self:setReanim(Cache.reanim(kind))
end

function Sprite:setReanim(reanim)
	self.reanim = reanim
	self.images = table.copy(self.reanim.images)
	self.hiddenLayers = {}
	
	self.triangles = {}
	self.animation.current = {name = 'nil'; first = 1; last = 1}
	self.animation.name = 'nil'
	self.animation.lerp = 0
	
	self.animation.curFrame = 1
	self.animation.nextFrame = 1
	
	self.animation.startLayers = {}
	self.animation.curLayers = {}
	self.animation.nextLayers = {}
	
	for i, layer in ipairs(self.reanim.layers) do
		table.insert(self.animation.startLayers, {name = layer.name; frame = ReanimFrame:new(layer.frames[1])})
		table.insert(self.animation.curLayers, {name = layer.name; frame = ReanimFrame:new(layer.frames[1])})
		table.insert(self.animation.nextLayers, {name = layer.name; frame = ReanimFrame:new(layer.frames[1])})
	end
	
	self.ground = self:getLayer('_ground')
	if self.ground then self:toggleLayer('_ground', false) end
	self:updateAnimationFrames(self.animation.startLayers, self.animation.nextLayers, self.animation.lerp)
end

function Sprite:getImageNames()
	local list = {}
	for image, _ in pairs(self.images) do
		table.insert(list, image)
	end
	return list
end
function Sprite:getLayerNames()
	local list = {}
	for _, layer in ipairs(self.reanim.layers) do
		table.insert(list, layer.name)
	end
	return list
end

function Sprite:getImage(image)
	if type(image) == 'string' then
		image = image:lower():gsub('image_reanim_', '')
	end
	
	return lambda.find(self.images, function(res, name) return (res == image or name:lower():gsub('image_reanim_', '') == image) end)
end
function Sprite:replaceImage(image, newResource)
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
function Sprite:getLayer(find, layers)
	if type(find) ~= 'string' then return nil end
	
	layers = (layers or self.animation.curLayers)
	find = find:gsub('anim_', '')
	
	return lambda.find(layers, function(layer) return (layer.name:gsub('anim_', '') == find) end)
end
function Sprite:layerIsHidden(layer)
	local foundLayer = self:getLayer(layer)
	
	if foundLayer then
		return self.hiddenLayers[foundLayer.name]
	else
		print(('%s: Could not find layer %s'):format(self.reanim.name, layer))
	end
end
function Sprite:toggleLayer(layer, on)
	local foundLayer = self:getLayer(layer)
	
	if foundLayer then
		self.hiddenLayers[foundLayer.name] = (not on)
	else
		print(('%s: Could not find layer %s'):format(self.reanim.name, layer))
	end
end

function Sprite:getAnimation(animation)
	animation = animation:gsub('anim_', '')
	
	return (animation and lambda.find(self.reanim.guides, function(anim) return (anim.name:gsub('anim_', '') == animation) end) or nil)
end
function Sprite:playAnimation(animation, force)
	local anim = self:getAnimation(animation)
	
	if (force or not self.animation.finished or anim ~= self.animation.current) then
		if anim then
			self.animation.current = anim
			self.animation.name = anim.name
		else
			if animation then
				print(('%s: Could not find layer %s'):format(self.reanim.name, animation))
				return
			end
			self.animation.current = {name = 'nil'; first = 1; last = self.reanim.length}
			self.animation.name = 'nil'
		end
		
		self.animation.lerp = 0
		self.animation.finished = false
			
		if not force then
			self.animation.nextFrame = self.animation.current.first
			self:copyFrames(self.animation.startLayers, self.animation.curLayers)
			self:copyFrames(self.animation.nextLayers, self.animation.nextFrame)
		else
			self.animation.curFrame = self.animation.current.first
			self.animation.nextFrame = self.animation.current.first
			self:copyFrames(self.animation.startLayers, self.animation.curFrame)
			self:copyFrames(self.animation.nextLayers, self.animation.nextFrame)
			self:copyFrames(self.animation.curLayers, self.animation.startLayers)
		end
		
		if self.ground then
			self.groundFrame:copy(self:getLayer('_ground', self.animation.nextLayers).frame)
		end
	end
end

function Sprite:update(dt)
	self:updateAnimation(dt)
end

function Sprite:updateAnimation(dt)
	if not self.animation then return end
	
	if not self.animation.finished then
		self.animation.lerp = (self.animation.lerp + self.reanim.fps * self.animation.speed * dt * self:getAnimationMultiplier())
		
		local looped = false
		if self.animation.lerp >= 1 then
			self.animation.lerp = (self.animation.lerp % 1)
			self.animation.curFrame = self.animation.nextFrame
			self.animation.startFrame = self.animation.nextFrame
			self.animation.nextFrame = self.animation.nextFrame + 1
			self.animation.onFrame:dispatch(self.animation.curFrame)
			
			if not self.animation.loop then
				if self.animation.nextFrame > self.animation.current.last then
					self.animation.nextFrame = (self.animation.current.last - 1)
					self.animation.startFrame = (self.animation.nextFrame)
					self.animation.curFrame = (self.animation.nextFrame)
					self.animation.finished = true
					self.animation.onFinish:dispatch()
				end
			elseif self.animation.loop and self.animation.nextFrame >= self.animation.current.last then
				self.animation.startFrame = self.animation.current.first
				self.animation.nextFrame = math.min(self.animation.current.first + 1, self.animation.current.last)
				self.animation.onLoop:dispatch()
				looped = true
			end
			
			self:copyFrames(self.animation.startLayers, self.animation.startFrame)
			self:copyFrames(self.animation.nextLayers, self.animation.nextFrame)
			self:copyFrames(self.animation.curLayers, self.animation.startLayers)
			
			if looped and self.ground and self.ground.frame.active then
				self.groundFrame:copy(self.ground.frame)
			end
		end
	end
	
	self:updateAnimationFrames(self.animation.startLayers, self.animation.nextLayers, self.animation.lerp)
	if self.ground and self.ground.frame.active then
		self.groundVelocity = (self.groundFrame.x - self.ground.frame.x) * self:getGroundMultiplier()
		self.x = (self.x + self.groundVelocity)
		self.groundFrame:copy(self.ground.frame)
	end
end

function Sprite:getAnimationMultiplier()
	return 1
end
function Sprite:getGroundMultiplier()
	return 1
end

function Sprite:copyFrames(to, index)
	for i, layer in ipairs(self.reanim.layers) do
		local frame = (type(index) == 'table' and index[i].frame or layer.frames[index])
		to[i].frame:copy(frame)
	end
end

function Sprite:updateAnimationFrames(start, next, lerp)
	for i, layer in ipairs(self.animation.curLayers) do
		layer.frame:lerp(
			start[i].frame,
			next[i].frame,
			lerp
		)
	end
end

function Sprite:draw(x, y, transforms)
	if not self.reanim or not self.visible then return end
	
	love.graphics.setShader(self.shader)
	self:render(x, y, transforms)
	love.graphics.setShader(nil)
end

function Sprite:render(x, y, transforms)
	Sprite.drawReanim(self.animation.curLayers, self.images, x, y, transforms or {self.transform}, self.hiddenLayers)
end

function Sprite.drawReanim(layers, textures, x, y, transforms, hiddenLayers)
	x, y = (x or 0), (y or 0)
	
	for i, layer in ipairs(layers) do
		if layer.frame.active and not hiddenLayers[layer.name] then
			local image = textures[layer.frame.image]
			local alpha = layer.frame.alpha
			
			if image and layer.frame.alpha > 0 then
				local mesh = Sprite.triangle
				local vert = mesh.vert
				
				for i, corner in ipairs(vert) do
					corner[1] = ((i % 2 == 1 and 0 or image:getPixelWidth()) * layer.frame.xScale)
					corner[2] = ((i <= 2 and 0 or image:getPixelHeight()) * layer.frame.yScale)
					
					Sprite.transformVertex(corner, layer.frame, false)
					Sprite.transformVertex(corner, transforms, true)
					
					corner[1], corner[2] = (corner[1] + x), (corner[2] + y)
				end
				mesh.mesh:setVertices(vert)
				mesh.mesh:setTexture(image)
				
				for _, frame in ipairs(transforms) do
					alpha = alpha * frame.alpha
				end
				
				love.graphics.setColor(1, 1, 1, alpha)
				love.graphics.draw(mesh.mesh)
			end
		end
	end
end

function Sprite.transformVertex(vert, frame, scaleCoords)
	if frame == nil then return end
	if type(frame) == 'table' and type(frame[1]) == 'table' then
		for _, frame in ipairs(frame) do
			Sprite.transformVertex(vert, frame, scaleCoords)
		end
		return
	end
	
	local xScale, yScale = (frame.scaleCoords and frame.xScale or 1), (frame.scaleCoords and frame.yScale or 1)
	
	vert[1], vert[2] = (vert[1] - frame.xOrigin - frame.xOffset) * xScale, (vert[2] - frame.yOrigin - frame.yOffset) * yScale
	
	local rX = (vert[1] * math.dcos(frame.yShear) - vert[2] * math.dsin(frame.xShear))
	local rY = (vert[1] * math.dsin(frame.yShear) + vert[2] * math.dcos(frame.xShear))
	
	vert[1], vert[2] = (frame.x * xScale + rX + frame.xOrigin), (frame.y * yScale + rY + frame.yOrigin)
end

return Sprite