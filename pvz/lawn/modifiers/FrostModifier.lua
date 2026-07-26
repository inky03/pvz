local FrostModifier = Modifier:extend('FrostModifier')

function FrostModifier:apply(new, frost, ice)
	if new then
		self.frost = (frost or 0)
		self.ice = (ice or 0)
		
		Sound.play('frozen')
	else
		self.frost = math.max(self.frost, frost or 0)
		self.ice = math.max(self.ice, ice or 0)
	end
end

function FrostModifier:update(event)
	local dt = event.dt
	
	if self.ice > 0 then
		self.ice = math.max(self.ice - dt, 0)
	else
		self.frost = math.max(self.frost - dt, 0)
		
		if self.frost <= 0 then
			self:destroy()
		end
	end
	
	self:setMultiplier('speed', self.ice > 0 and 0 or .5)
end

function FrostModifier:draw(event)
	Unit.pvzShader:send('frost', 1)
end

return FrostModifier
