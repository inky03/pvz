local SeedPacket = Cache.module('pvz.hud.SeedPacket')
local SeedBank = UIContainer:extend('SeedBank')

function SeedBank:init(lawn, x, y, sun)
	self.texture = Cache.image('images/SeedBank')
	self.lawn = lawn
	
	self.visualMoney = (sun or 50)
	self.money = self.visualMoney
	
	UIContainer.init(self, x, y, self.texture:getPixelWidth(), self.texture:getPixelHeight())
	
	self.seedSpacing = 59
	
	self:addSeed(Cache.plants('SunFlower'))
	self:addSeed(Cache.plants('PeaShooter'))
	self:addSeed(Cache.plants('Repeater'))
	self:addSeed(Cache.plants('GatlingPea'))
	self:addSeed(Cache.plants('SnowPea'))
	self:addSeed(Cache.plants('WallNut'))
end

function SeedBank:setMoney(money)
	self.visualMoney = money
	self.money = money
end

function SeedBank:addSeed(entity)
	local seed = self:addElement(SeedPacket:new(self.lawn, entity, 85 + #self.children * self.seedSpacing, 8, self))
	return seed
end

function SeedBank:mousePressed(x, y, button, isTouch, presses)
	if self.lawn.hoveringEntity then
		self.lawn.selectedPacket:onReturned()
		self.lawn.hoveringEntity:destroy()
		self.lawn.selectedPacket = nil
		self.lawn.hoveringEntity = nil
		
		self.canClickChildren = true
	end
end

function SeedBank:update(dt)
	UIContainer.update(self, dt)
	
	if not self.lawn.hoveringEntity then
		self.canClickChildren = true
	end
end

function SeedBank:draw(x, y)
	love.graphics.draw(self.texture, x, y)
	
	love.graphics.setColor(0, 0, 0)
	love.graphics.printf(self.visualMoney, x + 15, y + 65, 48, 'center')
	
	UIContainer.draw(self, x, y)
end

return SeedBank