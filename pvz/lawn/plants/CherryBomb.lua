local CherryBomb = Plant:extend('CherryBomb')

local ShakeModifier = Cache.module(Cache.modifiers('ShakeModifier'))
local BlazeModifier = Cache.module(Cache.modifiers('BlazeModifier'))

CherryBomb.defaultBlinkAnim = ''
CherryBomb.reanimName = 'CherryBomb'
CherryBomb.packetRecharge = 5000
CherryBomb.packetCost = 150
CherryBomb.blastDamage = 1800
CherryBomb.blastRange = .6
CherryBomb.id = 2

function CherryBomb:init(x, y, challenge)
	Plant.init(self, x, y, challenge)
	
	self.animation:add('explode', 'explode', false)
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
	
	self:applyModifier(ShakeModifier, false, 1, 1)
end

function CherryBomb:onPlant()
	Plant.onPlant(self)
	
	self.countdown = 100
	
	self.speed = (random.number(10, 15) / 30)
	self.animation:play('explode', true)
	
	Sound.play('reverse_explosion')
end

function CherryBomb:update(dt)
	if Plant.update(self, dt) == false then return false end
	
	if self.countdown then
		self.countdown = (self.countdown - dt * Constants.tickPerSecond)
		
		if self.countdown <= 0 then
			self:die()
		end
	end
end

function CherryBomb:die()
	self.dead = true
	
	self:setHitbox(
		-self.board.tileSize.x * self.blastRange, -self.board.tileSize.y * self.blastRange,
		self.board.tileSize.x * (1 + self.blastRange * 2), self.board.tileSize.y * (1 + self.blastRange * 2)
	)
	
	for _, zombie in ipairs(self:queryCollisionMultiple(self.damageGroup, self.damageFilter) or {}) do
		zombie:applyModifier(BlazeModifier, false, self.blastDamage, zombie.charredReanimName)
	end
	
	Sound.play('explosion')
	
	self.board:spawnParticle('Powie', self:getHitboxCenter())
	self:destroy()
end

return CherryBomb