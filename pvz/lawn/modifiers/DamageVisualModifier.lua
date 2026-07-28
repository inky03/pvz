local DamageModifier = Modifier:extend('DamageModifier')

function DamageModifier:init(parent)
	Modifier.init(self, parent)
	
	self.paused = false
	self.damagePhase = 0
end

function DamageModifier:apply(new, damagePhases)
	self.damagePhases = damagePhases
	
	self:test(self.parent.health)
end

function DamageModifier:hurt(event)
	self:test(self.parent.health - event.damage)
end

function DamageModifier:test(health)
	for i = (self.damagePhase + 1), #self.damagePhases do
		local phase = self.damagePhases[i]
		
		if health < phase.health then
			self.damagePhase = i
			
			if phase.trigger then phase.trigger(self.parent) end
		end
	end
end

return DamageModifier
