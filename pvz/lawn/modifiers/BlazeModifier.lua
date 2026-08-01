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
	end
end

function BlazeModifier:update(event)
	self.timer = (self.timer - event.dt * Constants.tickPerSecond)
	
	if self.timer <= 0 then
		self.parent:destroy()
	end
	
	event:stopPropagation()
	event:cancel()
	
	if self.charredReanim then Reanimation.update(self.parent, event.dt) end
end

function BlazeModifier:render(event)
	if self.charredReanim then return end
	
	local a = select(4, love.graphics.getColor())
	love.graphics.setColor(0, 0, 0, a)
end

function BlazeModifier:drawShadow(event)
	event:cancel()
end

return BlazeModifier
