local BlazeModifier = Modifier:extend('BlazeModifier')

function BlazeModifier:apply(new, damage, reanimName)
	self.timer = 300
	
	self.charredReanim = reanimName
	
	self.parent:hurt(damage)
end

function BlazeModifier:hurt(event)
	if (self.parent.health - event.damage) <= 0 then
		event:stopPropagation()
	else
		self:destroy()
	end
end

function BlazeModifier:die(event)
	event:stopPropagation()
	event:cancel()
	
	self.parent.dead = true
	
	if self.charredReanim then
		self.parent:setReanim(Cache.reanim(self.charredReanim))
		self.parent.animation:setLoop(false)
	else
		self.blazeTransform = ReanimFrame:new()
		self.blazeTransform:setColor(0, 0, 0)
		
		self.parent.animation.paused = true
	end
end

function BlazeModifier:update(event)
	self.timer = (self.timer - event.dt * Constants.tickPerSecond)
	
	if self.timer <= 0 then
		self.parent:destroy()
	end
	
	event:stopPropagation()
	event:cancel()
	
	Reanimation.update(self.parent, event.dt)
end

function BlazeModifier:draw(event)
	if self.charredReanim then return end
	
	local transforms = (event.transforms or {})
	
	table.insert(transforms, self.blazeTransform)
	
	event.transforms = transforms
end

function BlazeModifier:drawShadow(event)
	event:cancel()
end

return BlazeModifier
