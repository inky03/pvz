local Sun = Cache.module('pvz.lawn.collectibles.Sun')
local SunFlower = Plant:extend('SunFlower')

SunFlower.reanimName = 'SunFlower'
SunFlower.packetCost = 50

function SunFlower:init(x, y, challenge)
	Plant.init(self, x, y, challenge)
	
	self.glowny = -1
	self.fireRate = 2500
	self.fireTimer = random.int(300, self.fireRate / 2)
	
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
	self.animation:setFrame(4)
	
	self:attachBlink()
end

function SunFlower:update(dt)
	if not self.active then return end
	
	Plant.update(self, dt * self.speedMultiplier)
	
	self.fireTimer = (self.fireTimer - dt * Constants.tickPerSecond * self.speed * self.speedMultiplier)
	
	if self.fireTimer < 0 then
		self.fireTimer = (self.fireTimer + self.fireRate)
		self.glowny = 0
	end
	
	if self.glowny >= 0 then
		local prevGlowny = self.glowny
		self.glowny = (self.glowny + dt * Constants.tickPerSecond * self.speed * self.speedMultiplier)
		
		if self.glowny < 100 then
			self.glow = math.remap(self.glowny, 0, 100, 0, 1)
		elseif self.glowny < 200 then
			if prevGlowny < 100 then self:makeSun() end
			
			self.glow = math.remap(self.glowny, 100, 200, 1, 0)
		else
			self.glowny = -1
		end
	end
end

function SunFlower:makeSun()
	local xx, yy = self:elementToScreen(0, 0)
	self.challenge.collectibles:addElement(Sun:new(xx, yy, 'plant', self.challenge.seeds))
end

return SunFlower