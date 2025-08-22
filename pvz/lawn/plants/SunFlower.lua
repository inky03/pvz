local Sun = Cache.module('pvz.lawn.collectibles.Sun')
local SunFlower = Plant:extend('SunFlower')

SunFlower.reanimName = 'SunFlower'
SunFlower.packetCost = 50
SunFlower.id = 1

function SunFlower:init(x, y, challenge)
	Plant.init(self, x, y, challenge)
	
	self.glowny = -1
	self.glowing = false
	self.fireRate = 2500
	self.fireTimer = random.int(300, self.fireRate / 2)
	
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
	self.animation:setFrame(4)
	
	self:attachBlink()
end

function SunFlower:update(dt)
	if not self.active then return end
	
	Plant.update(self, dt)
	
	local plantDelta = (dt * Constants.tickPerSecond * self.speed * self.speedMultiplier)
	
	self.fireTimer = (self.fireTimer - plantDelta)
	
	if self.fireTimer < 0 then
		self.fireTimer = (self.fireTimer + self.fireRate)
		self.glowing = true
	end
	
	if self.glowing and not self.challenge.challengeCompleted then
		self.glowny = math.min(self.glowny + plantDelta, 100)
		
		if self.glowny >= 100 then
			self.glowing = false
			self:makeSun()
		end
	else
		self.glowny = math.max(self.glowny - plantDelta, 0)
	end
	
	self.glow = math.remap(self.glowny, 0, 100, 0, 1)
end

function SunFlower:makeSun()
	Sound.play('throw', 10)
	local xx, yy = self:elementToScreen(0, 0)
	self.challenge.collectibles:addElement(Sun:new(xx, yy, 'plant', self.challenge.seeds))
end

return SunFlower