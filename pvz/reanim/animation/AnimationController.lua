local AnimationController = class('AnimationController')

Animation = require 'pvz.reanim.animation.Animation'

function AnimationController:init(reanim)
	if reanim then self:setReanim(reanim) end
	
	self.onFinish = Signal:new()
	self.onFrame = Signal:new()
	self.onLoop = Signal:new()
	
	self:reset()
end

function AnimationController:setReanim(reanim)
	self.reanim = reanim
	self.list = {}
	
	self._cur = self:add('')
	self._ghost = Animation:new(self, self.reanim)
	self.current = Animation:new(self, self.reanim)
	
	self.crossFadeLength = 0
	self.crossFade = 0
	
	self:reset()
end

function AnimationController:reset()
	self.name = ''
	
	self.finished = false
	self.paused = false
	self.speed = 1
end

function AnimationController:update(dt)
	if self.paused then return end
	
	lambda.foreach(self.list, function(anim) anim:update(dt * self.speed, anim == self._cur) end)
	
	self.finished = self._cur.finished
	self._cur:updateFrame()
	
	if self.crossFade < 1 then
		if self.crossFadeLength > 0 then
			self.crossFade = math.min(1, self.crossFade + dt * self.speed / self.crossFadeLength)
		else
			self.crossFade = 1
		end
	end
	
	self:updateFrame(dt)
end
function AnimationController:updateFrame(dt)
	local dt = (dt or 0)
	
	lambda.foreach(self.current.layers, function(layer, i)
		layer.frame:lerp(
			self._ghost.layers[i].frame,
			self._cur.layers[i].frame,
			self.crossFade
		)
		
		if self._cur.justFinished then layer.frame.diffX, layer.frame.diffY = 0, 0 end
		
		for _, attachment in ipairs(layer.frame.attachments) do
			attachment.reanim:update(dt)
		end
	end)
end

function AnimationController:framesToSeconds(n)
	return (n / self.reanim.fps / self.speed)
end

function AnimationController:attachReanim(layer, reanim, basePose, offset)
	local basePose = (basePose or self.name)
	local baseLayer = self:getLayer(layer)
	
	if baseLayer then
		local transform = nil
		local base = Animation:new(self, self.reanim)
		local reanimTrack = self.reanim:getTrack(basePose)
		
		if reanimTrack then
			base:setTrack(reanimTrack)
			base:reset()
			base:updateFrame()
			
			local baseFrame = base:getLayer(layer).frame
			transform = ReanimFrame:new()
			transform:setPosition(-baseFrame.x, -baseFrame.y)
			transform:setShear(-baseFrame.xShear, -baseFrame.yShear)
			transform:setScale(1 / baseFrame.xScale, 1 / baseFrame.yScale)
		else
			print(('%s: Track %s doesn\'t exist'):format(self.reanim.name, basePose))
			return
		end
		
		baseLayer.frame:attachReanim(reanim, {transform, offset})
	else
		print(('%s: Layer %s doesn\'t exist'):format(self.reanim.name, track))
	end
end

function AnimationController:get(name)
	return lambda.find(self.list, function(anim) return anim.name == name end)
end
function AnimationController:add(name, track, loop)
	local anim = self:get(name)
	if anim then
		print(('%s: Animation %s already exists'):format(self.reanim.name, name))
		return anim
	end
	
	anim = Animation:new(self, self.reanim, name)
	anim.loop = (loop or true)
	
	if track then
		local reanimTrack = self.reanim:getTrack(track)
		if reanimTrack then
			anim:setTrack(reanimTrack)
		else
			print(('%s: Track %s doesn\'t exist'):format(self.reanim.name, track))
		end
	end
	anim:reset()
	
	table.insert(self.list, anim)
	return anim
end
function AnimationController:play(name, force, crossFade, reset)
	if not name then
		self:play('')
	elseif force or self.current.name ~= name then
		local reset = (reset == nil and true or reset)
		local anim = self:get(name)
		if anim then
			lambda.foreach(self._ghost.layers, function(layer, i) layer.frame:copy(self.current.layers[i].frame) end)
			
			if reset then self._cur:reset() end
			
			self._cur = anim
			self.current.name = self._cur.name
			self.current.length = self._cur.length
			self.current.track = self._cur.track
			self.current.first = self._cur.first
			self.current.last = self._cur.last
			self.name = name
			
			self.crossFade = 0
			self.crossFadeLength = (crossFade or (force and 0 or self:framesToSeconds(1)))
			
			self:update(0)
		else
			print(('%s: Animation %s doesn\'t exist'):format(self.reanim.name, name))
		end
	else
		-- let animation play ..
	end
end
function AnimationController:setFrame(index, next)
	self._cur:setFrame(index, next)
	self:update(0)
end
function AnimationController:getFrame()
	return self._cur.frame
end

function AnimationController:getLayer(find)
	return self.current:getLayer(find)
end

return AnimationController