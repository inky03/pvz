local SeedPacket = Cache.module('pvz.hud.SeedPacket')
local SeedBank = UIContainer:extend('SeedBank')

function SeedBank:init(x, y)
	self.texture = Cache.image('images/SeedBank')
	
	UIContainer.init(self, x, y, self.texture:getPixelWidth(), self.texture:getPixelHeight())
	
	self.seedSpacing = 59
	
	self:addSeed(Cache.plants('SunFlower'))
	self:addSeed(Cache.plants('PeaShooter'))
	self:addSeed(Cache.plants('Repeater'))
	self:addSeed(Cache.plants('GatlingPea'))
	self:addSeed(Cache.plants('SnowPea'))
end

function SeedBank:addSeed(entity)
	local seed = self:addElement(SeedPacket:new(entity, 85 + #self.children * self.seedSpacing, 8))
	return seed
end

function SeedBank:mousePressed(x, y, button, isTouch, presses)
	if lawn.hoveringEntity ~= nil then
		lawn.hoveringEntity:destroy()
		lawn.hoveringEntity = nil
		
		self.canClickChildren = true
	end
end

function SeedBank:update(dt)
	UIContainer.update(self, dt)
	
	if lawn.hoveringEntity == nil then
		self.canClickChildren = true
	end
end

function SeedBank:draw(x, y)
	love.graphics.draw(self.texture, x, y)
	
	UIContainer.draw(self, x, y)
end

return SeedBank