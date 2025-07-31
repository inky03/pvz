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
	self.finished = false
	self.justFinished = false
	
	lambda.foreach(reanim.layers, function(layer)
		table.insert(self.layers, {
			name = layer.name;
			frame = ReanimAnimationFrame:new(layer.frames[1]);
		})
	end)
end

function Animation:update(dt, materialized)
	if self.finished then return end
	
	self.lerp = (self.lerp + dt * self.speed * self.reanim.fps)
	self.justFinished = false
	
	if self.lerp >= 1 then
		self.frame = self.next
		self.next = (self.frame + 1)
		self.lerp = (self.lerp % 1)
		
		if materialized then self.controller.onFrame:dispatch(self) end
		
			-- print(self.reanim.name .. ' ' .. self.length)
		if self.next >= self.length then
			self.justFinished = true
			
			if self.loop then
				if materialized then self.controller.onLoop:dispatch(self) end
				self.frame = 1
				self.next = 2
			else
				if materialized then self.controller.onFinish:dispatch(self) end
				self.finished = true
			end
			
			if materialized then self:updateFrame() end
		end
	end
end
function Animation:updateFrame()
	self:updateLayers(self:getFrameIndex(self.frame), self:getFrameIndex(self.next), self.lerp)
end

function Animation:updateLayers(cur, next, lerp)
	lambda.foreach(self.layers, function(layer, i)
		local reanimLayer = self.reanim.layers[i]
		
		layer.frame:lerp(
			reanimLayer.frames[math.clamp(cur, self.first, self.last)],
			reanimLayer.frames[math.clamp(next, self.first, self.last)],
			lerp
		)
	end)
end
function Animation:getLayer(find)
	if type(find) ~= 'string' then return nil end
	
	local find = find:gsub('anim_', '')
	
	return lambda.find(self.layers, function(layer) return (layer.name:gsub('anim_', '') == find) end)
end

function Animation:reset()
	self.lerp = 0
	self.next = 2
	self.frame = 1
	self:updateLayers(self.frame, self.next, 0)
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
function Animation:setFrame(index, next) -- set frame to index in animation
	self.frame = index
	self.next = (next or index)
	self.lerp = 0
end

function Animation:setTrack(track)
	if not track then return end
	
	self.first = track.first
	self.last = track.last
	self.track = track
	
	self.length = (track.last - track.first + 1)
end

function Animation:__tostring()
	return ('Animation(name:%s, first:%s, last:%s, length:%s)'):format(self.name, self.first, self.last, self.length)
end

return Animation