local ShieldModifier = Modifier:extend('ShieldModifier')

local DamageVisualModifier = Cache.module(Cache.modifiers('DamageVisualModifier'))

function ShieldModifier:init(parent)
	Modifier.init(self, parent)
	
	self.damageVisual = DamageVisualModifier:new(self)
end

function ShieldModifier:apply(new, health, damagePhases, onDamage)
	self.health = health
	self.onDamage = onDamage
	
	self.damageVisual:apply(true, damagePhases)
	self.damageVisual:test(self.health)
end

function ShieldModifier:hurt(event)
	local targetHealth = (self.health - event.damage)
	local bleed = (math.max(targetHealth, 0) - targetHealth)
	
	self:onDamage(event.damage)
	
	self.health = targetHealth
	self.damageVisual:test(self.health)
	
	if self.health <= 0 then
		self:destroy()
		
		event.damage = -self.health
	else
		event:cancelDamage()
	end
end

return ShieldModifier
