local AnimationController = class('AnimationController')

Animation = require 'pvz.reanim.animation.Animation'

function AnimationController:init(reanim)
	if reanim then self:setReanim(reanim) end
	
	self.onFinish = Signal:new()
	self.onFrame = Signal:new()
	self.onLoop = Signal:new()
	
	self.groundVelocity = 0
	
	self:reset()
end

function AnimationController:setReanim(reanim)
	if not reanim then return end
	
	self.reanim = reanim
	self.parallel = {}
	self.list = {}
	
	self._prev = nil
	self._cur = self:add('', nil, false)
	self._ghost = Animation:new(self, self.reanim)
	self.current = Animation:new(self, self.reanim)
	
	self.frame = 0
	self.frameFloat = 0
	self.length = 0
	
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

function AnimationController:update(dt, noDiff)
	if self.paused or not self.reanim then return end
	
	lambda.foreach(self.list, function(anim)
		local active = (anim == self._cur or anim == self._prev)
		if active or self.parallel[anim.name] then
			anim:update(dt * self.speed, active)
		end
	end)
	
	local ground, groundX = self._cur:getLayer('_ground'), 0
	if ground then groundX = ground.x end
	
	self.current.lerp = self._cur.lerp
	self.current.next = self._cur.next
	self.current.frame = self._cur.frame
	self.current.finished = self._cur.finished
	self.finished = self._cur.finished
	self._cur:updateFrame(0)
	
	self.length = self._cur.length
	self.frame = self.current.frame
	self.frameFloat = math.lerp(self.current.frame, self.current.next, self.current.lerp)
	
	self.groundVelocity = (ground and ground.active and not self._cur.justFinished and (groundX - ground.x) or 0)
	
	if self.crossFade < 1 then
		if self._prev then
			local ground, groundX = self._prev:getLayer('_ground'), 0
			if ground then groundX = ground.x end
			
			self._prev:updateFrame(0)
			
			self.groundVelocity = (ground and ground.active and not self._prev.justFinished and (groundX - ground.x) or 0)
		end
		
		if self.crossFadeLength > 0 then
			self.crossFade = math.min(1, self.crossFade + dt * self.speed / self.crossFadeLength)
		else
			self.crossFade = 1
		end
	end
	
	self:updateFrame(dt, self._cur.justFinished)
end
function AnimationController:updateFrame(dt, noDiff)
	lambda.foreach(self.current.layers, function(layer, i)
		layer:lerp(
			self._ghost.layers[i],
			self._cur.layers[i],
			self.crossFade
		)
		
		if noDiff then layer.diffX, layer.diffY = 0, 0 end
		
		for _, attachment in ipairs(layer.attachments) do
			attachment.reanim:update(dt, noDiff)
		end
	end)
end

function AnimationController:framesToSeconds(n)
	return (n / self.reanim.fps / self.speed)
end

function AnimationController:attachReanim(layer, reanim, basePose)
	local basePose = (basePose or self.name)
	local baseLayer = self:getLayer(layer)
	
	if baseLayer then
		local transform = nil
		local base = Animation:new(self, self.reanim)
		local reanimTrack = self.reanim:getTrack(basePose)
		
		if reanimTrack then
			base:setTrack(reanimTrack)
			base:reset()
			base:updateFrame(0)
			
			local baseFrame = base:getLayer(layer)
			transform = ReanimFrame:new()
			transform:setShear(-baseFrame.xShear, -baseFrame.yShear)
			transform:setScale(1 / baseFrame.xScale, 1 / baseFrame.yScale)
			transform:setPosition(-baseFrame.x / baseFrame.xScale, -baseFrame.y / baseFrame.yScale)
		else
			print(('%s: Track %s doesn\'t exist'):format(self.reanim.name, basePose))
			return
		end
		
		baseLayer:attachReanim(reanim, transform)
	else
		print(('%s: Layer %s doesn\'t exist'):format(self.reanim.name, track))
	end
end

function AnimationController:get(name)
	return lambda.find(self.list, function(anim) return anim.name == name end)
end
function AnimationController:remove(name)
	for i, anim in ipairs(self.list) do
		if anim.name == name then
			table.remove(self.list, i)
			return
		end
	end
end
function AnimationController:add(name, track, loop)
	local anim = self:get(name)
	if anim then
		print(('%s: Animation %s already exists'):format(self.reanim.name, name))
		return anim
	end
	
	anim = Animation:new(self, self.reanim, name)
	anim.loop = (loop == nil and true or loop)
	
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
	elseif force or self.current.name ~= name or self.finished then
		local reset = (reset == nil and true or reset)
		local anim = self:get(name)
		if anim then
			self._prev = self._cur
			
			lambda.foreach(self._ghost.layers, function(layer, i) layer:copy(self.current.layers[i]) end)
			
			self._cur = anim
			self.current.name = anim.name
			self.current.length = anim.length
			self.current.track = anim.track
			self.current.first = anim.first
			self.current.last = anim.last
			self.name = name
			
			self.crossFade = 0
			self.crossFadeLength = (crossFade or (force and 0 or self:framesToSeconds(3)))
			
			if reset then anim:reset() end
			
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
	return self._cur
end

function AnimationController:getLayer(find)
	return self.current:getLayer(find)
end

return AnimationController