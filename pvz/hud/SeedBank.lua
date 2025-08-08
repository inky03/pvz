local SeedPacket = Cache.module('pvz.hud.SeedPacket')
local SeedBank = UIContainer:extend('SeedBank')

function SeedBank:init(lawn, x, y, sun)
	self.texture = Cache.image('SeedBank', 'images')
	self.seeds = {}
	self.lawn = lawn
	
	self:setMoney(sun or 50)
	
	UIContainer.init(self, x, y, self.texture:getPixelWidth(), self.texture:getPixelHeight())
	
	self.seedSpacing = 59
	
	self.moneyText = Font:new('ContinuumBold', 14, 10, 55, 55)
	self.moneyText:setLayerColor('Main', 0, 0, 0)
	self.moneyText:setText(self.visualMoney)
	self.moneyText:setAlignment('center')
	self:addElement(self.moneyText)
	
	self:addSeed(Cache.plants('SunFlower'))
	self:addSeed(Cache.plants('PeaShooter'))
	self:addSeed(Cache.plants('Repeater'))
	-- self:addSeed(Cache.plants('GatlingPea'))
	self:addSeed(Cache.plants('SnowPea'))
	self:addSeed(Cache.plants('WallNut'))
end

function SeedBank:setMoney(money)
	self.visualMoney = money
	self.money = money
end

function SeedBank:addSeed(entity)
	local seed = self:addElement(SeedPacket:new(self.lawn, entity, 85 + #self.seeds * self.seedSpacing, 8, self))
	table.insert(self.seeds, seed)
	return seed
end

function SeedBank:mousePressed(x, y, button, isTouch, presses)
	if self.lawn.hoveringEntity then
		self.lawn.selectedPacket:onReturned()
		self.lawn.hoveringEntity:destroy()
		self.lawn.selectedPacket = nil
		self.lawn.hoveringEntity = nil
		
		self.canClickChildren = true
		
		Sound.play('tap2')
	end
end

function SeedBank:update(dt)
	UIContainer.update(self, dt)
	
	self.moneyText:setText(self.visualMoney)
	
	if not self.lawn.hoveringEntity then
		self.canClickChildren = true
	end
end

function SeedBank:draw(x, y)
	love.graphics.draw(self.texture, x, y)
	
	UIContainer.draw(self, x, y)
end

return SeedBank