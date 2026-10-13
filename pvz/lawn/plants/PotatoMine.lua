local PotatoMine = Plant:extend('PotatoMine')

local BlazeModifier = Cache.module(Cache.modifiers('BlazeModifier'))

PotatoMine.reanimName = 'PotatoMine'
PotatoMine.packetRecharge = 3000
PotatoMine.packetCost = 25
PotatoMine.blastDamage = 1800
PotatoMine.blastRange = .4
PotatoMine.id = 4

function PotatoMine:init(x, y, challenge)
	Plant.init(self, x, y, challenge)
	
	self.transform:setScale(.8, .8)
	self.transform:setOffset(-12, -12)
	
	self.countdown = 1500
	self.ready = false
	self.rise = false
	
	self.animation:add('idle', 'idle')
	self.animation:add('rise', 'rise', false)
	self.animation:add('armed', 'armed')
	self.animation:play('idle', true)
	
	self.animation.onFinish:add(function(animation)
		if animation.name == 'rise' then
			self:attach('light', self.light, 'armed')
			self.animation:play('armed')
			self.ready = true
		end
	end)
	
	self.light = Reanimation:new(self.reanimName)
	self.light.animation:setFrameRate(random.number(10, 13))
	local glow = self.light.animation:add('armed', 'armed')
	glow.truncateActive = false
	glow.parallel = true
	self.light.animation:play('armed', true)
	self.light:showOnlyLayer('glow')
	self:toggleLayer('glow', false)
	
	self:attachBlink(self, 'eye', 'armed')
	
	self:setSpeed(1)
end

function PotatoMine:onPlant()
	Plant.onPlant(self)
	
	self:setHitbox(
		self.hitbox.x - self.board.tileSize.y * self.blastRange, self.hitbox.y,
		self.hitbox.w + self.board.tileSize.y * self.blastRange * 2, self.hitbox.h
	)
end

function PotatoMine:update(dt)
	Plant.update(self, dt)
	
	self.countdown = (self.countdown - dt * Constants.tickPerSecond * self.speed * self.speedMultiplier)
	
	if not self.rise and self.countdown < 0 then
		trace('hello')
		
		self.rise = true
		self.health = 4000
		self.animation:play('rise', nil, nil, nil, 18)
		self.board:spawnParticle('PotatoMineRise', self:getHitboxCenter())
	end
end

-- wip probably should just try to explode when theres zombies nearby ?
function PotatoMine:hurt(damage, glow)
	if not self.ready then return Plant.hurt(self, damage, glow) end
	
	self:special()
end

function PotatoMine:special()
	self.dead = true
	
	for _, zombie in ipairs(self:queryCollisionMultiple(self.damageGroup, self.damageFilter) or {}) do
		zombie:applyModifier(BlazeModifier, false, self.blastDamage, zombie.charredReanimName) -- also dont play charred death
	end
	
	Sound.play('potato_mine')
	
	self.board:spawnParticle('PotatoMine', self:getHitboxCenter())
	self:destroy()
end

return PotatoMine
