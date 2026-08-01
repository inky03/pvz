local Animation = class('Animation')

local ReanimAnimationFrame = require 'pvz.reanim.animation.ReanimAnimationFrame'

function Animation:init(controller, reanim, name)
	self.controller = controller
	self.name = (name or '')
	self.reanim = reanim
	self.layers = {}
	
	self.first = 1
	self.last = reanim.length
	self.length = reanim.length
	
	self.lerp = 0
	self.next = 2
	self.frame = 1
	self.speed = 1
	self.loop = true
	self.paused = false
	self.finished = false
	self.justFinished = false
	self.parallel = false
	self.fps = reanim.fps
	
	lambda.foreach(reanim.layers, function(layer)
		local newFrame = ReanimAnimationFrame:new(layer.frames[1])
		table.insert(self.layers, newFrame)
		newFrame.layerName = layer.name
	end)
end

function Animation:update(dt, materialized)
	if self.paused or self.finished then return end
	
	self.lerp = (self.lerp + dt * self.speed * self.fps)
	self.justFinished = false
	
	if self.lerp >= 1 then
		if self.next > (self.loop and self.length - 1 or self.length) then
			self.justFinished = true
			
			if self.loop then
				self.next = 2
				self.frame = 1
				if materialized then self.controller.onLoop:dispatch(self) end
			else
				self.lerp = 0
				self.finished = true
				if materialized then self.controller.onFinish:dispatch(self) end
			end
			
			self:updateFrame()
		else
			self.frame = self.next
			self.next = (self.frame + 1)
			
			if materialized then self.controller.onFrame:dispatch(self) end
		end
		
		self.lerp = (self.lerp % 1)
	end
end
function Animation:updateFrame()
	self:updateLayers(self:getFrameIndex(self.frame), self:getFrameIndex(self.next), self.lerp)
end

function Animation:updateLayers(cur, next, lerp)
	for i = 1, #self.layers do
		local layerFrames = self.reanim.layers[i].frames
		
		self.layers[i]:lerp(
			layerFrames[math.clamp(cur, self.first, self.last)],
			layerFrames[math.clamp(next, self.first, self.last)],
			lerp
		)
	end
end
function Animation:getLayer(find)
	if type(find) ~= 'string' then return nil end
	
	local find = find:gsub('anim_', '')
	
	return lambda.find(self.layers, function(layer) return (layer.layerName:gsub('anim_', '') == find) end)
end

function Animation:reset()
	self.lerp = 0
	self.next = 2
	self.frame = 1
	self.finished = false
	self:updateFrame()
end

function Animation:getFrameIndex(index) -- return index in reanim from index in animation
	local index = (index or self.frame)
	return (index + self.first - 1)
end
function Animation:getFrameFromIndex(index) -- return index in animation from index in reanim
	return (index - self.first + 1)
end

function Animation:setFrameFromIndex(index) -- set frame to index in reanim
	self:setFrame(self:getFrameFromIndex(index))
end
function Animation:setFrame(index, next, lerp) -- set frame to index in animation
	local offset = (self.loop and 0 or 1)
	local fun = (self.loop and math.wrap or math.clamp)
	self.frame = fun(math.floor(index), 1, self.length)
	self.next = fun(next or math.ceil(index), 1, self.length + offset)
	self.lerp = (lerp or ((self.frame < self.length - 1 or self.loop) and (index % 1) or math.min(index - self.frame, 1)))
	
	if self.frame < self.length then
		self.finished = false
	end
end

function Animation:setTrack(track, after)
	if not track then return end
	
	local first, last
	
	if after then
		for i = 1, #track.keyframes do
			local keyframe = track.keyframes[i]
			
			if after >= keyframe.first and after <= keyframe.last then
				first, last = after, keyframe.last
				
				break
			end
		end
	elseif #track.keyframes > 0 then
		first, last = track.keyframes[1].first, track.keyframes[1].last
	end
	
	if not first then
		trace('Track ' .. track.name .. ' has no visible keyframes')
		
		return
	end
	
	self.track, self.first, self.last = track, first, last
	
	self.length = (self.last - self.first + 1)
end

function Animation:__tostring()
	return ('Animation(name:%s, frame: %s, first:%s, last:%s, length:%s)'):format(self.name, self.frame, self.first, self.last, self.length)
end

return Animation